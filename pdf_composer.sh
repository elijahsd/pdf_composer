#!/bin/bash

function a4toa5() { 

INPUT=$1

NAME_INPUT=${INPUT%%.*}
TEMP_OUTPUT=${NAME_INPUT}-temp.pdf
TEMP_OUTPUT_LEFT=${NAME_INPUT}-temp-left.pdf
TEMP_OUTPUT_RIGHT=${NAME_INPUT}-temp-right.pdf
OUTPUT=${NAME_INPUT}-a5.pdf

WIDTH=$(pdfinfo $INPUT | grep "Page size" | awk '{print int($3)}')
HEIGHT=$(pdfinfo $INPUT | grep "Page size" | awk '{print int($5)}')
pdfjam $INPUT --papersize "{${HEIGHT}pt,${WIDTH}pt}" --angle 270 --outfile $TEMP_OUTPUT 2>/dev/null >/dev/null
INPUT=$TEMP_OUTPUT

WIDTH=$(pdfinfo $INPUT | grep "Page size" | awk '{print int($3)}')
HEIGHT=$(pdfinfo $INPUT | grep "Page size" | awk '{print int($5)}')

A5WIDTH=$(($WIDTH / 2))
A5HEIGHT=$((HEIGHT))

pdfjam --viewport "$A5WIDTH 0 $WIDTH $HEIGHT" --papersize "{${A5WIDTH}pt, ${A5HEIGHT}pt}"  $INPUT  --outfile $TEMP_OUTPUT_RIGHT 2>/dev/null >/dev/null
rm $TEMP_OUTPUT

}

function a5toa4() {

pdfnup $2 $1 2>/dev/null >/dev/null
rm $1 $2

}

function rotate() {

pdftk $1 cat 1-endW output $1-rotate.pdf 2>/dev/null >/dev/null
rm $1

}

ls *.pdf | sort -n | while read l;
do
    a4toa5 $l
done

last=""
ls *right.pdf | sort -n | while read l;
do
    if [ -z "$last" ]; then
        last=$l
    else
        a5toa4 $last $l
        last=""
    fi
done

ls *nup.pdf | sort -n | while read l;
do
    rotate $l
done

pdfjoin `ls *rotate.pdf | sort -n` 2>/dev/null >/dev/null
rm *rotate.pdf

if [ -n "`ls *right.pdf`" ]; then
    name=`ls *right.pdf | sed 's/-.*$//'`
    pdfjam --fitpaper true --suffix output -- `ls *joined.pdf` $name.pdf 2>/dev/null >/dev/null
    rm *right.pdf
    rm *joined.pdf
    mv `ls *output.pdf` joined.pdf
fi

mv `ls *joined.pdf` output.pdf
