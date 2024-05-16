#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
DELETE=$($PSQL "TRUNCATE teams, games;")
# echo $TEST

cat games.csv | while IFS="," read YEAR ROUND WINNER LOSER WINNER_GOALS LOSER_GOALS
do
  if [[ $YEAR != year ]]
  then
    # get winner ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    # if not found
    while [[ -z $WINNER_ID ]]
    do
      # insert into teams
      WINNER_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $WINNER_INSERT == "INSERT 0 1" ]]
      then
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
      fi
    done
    
    # get loser ID
    LOSER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$LOSER';")
    # if not found
    while [[ -z $LOSER_ID ]]
    do
      # insert into teams
      LOSER_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$LOSER');")
      if [[ $LOSER_INSERT == "INSERT 0 1" ]]
      then
        LOSER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$LOSER';")
      fi
    done

    # insert row into games table
    GAME_INSERT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $LOSER_ID, $WINNER_GOALS, $LOSER_GOALS);")
    while [[ $GAME_INSERT != "INSERT 0 1" ]]
    do
      GAME_INSERT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $LOSER_ID, $WINNER_GOALS, $LOSER_GOALS);")
    done
  fi
done