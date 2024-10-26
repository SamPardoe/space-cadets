#!/bin/bash
svrname=${1}
svr=/tmp/chatsvr${svrname}.txt
#[ -p $svr ] || touch $svr
if [[ -f $svr ]]; then
  rm $svr
fi
touch $svr
if [[ -f /tmp/${svrname}clients ]]; then
  rm /tmp/${svrname}clients
fi
#write: use -1 index? need to write to all clients
#get clients
#everything in whilerunning loop
running=1
latest=0
while [[ $running -ne 0 ]]; do
  if [[ ! -f /tmp/${svrname}clients ]]; then
    continue
  fi
  IFS=$'\r\n' GLOBIGNORE='*' command eval clientArr='($(cat /tmp/${svrname}clients))'
  last=$latest
  latest=$( tail -n 1 $svr)
  from=${latest: -1}
  if [[ ! $latest == $last ]]; then
    (echo ${latest%?} | sed "s/^/${clientArr[$from]} @ $(date +%H:%M:%S) > /")
  fi
  #(echo "Connected clients: ${clients[@]}" ; cat) >> $svr
  #if [[ ${#clientArr[@]} ]]; then
  #  echo "No users present in the server, shutting down."
  #  running=0
  #fi
done
#rm /tmp/chatsvr${svrname}.txt
