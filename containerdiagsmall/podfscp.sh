#!/bin/sh

usage() {
  printf "Usage: %s: [-sv] [-p PODNAME]... FILE...\n" $0
  cat <<"EOF"
             -p: PODNAME. May be specified multiple times.
             -s: Gather standard files of each pod as well.
             -v: verbose output to stderr
EOF
  exit 2
}

printVerbose() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] ${@}" >> /dev/stderr
}

PODNAMES=""
VERBOSE=0
GETSTANDARD=0

OPTIND=1
while getopts "hp:sv?" opt; do
  case "$opt" in
    h|\?)
      usage
      ;;
    p)
      PODNAMES="${PODNAMES} ${OPTARG}"
      ;;
    s)
      GETSTANDARD=1
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

if [ "${PODNAMES}" = "" ]; then
  echo "ERROR: Missing -p PODNAME"
  usage
fi

if [ "${#}" -eq 0 ]; then
  echo "ERROR: Missing FILEs"
  usage
fi

processPod() {
  PODNAME="${1}"
  [ "${VERBOSE}" -eq "1" ] && printVerbose "processPod ${PODNAME} with ${@}"
  shift
  mkdir -p pods/${PODNAME}
  PODFS="$(podinfo.sh -r "${PODNAME}")"
  [ "${VERBOSE}" -eq "1" ] && printVerbose "processPod PODFS=${PODFS}"
  for ARG in "${@}"; do
    [ "${VERBOSE}" -eq "1" ] && printVerbose "processPod ARG=${ARG}"

    REALPATH="$(podfspath.sh "${PODFS}" "${ARG}")"

    [ "${VERBOSE}" -eq "1" ] && printVerbose "processPod REALPATH=${REALPATH}"

    if [ "${REALPATH}" != "" ]; then
      cp -r ${REALPATH} pods/${PODNAME}/
    else
      printVerbose "Path ${ARG} for pod ${PODNAME} does not evaluate to a real path within ${PODFS}"
    fi
  done

  if [ "${GETSTANDARD}" -eq "1" ]; then
    PODSTDOUTERR="$(podinfo.sh -o "${PODNAME}")"
    if [ "${PODSTDOUTERR}" != "" ]; then
      cp "/host/${PODSTDOUTERR}" pods/${PODNAME}/stdouterr.log
    else
      printVerbose "Stdout/stderr file for pod ${PODNAME} is blank"
    fi

    # Next let's grab various cgroup info
    # /sys/fs/cgroup/cpuset/cpuset.memory_pressure
    # /sys/fs/cgroup/cpuset/cpuset.cpus /sys/fs/cgroup/cpuset/cpuset.effective_cpus
    PODPID="$(podinfo.sh "${PODNAME}")"
    if [ "${PODPID}" != "" ]; then
      [ "${VERBOSE}" -eq "1" ] && printVerbose "processPod PODPID=${PODPID}"
      mkdir -p pods/${PODNAME}/cgroup/cpuset
      echo "${PODPID}" > pods/${PODNAME}/pid.txt
      cp "/host/proc/${PODPID}/cgroup" pods/${PODNAME}/cgroup/

      # Grab the actual cgroup name
      CGROUP="$(cat "/host/proc/${PODPID}/cgroup" | awk -F: 'NR==1 {print $3;}')"
      if [ "${CGROUP}" != "" ]; then
        [ "${VERBOSE}" -eq "1" ] && printVerbose "processPod CGROUP=${CGROUP}"
        cp -r /host/sys/fs/cgroup/cpu/${CGROUP} pods/${PODNAME}/cgroup/cpu/ 2>>cmderr.txt
        cp -r /host/sys/fs/cgroup/memory/${CGROUP} pods/${PODNAME}/cgroup/memory/ 2>>cmderr.txt
        cp /host/sys/fs/cgroup/cpuset/cpuset.cpus /host/sys/fs/cgroup/cpuset/cpuset.effective_cpus pods/${PODNAME}/cgroup/cpuset/ 2>>cmderr.txt
      fi
    else
      printVerbose "PID for pod ${PODNAME} is blank"
    fi
  fi
}

for PODNAME in ${PODNAMES}; do
  processPod "${PODNAME}" "${@}"
done
