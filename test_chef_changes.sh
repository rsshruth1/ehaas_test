#!/bin/bash

#####################################################################
# Start of testunit 1
# Make sure all the Order is placed around the same time
# We can check the logs for the number of times the order is made
#    and get its timestamp. If the timestamp for each entry of the
#    order placed is around the same time.
# Make sure that the last order is made before we start
#    waiting for the machines to boot up
#
# Way to use the script :
# sh test2.sh <cluster_number>
######################################################################

# Make sure we have all the inputs we want from the users
if [ "$#" -ne 1 ]
then
        echo " Please provide the cluster number and plan details as input "
        echo " Example : sh test2.sh 143 "
        exit 1
fi

log_file="chef_output.log"

# Uncomment this on the real env
#log_file=$RAILS_ROOT"/log/jobs/job-"$1"/chef-boot.log"

# Get the number of times the order is placed
var1=`grep 'Order is placed successfully' $log_file | wc -l`

# Get the entire line to find the time stamp of when it was ordered
var2=(`grep -i 'Order is placed successfully' $log_file `)

# Get the number of words in the line, to parse the timestamp
input=`grep 'Order is placed successfully' $log_file | head -n 1`
words=( $input )

# Find out if we are testing on BM or CCI
# If BM we should find this string in the log and word count should be greater than 0
check=`grep -i "SLProvisioner#check_provision_state" $log_file | wc -l`
if [ "$check" -ne 0 ]
then
        # Get the timestamp of the first occurance of function showing that we are waiting for servers to boot
        check_pro=(`grep -i "SLProvisioner#check_provision_state" $log_file | head -n 1`)
#       echo ${check_pro[0]}

        check_pro[0]=${check_pro[0]//]}
        check_pro[0]=${check_pro[0]//[}

        check_pro_date=${check_pro[0]%T*}
        check_pro_time=${check_pro[0]#*T}
else
        # Else it should be a CCI on which we are checking
        check_pro=(`grep -i "[SLProvisioner#create_cci_node] Provisioning instance" $log_file | head -n 1`)
#        echo ${check_pro[0]}
        check_pro[0]=${check_pro[0]//]}
        check_pro[0]=${check_pro[0]//[}

        check_pro_date=${check_pro[0]%T*}
        check_pro_time=${check_pro[0]#*T}
fi

j=0
        i=0
        while [ "$i" -ne "$var1" ]
        do
                ts[i]=${var2[$j]}
                j=`expr $j + ${#words[@]}`
                # Remove the special characters
                ts[i]=${ts[$i]//]}
                ts[i]=${ts[$i]//[}
                i=`expr $i + 1`

        done
        j=1
        loop1=`expr $var1 - 1`
        i=0

        while [ "$i" -ne "$var1" ]
        do
                time1=${ts[$j]#*T}
                date1=${ts[$j]%T*}
                time2=${ts[$i]#*T}
                date2=${ts[$j]%T*}
                secdiff=$(($(date -d "$date1 $time1" +%s) - $(date -d "$date2 $time2" +%s) ))
                echo $date1 $time1 "-" $date2 $time2 "=" $secdiff "seconds"
                j=`expr $j+1`
                i=`expr $i + 1`
                if [ "$i" = $loop1 ]
                then
                        # make sure that all the orders are made before we start waiting for servers to boot
                        time_diff=$(($(date -d "$check_pro_date $check_pro_time" +%s) - $(date -d "$date1 $time1" +%s) ))
                        if [ "$time_diff" -gt 0 ]
                        then
                                echo "All the orders were made before we start waiting for servers to boot as expected -- PASSED "
                        else
                                echo "All the orders were NOT made before we start waiting for servers to boot as expected -- FAILED "
                        fi
                i=`expr $i + 1 `
                fi
        done


###########################################################
# Testunit 1 Ends
###########################################################
