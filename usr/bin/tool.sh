#!/bin/bash
set -e
#trapping function
function itsatrap {
  echo "You interrupted the script"
  exit
}
#Show environment variables, info about memory,network and procces
function basic {
  create_logs "$(echo -e "\n[$(date)]")"
  environment
  pid
  network
  disk
}

#Show environment variables
function environment {
	# output of the env and write to the log file
	printenv | grep SHELL | tee -a env.log
	printenv | grep HOME | tee -a env.log
	printenv | grep PWD | tee -a env.log
	printenv | grep USER | tee -a env.log
  printenv | grep PATH | tee -a env.log
}
#Show statistics about current directory
function status {
	stat env.log #info about env.log file
  echo -e "Directory information:\n"
  echo "The number of files and directories with 'find'"
  find . -type f | wc -l
  find . -mindepth 1 -maxdepth 1 -type d | wc -l
  echo "The number of files and directories with 'ls'"
  ls -l . | grep ^- | wc -l
  ls -l . | grep ^d | wc -l
  ls -la
}

function usage {
  echo -e "\nHelp: $1 OPTION"
  echo -e "\t-b basic \tPrints information about environments"
  echo -e "\t-s stat \tPrints information about statistics"
  echo -e "\t-h\t\tfor help"
  exit 0
}

#pid of the script
function pid {
  PID=$$
  create_logs "$(echo -e "\nThe PID of the script: $PID")"
  create_logs "$(grep -i "PPID" /proc/$PID/status)"
  create_logs "$(grep -i "VMSIZE" /proc/$PID/status)"
}

#Calculeted used memory
function memory {
  TOTALMEM=$(free --mega | grep Mem | awk '{print $2}')
  USEDMEM=$(free --mega | grep Mem | awk '{print $3}')
  PERC=$(free --mega | grep Mem | awk '{print $3 / $2 * 100}')
  PERCOUT=$(echo -e \ "\nThe percent of used memory is $USEDMEM MB / $TOTALMEM MB * 100% = $PERC%")
  create_logs "$PERCOUT"
}
#Inforamation about HTTP status, IP addr, open ports
function network() {
  PING=$(ping -c 2 8.8.8.8)
  create_logs "$(echo -e "\nPing to 8.8.8.8\n$PING")"
  CURL=$(curl -Is www.google.com | grep -w -m 1 "HTTP" | awk '{print $2" "$3}')
  create_logs "$(echo -e \nHTTP status of www.google.com\n$CURL)"
  IP=$(dig google.com +short)
  create_logs "$(echo -e "\nIPv4 addr of www.google.com\n$IP")"
  NETCAT=$(nc -zv localhost 1-65535 2>&1 | grep succeeded | wc -l)
  create_logs "$(echo -e "\nThe number of open ports is $NETCAT")"
}

#Show the number of partition, filesystem size and hardfile
function disk {
  PARTITION=$(lsblk | grep part |wc -l)
  create_logs "$(echo -e "\nThe quantity of partition is $PARTITION")"
  FSSIZE=$(df -ht ext4 --output=source,fstype,size)
  create_logs "$(echo -e "\nFilesystem size \n$FSSIZE")"
  BIGFILES=$(du -ah $PWD | sort -hr | sed "1d" | head -5)
  create_logs "$(echo -e "\nThe hardest files of the current directory\n$BIGFILES")"
}

#Write all impotant information in logfile
function create_logs {
  echo "$1" | tee -a /var/log/avpackage/avpackage_log.log
}

#writng the fact to call of script
[ -e /tmp/notifyfifo] && echo "[$(date)] - Basic script was running" >> /tmp/notifyfifo

while getopts "bsh" opt
	do
		case $opt in #swith-case constraction
			b) echo -e "\nBasic";basic;; #call function evironment
			s) echo -e "\nFile status is:";status;; #call function status
			h) usage $0;; #call function usage
			*) echo "Try 'tool.sh -h' for more information.";;
		esac
	done

  if [ -z "$1" ]
  	then
  		echo "Try 'tool.sh -h' for more information."
  		exit 1 # code fail
  fi

trap itsatrap SIGINT #processing the interrupt function
echo "please wait for 10 seconds before starting or press Ctrl+C to interrupt"
sleep 10
