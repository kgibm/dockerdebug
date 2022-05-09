#!/usr/bin/awk -f
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
