# dockerdebug

* [WebSphere Application Server Troubleshooting and Performance Lab on Docker](https://github.com/kgibm/dockerdebug/tree/master/fedorawasdebug)

## Development

### Rebuilding the WebSphere Application Server Troubleshooting and Performance Lab on Docker

1. `docker system prune -a`
1. `cd fedoradebug`
1. `! test -e remotepassword.txt && printf "websphere" > remotepassword.txt`
1. `DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt --progress=plain -t kgibm/fedoradebug .`
1. `cd fedorajavadebug`
1. `! test -e remotepassword.txt && printf "websphere" > remotepassword.txt`
1. `DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt --progress=plain -t kgibm/fedorajavadebug .`
1. `cd fedorawasdebug`
1. `! test -e remotepassword.txt && printf "websphere" > remotepassword.txt`
1. `DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt --progress=plain -t kgibm/fedorawasdebug .`
1. `DOCKER_BUILDKIT=1 docker build --secret id=remotepassword,src=remotepassword.txt --progress=plain -t kgibm/fedorawasdebugejb -f Dockerfile.ejb .`
1. Run and test the image.
1. `git commit -am "VXX: New version with ..."`
1. `git push`
1. `docker login`
1. `docker images`
1. For each of the above images:
    1. `docker tag $IMAGEID $NAME:VXX` (Example `$NAME`=`kgibm/fedoradebug`)
    1. `docker push $NAME:VXX`
1. After all VXX versions are pushed, push the latest tags:
    1. `docker push $NAME:latest`
1. `git tag VXX`
1. `git push --tags`
