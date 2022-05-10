# containerdiagsmall

This container image, available at [quay.io/kgibm/containerdiagsmall](https://quay.io/repository/kgibm/containerdiagsmall), helps perform diagnostics on running containers using [worker node debug pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#node-shell-session).

The main issue today in remoting into running containers and debugging them is that you are limited to the diagnostic tools baked into the container image (until [ephemeral debug containers](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container) become more widely available). A general best practice is to build images with minimal utilities, so administrators are often lacking even basic tools like `top -H` to investigate per-thread CPU utilization.

One option is to run a worker node debug pod using an image that has the diagnostic tools that you want. This `containerdiagsmall` image provides commonly used diagnostic tools and shell scripts that help perform key functions such as mapping a pod name to a worker node process ID to target diagnostic tools at it or getting its ephemeral filesystem to gather files from the container. For example, to get per-thread CPU usage for 10 seconds given a pod name and then gather the `/logs` directory:

`oc debug node/$NODE -t --image=quay.io/kgibm/containerdiagsmall -- run.sh sh -c 'top -b -H -d 2 -n 5 -p $(podinfo.sh -p $POD) > top.txt && podfscp.sh -s -p $POD /logs'`

Security note: using a worker node debug pod requires cluster administrator privileges and runs the debug pod as `root`.

## Examples

### WebSphere Liberty performance, hang, or high CPU issues

Execute [`linperf.sh`](https://www.ibm.com/support/pages/mustgather-performance-hang-or-high-cpu-issues-websphere-application-server-linux), gather Liberty logs and javacores, and delete the javacores.

Replace `$NODE` with the node name and `$POD` with the pod name:

```
oc debug node/$NODE -t --image=quay.io/kgibm/containerdiagsmall -- libertyperf.sh $POD
```
