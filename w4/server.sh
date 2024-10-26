#!/bin/bash
#Get server name & initialise server & client list
svrname=${1}
svr=/tmp/chatsvr${svrname}.txt
if [[ -f $svr ]]; then
  rm $svr
fi
touch $svr
if [[ -f /tmp/${svrname}clients ]]; then
  rm /tmp/${svrname}clients
fi
#print messages
running=1
latest=0
while [[ $running -ne 0 ]]; do
  if [[ ! -f /tmp/${svrname}clients ]]; then
    continue
  fi
  IFS=$'\r\n' GLOBIGNORE='*' command eval clientArr='($(cat /tmp/${svrname}clients))' #update client list
  #only print if there is a new message
  last=$latest
  latest=$( tail -n 1 $svr)
  from=${latest: -1}
  if [[ ! $latest == $last ]]; then
    (echo ${latest%?} | sed "s/^/${clientArr[$from]} @ $(date +%H:%M:%S) > /")
  fi
done
