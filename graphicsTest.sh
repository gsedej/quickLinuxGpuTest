#!/bin/bash

# by: Gašper Sedej
# GPL3 lincence
# ver 0.2, 2012-07-25


if [ $# -ne 1 ] ; then
	echo "Use folder as argument (e.g.: ./graphicsTest.sh gf-550)"
	exit
fi

sleepTime="1"


echo "Path: `pwd`/$1"
read -p "OK (y/n)?"

if [ "$REPLY" == "y" ]; then
	mkdir -p "$1"

	echo "----------"
	echo "Driver information:"
	echo "----------"
	echo "glxinfo:"
	
	glxfile="$1"/"glxinfo.out"
	glxinfo > $glxfile
	#echo "Direct rendering:"
	cat $glxfile | grep "direct rendering"
	cat $glxfile | grep -i "opengl"
	sleep $sleepTime
	
	echo "modinfo:"
	
	modFile="$1"/"modinfo.out"
	activeMod=`lsmod | grep -e "i810" -e "i915" -e "r128" -e "radeon" -e "savage" -e "sis" -e "nouveau" -e "poulsbo" -e "fglrx" -e "nvidia" | awk '{print $1}'`
	echo "Active kernel object: $activeMod"
	sleep $sleepTime
	
	if [ $activeMod == nvidia ] ; then
		modinfo "nvidia_current" > $modFile
	else
		modinfo $activeMod > $modFile
		
	fi
	cat $modFile | grep file
	
	
	
	
	echo "GPU:"
	#lspci | grep VGA
	lspci -nn > "$1"/"lspci.out"
	lspci | grep VGA | cut -f2- -d ' '
		
	echo "----------"
	echo "Graphical benchmarks:"
	echo "----------"
	gl2file="$1"/"glmark2.out"
	gl2esfile="$1"/"glmark2-es2.out"
	
	echo "glmark2 (opengl2)"
	sleep $sleepTime
	glmark2 > "$gl2file"
	cat "$gl2file" | grep "Score"
	
	#echo "glmark2-es2 (OpenGL ES2.0)"
	#sleep $sleepTime
	#glmark2-es2 > "$gl2esfile"
	#cat "$gl2esfile" | grep "Score"
	
	echo "----------"
	echo "Saving logs..."
	echo "----------"
	dmesg > "$1"/"dmesg.out"
	cat "/var/log/syslog" > "$1"/"syslog.out"
	cat "/var/log/Xorg.0.log" > "$1"/"Xorg.0.log.out"
fi

