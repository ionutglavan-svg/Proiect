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
    #in locatie_col sunt salvate pozitiile pt elementele care trebuie afisate
    locatie_col=${locatie_col%,} #sterge ultima virgula din string: ${var%pattern} - sterge cel mai scurt pattern de la finalul string-ului
    afisare=$(cut -d "," -f${locatie_col} "$csv_file" | tail -n +2) 
    echo "$afisare"
fi
if [ "$1" = "--select-all" ] ; then
        

    IFS=", " read  -r -a cuvinte <<< "${arr_cvs[@]}"

    #echo "${cuvinte[@]}"  #am creeat un array format din cuvintele fisierului
    max=0
    for cuv in "${cuvinte[@]}"
    do
    if [ ${#cuv} -gt $max ]
    then
        max=${#cuv}
    fi
    done
    # echo $max 
    #mai sus am aflat numarul maxim de litere dintre toate cuvintele

    j=0
    while [ $j -lt ${#cuvinte[@]} ]
    do
        # echo "${cuvinte[$j]}"
        
        while [ $max -gt ${#cuvinte[$j]} ]
        do
            cuvinte[$j]+=" "
        done
        cuvinte[$j]+="|"
        ((j++))
    done

    #mai sus am adaugat spatii si pipe uri fiecarui cuvant in functie de numarul maxim de litere
    IFS=", " read  -r -a cuv_0 <<< "${arr_cvs[0]}" #am creeat un array ce contine toate cuvintele primei linii
    x="${#cuv_0[@]}" #am retinut numarul de cuvinte (practic numarul de coloane din csv)

    nr_linii=$(($x*($max+1)))

    linii=""
        i=0
        while [ $i -le $nr_linii ]
        do
        linii+="-"
        ((i++))
        done
    
    #mai sus am creeat string ul cu linii delimitatoare
    cuv_act=()
    j=0
    while [ $j -lt ${#cuvinte[@]} ]
    do
        if [ $x -gt 0 ]
        then
        cuv_act+="${cuvinte[$j]}"
        ((x--))
        else
        echo "$cuv_act"
        cuv_act="${cuvinte[$j]}"
        x=$((${#cuv_0[@]} - 1))
        if [ $j -eq ${#cuv_0[@]} ]
        then
        echo $linii
        fi
        fi
        ((j++))
    done
    #mai sus am luat pe rand fiecare cuvant si l am concatenat astfel inacat sa se obtina numarul total de coloane (repetat)
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

