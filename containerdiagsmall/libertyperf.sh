#!/bin/sh
usage() {
  printf "Usage: %s [-s SCRIPTSPAN] [PODNAME]...\n" "$(basename "${0}")"
  cat <<"EOF"
             -s: SCRIPTSPAN for linperf.sh
EOF
  exit 2
}

SCRIPTSPAN=240

OPTIND=1
while getopts "hs:?" opt; do
  case "$opt" in
    h|\?)
      usage
      ;;
    s)
      SCRIPTSPAN="${OPTARG}"
      ;;
  esac
done

shift $((OPTIND-1))

if [ "${1:-}" = "--" ]; then
  shift
fi

if [ "${#}" -eq 0 ]; then
  echo "ERROR: Missing PODNAMEs"
  usage
fi

PODARGS=""
for ARG in "${@}"; do
  PODARGS="${PODARGS} -p ${ARG}"
done

run.sh sh -c "linperf.sh -q -s ${SCRIPTSPAN} $(podinfo.sh -p "${@}") && podfscp.sh -s ${PODARGS} /logs /config /output/javacore* && podfsrm.sh ${PODARGS} /output/javacore*"
