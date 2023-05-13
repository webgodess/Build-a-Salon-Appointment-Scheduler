#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only  -c"

#$($PSQL "truncate customers,appointments restart identity")
echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"


SERVICE_ID=$($PSQL "SELECT service_id FROM services")
SERVICE=$($PSQL "SELECT name FROM services")



SHOW_SERVICES() {
echo "$(paste -d ')' <(echo "$SERVICE_ID") <(echo "$SERVICE"))"
read SERVICE_ID_SELECTED

# Count the number of services and assign them to a variable

SERVICE_NUM=$(echo "$SERVICE" | wc -l)

#echo $SERVICE_NUM


if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
echo -e "\nI could not find that service. What would you like today?\n"
 SHOW_SERVICES 

# If you pick a service that doesn't exist
 elif [[ ! $SERVICE_ID_SELECTED -le $SERVICE_NUM ]]
then 
echo -e "\nI could not find that service. What would you like today?\n"
SHOW_SERVICES 

else
#send the result of the #service_id_selected to the book_service function
BOOK_SERVICE $SERVICE_ID_SELECTED
fi

}

BOOK_SERVICE(){
#echo $SERVICE_ID_SELECTED
  SERVICE_SELECTED=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

echo -e "\nWhat's your phone number?\n"
read CUSTOMER_PHONE

#check if they are a customer
CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")


if [[ -z $CUSTOMER_ID ]]
then
echo -e "\nI don't have a record for that phone number, what's your name?
\n"

read CUSTOMER_NAME

echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME\n?"

read SERVICE_TIME

$PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')"
CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
#echo $CUSTOMER_ID
$PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')"

echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME.
\n"

else

CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME?\n"
read SERVICE_TIME

$PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')"

echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME.
\n"

fi

}

SHOW_SERVICES






