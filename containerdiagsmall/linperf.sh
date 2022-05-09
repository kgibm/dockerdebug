#!/bin/sh
# /*******************************************************************************
#  * (c) Copyright IBM Corporation 2022.
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *    http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.
#  *******************************************************************************/
###############################################################################
#
# This script is used to collect data for 
# 'MustGather: Performance, Hang or High CPU Issues on Linux'
#
# ./linperf.sh [PID(s)_of_the_problematic_JVM(s)_separated_by_spaces]
#
SCRIPT_VERSION=2022.05.03
###############################################################################
#                        #
# Variables              # 
#                        #
##########################
SCRIPT_SPAN=240          # How long the whole script should take. Default=240
JAVACORE_INTERVAL=30     # How often javacores should be taken. Default=30
TOP_INTERVAL=60          # How often top data should be taken. Default=60
TOP_DASH_H_INTERVAL=5    # How often top dash H data should be taken. Default=5
VMSTAT_INTERVAL=5        # How often vmstat data should be taken. Default=5
###############################################################################
# * All values are in seconds.
# * All the 'INTERVAL' values should divide into the 'SCRIPT_SPAN' by a whole 
#   integer to obtain expected results.
# * Setting any 'INTERVAL' too low (especially JAVACORE) can result in data
#   that may not be useful towards resolving the issue.  This becomes a problem 
#   when the process of collecting data obscures the real issue.
# * 04/17/2019 - Changed JAVACORE_INTERVAL from 120 to 30 (ajay Bhalodia)
###############################################################################

KEEPQUIET=0
ALLOWSTATS=0
OPTIND=1
while getopts "j:qs:t:u:v:z" opt; do
  case "$opt" in
    j)
      JAVACORE_INTERVAL="${OPTARG}"
      ;;
    q)
      KEEPQUIET=1
      ;;
    s)
      SCRIPT_SPAN="${OPTARG}"
      ;;
    t)
      TOP_INTERVAL="${OPTARG}"
      ;;
    u)
      TOP_DASH_H_INTERVAL="${OPTARG}"
      ;;
    v)
      VMSTAT_INTERVAL="${OPTARG}"
      ;;
    z)
      ALLOWSTATS=1
      ;;
  esac
done

shift $((OPTIND-1))

if [ "${1:-}" = "--" ]; then
  shift
fi

