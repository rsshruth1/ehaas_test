#!/bin/bash

# Check for the number of components that are failing and passing
var1=`grep -o '\bOK\b' /tmp/preflight/preflight_output.txt | wc -l`
var2=`grep -o '\bFail\b' /tmp/preflight/preflight_output.txt | wc -l`

echo "Total number of components verified = " $(($var1 + $var2))
#echo $(($var1 + $var2))

echo "Number of components successful =" $var1
var3=`grep "OK" output.txt | sed 's/.... OK/,/' `
#echo `grep "OK" output.txt | sed 's/.... OK/,\\n/'`

echo $var3

echo "Number of components Failing =" $var2
var4=`grep "Fail" output.txt | sed 's/.... Fail/ , /' `
echo $var4

echo "=========================================="
total=`expr $var1 + $var2`
per=100
var2=`expr $var1 \* $per`
echo "Success percent = " $(($var2 / $total  )) "%"
echo "=========================================="
per=`expr $var2 / $total`
if [ "$per" = "100" ]
then
        echo "VERIFICATION SCRIPTS COMPLETED SUCCESSFULLY !!!"
else
        echo "VERIFICATION SCRIPTS FAILED "
fi

