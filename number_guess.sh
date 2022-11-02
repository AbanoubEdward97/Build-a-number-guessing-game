#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# create the random number
NUMBER_TO_GUESS=$(( $RANDOM%1000 ))
# FUNCTIONS
echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"
echo "Enter your username:"
read USER_INPUT
# check for the username validity 
  USERNAME_FROM_DATABASE=$($PSQL "select username from users where username='$USER_INPUT'")
  if [[ -z $USERNAME_FROM_DATABASE ]]
  then
    # not found , therefore add it to the database 
    INSERT_USERNAME_RESULT=$($PSQL "insert into users(username) values('$USER_INPUT')")
    USERNAME_FROM_DATABASE=$USER_INPUT
    echo "Welcome, $USERNAME_FROM_DATABASE! It looks like this is your first time here."
  else # found that username
    GAMES_PLAYED=$($PSQL "select games_played from users where username='$USERNAME_FROM_DATABASE'")
    BEST_GAME=$($PSQL "select best_game from  users where username='$USERNAME_FROM_DATABASE'")
    echo "Welcome back, $USERNAME_FROM_DATABASE! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
 echo -e "\nGuess the secret number between 1 and 1000:"
  I=0
      while [[ ! $GUESSED_NUMBER -eq $NUMBER_TO_GUESS ]]
      do
        # read numer input from the user
        read GUESSED_NUMBER
        # check for the number validity 
        # if it is valid , check for the value
        if [[ $GUESSED_NUMBER =~ ^[0-9][0-9]*$ ]]
        then
          (( I++ ))
          # if it is higher than the number , echo a message
          if [[ $GUESSED_NUMBER -gt $NUMBER_TO_GUESS ]]
          then # the number is higher than predicted
            echo "It's lower than that, guess again:"
          elif [[ $GUESSED_NUMBER -lt $NUMBER_TO_GUESS ]]  # the number is higher than predicted
          then
            echo "It's higher than that, guess again:"
          fi
        else    
          # else , print a message to enter a valid number
          echo "That is not an integer, guess again:" 
        fi
      done
  # The guess is correct 
  echo "You guessed it in $I tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
  GET_GAMES_PLAYED=$($PSQL "select games_played from users where username='$USERNAME_FROM_DATABASE'")
  GAMES_PLAYED=$(( $GET_GAMES_PLAYED+1 )) 
  UPDATE_GAMES_PLAYED_RESULT=$($PSQL "update users set games_played=$GAMES_PLAYED where username='$USERNAME_FROM_DATABASE'")
  # get best game from the database
  GET_BEST_GAME=$($PSQL "select best_game from users where username='$USERNAME_FROM_DATABASE'")
  if [[ $GET_BEST_GAME -eq 0 || $I -lt $GET_BEST_GAME ]] # check if number of tries is less than the recorded value or its zero 
  then
    GET_BEST_GAME=$I
    UPDATE_BEST_GAME_RESULT=$($PSQL "update users set best_game=$GET_BEST_GAME where username='$USERNAME_FROM_DATABASE'")
  fi
