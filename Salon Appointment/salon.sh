#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

MAIN(){
  
  read SERVICE_ID_SELECTED

  SERVICE_DETAILS=$($PSQL "SELECT service_id, name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
  read -r SERVICE_ID BAR SERVICE_NAME <<< "$SERVICE_DETAILS"
  
  if [[ -z $SERVICE_ID ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    SHOW_SERVICES;
    MAIN;
  else
    echo -e "\nWhat's your phone number?"

    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #read -r CUSTOMER_ID BAR CUSTOMER_NAME <<< "$CUSTOMER_DETAIL"

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      #insert into customers
      INSERT_CUST_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      if [[ $INSERT_CUST_RESULT != 'INSERT 0 1' ]]
      then
        echo -e "\nOops! There is a problem with the system. We are currently unable to schedule your appointment. Please visit again!"
      fi
    fi

    #ask for time
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME

    #fetch customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #insert into appointments
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $INSERT_APPOINTMENT == 'INSERT 0 1' ]]
    then
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      echo -e "\Error creating an Appointment."
    fi
  fi
  
}

SHOW_SERVICES(){

  if [[ ! -z $SERVICES ]]
  then    
    echo "$SERVICES" | while read ser_id bar ser_name
    do
      echo -e "$ser_id) $ser_name"
    done
  fi
}

SHOW_SERVICES
MAIN