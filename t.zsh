#!/bin/zsh

zhist=~/.zhistory

echo "----- sanity check ---"
#IFS=' ' read -r -a test<<< "a b cd ef ghi"
some="a b cd ef ghi"
test=("${(@s/ /)some}")
for i in "${test[@]}"; do
   echo "$i";
done;

echo "-----"
echo "unedited output of zhist"
echo $(tail $zhist)
echo "~~~"
echo $(tail -n 5 $zhist | sed "s/: [0-9]*:[0-9];/||/g")
echo "-----"


echo "--- cmd to split unfiltered ---"
#result=$(tail -n 5 $zhist | cut -c 16-)
#result=$(tail -n 5 $zhist | sed "s/: [0-9]*:[0-9];//g" | tr ~ '\n')
result=$(tail -n 5 $zhist | sed "s/: [0-9]*:[0-9];/;/g")
result=$(echo $result | cut -c 2-)
echo $result

echo "--- Splitting result into array ---"
#IFS=';' read -a array <<< "$result" unset IFS
#array=("${(@s/;/)result}")
array=("${(f)result}")
#array=$(tr ' ' '\n' <<< "${array[@]}" | sort -u | tr '\n' ' ')

echo ${array[@]}
echo " --- "
echo "length is ${#array[@]}"

for element in "${array[@]}"
do
    echo "$element"
done

# for i in ${array[@]} do echo "$i" done
