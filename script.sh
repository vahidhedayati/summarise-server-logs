#!/bin/bash
# Vahid Hedayati Feb 2013 - nice little script to summarise server logs into one over all report
# This is the list of the attached summary files, in your own script you would need to run 
# through your server/instance list and for each server output its content to file 

# use the list of summary files as per below - 
files="summary1 summary2 summary3"

# Random number to be used whilst processing files
RAND="$$"

#Last file name
oldname="";
#Counter
i=0

# go through the list of files
for names in $(echo $files); do
        #increment counter
        ((i++));
        # Store very first file as last file name and move on
        if [ $i == 1 ]; then
                oldname=$names
                shift;
        else
            # in all other cases create a random file of last file name
            oldname1=$names.$RAND

            # Now compare last file name - new or current file and get any values missing from new file and add it as a 0
            # entry on previous file - this is a hack to ensure the awk statement below picks up all instances
            for entries in $(awk 'NR==FNR { _[$1]=$2 } NR!=FNR { if (_[$1] == "") { if  ($2 ~ /[0-9]/)   { nn=0; nn=(_[$1]+=$2);  print FNR"-"$1"%0" }  } }' $oldname $names); do
                line=$(echo ${entries%%-*})
                content=$(echo ${entries#*-})
                content=$(echo $content|tr "%" " ")
                #Using ed edit old file and add in the entry with a 0 value 
                edit=$(ed -s $oldname  << EOF
$line
a
$content
.
w
q
EOF 
)
              #Carry out edit and echo out all the output to /dev/null
              $edit  >/dev/null 2>&1

            done

            # Now process the previous file vs current file and add up any rows that has two columns and 2nd column is a numeric value
            awk 'NR==FNR { _[$1]=$2 } NR!=FNR { if (_[$1] != "") { if  ($2 ~ /[0-9]/)   { nn=0; nn=($2+_[$1]); print $1" "nn; } else { print $1;} }else { print; } }' $names $oldname> $oldname1
            # previous name now gets set to the new outputted oldname1
            oldname=$oldname1
    # Finish the counter loop
    fi
# Done all the servers
done


   #VH 16/01/14

  echo "-------------------------------------------------------------------------------------------------------------"
  echo "OVERALL  SUMMARY FOR ALL SERVERS"
  echo "-------------------------------------------------------------------------------------------------------------"
  ##cat $oldname
   newname=$oldname.$RAND
   cat $oldname|grep -v "Average_response_time_SOMETHING_ms:" >$newname
   avg=$(cat $oldname |grep "Average_response_time_SOMETHING_ms: "|awk -F": " '{print $2}')
   avg1=$(echo $avg|awk -v tot=$i '{$3=$1 /tot;print $3}')
   #content=$content"Avg_Response_in_ms_old: $avg\n"
   content="Average_response_time_SOMETHING_ms: $avg1\n"
   content1=$(echo -e $content)


   # Added this block which can be used outside of the loop to work out final averages if the reports are to contain averages.



# out of the loop now 
# echo out the final sum
cat $oldname

# delete all randomly created files
rm summary?.*


# Enjoy This took me a few days to figure out but I will be using it across all our clustered solutions to produce over all summaries.
# the trick is to ensure the server report has two column per row and the 2nd row is the numeric value - any one columned rows are just outputted - 
# two columns with secondary not being numeric will result with a sum of 0 as second value 
