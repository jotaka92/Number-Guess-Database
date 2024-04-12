#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

GAMES_PLAYED=1

USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING (user_id) WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM users INNER JOIN games USING (user_id) WHERE username = '$USERNAME'")

if [[ -z $USERNAME_RESULT ]]

then
  # If username does not exist, insert a new user record
  $PSQL "INSERT INTO users(username, games_played) VALUES ('$USERNAME', $GAMES_PLAYED)"
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Display welcome back message with user's stats
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start the number guessing game
NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

# Game loop
until [[ $USER_GUESS == $NUMBER ]] 
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]] 
  then
      echo "That is not an integer, guess again:"
      read USER_GUESS
      ((GUESS_COUNT++))
  else
    if [[ $USER_GUESS -gt $NUMBER ]] 
    then
      echo "It's lower than that, guess again:"
      read USER_GUESS
      ((GUESS_COUNT++))
    else
      echo "It's higher than that, guess again:"
      read USER_GUESS
      ((GUESS_COUNT++))
    fi
  fi
done

((GUESS_COUNT++))

# Game over, user guessed the correct number
echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
INSERT_GAME=$($PSQL "INSERT INTO games (number_guesses, user_id) VALUES ($GUESS_COUNT, $USER_ID)")
