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
1. Delete existing images:
   ```
   podman stop --all
   podman system prune --all --force
   podman rmi --all
   ```
1. `cd fedoradebug`
1. `podman build -t kgibm/fedoradebug .`
1. `cd ../fedorajavadebug`
1. `podman build -t kgibm/fedorajavadebug .`
1. `cd ../fedorawasdebug`
1. Remove any previous IHS zips
1. Download the latest "IBM HTTP Server archive file for 64-bit Linux, x86" from <https://www.ibm.com/support/pages/fix-list-ibm-http-server-version-90>
1. Update version number and date, and revision history in `WAS_Troubleshooting_Perf_Lab.md`
1. Generate lab PDF (yes, this is before building the final image):
   ```
   sed 's/<img src="\(.*\)" width.*\/>/![](\1)/g' WAS_Troubleshooting_Perf_Lab.md > WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   pandoc --pdf-engine=xelatex -V geometry:margin=1in -s -o WAS_Troubleshooting_Perf_Lab.pdf --metadata title="WebSphere Application Server Troubleshooting and Performance Lab on Docker" WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   rm WAS_Troubleshooting_Perf_Lab_imagesconverted.md
   ```
1. `git` add, commit, and push the `WAS_Troubleshooting_Perf_Lab.*` files.
1. `podman pull websphere-liberty`
1. `podman pull ibmcom/websphere-traditional`
1. If needed, update Liberty build in `MAVEN_LIBERTY_VERSION` in `fedorawasdebug/Dockerfile`
1. `podman build -t kgibm/fedorawasdebug .`
1. Run and test the image.
1. `podman build -t kgibm/fedorawasdebugejb -f Dockerfile.ejb .`
1. `git commit -am "VXX: New version with ..."`
1. `git push`
1. `podman login`
1. `podman images`
1. For each of the above images: `podman tag $IMAGEID $NAME:VXX` (Example `$NAME`=`kgibm/fedoradebug`)
1. Push all the VXX images: `podman push kgibm/fedoradebug:VXX && podman push kgibm/fedorajavadebug:VXX && podman push kgibm/fedorawasdebug:VXX && podman push kgibm/fedorawasdebugejb:VXX`
1. After all VXX versions are pushed, push the latest tags: `podman push kgibm/fedoradebug:latest && podman push kgibm/fedorajavadebug:latest && podman push kgibm/fedorawasdebug:latest && podman push kgibm/fedorawasdebugejb:latest`
1. `git tag VXX`
1. `git push --tags`
1. Delete old images from:
    1. <https://hub.docker.com/repository/docker/kgibm/fedoradebug/tags?page=1&ordering=last_updated>
    1. <https://hub.docker.com/repository/docker/kgibm/fedorajavadebug/tags?page=1&ordering=last_updated>
    1. <https://hub.docker.com/repository/docker/kgibm/fedorawasdebug/tags?page=1&ordering=last_updated>
    1. <https://hub.docker.com/repository/docker/kgibm/fedorawasdebugejb/tags?page=1&ordering=last_updated>
