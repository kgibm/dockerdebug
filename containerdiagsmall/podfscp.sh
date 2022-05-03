#!/bin/sh

usage() {
  printf "Usage: %s: [-ov] [-p PODNAME]... FILE...\n" $0
  cat <<"EOF"
             -o: Gather stdout/stderr log of each pod as well.
             -p: PODNAME. May be specified multiple times.
             -v: verbose output to stderr
EOF
  exit 2
}

printVerbose() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] ${@}" >> /dev/stderr
}

PODNAMES=""
VERBOSE=0
CPSTDOUTERR=0

OPTIND=1
while getopts "hop:v?" opt; do
  case "$opt" in
    h|\?)
      usage
      ;;
    o)
      CPSTDOUTERR=1
      ;;
    p)
      PODNAMES="${PODNAMES} ${OPTARG}"
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

  if [ "${CPSTDOUTERR}" -eq "1" ]; then
    PODSTDOUTERR="$(podinfo.sh -o "${PODNAME}")"
    if [ "${PODSTDOUTERR}" != "" ]; then
      cp "/host/${PODSTDOUTERR}" pods/${PODNAME}/stdouterr.log
    else
      printVerbose "Stdout/stderr file for pod ${PODNAME} is blank"
    fi
  fi
}

for PODNAME in ${PODNAMES}; do
  processPod "${PODNAME}" "${@}"
done
