#!/usr/bin/awk -f
# usage: ps -elf | grep debug-node | debugpodinfo.awk [-v "fssearch=value"]
{
  for (i = 0; i < NF-1; i++) {
    if ($i == "--persist-dir") {
      persistdir = $(i+1);
      cmd = "cat /host/" persistdir "/state.json | jq -r '.annotations.\"io.kubernetes.cri-o.MountPoint\", .annotations.\"io.kubernetes.pod.name\", .annotations.\"io.kubernetes.pod.namespace\"'";
      found = 0;
      cmd | getline result;
      
      if (system("test -f /host/" result "/" fssearch) == 0) {
        while ((cmd | getline result) > 0) {
          print result;
        }
      }

      close(cmd);
      break;
    }
  }
}
