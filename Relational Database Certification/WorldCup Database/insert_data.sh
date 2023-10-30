#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  if [[ $year != 'year' ]]
  then
    #Inserting into TEAMS table
    #echo "Year: $year --- Round: $round --- Winner: $winner --- opponent: $opponent --- winner_goals: $winner_goals --- opponent_goals: $opponent_goals"
    WINNER_EXIST_RESULT=$($PSQL "SELECT count(*) FROM teams WHERE name='$winner'")
    if [[ $WINNER_EXIST_RESULT -eq 0 ]]
    then
      #echo Inserting team $winner
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams (name) VALUES ('$winner')")
    fi
    OPPONENT_EXIST_RESULT=$($PSQL "SELECT count(*) FROM teams WHERE name='$opponent'")
    if [[ $OPPONENT_EXIST_RESULT -eq 0 ]]
    then
      #echo Inserting team $opponent
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams (name) VALUES ('$opponent')")
    fi

    #FETCH WINNER_ID and OPPONENT_ID from TEAMS table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name=('$winner')")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name=('$opponent')")
    echo WINNER_ID: $WINNER_ID ------ OPPONENT_ID: $OPPONENT_ID

    #INSERTING INTO GAMES Table
    GAMES_INSERT_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year,'$round',$WINNER_ID,$OPPONENT_ID,$winner_goals,$opponent_goals)")
    echo GAME INSERT RESULT: $GAMES_INSERT_RESULT

  fi
done