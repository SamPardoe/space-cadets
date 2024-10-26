#!/bin/bash
usrname=${1}
svrname=${2}
svr=/tmp/chatsvr${svrname}.txt
IFS=$'\r\n' GLOBIGNORE='*' command eval clientArr='($(cat /tmp/${svrname}clients))'
usrpos=${#clientArr[@]}
echo "Your position is $usrpos"
#add user to the client list
echo $usrname >> /tmp/${svrname}clients
connected=1
latest=0
while [[ $connected -ne 0 ]]; do
  #read instr
  #if [[ $instr == "piss-off" ]]; then
  #  echo "Quitting server...asshole."
  #  (cat /tmp/${svrname}clients | sed "s/$usrname/disconnected/") > /tmp/${svrname}clients
  #  connected=0
  #  break
  #fi
  if [[ ! -f /tmp/${svrname}clients ]]; then
    continue
  fi
  #print to screen the values from server
  IFS=$'\r\n' GLOBIGNORE='*' command eval clientArr='($(cat /tmp/${svrname}clients))'
  #echo balls
  last=$latest
  latest=$(tail -n 1 $svr)
  from=${latest: -1}
  #echo $from , ${clientArr[$from]}
  (if [[ ! $latest == $last ]]; then
    (echo ${latest%?} | sed "s/^/${clientArr[$from]} @ $(date +%H:%M:%S) > /") &
    fi) &
  (read instr
  if [[ -z $instr ]]; then
    continue
  else
    if [[ $instr == "piss-off" ]]; then
      echo "Quitting server...asshole."
      (cat /tmp/${svrname}clients | sed "s/$usrname/disconnected/") > /tmp/${svrname}clients
      connected=0
      break 
    fi
    echo $instr$usrpos >> $svr
    fi) &
  done
