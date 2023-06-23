#!/bin/bash
set -x
#USAGE: put all the csv files in the same folder as group.sh. Then execute ./group.sh

# Set the block size to 32KB (32768 bytes)
block_size=32768

ONE=",1"
#reset temporarry files
>temp1.csv

#reset input file
>input.csv
rm input0.csv

#reset output file
>output.csv

#remove funny msdos formatting from all csv files
ls *.csv | ./para --jobs 6 sed -i -e 's/\r$//' {} &
wait

#move the content of all csv files in this directory to input.csv
cat *.csv > input0.csv &
wait


#remove all double quotation marks
ls input0.csv | ./para --jobs 6 sed 's/\"//g'  > input.csv
wait


#extract the third column containing the timestamp to temp1.csv
#while IFS=, read -r f1 f2 f3 f4 f5 f6 f7 f8 ; do
#take the first 8 characters of the date field
#locDate=`echo $f3 | head -c 8`
#echo $locDate$ONE >>temp1.csv
#echo $locDate  | ./para --jobs 6 echo {}  >> temp1.csv
#done < input.csv
awk_script_one='BEGIN{FS=","} {print substr($3,1,8)}'
awk 'BEGIN{FS=","} {print substr($3,1,8) ",1" }' < input.csv | ./para  --jobs 10 echo {} >  temp1.csv
wait

awk_script='BEGIN{FS=","} {a[$1]+=$2;}END{for(i in a)print i", "a[i];}'
#Group-by and Sum
#./para --jobs 6 awk 'BEGIN{FS=","} {a[$1]+=$2;}END{for(i in a)print i", "a[i];}' temp1.csv > output.csv
awk "$awk_script"  < temp1.csv | ./para --jobs 20  echo {} >  output.csv
wait
