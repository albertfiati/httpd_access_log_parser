#!/bin/bash
LIMIT=-1
IP_TABLE=ip.table.txt
BLACKLISTED_DNS=dns.blacklist.txt


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
			-) FILE=$1
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
	if [ -f "$BLACKLISTED_DNS" ]; then
		DOMAIN=$(grep $1 $IP_TABLE | head -1 | awk '{print $2}')

		if [[ ! ${#DOMAIN} -gt 0 ]]; then
			DOMAIN=$(nslookup $1 | grep 'name*.*.$' | awk '{print $4}' |  rev | cut -d"." -f2,3 | rev)	
			echo -e $1 "\t " $DOMAIN >> $IP_TABLE
		fi

		#check if the string is empty
		if [[ ${#DOMAIN} -gt 0 ]]; then
			#checking if the IP is blacklisted
			if grep -q "$DOMAIN" "$BLACKLISTED_DNS"; then
				echo *Blacklisted*
			fi
		fi
		
	else
		echo file not found
	fi
}

#fetch ip's with the most no. of connection attempts
connectionAttempts(){
	#$1 => $LIMIT
	#$2 => $FILE

	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		echo -e IP Address "\t" Counts " " Blacklisted
		echo    ---------------------------------------
		cat $2 | awk '{print $1}' | sort | uniq -c | sort -r | awk '{print $2 "\t " $1}' | head -$1 | while IFS=" " read -r -a line; do 
	        IP_ADD=${line[0]}
			COUNT=${line[1]}
			echo -e $IP_ADD "\t" $COUNT "\t" $(iPIsBlackListed $IP_ADD)
	    done
	else
		echo
		echo -e IP Address "\t" Counts
		echo    -------------------------
		cat $2 | awk '{print $1}' | sort | uniq -c | sort -r | awk '{print $2 "\t " $1}' | head -$1 
	fi
}

#fetch ip's with the most no of successful connection attempts
successfulConnections(){
	#$1 => $LIMIT
	#$2 => $FILE

	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		#echo -e IP Address "\t "Code "\t" Counts " " Blacklisted
		echo -e IP Address "\t " Counts " " Blacklisted
		echo    --------------------------------------------------
		cat $2 | awk '{print $1 "\t" $9}' | sort | uniq -c | grep "2\d\{2\}$" | sort -r | awk '{print $2 "\t " $1}' | head -$1 | while IFS=" " read -r -a line; do 
	        IP_ADD=${line[0]}
			COUNT=${line[1]}
			echo -e $IP_ADD "\t" $COUNT "\t" $(iPIsBlackListed $IP_ADD)
	    done
	else
		echo 
		echo -e IP Address "\t" Counts
		echo    -----------------------------------
		cat $2 | awk '{print $1 "\t" $9}' | sort | uniq -c | grep "2\d\{2\}$" | sort -r | awk '{print $2 "\t" $1}' | head -$1
	fi
}

#fetch most result codes and their source
mostResultCodes(){
	#$1 => $LIMIT
	#$2 => $FILE

	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		#echo -e IP Address "\t "Code "\t" Counts " " Blacklisted
		echo -e Code "\t " IP Address "\t " Blacklisted
		echo    --------------------------------------------------
		cat $2 | awk '{print $9}' | sort -r | uniq -d | awk '{print $1}' | while read code
		do
			echo ""
			cat $2 | awk '{print $9 "\t" $1}' | grep "^$code" | sort | uniq -c | sort -r | awk '{print $2 "\t " $3}' | head -$1 | while IFS=" " read -r -a line; do 
				IP_ADD=${line[1]}
				CODE=${line[0]}

				echo -e $CODE "\t " $IP_ADD "\t " $(iPIsBlackListed $IP_ADD)
			done
		done
	else
		echo
		#echo -e IP Address "\t" Code "\t" Counts
		echo -e Code "\t " IP Address
		echo    -----------------------------------
		cat $2 | awk '{print $9}' | sort -r | uniq -d | awk '{print $1}' | while read code
		do
			echo ""
			cat $2 | awk '{print $9 "\t" $1}' | grep "^$code" | sort | uniq -c | sort -r | awk '{print $2 "\t" $3}' | head -$1
		done
	fi
}

#fetch ip's with the most no of failed connection attempts
failureConnections(){
	#$1 => $LIMIT
	#$2 => $FILE

	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		#echo -e IP Address "\t "Code "\t" Counts " " Blacklisted
		echo -e Code "\t "IP Address "\t" Blacklisted
		echo    --------------------------------------------------

		cat $2 | awk '{print $9}' | sort -r | uniq -d | awk '{print $1}' | grep "^[4-5]" | while read code
		do
			echo ""
			cat $2 | awk '{print $9 "\t" $1}' | grep "^$code" | sort | uniq -c | sort -r | awk '{print $2 "\t " $3}' | head -$1 | while IFS=" " read -r -a line; do 
	        	IP_ADD=${line[1]}
				CODE=${line[0]}

				echo -e $CODE "\t" $IP_ADD "\t" $(iPIsBlackListed $IP_ADD)
			done
		done
	else
		echo
		#echo -e IP Address "\t" Code "\t" Counts
		echo -e Code "\t" IP Address
		echo    -----------------------------------
		cat $2 | awk '{print $9}' | sort -r | uniq -d | awk '{print $1}' | grep "^[4-5]" | while read code
		do
			echo ""
			cat $2 | awk '{print $9 "\t" $1}' | grep "^$code" | sort | uniq -c | sort -r | awk '{print $2 "\t" $3}' | head -$1
		done
	fi
}

#fetch ip's with the most no of connection attempts
mostBytes(){
	if [[ "$CHECKBLACKLIST" = "-e" ]]; then
		echo
		echo -e IP Address "\t" Bytes "\t" Blacklisted
		echo    --------------------------------------------------
		cat http_logs.log | awk '{print $1 "\t " $10}' | sort | grep "[0-9]$" | awk '{arr[$1]+=$2} END {for (i in arr) {print arr[i] "\t" i}}' | sort -nr | awk '{print $2 "\t " $1}' | head -$1 | while IFS=" " read -r -a line; do 
	        IP_ADD=${line[0]}
			BYTES=${line[1]}

			echo -e $IP_ADD "\t" $BYTES "\t " $(iPIsBlackListed $IP_ADD)
	    done
	else
		echo
		echo -e IP Address "\t" Bytes 
		echo    ------------------------
		cat http_logs.log | awk '{print $1 "\t " $10}' | sort | grep "[0-9]$" | awk '{arr[$1]+=$2} END {for (i in arr) {print arr[i] "\t" i}}' | sort -nr | awk '{print $2 "\t" $1}' | head -$1
	fi
} 

#print opperation instructions
executeCommand(){
	#$1 => $LIMIT
	#$2 => $OPP
	#$3 => $FILE

	echo ""
	case $2 in
		-c) echo ">>" Which IP address makes the most number of connection attempts?
			connectionAttempts $1 $3
			;;
		-2) echo ">>" Which address makes the most number of successful attempts?
			successfulConnections $1 $3
			;;
		-r) echo ">>" What are the most common results codes and where do they come from?
			mostResultCodes $1 $3
			;;
		-F) echo ">>" What are the most common result codes that indicate failure and where do they come from?
			failureConnections $1 $3
			;;
		-t) echo ">>" Which IP number get the most bytes sent to them?
			mostBytes $1 $3
			;;
		-e) echo ">>" Checking for blacklists
			iPIsBlackListed $1 $3
			;;
		*) echo ">>" Invalid option
			;;
	esac

	echo ""
}

