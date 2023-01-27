#!/bin/bash

function random_number() {

  printf "%0$1g" $(( $RANDOM % $2 +1))
}

if [ -z "$2" ]; then 
    echo "Usage:  foo.sh (# of files to generate) [transaction date YYYYMMDD] [output folder]"
    exit    
fi

NUMBER_OF_TEST_TO_CREATE=$1

### get date/time 

if [ $2 == "random" ]; then

  ### put code here to random date
  NEW_TRANSACTION_DATE="2020"$(random_number 2 12)$(random_number 2 31)
  #NEW_TRANSACTION_DATE=$(random_number 4 2019)$(random_number 2 12)$(random_number 2 31)
  NEW_DD2_DATE="DD2^"${NEW_TRANSACTION_DATE:4:2}"^"${NEW_TRANSACTION_DATE:6:2}"^"${NEW_TRANSACTION_DATE:2:2}

else

  NEW_TRANSACTION_DATE=$2
  NEW_DD2_DATE="DD2^"${NEW_TRANSACTION_DATE:4:2}"^"${NEW_TRANSACTION_DATE:6:2}"^"${NEW_TRANSACTION_DATE:2:2}

fi

if [ -z "$3" ]; then

  OUTPUT_FOLDER="./"

else

  OUTPUT_FOLDER=$3

fi

if [ -z "$4" ]; then
  TEMPLATE_FOLDER="./"

else

  TEMPLATE_FOLDER=$4

fi

filename=$4"template_demo.txt"
TRANSACTION_NUMBER="$(awk -F"^" 'NR==1 {print $9}' "$filename")"
TRANSACTION_DATE="$(awk -F"^" 'NR==1 {print $10}' "$filename")"
TRANSACTION_TIME="$(awk -F"^" 'NR==1 {print $11}' "$filename")"

DD2_DATE="$(awk -F"^" 'NR==3 {print $1"^"$2"^"$3"^"$4}' "$filename")"

### loop to create number of files

for i in $(seq -f "%04g" 1 ${NUMBER_OF_TEST_TO_CREATE})
do

# NEW_TRANSACTION_NUMBER=${TRANSACTION_NUMBER:0:7}$i
  NEW_TRANSACTION_NUMBER=$(random_number 7 10000000)$i
  RAND_TIME=$(random_number 2 24)$(random_number 2 60)$(random_number 2 60)

  sed "s/$TRANSACTION_NUMBER/$NEW_TRANSACTION_NUMBER/g; \
       s/$TRANSACTION_DATE/$NEW_TRANSACTION_DATE/g; \
       s/$DD2_DATE/$NEW_DD2_DATE/g; \
       s/$TRANSACTION_TIME/$RAND_TIME/g;" \
      $filename > \
      $OUTPUT_FOLDER"DEMO-"$NEW_TRANSACTION_NUMBER

done
