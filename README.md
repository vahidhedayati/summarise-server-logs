summarise-server-logs
=====================

Bash script using awk to run through server summaries to produce an over all result. 

Assuming you have more than one application server and you are retrieving a daily report from its logs. 

To get an overall summary, the easiest method would be to look at all the logs together and do a final loop of retrieving relevant values. 

Using this script in conjunction with exporting the actual summaries to file you can add all the values to make final report. In short change report times from 30 minutes to 2 minutes to compile because the over all result is a sum of the summaries. 

This script can be added to any script which does a similar job. 

What you would need to do is produce any report that looks like the above report where the numeric value is after the field, the field can't have spaces (you can use tr "_" " " to remove _ from the field if required.. basically 2 field summary from each server - with any type of heading - the script will add the content together - the initial problem was where there was a new user or something under a heading on the file being compared. This is now been fixed by finding the and using ed to add to original file.)
