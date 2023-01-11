#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n" 

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "What can we do for you?\n"
  SERVICES=$($PSQL "SELECT * FROM services order by SERVICE_ID") 
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
   echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

  if [[ -z $SERVICE ]]
  then
    MAIN_MENU "I could not find that service.\n"
  else
    SERVICE $SERVICE_ID_SELECTED
  fi
}

: '
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "What can we do for you?"
  echo -e "\n1) Haircut\n2) Colouring\n3) Permanent\n" 
  read MAIN_MENU_SELECTION
  case $MAIN_MENU_SELECTION in
    1) SERVICE "1" ;;
    2) SERVICE "2" ;;
    3) SERVICE "3" ;;
    *) MAIN_MENU "I could not find that service.\n" ;;
  esac
}
'

SERVICE() {
  if [[ $1 == "1" ]]
  then
    SERVICE="Haircut"
  fi
  if [[ $1 == "2" ]]
  then
    SERVICE="Colouring"
  fi
  if [[ $1 == "3" ]]
  then
    SERVICE="Permanent"
  fi
# get customer info
  echo -e "\nWhat's your phone number?" 
  read CUSTOMER_PHONE
  echo Phone registered: $CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
    # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME 
    # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # ask for appointment time
      echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?" 
      read SERVICE_TIME
    # get service availability
      SERVICE_AVAILABILITY=$($PSQL "SELECT customer_id FROM appointments WHERE time = '$SERVICE_TIME'") 
    # if not available
      :#if [[ ! -z $SERVICE_AVAILABILITY ]]
      #then
      #echo -e "\nWe don't have availability at that time, please choose a different hour" 
      #  SERVICE $1
      #else
        INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$1', '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $(echo $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
      #fi
}

MAIN_MENU