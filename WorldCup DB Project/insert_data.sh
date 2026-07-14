#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -q -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -q -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
truncate_result=$($PSQL "truncate games, teams restart identity;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ "$YEAR" -ne "year" ]]
  then
    WINNER_ID=$($PSQL "insert into teams (name) values ('$WINNER') on conflict (name) do update set name = '$WINNER' returning team_id;")
    OPPONENT_ID=$($PSQL "insert into teams (name) values ('$OPPONENT') on conflict (name) do update set name = '$OPPONENT' returning team_id;")
    # echo Winner: $WINNER_ID. Opponent: $OPPONENT_ID
    INSERT_RESULT=$($PSQL "insert into games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
  fi
done