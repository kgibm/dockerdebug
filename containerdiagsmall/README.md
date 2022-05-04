# containerdiagsmall

Examples:

* WebSphere Liberty:
    * Execute `linperf.sh`, gather Liberty logs and javacores, and remove the javacores. Replace `$POD` with the pod name:
      ```
      oc debug node/worker0.swatocp.cp.fyre.ibm.com -t --image=quay.io/kgibm/containerdiagsmall -- run.sh sh -c 'linperf.sh -q -s 60 $(podinfo.sh -p $POD) && podfscp.sh -s -p $POD /logs /config /output/javacore* && podfsrm.sh -p $POD /output/javacore*'
      ```
