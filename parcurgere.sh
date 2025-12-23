#!/bin/bash

csv_file="$1"
shift
arr_cvs=() #declarare array

while IFS="," read line
do
    arr_cvs+=("$line") #se salveaza fiecare linie din fisier ca un element al array-ului
done < "$csv_file"
if [ "$1" = "--select" ] ; then
    shift
    locatie_col=""
    coloane_selectate=$(echo "$1" | tr ',' ' ')
    for word in $coloane_selectate
    do
        locatie_col_act=$(head -1 "$csv_file" | tr ',' '\n' | nl | grep -w "$word" | tr -d " " | awk -F " " '{print $1}' )
        #linia de mai sus obtine pozitia variabilei word de pe prima linie a fisierului
        locatie_col+="$locatie_col_act "
        locatie_col=$(echo "$locatie_col" | tr ' ' ',')
    done
    locatie_col=${locatie_col%,} #sterge ultima virgula din string: ${var%pattern} - sterge cel mai scurt pattern de la finalul string-ului
    afisare=$(cut -d "," -f${locatie_col} "$csv_file" | tail -n +2)
    echo "$afisare"
fi
if [ "$1" = "--select-all" ] ; then
    for continut in "${arr_cvs[@]}" #folosim caracterul @ pt a ne referii la tot array-ul
    do
        echo "$continut"
    done
fi
if [ "$1" = "--validate" ] ; then
    header="${arr_cvs[0]}"
    header=$(echo "$header" | tr ',' ' ')
    index=0
    for word in $header
    do
        echo "$index : $word"
        ((index++))
    done
fi

