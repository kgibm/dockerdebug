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
# Kubernetes debug pods are transient but we normally want to save output
# for download. The idea of this script is that we run the specified commands
# and then pause for download.
# Example:
# oc debug node/$NODE -t --image=quay.io/kgibm/containerdiagsmall -- run.sh sh -c 'echo "Hello World"'

usage() {
  printf "Usage: %s [-sv] [-d DELAY] COMMAND [ARGUMENTS]\n" "$(basename "${0}")"
  cat <<"EOF"
             -d: DELAY in seconds between checking command and download completion.
             -s: Skip statistics collection
             -v: verbose output to stderr
EOF
  exit 2
}

DESTDIR="/tmp"
VERBOSE=0
SKIPSTATS=0
DELAY=30
OUTPUTFILE="stdouterr.log"

OPTIND=1
while getopts "d:hsv?" opt; do
  case "$opt" in
    d)
      DELAY="${OPTARG}"
      ;;
    h|\?)
      usage
      ;;
    s)
      SKIPSTATS=1
      ;;
    v)
      VERBOSE=1
      ;;
  esac
done

shift $((OPTIND-1))

if [ "${1:-}" = "--" ]; then
  shift
fi

# Remove any trailing slash from $DESTDIR
DESTDIR="${DESTDIR%/}"

if [ ! -d "${DESTDIR}" ]; then
  echo "ERROR: Expecting a Kubernetes debug pod that has a mount at ${DESTDIR}"
  exit 1
fi

printVerbose() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] ${@}" >> /dev/stderr
}

printInfo() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] ${@}" | tee -a "${OUTPUTFILE}"
}

if [ "${#}" -eq 0 ]; then
  echo "ERROR: Missing COMMAND"
  usage
fi

TARGETDIR="$(mktemp -d "${DESTDIR}/containerdiag.XXXXXXXXXX")"

if [ "${TARGETDIR}" = "" ]; then
  echo "ERROR: Failed to create a temporary directory in ${DESTDIR}"
  exit 3
fi

# Add a trailing slash to $TARGETDIR
TMPNAME="$(basename "${TARGETDIR}")"
TARGETDIR="${TARGETDIR}/"

echo "Writing to ${TARGETDIR}"

pushd "${TARGETDIR}" || exit 4

# Now we can finally start the execution
printInfo "containerdiag: started on $(hostname). Gathering first set of system info."

nodeInfo() {
  mkdir -p node/$1
  top -b -d 1 -n 2 &> node/$1/top.txt
  top -H -b -d 1 -n 2 &> node/$1/topthreads.txt
  ps -elfyww &> node/$1/ps.txt
  iostat -xm 1 2 &> node/$1/iostat.txt
  ip addr &> node/$1/ipaddr.txt
  ip -s link &> node/$1/iplink.txt
  ss --summary &> node/$1/sssummary.txt
  ss -amponeti &> node/$1/ssdetails.txt
  nstat -saz &> node/$1/nstat.txt
  netstat -i &> node/$1/netstati.txt
  netstat -s &> node/$1/netstats.txt
  netstat -anop &> node/$1/netstat.txt
  chroot /host systemd-cgtop -b --depth=5 -d 1 -n 2 &> node/$1/cgtop.txt
  cat /proc/loadavg &> node/$1/loadavg.txt
}

# Gather the first set of node info
if [ "${SKIPSTATS}" -eq "0" ]; then
  nodeInfo "stats_iteration1_$(date +"%Y%m%d_%H%M%S")"
fi

# We can't just run the process directly because some kube/oc debug
# sessions will timeout if nothing happens for a while, so we put
# it in the background and then wait until it's done
( "$@" 2>&1 | tee -a "${OUTPUTFILE}" ) &

BGPID="${!}"

printInfo "containerdiag: waiting for background commands (PID ${BGPID}) to finish..."

# Some scripts finish in a few seconds, so optimize for that case
sleep 5

if [ -d /proc/${BGPID} ]; then
  while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] containerdiag: Waiting for script to complete"
    sleep ${DELAY}
    if [ ! -d /proc/${BGPID} ]; then
      break
    fi
  done
fi

printInfo "containerdiag: command completed. Gathering second set of system info."

if [ "${SKIPSTATS}" -eq "0" ]; then
  nodeInfo "stats_iteration2_$(date +"%Y%m%d_%H%M%S")"
fi

mkdir -p node/info
chroot /host date &> node/info/date.txt
chroot /host uname -a &> node/info/uname.txt
chroot /host journalctl -b | head -2000 &> node/info/journalctl_head.txt
chroot /host journalctl -b -n 2000 &> node/info/journalctl_tail.txt
chroot /host journalctl -p warning -n 500 &> node/info/journalctl_errwarn.txt
chroot /host sysctl -a &> node/info/sysctl.txt
chroot /host lscpu &> node/info/lscpu.txt
ulimit -a &> node/info/ulimit.txt
uptime &> node/info/uptime.txt
hostname &> node/info/hostname.txt
cat /host/proc/cpuinfo &> node/info/cpuinfo.txt
cat /host/proc/meminfo &> node/info/meminfo.txt
cat /host/proc/version &> node/info/version.txt
cp -r /host/proc/pressure node/info/ 2>/dev/null
cat /host/etc/*elease* &> node/info/release.txt
chroot /host df -h &> node/info/df.txt
chroot /host systemctl list-units &> node/info/systemctlunits.txt
chroot /host systemd-cgls &> node/info/cgroups.txt

printInfo "containerdiag: All data gathering complete. Packaging for download."

# After we're done, we want to package everything up into a tgz
# and show an example command of how to download it.
TARFILE="${TARGETDIR%/}.tar.gz"
tar -czf "${TARFILE}" -C "${TARGETDIR}" . || exit 5

rm -rf "${TARGETDIR}"

echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] Finished with output in ${TARFILE}"

# Now we need to figure out our own pod name and namespace to create the
# right download command. We touch a file in our temp directory which we'll
# then search for.
touch /tmp/${TMPNAME}

[ "${VERBOSE}" -eq "1" ] && printVerbose "Touched /tmp/${TMPNAME}"

DEBUGPODINFO="$(ps -elf | grep debug-node | /opt/debugpodinfo.awk -v "fssearch=/tmp/${TMPNAME}" 2>/dev/null)"

[ "${VERBOSE}" -eq "1" ] && printVerbose "debugpodinfo.awk output: ${DEBUGPODINFO}"

DEBUGPODNAME="$(echo "${DEBUGPODINFO}" | awk 'NR==1')"
DEBUGPODNAMESPACE="$(echo "${DEBUGPODINFO}" | awk 'NR==2')"

echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] Debug pod is ${DEBUGPODNAME} in namespace ${DEBUGPODNAMESPACE}"

while true; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] Files are ready for download. Download with the following command in another window:"
  echo ""
  echo "  kubectl cp ${DEBUGPODNAME}:${TARFILE} $(basename "${TARFILE}") --namespace=${DEBUGPODNAMESPACE}"
  echo ""
  if read -p "After the download is complete, press ENTER to end this script and clean up: " -t ${DELAY} READSTR; then
    break
  fi
  echo ""
done

echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] Processing finished. Deleting ${TARFILE}"

rm -f "${TARFILE}"

echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] run.sh finished."
