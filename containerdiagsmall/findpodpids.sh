#!/bin/sh

usage() {
  printf "Usage: %s: [-n] [-v] PODNAME...\n" $0
  cat <<"EOF"
          -n: Use runc without `--root /host/run/runc`
          -v: printVerbose output to stderr
EOF
  exit 2
}

printVerbose() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] ${@}" >> /dev/stderr
}

RUNC="runc --root /host/run/runc"
DEBUG=0
VERBOSE=0

OPTIND=1
while getopts "dhnv?:" opt; do
  case "$opt" in
    d)
      DEBUG=1
      ;;
    h|\?)
      usage
      ;;
    n)
      RUNC="runc"
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

if [ "${#}" -eq 0 ]; then
  echo "ERROR: Missing pod name(s)"
  usage
fi

[ "${VERBOSE}" -eq "1" ] && printVerbose "Started"

[ "${VERBOSE}" -eq "1" ] && printVerbose "${RUNC} list"

if [ "${DEBUG}" -eq "0" ]; then
  RUNCLIST="$(${RUNC} list)"
else
  RUNCLIST="$(cat example_runclist.txt)"
fi

[ "${VERBOSE}" -eq "1" ] && printVerbose "${RUNCLIST}"=
FOUND=0
for ID in $(echo "${RUNCLIST}" | awk 'NF > 3 && $3 != "stopped" && $3 != "STATUS" {print $1}' -); do
  [ "${VERBOSE}" -eq "1" ] && printVerbose "${RUNC} state ${ID}"
  
  if [ "${DEBUG}" -eq "0" ]; then
    RUNCSTATE="$(${RUNC} state ${ID})"
  else
    RUNCSTATE="$(cat example_runcstate.txt)"
  fi

  [ "${VERBOSE}" -eq "1" ] && printVerbose "${RUNCSTATE}"
  RUNCSTATEROWS="$(echo "${RUNCSTATE}" | jq -r '.pid, .annotations."io.kubernetes.container.name", .annotations."io.kubernetes.pod.name", .rootfs, .annotations."io.kubernetes.cri-o.LogPath"')"
  PID="$(echo "${RUNCSTATEROWS}" | awk 'NR==1')"
  CONTAINERNAME="$(echo "${RUNCSTATEROWS}" | awk 'NR==2')"
  PODNAME="$(echo "${RUNCSTATEROWS}" | awk 'NR==3')"
  ROOTFS="$(echo "${RUNCSTATEROWS}" | awk 'NR==4')"
  STDOUTERR="$(echo "${RUNCSTATEROWS}" | awk 'NR==5')"
  for SEARCH in "${@}"; do
    if [ "${SEARCH}" = "${PODNAME}" ]; then
      if [ "${FOUND}" -gt 0 ]; then
        printf " "
      fi
      printf "${PID}"
      FOUND="$(((${FOUND}+1)))"
    fi
  done
done

if [ "${FOUND}" -gt 0 ]; then
  printf "\n"
fi

[ "${VERBOSE}" -eq "1" ] && printVerbose "Finished"
