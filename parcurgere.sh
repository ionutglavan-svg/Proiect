#!/bin/bash

csv_file="$1"
shift
arr_cvs=() #declarare array

pretty_print() {
    array=("$@")  #pasam un array ca argument
    i=0
    for field in "${array[@]}" #adaugam o virgula la finalul elementelor de pe array
    do
        array[i]+=","
        ((i++))
    done
    IFS="," read -r -a cuvinte <<< "${array[@]}" #cuvinte este un array cu toate field-urile din fisier ca elemente distincte
    max=0
    # echo ${cuvinte[@]}
    for cuv in "${cuvinte[@]}"
    do
    if [ ${#cuv} -gt $max ]
    then
        max=${#cuv}
    fi
    done
    #mai sus am aflat numarul maxim de litere dintre toate cuvintele
    j=0
    while [ $j -lt ${#cuvinte[@]} ]
    do
        while [ $max -gt ${#cuvinte[$j]} ]
        do
            cuvinte[$j]+=" "
        done
        cuvinte[$j]+="|"
        ((j++))
    done
    #mai sus am adaugat spatii si pipe uri fiecarui cuvant in functie de numarul maxim de litere
    IFS="," read  -r -a cuv_0 <<< "${array[0]}" #am creeat un array ce contine toate cuvintele primei linii
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
    linie_act=()
    j=0
    while [ $j -le ${#cuvinte[@]} ]
    do
        if [ $x -gt 0 ]
        then
            linie_act+="${cuvinte[$j]}"
            ((x--))
        else
            echo "$linie_act"
            linie_act="${cuvinte[$j]}"
            x=$((${#cuv_0[@]} - 1))
            if [ $j -eq ${#cuv_0[@]} ]
            then
                echo $linii
            fi
        fi
        ((j++))
    done
    return
}

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
    afisare=$(cut -d "," -f${locatie_col} "$csv_file" | tail -n +1) 
    
   while IFS= read -r line
   do
   array_afisare+=("$line")
   done < <(echo "$afisare")

    pretty_print "${array_afisare[@]}"

fi
if [ "$1" = "--select-all" ] ; then
        pretty_print "${arr_cvs[@]}"
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

if [ "$1" = "--where" ] ; then
    shift
    IFS="=" read -ra cuvinte_cautare <<< "$1"
    # echo "${cuvinte_cautare[@]}"
    linii_cautate="${arr_cvs[0]}"
    #echo "${linii_cautate[@]}"
    c0="${cuvinte_cautare[0]}"
    c1="${cuvinte_cautare[1]}"

    IFS="," read  -r -a cuv_0 <<< "${arr_cvs[0]}"
    i=0 
    while [ $i -lt "${#cuv_0[@]}" ] ; do
        if [ "$c0" = "${cuv_0[$i]}" ]
            then
                numar_col=$i
               
            fi
        ((i++))
    done
    #  echo "$numar_col"
    for linie in "${arr_cvs[@]}"
    do
        IFS="," read -ra caut_in_linie <<< "$linie"
       
            if [ "$c1" = "${caut_in_linie[$numar_col]}" ]
            then
                linii_cautate+=("$linie")
            fi
       
    done
    if [ "${#linii_cautate[@]}" -gt 1 ] ; then
    pretty_print "${linii_cautate[@]}"
    else
    echo "Reintroduceti!"
    fi
fi