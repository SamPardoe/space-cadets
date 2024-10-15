#!/bin/bash

#function to get value of variable from array
getFromArr () {
	local arr=$1
	local search=$2
	local count=0
	local found=false
	
	if [[ -n "${arr[$search]}" ]]
	then
		#count=${arr[$search]}
		echo ${arr[$search]}
	else
		:
	fi
	#echo $count
}

#function to break and reset to start while loops
whileHandler () {
	local vararr=$1
	local var=$2
	local arr=$3
	#local curI=$4

	#local tempHold=$(getFromArr "$vararr" "$var")
	
	#if [[ $tempHold -eq 0 ]]
	if [[ ! -n "${vararr[$var]}" ]]
	then
		echo "broken"
	else
		#echo ${arr[$curI]}
		#echo $curI
		echo "continued"
	fi
}

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
declare -a whileArrVars whileArrVals whileArrStarts #whileArrConditions
#IFS=$'\r\n' GLOBIGNORE='*' command eval array="($(cat ./barebones.txt | sed 's/^[ \t]*//'))"
#IFS=$'\r\n' GLOBIGNORE='*' command eval array='($(cat ./barebones.txt | tr -d "[[:blank:]]"))'
IFS=$'\r\n' GLOBIGNORE='*' command eval array='($(cat ./barebones.txt | sed "s/ */ /" | sed "s/\t*//g"))'
#IFS=$'\n' array=( $(xargs sed 's/^[ \t]*//' barebones.txt) )
#declare -a array="($(<barebones.txt))"

#checking and executing commands
while ! $brokenTF
do
	currentInstr="${array[$i]}"
	##echo $currentInstr
	#currentInstrW=${currentInstr//[[:blank:]]/} causes loss of spaces too - error in formatting
	#currentInstrW=$currentInstr# | sed -e 's,\\[trn],,g'
	#echo $currentInstrW
	#check syntax
	####if [[ ! $currentInstr =~ ";" ]]
	####then
	####	if [[ $currentInstr =~ "e" ]] || [[ $currentInstr =~ 'r' ]]
	####	then
	####		echo "error, missing ; in line $i"
	####		brokenTF=true
	####		((i+=1))
	####	else
	####		echo "end of file"
	####		brokenTF=true
	####	fi
	#check if end
	if [[ $currentInstr =~ "end" ]]
	then
		if [[ ${#whileArrVals[@]} == 0 ]]
		then
			echo "exited while loop"
			((i+=1))
		else
			#whileHandled=$(whileHandler "$valArray" "${whileArrVars[0]}" "$array" "${whileArrStarts[0]}")
			#if [[ $whileHandled == "broken" ]]
			#if [[ ! -n "${valArray[${whileArrVars[0]}]}" ]]
			if [[ "${valArray[${whileArrVars[$((${#whileArrVars[@]}-1))]}]}" == 0 ]]
			then
				unset whileArrVars[$((${#whileArrVars[@]}-1))]
				unset whileArrVals[$((${#whileArrVals[@]}-1))]
				unset whileArrStarts[$((${#whileArrStarts[@]}-1))]
				###whileArrVars=("${whileArrVars[@]:1}")
				###whileArrVals=("${whileArrVals[@]:1}")
				#whileArrConditions=("${whileArrConditions[@]:1}")
				###whileArrStarts=("${whileArrStarts[@]:1}")
				#throwing issues : try setting array params to custom for association and changing how call : whileArr[][@]:1	
				((i+=1))
				##echo $whileArrVars
				##echo dropped
				echo ending while loop
			#else
			#elif [[ $whileHandled == "continued" ]]
			#elif [[ -n "${valArray[${whileArrVars[0]}]}" ]]
			#then
			else
				#i=$whileHandled
				i=${whileArrStarts[-1]}
				echo i is $i
			fi
		fi
	#check if clear
	elif [[ $currentInstr =~ "clear" ]]
	then
		clearVar=${currentInstr:7:$((${#currentInstr}-8))}
		#searchVar=$(getFromArr "$valArray" "$clearVar")
		#if [[ $searchVar == 1000000000 ]]
		if [[ ! -n "${valArray[$clearVar]}" ]]
		then
			valArray["$clearVar"]="0"
			echo "defined variable $clearVar as 0"
			##for key in ${!valArray[@]}
			##do
			##	echo "${key}, ${valArray[${key}]}"
			##done
			##echo ${valArray[@]}
		else
			valArray[$clearVar]=0
			echo "reset variable $clearVar to 0"
		fi
		((i+=1))
	#check if incr
	elif [[ $currentInstr =~ "incr" ]]
	then
		incVar=${currentInstr:6:$((${#currentInstr}-7))}
		#searchVar=$(getFromArr "$valArray" "$incVar")
		#if [[ $searchVar == 1000000000 ]]
		if [[ ! -n "${valArray[$incVar]}" ]]
		then
			echo "variable $incVar not defined"
			brokenTF=true
		else
			((valArray[$incVar]+=1))
			echo $incVar incremented to ${valArray[$incVar]}
			((i+=1))
		fi
	#check if decr
	elif [[ $currentInstr =~ "decr" ]]
	then
		decVar=${currentInstr:6:$((${#currentInstr}-7))}
		#searchVar=$(getFromArr "$valArray" "$decVar")
		#if [[ $searchVar == 1000000000 ]]
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
			echo $decVar decremented to ${valArray[$decVar]}
			((i+=1))
		fi
	#check if while loop
	elif [[ $currentInstr =~ "while" ]]
	then
		((i+=1))
		echo beginning while loop
		#getting condition variables
		#varEnd=$currentInstr | position 3
		#"$currentInstr" | position 3 > varEnd
		#echo var end is $varEnd
		#echo $currentInstr | position 3
		#valStart="$($currentInstr | position 4)"
		#echo $valStart
		#valEnd="$($currentInstr | position 5)"
		#echo $valEnd
		##echo ${#currentInstr}
		varEnd=$(finder "2" "$currentInstr")
		valStart=$(finder "4" "$currentInstr")
		valEnd=$(finder "5" "$currentInstr")
		##echo $varEnd	
		##echo $valStart
		##echo $valEnd
		conditionVar=${currentInstr:7:$(($varEnd-5))}
		##echo test"$conditionVar"test
		conditionVal=${currentInstr:$valStart:$(($valEnd-12))}
		##echo $conditionVal
		conditionCondition=${currentInstr:$varEnd:$(($valStart-3))}
		##echo $conditionCondition
		##echo $i
		#updating whileArr
		#echo ${#whileArrVars[@]}
		#whileArrVars+="X"
		#echo $whileArrVars
		#whileArrVars[${#whileArrVars[@]}]=("$conditionVar")
		#whileArrVals[${#whileArrVals[@]}]=("$conditionVal")
		#whileArrConditions[${#whileArrConditions}]=('$conditionCondition')
		#whileArrStarts[${#whileArrStarts[@]}]=("$i")
		
		whileArrVars+=("$conditionVar")
		whileArrVals+=("$conditionVal")
		whileArrStarts+=("$i")
		##echo $whileArrVars $whileArrVals $whileArrStarts
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
##echo "${array[@]}"
#echo ${array[0]}
##echo ${whileArrVars[@]} ${whileArrVals[@]} ${whileArrStarts[@]}
for key in ${!valArray[@]}
do
	echo "${key} : ${valArray[${key}]}"
done
#echo $valArray
