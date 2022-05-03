#!/bin/sh

usage() {
  printf "Usage: %s: [-r] [-p PODNAME]... FILE...\n" $0
  cat <<"EOF"
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

OPTIND=1
while getopts "hp:v?" opt; do
  case "$opt" in
    h|\?)
      usage
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

    # We need to get the absolute path because symlinks won't work as it assumes
    # a chroot, and we can't chroot, because then we can't copy out
    REALPATH="$(chroot "/host/${PODFS}/" sh -c "cd \$(dirname \"${ARG}\") && pwd -P")"
    [ "${VERBOSE}" -eq "1" ] && printVerbose "processPod REALPATH=${REALPATH}"

    if [ "${REALPATH}" != "" ]; then
      ARG="/host/${PODFS}/${REALPATH}/$(basename "${ARG}")"
      [ "${VERBOSE}" -eq "1" ] && printVerbose "processPod Copying ${ARG}"
      cp -r ${ARG} pods/${PODNAME}/
    else
      printVerbose "Path ${ARG} for pod ${PODNAME} does not evaluate to a real path within ${PODFS}"
    fi
  done
}

for PODNAME in ${PODNAMES}; do
  processPod "${PODNAME}" "${@}"
done
