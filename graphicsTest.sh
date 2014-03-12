#!/bin/bash

# by: Gašper Sedej
# GPL-v3 lincence
# ver 0.4, 2012-07-31


if [ $# -ne 1 ] ; then
	echo "Use folder as argument (e.g.: ./graphicsTest.sh gf-550)"
	exit
fi

sleepTime="1"
useGlmark2="n"
useGlmark2es="n"
rootFolder="/tmp/graphicsTest/$1"
saveFolder="`pwd`/$1"



#echo "Path: `pwd`/$1"
echo "Working path: $rootFolder"

# check if folder exists
if [ -d $rootFolder ]; then
	read -p "Folder already exists. Continue (y/n)?"
	if [ "$REPLY" != "y" ]; then
		"Exiting..."
	fi
fi


	
mkdir -p "$rootFolder"


echo -e "\n"
echo "----------"
echo "GPU:"
echo "----------"
#lspci | grep VGA
lspci -nn > "$rootFolder"/"lspci.out"
lspci | grep VGA | cut -f5- -d ' '
#info about all graphics cards
for I in `lspci |awk '/VGA/{print $1}'`;do lspci -v -s $I;done > "$rootFolder"/"lspci-gpu.out"
echo "GPU memory:"
for I in `lspci |awk '/VGA/{print $1}'`;do lspci -v -s $I | sed -n '/Memory.*, prefetchable/s/.*\[size=\([^]]\+\)\]/\1/p';done
sleep $sleepTime


echo -e "\n"
echo "----------"
echo "modinfo:"
echo "----------"
modFile="$rootFolder"/"modinfo.out"

for I in `lspci |awk '/VGA/{print $1}'`;do lspci -v -s $I | grep -i "kernel driver" | awk '{print $NF}';done > /tmp/activeMod
activeMod=`cat /tmp/activeMod`
echo "Active kernel object: $activeMod"

# nvidia has different mod name, at least on ubuntu
if [ $activeMod == nvidia ] ; then
	# ne morem ugotoviti kateri obstaja. skrijem error
	modinfo "nvidia_current" "nvidia_current_updates" 2>&1 | grep -v "ERROR: modinfo:" | > $modFile
	# nvidia-smi
else
	modinfo $activeMod > $modFile	
fi
echo "Modinfo:"
cat $modFile | grep file
sleep $sleepTime


echo -e "\n"
echo "----------"
echo "OpenGL information:"
echo "----------"

glxin=`which glxinfo`
if [ -n $glxin ]; then
	glxfile="$rootFolder"/"glxinfo.out"
	glxinfo > $glxfile
	#echo "Direct rendering:"
	cat $glxfile | grep "direct rendering"
	# `cat $glxfile | grep "direct rendering"| awk '{print $3}'`
	cat $glxfile | grep -i "opengl"
	sleep $sleepTime
else
	echo "glxinfo not installed" 
fi
sleep $sleepTime


echo -e "\n"
echo "----------"
echo "Graphical benchmarks:"
echo "----------"

if [ $useGlmark2 == "y" ]; then
	echo "Benchmarking glmark2"
	
	# najprej preveri ce obstaja program
	glm2=`which glmark2`
	if [ -n $glm2 ]; then
		gl2file="$rootFolder"/"glmark2.out"
		echo "glmark2 (opengl2)"
		sleep $sleepTime
		glmark2 > "$gl2file"
		cat "$gl2file" | grep "Score"
	else
		echo "glmark2 not found"
	fi

else
	echo "Skipping glmark2..."
fi


if [ $useGlmark2es == "y" ]; then
	echo "Benchmarking glmark2-es"
	if [ -n $glm2 ]; then
		gl2esfile="$rootFolder"/"glmark2-es2.out"
		echo "glmark2-es2 (OpenGL ES2.0)"
		sleep $sleepTime
		glmark2-es2 > "$gl2esfile"
		cat "$gl2esfile" | grep "Score"
	else
		echo "glmark2-es not found"
	fi
else
	echo "Skipping glmark2-es..."
fi

sleep $sleepTime
echo -e "\n"
echo "----------"
echo "Saving logs..."
echo "----------"
dmesg > "$rootFolder"/"dmesg.out"
cat "/var/log/syslog" > "$rootFolder"/"syslog.out"
cat "/var/log/Xorg.0.log" > "$rootFolder"/"Xorg.0.log.out"

echo "Test ended!"

read -p "Save results to $saveFolder/? (y/n)"
if [ "$REPLY" == "y" ]; then
	if [ -d $saveFolder ]; then
		read -p "Directory exists. Overwrite? (y/n)"
		if [ "$REPLY" != "y" ]; then
			echo "Exiting without saving"
			exit
		fi
		
	fi
	echo "saving results... "
fi


