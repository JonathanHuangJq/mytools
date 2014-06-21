#!/bin/bash

usage(){
	echo "Usage: $0 vector_name [interval]"
	exit 1
}

[[ $# -eq 0 ]] && usage

if [ x$1 != x ]
then
	VECT=$1
else
	echo "***Error: Need a device vector name"
	usage
fi

if [ x$2 != x ]
then
	INTERVAL=$2
else
	INTERVAL=5
fi

cpu_num=`grep processor /proc/cpuinfo| wc -l`
irqlist=`grep $VECT /proc/interrupts | awk -F: '{print $1}'`

function get_vect_name {

	grep "$1:" /proc/interrupts | awk -F" " \
	    '{if (NF-'"$cpu_num"'>3){print $1$(NF-1)$NF}else{print $1$NF}}'
}

function dump_irq_smp_affinity {
	printf "\n"
	for irq in $irqlist
	do
		name=`get_vect_name $irq`
		value=`cat /proc/irq/$irq/smp_affinity`
		
		printf "%30s %40s\n" $name $value
	done;
}

echo "Current interval is $INTERVAL, use CTRL+C to quit..."

while (true)
do
	dump_irq_smp_affinity
	sleep $INTERVAL
done;
