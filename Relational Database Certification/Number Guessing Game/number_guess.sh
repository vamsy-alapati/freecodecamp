#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
echo RANDOM_NUMBER: $RANDOM_NUMBER

echo "Enter your username:"
read USER_NAME

#checking if the user name is given and it is less than or equal to 22 characters
if [[ ! -z $USER_NAME && ${#USER_NAME} -le 22 ]]
then
  USER=$($PSQL "SELECT * FROM users WHERE username = '$USER_NAME';")
fi

#check the user is present in database and greet them with their details if available and create an entry if not
if [[ -z $USER ]]
then
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users (username, games_played) VALUES ('$USER_NAME',0);")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  echo $USER | while IFS='|' read USER_NAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"

GUESS_COUNT=0
ANSWERED=0

#loop the input to keep reading the user guess until they guess it right
#exit the loop once the user guesses the number correct
while [[ $ANSWERED -ne 1 ]]
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  
  if [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    (( GUESS_COUNT++ ))
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    (( GUESS_COUNT++ ))
  elif [[ $GUESS -eq $RANDOM_NUMBER ]]
  then
    (( GUESS_COUNT++ ))
    ANSWERED=1
  fi

done

#fetch the games_played and the best game
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USER_NAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USER_NAME'")

#check if the current count of the guesses is less than best game value and update the best count and the games played for the user
if [[ $GUESS_COUNT -lt $BEST_GAME || -z $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET games_played=games_played+1, best_game=$GUESS_COUNT WHERE username='$USER_NAME';")
else
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USER_NAME';")
fi

echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"