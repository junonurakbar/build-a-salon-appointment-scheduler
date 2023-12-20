#! /bin/bash
# PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"   # certification ex
# PSQL="psql -X --username=freecodecamp --dbname=bikes --tuples-only -c"  # code from tutorial
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  # check to see if there's an argument passed to a function MAIN_MENU
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?"
  # get service names
  SERVICE_NAMES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  # make a while loop, to print the service names
  echo "$SERVICE_NAMES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  #read input
  read SERVICE_ID_SELECTED
  # make a case selection
  case $SERVICE_ID_SELECTED in
    1) CUSTOMER_DATA ;;
    2) CUSTOMER_DATA ;;
    3) CUSTOMER_DATA ;;
    4) CUSTOMER_DATA ;;
    5) CUSTOMER_DATA ;;
    *) MAIN_MENU "I could not find that service. What would you like today?"
  esac
}

CUSTOMER_DATA() {
  # ask customer to get a phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  # get a customer's name based on his/her phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # check to see if the customer's phone number is recorded on customers psql table 
  if [[ -z $CUSTOMER_NAME ]]
  then
    # if customer's data is not recorded, ask for their names
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # insert customer's data
    INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

    # make an appointment
    APPOINTMENT
    
  else
    # if customer's data is already recorded, make an appointment
    APPOINTMENT
  fi
}

# make an appointment
APPOINTMENT() {
  # get customer id based on their phone number
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # remove white spaces for display purposes to remove white spaces at the beginning
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')

  # ask for time appointment
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  if [[ $SERVICE_TIME =~ (^[0-9]+:[0-9]+$ || ^[0-9]+ || [0-9]+$ || am$ || pm$) ]]
  then
    # insert a row into the psql table appointments
    INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # for display purpose i eliminate spaces for the service name, service time, and the customer name
    SERVICE_TIME_FORMATTED=$(echo $SERVICE_TIME | sed -E 's/^ *| *$//g')
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED."
  fi
}

MAIN_MENU