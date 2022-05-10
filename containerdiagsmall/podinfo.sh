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

usage() {
  printf "Usage: %s [-oprv] PODNAME...\n" "$(basename "${0}")"
  cat <<"EOF"
             -o: Print space-delimited list of stdout/stderr file paths matching PODNAME(s)
             -p: Default. Print space-delimited list of PIDs matching PODNAME(s)
             -r: Print space-delimited list of root filesystem paths matching PODNAME(s)
             -v: verbose output to stderr
EOF
  exit 2
}

printVerbose() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S.%N %Z')] ${@}" >> /dev/stderr
}

RUNC="chroot /host runc"
DEBUG=0
VERBOSE=0
OUTPUTTYPE=0

OPTIND=1
while getopts "dhnoprv?" opt; do
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
    o)
      OUTPUTTYPE=2
      ;;
    p)
      OUTPUTTYPE=0
      ;;
    r)
      OUTPUTTYPE=1
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
  RUNCLIST="$(cat debug/example_runclist.txt)"
fi

[ "${VERBOSE}" -eq "1" ] && printVerbose "${RUNCLIST}"
FOUND=0
for ID in $(echo "${RUNCLIST}" | awk 'NF > 3 && $3 != "stopped" && $3 != "STATUS" {print $1}' -); do
  [ "${VERBOSE}" -eq "1" ] && printVerbose "${RUNC} state ${ID}"
  
  if [ "${DEBUG}" -eq "0" ]; then
    RUNCSTATE="$(${RUNC} state ${ID})"
  else
    RUNCSTATE="$(cat debug/example_runcstate.txt)"
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
      if [ "${OUTPUTTYPE}" -eq "0" ]; then
        printf "${PID}"
      elif [ "${OUTPUTTYPE}" -eq "1" ]; then
        printf "${ROOTFS}"
      elif [ "${OUTPUTTYPE}" -eq "2" ]; then
        printf "${STDOUTERR}"
      fi
      FOUND="$(((${FOUND}+1)))"
    fi
  done
done

if [ "${FOUND}" -gt 0 ]; then
  printf "\n"
fi

[ "${VERBOSE}" -eq "1" ] && printVerbose "Finished"
