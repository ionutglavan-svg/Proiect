#!/bin/bash

csv_file="$1"

arr_cvs=()

while IFS="," read line
do
    arr_cvs+=("$line")
    #echo "${arr_cvs[@]}"
done < "$csv_file"

index=0
echo "space"

for continut in "${arr_cvs[@]}"
do
    echo "Continutul pe linia $index : $continut "
    ((index++))
done

col="$2"
locatie_col=$(head -1 "$csv_file" | tr ',' '\n' | nl | grep -w "$col" | tr -d " " | awk -F " " '{print $1}' )

#echo "$locatie_col"

proba=$(cut -d "," -f${locatie_col} "$csv_file" | tail -n +2)
echo "$proba"
