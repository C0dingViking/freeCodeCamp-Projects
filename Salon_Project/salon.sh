#!/bin/bash

PSQL="psql -U freecodecamp -d salon -Atqc"

SERVICE_MENU() {
  echo -e $1

  while IFS='|' read -r ID SERVICE
  do
    echo "$ID) $SERVICE"
  done < <($PSQL "select * from services;")
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE ]]
  then
    SERVICE_MENU "\nI could not find that service. What would you like today?"
  fi
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
SERVICE_MENU "Welcome to My Salon, how can I help you?"

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME') returning customer_id;")
fi

CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE' and name = '$CUSTOMER_NAME';")

echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
read SERVICE_TIME

INSERT_SERVICE_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."