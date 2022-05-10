# containerdiagsmall

## Examples

### WebSphere Liberty performance, hang, or high CPU issues

Execute [`linperf.sh`](https://www.ibm.com/support/pages/mustgather-performance-hang-or-high-cpu-issues-websphere-application-server-linux), gather Liberty logs and javacores, and delete the javacores.

Replace `$NODE` with the node name and `$POD` with the pod name:

```
oc debug node/$NODE -t --image=quay.io/kgibm/containerdiagsmall -- libertyperf.sh $POD
```

## Repository

<https://quay.io/repository/kgibm/containerdiagsmall>
