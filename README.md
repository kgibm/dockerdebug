# dockerdebug

* [WebSphere Application Server Troubleshooting and Performance Lab on Docker](https://github.com/kgibm/dockerdebug/tree/master/fedorawasdebug)

## Development

### Rebuilding the WebSphere Application Server Troubleshooting and Performance Lab on Docker

1. Prepare:
    1. macOS: Install the following and then open a new terminal window.
    ```
    brew install pandoc
    brew install --cask mactex
    ```
1. `docker system prune -a`
1. `cd fedoradebug`
1. `! test -e remotepassword.txt && printf "websphere" > remotepassword.txt`
1. `docker build --secret id=remotepassword,src=remotepassword.txt -t kgibm/fedoradebug .`
1. `cd ../fedorajavadebug`
1. `! test -e remotepassword.txt && printf "websphere" > remotepassword.txt`
1. `docker build --secret id=remotepassword,src=remotepassword.txt -t kgibm/fedorajavadebug .`
1. `cd ../fedorawasdebug`
1. `! test -e remotepassword.txt && printf "websphere" > remotepassword.txt`
1. Update version number and date, and revision history in `WAS_Troubleshooting_Perf_Lab.md`
1. Generate lab PDF:
   ```
   sed 's/<img src="\(.*\)" width.*\/>/![](\1)/g' WAS_Troubleshooting_Perf_Lab.md > WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   pandoc --pdf-engine=xelatex -V geometry:margin=1in -s -o WAS_Troubleshooting_Perf_Lab.pdf --metadata title="WebSphere Application Server Troubleshooting and Performance Lab on Docker" WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   rm WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   ```
1. `git` add, commit, and push the `WAS_Troubleshooting_Perf_Lab.*` files.
1. `docker pull websphere-liberty`
1. `docker pull ibmcom/websphere-traditional`
1. `docker pull ibmcom/ibm-http-server`
1. If needed, update Liberty build in `MAVEN_LIBERTY_VERSION` in `fedorawasdebug/Dockerfile`
1. `docker build --secret id=remotepassword,src=remotepassword.txt -t kgibm/fedorawasdebug .`
1. Run and test the image.
1. `docker build --secret id=remotepassword,src=remotepassword.txt -t kgibm/fedorawasdebugejb -f Dockerfile.ejb .`
1. `git commit -am "VXX: New version with ..."`
1. `git push`
1. `docker login`
1. `docker images`
1. For each of the above images: `docker tag $IMAGEID $NAME:VXX` (Example `$NAME`=`kgibm/fedoradebug`)
1. Push all the VXX images: `docker push kgibm/fedoradebug:VXX && docker push kgibm/fedorajavadebug:VXX && docker push kgibm/fedorawasdebug:VXX && docker push kgibm/fedorawasdebugejb:VXX`
1. After all VXX versions are pushed, push the latest tags: `docker push kgibm/fedoradebug:latest && docker push kgibm/fedorajavadebug:latest && docker push kgibm/fedorawasdebug:latest && docker push kgibm/fedorawasdebugejb:latest`
1. `git tag VXX`
1. `git push --tags`
1. Delete old images from:
    1. <https://hub.docker.com/repository/docker/kgibm/fedoradebug/tags?page=1&ordering=last_updated>
    1. <https://hub.docker.com/repository/docker/kgibm/fedorajavadebug/tags?page=1&ordering=last_updated>
    1. <https://hub.docker.com/repository/docker/kgibm/fedorawasdebug/tags?page=1&ordering=last_updated>
    1. <https://hub.docker.com/repository/docker/kgibm/fedorawasdebugejb/tags?page=1&ordering=last_updated>
