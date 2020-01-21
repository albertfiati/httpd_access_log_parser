declare -A my_arr

A='192.168.10.20'
B=$"${A//[.]/}"

my_arr[$B]=19090