if [ $# -eq 0 ] && [ $ALLOWSTATS -eq 0 ]
then
  echo "$0 : Unable to find required PID argument.  Please rerun the script as follows:"
  echo "$0 : ./linperf.sh [PID(s)_of_the_problematic_JVM(s)_separated_by_spaces]"
  exit 1
fi
##########################
# Create output files    #
#                        #
##########################
# Create the screen.out and put the current date in it.
echo > screen.out
date >> screen.out

# Starting up
echo $(date) "MustGather>> linperf.sh script starting..." | tee -a screen.out
echo $(date) "MustGather>> Script version:  $SCRIPT_VERSION." | tee -a screen.out

# Display the PIDs which have been input to the script
for i in $*
do
	echo $(date) "MustGather>> PROBLEMATIC_PID is:  $i" | tee -a screen.out
done

# Display the being used in this script
echo $(date) "MustGather>> SCRIPT_SPAN = $SCRIPT_SPAN" | tee -a screen.out
echo $(date) "MustGather>> JAVACORE_INTERVAL = $JAVACORE_INTERVAL" | tee -a screen.out
echo $(date) "MustGather>> TOP_INTERVAL = $TOP_INTERVAL" | tee -a screen.out
echo $(date) "MustGather>> TOP_DASH_H_INTERVAL = $TOP_DASH_H_INTERVAL" | tee -a screen.out
echo $(date) "MustGather>> VMSTAT_INTERVAL = $VMSTAT_INTERVAL" | tee -a screen.out

# Collect the user currently executing the script
echo $(date) "MustGather>> Collecting user authority data..." | tee -a screen.out
date > whoami.out
whoami >> whoami.out 2>&1
echo $(date) "MustGather>> Collection of user authority data complete." | tee -a screen.out

# Create some of the output files with a blank line at top
echo $(date) "MustGather>> Creating output files..." | tee -a screen.out
echo > vmstat.out
echo > ps.out
echo > top.out
echo $(date) "MustGather>> Output files created:" | tee -a screen.out
echo $(date) "MustGather>>      vmstat.out" | tee -a screen.out
echo $(date) "MustGather>>      ps.out" | tee -a screen.out
echo $(date) "MustGather>>      top.out" | tee -a screen.out
for i in $*
do
	echo > topdashH.$i.out
	echo $(date) "MustGather>>      topdashH.$i.out" | tee -a screen.out
done

###############################################################################
#                       #
# Start collection of:  #
#  * netstat x2         #
#  * top                #
#  * top dash H         #
#  * vmstat             #
#                       #
#########################
# Start the collection of netstat data.
# Collect the first netstat: date at the top, data, and then a blank line
echo $(date) "MustGather>> Collecting the first netstat snapshot..." | tee -a screen.out
date >> netstat.out
netstat -pan >> netstat.out 2>&1
echo >> netstat.out
echo $(date) "MustGather>> First netstat snapshot complete." | tee -a screen.out

# Start the collection of top data.
# It runs in the background so that other tasks can be completed while this runs.
echo $(date) "MustGather>> Starting collection of top data..." | tee -a screen.out
date >> top.out
echo >> top.out
top -bc -d $TOP_INTERVAL -n `expr $SCRIPT_SPAN / $TOP_INTERVAL + 1` >> top.out 2>&1 &
echo $(date) "MustGather>> Collection of top data started." | tee -a screen.out

# Start the collection of top dash H data.
# It runs in the background so that other tasks can be completed while this runs.
echo $(date) "MustGather>> Starting collection of top dash H data..." | tee -a screen.out
for i in $*
do
	date >> topdashH.$i.out
	echo >> topdashH.$i.out
	echo "Collected against PID $i." >> topdashH.$i.out
	echo >> topdashH.$i.out
	top -bH -d $TOP_DASH_H_INTERVAL -n `expr $SCRIPT_SPAN / $TOP_DASH_H_INTERVAL + 1` -p $i >> topdashH.$i.out 2>&1 &
	echo $(date) "MustGather>> Collection of top dash H data started for PID $i." | tee -a screen.out
done

# Start the collection of vmstat data.
# It runs in the background so that other tasks can be completed while this runs.
echo $(date) "MustGather>> Starting collection of vmstat data..." | tee -a screen.out
date >> vmstat.out
vmstat $VMSTAT_INTERVAL `expr $SCRIPT_SPAN / $VMSTAT_INTERVAL + 1` >> vmstat.out 2>&1 &
echo $(date) "MustGather>> Collection of vmstat data started." | tee -a screen.out

################################################################################
#                       #
# Start collection of:  #
#  * javacores          #
#  * ps                 #
#                       #
#########################
# Initialize some loop variables
n=1
m=`expr $SCRIPT_SPAN / $JAVACORE_INTERVAL`

# Loop
while [ $n -le $m ]
do
	
	# Collect a ps snapshot: date at the top, data, and then a blank line
	echo $(date) "MustGather>> Collecting a ps snapshot..." | tee -a screen.out
	date >> ps.out
	ps -eLf >> ps.out 2>&1
	echo >> ps.out
	echo $(date) "MustGather>> Collected a ps snapshot." | tee -a screen.out
	
	# Collect a javacore against the problematic pid (passed in by the user)
	# Javacores are output to the working directory of the JVM; in most cases this is the <profile_root>
	echo $(date) "MustGather>> Collecting a javacore..." | tee -a screen.out
	for i in $*
	do
		kill -3 $i >> screen.out 2>&1
		echo $(date) "MustGather>> Collected a javacore for PID $i." | tee -a screen.out
	done
	
	# Pause for JAVACORE_INTERVAL seconds.
	echo $(date) "MustGather>> Continuing to collect data for $JAVACORE_INTERVAL seconds..." | tee -a screen.out
	sleep $JAVACORE_INTERVAL
	
	# Increment counter
	n=`expr $n + 1`

done

# Collect a final javacore and ps snapshot.
echo $(date) "MustGather>> Collecting the final ps snapshot..." | tee -a screen.out
date >> ps.out
ps -eLf >> ps.out 2>&1
echo >> ps.out
echo $(date) "MustGather>> Collected the final ps snapshot." | tee -a screen.out

echo $(date) "MustGather>> Collecting the final javacore..." | tee -a screen.out
for i in $*
do
	kill -3 $i >> screen.out 2>&1
	echo $(date) "MustGather>> Collected the final javacore for PID $i." | tee -a screen.out
done

# Collect a final netstat
echo $(date) "MustGather>> Collecting the final netstat snapshot..." | tee -a screen.out
date >> netstat.out
netstat -pan >> netstat.out 2>&1
echo $(date) "MustGather>> Final netstat snapshot complete." | tee -a screen.out

################################################################################
#                       #
# Other data collection #
#                       #
#########################
echo $(date) "MustGather>> Collecting other data.  This may take a few moments..." | tee -a screen.out

dmesg > dmesg.out 2>&1
df -hk > df-hk.out 2>&1

echo $(date) "MustGather>> Collected other data." | tee -a screen.out
################################################################################
#                       #
# Compress & Cleanup    #
#                       #
#########################
# Brief pause to make sure all data is collected.
echo $(date) "MustGather>> Preparing for packaging and cleanup..." | tee -a screen.out
sleep 5

# Tar the output files together
echo $(date) "MustGather>> Compressing output files into linperf_RESULTS.tar.gz" | tee -a screen.out

# Build a string to contain all the file names
FILES_STRING="netstat.out vmstat.out ps.out top.out screen.out dmesg.out whoami.out df-hk.out"
for i in $*
do
	TEMP_STRING=" topdashH.$i.out"
	FILES_STRING="$FILES_STRING $TEMP_STRING"
done

tar -cvf linperf_RESULTS.tar $FILES_STRING

# GZip the tar file to create linperf_RESULTS.tar.gz
gzip linperf_RESULTS.tar

# Clean up the output files now that they have been tar/gz'd.
echo $(date) "MustGather>> Cleaning up..."
rm $FILES_STRING

echo $(date) "MustGather>> Clean up complete."
echo $(date) "MustGather>> linperf.sh script complete."

if [ $KEEPQUIET -eq 0 ]; then
	echo
	echo -e "$(tput setaf 0)$(tput setab 3)\t\t\t\t\t\t\t\t\t\t$(tput sgr 0)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  To share with IBM support, upload all the following files:"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  * linperf_RESULTS.tar.gz"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  * /var/log/messages (Linux OS files)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  For WebSphere Application Server:"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  * Logs (systemout.log, native_stderr.log, etc)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  * javacores"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  * server.xml for the server(s) that you are providing data for"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  For Liberty:"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  * Logs (messages.log, console.log, etc)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  * Javacores generated by the script (if running on an IBM JDK)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  * server.env, server.xml, and jvm.options"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  NOTE: The javacores are NOT packed up in the"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)  linperf_RESULTS.tar.gz file so you need to zip those up and send them"
	echo -e "$(tput setaf 0)$(tput setab 3)  $(tput sgr 0)"
	echo -e "$(tput setaf 0)$(tput setab 3)\t\t\t\t\t\t\t\t\t\t$(tput sgr 0)"
fi
################################################################################
