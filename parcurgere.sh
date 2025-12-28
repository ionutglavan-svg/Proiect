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
    #echo "${array[@]}"
    IFS=$',' read -r -a cuvinte <<< "${array[@]}" #cuvinte este un array cu toate field-urile din fisier ca elemente distincte
    max=0
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
    #echo "$line"
    arr_cvs+=("$line") #se salveaza fiecare linie din fisier ca un element al array-ului
done < "$csv_file"
# echo ""
if [ "$1" = "--select" ] ; then
    shift
    locatie_col=""
    coloane_selectate=$(echo "$1" | tr ',' ' ')
    for word in $coloane_selectate
    do
        locatie_col_act=$(head -1 "$csv_file" | tr ',' '\n' | nl | grep -w "$word" | tr -d " " | awk -F " " '{print $1}' )
        #linia de mai sus obtine pozitia variabilei word de pe prima linie a fisierului
         if [ -z "$locatie_col_act" ] ; then
            echo "Coloana $word nu a fost gasita"
            exit 1
        fi
        locatie_col+="$locatie_col_act "
        locatie_col=$(echo "$locatie_col" | tr ' ' ',') 
    done
    #in locatie_col sunt salvate pozitiile pt elementele care trebuie afisate
    locatie_col=${locatie_col%,} #sterge ultima virgula din string: ${var%pattern} - sterge cel mai scurt pattern de la finalul string-ului
    afisare=$(cut -d "," -f${locatie_col} "$csv_file" | tail -n +1)
    #echo "$afisare"
    while IFS= read -r line
    do
        array_afisare+=("$line") #se salveaza fiecare linie din fisier ca un element al array-ului
    done < <(echo "$afisare")
    # echo "${array_afisare[@]}"
    pretty_print "${array_afisare[@]}"
fi
if [ "$1" = "--select-all" ] ; then
        # echo "${arr_cvs[@]}"
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
    c0="${cuvinte_cautare[0]}" #elementul din antet cautat
    c1="${cuvinte_cautare[1]}" #proprietatea pe care trebuie sa o indeplineasca

    IFS="," read  -r -a cuv_0 <<< "${arr_cvs[0]}"
    i=0 
    while [ $i -lt "${#cuv_0[@]}" ] ; do #se cauta coloana pe care se afla c0
        if [ "$c0" = "${cuv_0[$i]}" ]
            then
                numar_col=$i
               
            fi
        ((i++))
    done
    #  echo "$numar_col"
    for linie in "${arr_cvs[@]}"
    do
        IFS="," read -ra caut_in_linie <<< "$linie" #caut_in_linie = array format din elementele unei linii
       
            if [ "$c1" = "${caut_in_linie[$numar_col]}" ] #daca c1 apare in linie actuala se aduga toata linia la afisare
            then
                linii_cautate+=("$linie") #linii_cautate = liniile care vor fi afisate
            fi
       
    done
    if [ "${#linii_cautate[@]}" -gt 1 ] ; then
        pretty_print "${linii_cautate[@]}"
    else
        echo "Reintroduceti!"
    fi
fi
if [ "$1" = "--sort-by" ] ; then
    shift
    criteriu_sortare="$1"
    extra=""
    if [ "$2" = "asc" ] ; then
        : #do nothing
    else
        if [ "$2" = "desc" ] ; then
            extra+="r" 
        else
            echo "Argument invalid"
            exit 1
        fi
    fi
    #echo "$extra"
    loc_criteriu=$(head -1 "$csv_file" | tr ',' '\n' | nl | grep -w "$criteriu_sortare" | tr -d " " | awk -F " " '{print $1}' )
    #coloana pe care se afla criteriul de sortare
    echo "$loc_criteriu"
    if [ -z "$loc_criteriu" ] ; then
        echo "Coloana nu a fost gasita"
        exit 1
    fi
    
    prima_linie="${arr_cvs[1]}"
    prima_linie=$(echo "$prima_linie" | tr ',' ' ')
    
    for field in $prima_linie
    do
        arr_prima_linie+=("$field")
    done 
    array_afisare+=("${arr_cvs[0]}")
    sed '1d' "$csv_file" > aux.csv #creaza fisierul aux.csv in care avem doar datele din csv fara header
    poz_crit_array=$(($loc_criteriu-1)) #array-ul incepe numaratoarea de la 0 dar pozitile coloanelor sunt numerotate de la 1
    
    if [[ "${arr_prima_linie[$poz_crit_array]}" =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]; then #verifica daca criteriul este unul numeric sau nu
        # =~ testeaza daca string-ul din stanga indeplineste un anumit pattern
        # ^ spune programului sa verifice pattern-ul la inceputul string-ului (ancora de inceput)
        # $ spune programului sa verifice pattern-ul la finalul string-ului (ancora de sfarsit)
        # in combinatie ^123$ inseamna ca string-ul din stanga trebuie sa fie exact 123
        # ? carecterul precedent este optional
        # * inseamna zero sau mai multe din caracterul precedent. In acest caz avem [0-9]* cea ce inseamna orice
    #numar de cifre prezent, zero inclus
        #\. caracterul "." urmat de "?" deoarece este optional
        # + verifica daca caracterul precedent apare cel putin o data

        #echo "It is a valid number (includes decimals)"
        extra+="g"
    fi

    sorted=$(sort --key="$loc_criteriu" -${extra}t, aux.csv ) #sorteaza fisierul aux.csv in functie de cheia selectata, -g este folosit in cazul in care sortam o categorie numerica
    while IFS= read -r line
    do
        array_afisare+=("$line") #se salveaza fiecare linie din fisier ca un element al array-ului
    done < <(echo "$sorted")
    pretty_print "${array_afisare[@]}"
fi