createIPTables(){
	if [ ! -f "$IP_TABLE" ]; then
		touch $IP_TABLE
	else
		$(> $IP_TABLE)
	fi
	
	echo -e IP Address "\t "  Domain >> $IP_TABLE
	echo -e ------------------------------- >> $IP_TABLE
}

#clear
echo "***************************************************************************"
echo
echo -e "\t\t\t" SCRATCH Log analyzer
echo
echo "***************************************************************************"

#check if the required number of options are provided
if [ $# -gt 0 ]; then 
	
	readOptions $@

	# read file from standard input if not provided
	while [[ -z $FILE || ! -f $FILE ]]; do
		read -p "Provide absolute path to the log file: " FILE
	done

	# set limit to number of lines in the log file
	if [ ! $LIMIT -gt 0 ]; then
		LIMIT=$(< "$FILE" wc -l | xargs)
	fi

	# print read options
	echo ""
	echo -e Filename "\t: $FILE"
	echo -e Opperation "\t: $OPP"
	echo -e Limit "\t\t: $LIMIT"
	echo Check blacklist ": $CHECKBLACKLIST"
	echo ""

	createIPTables
	executeCommand $LIMIT $OPP $FILE
else
	echo "Invalid command. See help below"
	echo ""
	echo "Command"
	echo " ./log_sum.sh [-n N] (-c|-2|-r|-F|-t) <filename>"
	echo ""
	echo "Options"
	echo " -n: Limit the number of results to N"
	echo " -c: Which IP address makes the most number of connection attempts?"
	echo " -2: Which address makes the most number of successful attempts?"
	echo " -r: What are the most common results codes and where do they come from?"
	echo " -F: What are the most common result codes that indicate failure (no auth, not found etc) and where do they come from?"
	echo " -t: Which IP number get the most bytes sent to them?"
	echo " <filename> refers to the logfile. If ’-’ is given as a filename, or no filename is given, then standard input should be read. This enables the script to be used in a pipeline."
	echo ""
fi