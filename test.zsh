#!/bin/bash

zhist=~/.zhistory

echo "----- sanity check ---"
IFS=' ' read -r -a test<<< "a b cd ef ghi"
for i in "${test[@]}"; do
   echo "$i";
done;

echo "-----"
echo "unedited output of zhist"
echo $(tail $zhist)
echo "-----"

echo "--- cmd to split unfiltered ---"
#result=$(tail -n 5 $zhist | cut -c 16-)
#result=$(tail -n 5 $zhist | sed "s/: [0-9]*:[0-9];//g" | tr ~ '\n')
result=$(tail -n 5 $zhist | sed "s/: [0-9]*:[0-9];/\n/g")
result=$(echo $result | cut -c 2-)
echo $result

echo "--- Splitting result into array ---"
IFS='\n' read -a array <<< "$result" unset IFS
#array=$(tr ' ' '\n' <<< "${array[@]}" | sort -u | tr '\n' ' ')
array=$($array | uniq)

echo ${array[@]}
echo " --- "
echo "length is ${#array[@]}"

for element in "${array[@]}"
do
    echo "$element"
done

# for i in ${array[@]} do echo "$i" done
