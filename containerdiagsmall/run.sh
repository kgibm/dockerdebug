#!/bin/sh
# Kubernetes debug pods are transient but we normally want to save output
# for download. The idea of this script is that we create a temporary directory
# in /host/, change to that directory, and then run the specified commands.
# The files may then be downloaded (and deleted) after the debug pod exits.
# Example:
# oc debug node/$NODE -t --image=quay.io/kgibm/containerdiagsmall -- run.sh sh -c 'echo "Hello World"'

usage() {
  printf "Usage: %s: [-v] COMMAND [ARGUMENTS]\n" $0
  cat <<"EOF"
          -v: verbose output to stderr
EOF
  exit 2
}

DESTDIR="/host/tmp"
DEBUG=0
VERBOSE=0
DELAY=30

OPTIND=1
while getopts "dhv?:" opt; do
  case "$opt" in
    d)
      DEBUG=1
      DESTDIR="/tmp"
      ;;
    h|\?)
      usage
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
OUTPUTFILE="stdouterr.log"

printInfo "containerdiag: started on $(hostname)"

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

printInfo "containerdiag: command completed. Gathering system info."

mkdir node

chroot /host journalctl -b | head -2000 &> node/journalctl_head.txt
chroot /host journalctl -b -n 2000 &> node/journalctl_tail.txt
chroot /host journalctl -p warning -n 500 &> node/journalctl_errwarn.txt
chroot /host sysctl -a &> node/sysctl.txt
chroot /host lscpu &> node/lscpu.txt
top -b -d 2 -n 2 &> node/top.txt
top -H -b -d 2 -n 2 &> node/topthreads.txt
ps -elfyww &> node/ps.txt
cat /host/proc/meminfo &> node/meminfo.txt
chroot /host df -h &> node/df.txt
iostat -xm 2 2 &> node/iostat.txt
ip addr &> node/ipaddr.txt
ip -s link &> node/iplink.txt
ss --summary &> node/sssummary.txt
ss -amponeti &> node/ssdetails.txt
nstat -saz &> node/nstat.txt
netstat -i &> node/netstati.txt
netstat -s &> node/netstats.txt
netstat -anop &> node/netstat.txt
ulimit -a &> node/ulimit.txt
uptime &> node/uptime.txt
hostname &> node/hostname.txt

printInfo "containerdiag: All data gathering complete. Packaging for download."

# After we're done, we want to package everything up into a tgz
# and show an example command of how to download it.
TARFILE="${TARGETDIR%/}.tar.gz"
tar -czf "${TARFILE}" -C "${TARGETDIR}" . || exit 5

if [ "${DEBUG}" -eq "0" ]; then
  rm -rf "${TARGETDIR}"
else
  popd
  tree -f "${TARGETDIR}"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] Finished with output in ${TARFILE}"

# Now we need to figure out our own pod name and namespace to create the
# right download command. We touch a file in our temp directory which we'll
# then search for.
touch /tmp/${TMPNAME}

[ "${VERBOSE}" -eq "1" ] && printVerbose "Touched /tmp/${TMPNAME}"

DEBUGPODINFO="$(ps -elf | grep debug-node | /opt/debugpodinfo.awk -v "fssearch=/tmp/${TMPNAME}")"

[ "${VERBOSE}" -eq "1" ] && printVerbose "debugpodinfo.awk output: ${DEBUGPODINFO}"

DEBUGPODNAME="$(echo "${DEBUGPODINFO}" | awk 'NR==1')"
DEBUGPODNAMESPACE="$(echo "${DEBUGPODINFO}" | awk 'NR==2')"

echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] Debug pod is ${DEBUGPODNAME} in namespace ${DEBUGPODNAMESPACE}"

while true; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] Files ready for download. Download with the following command in another window:"
  echo ""
  echo "  kubectl cp ${DEBUGPODNAME}:${TARFILE} $(basename "${TARFILE}") --namespace=${DEBUGPODNAMESPACE}"
  echo ""
  echo "After download is complete, press ENTER to end this script and clean up: "
  if read -t ${DELAY} READSTR; then
    break
  fi
done

echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] Processing finished. Deleting ${TARFILE}"

rm -f "${TARFILE}"

echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] run.sh finished."
