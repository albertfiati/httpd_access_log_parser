#!/bin/bash
LIMIT=10

#read options from the terminal
readOptions(){
	while [[ $# -gt 0 ]]
	do
		case $1 in
			-n) LIMIT=$2
				shift
				shift
				;;
			-e) CHECKBLACKLIST=$1
				shift
				;;
			*.log) FILE=$1
				shift
				;;
			*) OPP=$1
				shift
				;;
		esac
	done	
}

#check if IP has been blacklisted
iPIsBlackListed(){
	#DOMAIN=$(nslookup $1 | grep 'name*.*.$' | awk '{print $4}' | cut -d"." -f2,3)
	DOMAIN=$(nslookup $1 | grep 'name*.*.$' | awk '{print $4}' |  rev | cut -d"." -f2,3 | rev)

	#check if the string is empty
	if [[ ${#DOMAIN} -gt 0 ]]; then
		#echo $(grep "$DOMAIN" dns.blacklist.txt)

		#checking if the IP is blacklisted
		if grep -q "$DOMAIN" dns.blacklist.txt ; then
			echo blacklisted
		fi
	fi
}

#fetch ip's with the most no of connection attempts
connectionAttempts(){
	#cat $2 | awk '{print "\t" $1}' | sort | uniq -c | sort -r | awk '{print $2 "\t " $1}' | head -$1 

	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		echo -e IP Address "\t" Counts " " Blacklisted
		echo    ---------------------------------------
		cat $2 | awk '{print "\t" $1}' | sort | uniq -c | sort -r | awk '{print $2 " " $1}' | head -$1 | while IFS=" " read -r -a line; do 
	        echo -e ${line[0]} "\t" ${line[1]} "\t " $(iPIsBlackListed ${line[0]})
	    done
	else
		echo
		echo -e IP Address "\t" Counts
		echo    -------------------------
		cat $2 | awk '{print "\t" $1}' | sort | uniq -c | sort -r | awk '{print $2 "\t " $1}' | head -$1 
	fi
}

#fetch ip's with the most no of connection attempts
successfulConnections(){
	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		echo -e IP Address "\t "Code "\t" Counts " " Blacklisted
		echo    --------------------------------------------------
		grep '\.*1.1"\s\(2\|3\)\d\{2\}' $2 |  awk '{print "\t" $1 "\t\t" $9}' | sort | uniq -c | sort -r | awk '{print $2 "\t " $3 "\t " $1}' | head -$1 | while IFS=" " read -r -a line; do 
	        echo -e ${line[0]} "\t " ${line[1]} "\t" ${line[2]} "\t " $(iPIsBlackListed ${line[0]})
	    done
	else
		echo 
		echo -e IP Address "\t "Code "\t" Counts
		echo    -----------------------------------
		grep '\.*1.1"\s\(2\|3\)\d\{2\}' $2 |  awk '{print "\t" $1 "\t\t" $9}' | sort | uniq -c | sort -r | awk '{print $2 "\t " $3 "\t " $1}' | head -$1
	fi
}

#fetch most result codes and their source
mostResultCodes(){
	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		echo -e IP Address "\t "Code "\t" Counts " " Blacklisted
		echo    --------------------------------------------------
		cat $2 |  awk '{print "\t" $9 "\t\t" $1}' | sort | uniq -c | sort -r | awk '{print $3 "\t " $2"\t "$1}' | head -$1 | while IFS=" " read -r -a line; do 
	        echo -e ${line[0]} "\t " ${line[1]} "\t" ${line[2]} "\t " $(iPIsBlackListed ${line[0]})
	    done
	else
		echo
		echo -e IP Address "\t" Code "\t" Counts
		echo    -----------------------------------
		cat $2 |  awk '{print "\t" $9 "\t\t" $1}' | sort | uniq -c | sort -r | awk '{print $3 "\t " $2"\t "$1}' | head -$1
	fi
}

#fetch ip's with the most no of connection attempts
failureConnections(){
	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		echo -e IP Address "\t "Code "\t" Counts " " Blacklisted
		echo    --------------------------------------------------
		grep '\.*1.1"\s\(4\|5\)\d\{2\}' $2 |  awk '{print"\t " $9"\t\t " $1}' | sort -r | uniq -c | sort -r | awk '{print $3 "\t " $2"\t " $1}' | head -$1 | while IFS=" " read -r -a line; do 
	        echo -e ${line[0]} "\t " ${line[1]} "\t" ${line[2]} "\t " $(iPIsBlackListed ${line[0]})
	    done
	else
		echo
		echo -e IP Address "\t" Code "\t" Counts
		echo    -----------------------------------
		grep '\.*1.1"\s\(4\|5\)\d\{2\}' $2 |  awk '{print"\t " $9"\t\t " $1}' | sort -r | uniq -c | sort -r | awk '{print $3 "\t " $2"\t " $1}' | head -$1
	fi
}

#fetch ip's with the most no of connection attempts
mostBytes(){
	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		echo -e IP Address "\t" Bytes " " Blacklisted
		echo    --------------------------------------------------
		cat $2 | awk '{print $10 "\t " $1}' | grep '^\d' | sort -hr | uniq -d | awk '{print $2 "\t " $1}' | head -$1 | while IFS=" " read -r -a line; do 
	        echo -e ${line[0]} "\t " ${line[1]} "\t " $(iPIsBlackListed ${line[0]})
	    done
	else
		echo
		echo -e IP Address "\t" Bytes 
		echo    ------------------------
		cat $2 | awk '{print $10 "\t " $1}' | grep '^\d' | sort -hr | uniq -d | awk '{print $2 "\t " $1}' | head -$1
	fi
} 

#print opperation instructions
executeCommand(){
	echo ""
	case $2 in
		-c) echo Which IP address makes the most number of connection attempts?
			connectionAttempts $1 $3
			;;
		-2) echo Which address makes the most number of successful attempts?
			successfulConnections $1 $3
			;;
		-r) echo What are the most common results codes and where do they come from?
			mostResultCodes $1 $3
			;;
		-F) echo What are the most common result codes that indicate failure and where do they come from?
			failureConnections $1 $3
			;;
		-t) echo Which IP number get the most bytes sent to them?
			mostBytes $1 $3
			;;
		-e) echo Checking for blacklists
			;;
		*) echo nothing
			;;
	esac

	echo ""
}


clear
echo "***************************************************************************"
echo
echo -e "\t\t\t" SCRATCH Log analyzer
echo
echo "***************************************************************************"

#check if the required number of options are provided
if [ $# -gt 0 ]; then 
	
	readOptions $@

	echo ""
	echo Filename "$FILE"
	echo OPP "$OPP"
	echo LIMIT "$LIMIT"
	echo BL "$CHECKBLACKLIST"
	echo ""

	executeCommand $LIMIT $OPP $FILE
else
	echo Please provide options
fi