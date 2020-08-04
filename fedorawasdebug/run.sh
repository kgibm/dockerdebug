#!/bin/sh
set -e
(
  sleep 15

  case $OSTYPE in
    darwin*)
      open vnc://:websphere@localhost:5902 ;;
    *)
      vncviewer localhost:5902 ;;
  esac
) &
docker run --cap-add SYS_PTRACE --cap-add NET_ADMIN --ulimit core=-1 --ulimit memlock=-1 --ulimit stack=-1 --shm-size="256m" --rm -p 9080:9080 -p 9443:9443 -p 9043:9043 -p 9081:9081 -p 9444:9444 -p 5901:5901 -p 5902:5902 -p 3390:3389 -p 22:22 -p 9082:9082 -p 9083:9083 -p 9445:9445 -p 8080:8080 -p 8081:8081 -p 8082:8082 -p 12000:12000 -p 12005:12005 -v /:/host/ -it kgibm/fedorawasdebug
