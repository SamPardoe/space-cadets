#!/bin/bash

#Find the start index of the nth word in a given string
finder () { 
	local n=$1
	local string=$2
	local counter=1
	local indexhold=0
	while [[ $indexhold -lt ${#string} ]]
	do
		if [[ ${string:$indexhold:1} == " " ]] && [[ $counter -eq $n ]]
		then
			break
		elif [[ ${string:$indexhold:1} == " " ]]
		then
			((counter+=1))
			((indexhold+=1))
		else
			((indexhold+=1))
		fi
		
	done
	echo $indexhold
}

brokenTF=false
i=0

#declare arrays 
declare -A valArray
declare -a whileArrVars whileArrVals whileArrStarts
IFS=$'\r\n' GLOBIGNORE='*' command eval array='($(cat ./barebones.txt | sed "s/ */ /" | sed "s/\t*//g"))'

#checking and executing commands
while ! $brokenTF
do
	currentInstr="${array[$i]}"
	#check syntax
	if [[ ! $currentInstr =~ ";" ]]
	then
		if [[ $currentInstr =~ "e" ]] || [[ $currentInstr =~ 'r' ]]
		then
			echo "error, missing ; in line $i"
			brokenTF=true
			((i+=1))
		else
			echo "end of file"
			brokenTF=true
		fi
	#check if end
	elif [[ $currentInstr =~ "end" ]]
	then
		if [[ ${#whileArrVals[@]} == 0 ]]
		then
			echo "exited while loop"
			((i+=1))
		else
			if [[ "${valArray[${whileArrVars[$((${#whileArrVars[@]}-1))]}]}" == 0 ]]
			then
				unset whileArrVars[$((${#whileArrVars[@]}-1))]
				unset whileArrVals[$((${#whileArrVals[@]}-1))]
				unset whileArrStarts[$((${#whileArrStarts[@]}-1))]
				((i+=1))
				echo "ending while loop"
			else
				i=${whileArrStarts[-1]}
				echo "i is $i"
			fi
		fi
	#check if clear
	elif [[ $currentInstr =~ "clear" ]]
	then
		clearVar=${currentInstr:7:$((${#currentInstr}-8))}
		if [[ ! -n "${valArray[$clearVar]}" ]]
		then
			valArray["$clearVar"]="0"
			echo "defined variable $clearVar as 0"
		else
			valArray[$clearVar]=0
			echo "reset variable $clearVar to 0"
		fi
		((i+=1))
	#check if incr
	elif [[ $currentInstr =~ "incr" ]]
	then
		incVar=${currentInstr:6:$((${#currentInstr}-7))}
		if [[ ! -n "${valArray[$incVar]}" ]]
		then
			echo "variable $incVar not defined"
			brokenTF=true
		else
			((valArray[$incVar]+=1))
			echo "$incVar incremented to ${valArray[$incVar]}"
			((i+=1))
		fi
	#check if decr
	elif [[ $currentInstr =~ "decr" ]]
	then
		decVar=${currentInstr:6:$((${#currentInstr}-7))}
		if [[ ! -n "${valArray[$decVar]}" ]]
		then
			echo "variable $decVar not defined"
			brokenTF=true
		elif [[ "$valArray[$decVar]" == 0 ]]
		then
			echo "variable $decVar already at 0, cannot be decremented further"
			brokenTF=true
		else
			((valArray[$decVar]-=1))
			echo "$decVar decremented to ${valArray[$decVar]}"
			((i+=1))
		fi
	#check if while loop
	elif [[ $currentInstr =~ "while" ]]
	then
		((i+=1))
		echo beginning while loop
		#getting condition variables
		varEnd=$(finder "2" "$currentInstr")
		valStart=$(finder "4" "$currentInstr")
		valEnd=$(finder "5" "$currentInstr")

		conditionVar=${currentInstr:7:$(($varEnd-5))}
		conditionVal=${currentInstr:$valStart:$(($valEnd-12))}
		conditionCondition=${currentInstr:$varEnd:$(($valStart-3))}
		
		whileArrVars+=("$conditionVar")
		whileArrVals+=("$conditionVal")
		whileArrStarts+=("$i")
	else
		echo 'error unrecognised command'
		echo $currentInstr $i
		brokenTF=true

	fi
	if [[ $i -eq ${#array[@]} ]]
	then
		brokenTF=true
	fi
done
for key in ${!valArray[@]}
do
	echo "${key} : ${valArray[${key}]}"
done
