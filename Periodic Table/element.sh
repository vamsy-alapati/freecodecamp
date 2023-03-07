#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --tuples-only -c"

#check if there is any argument
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

#if the argument is a number
if [[ $1 =~ ^[1-9]+$ ]]
then
  ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e, types t, properties p WHERE e.atomic_number = p.atomic_number AND p.type_id = t.type_id AND e.atomic_number = '$1'")
else
  ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e, types t, properties p WHERE e.atomic_number = p.atomic_number AND p.type_id = t.type_id AND (e.symbol = '$1' OR e.name = '$1')")
fi

if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database."
else
  echo $ELEMENT | while IFS=' | ' read ATOMIC_NUMBER SYMBOL NAME TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
  do
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
fi

