#!/bin/bash
folder=$1
program=$2
cd $folder
make &> /dev/null
goodmake=$?
if [ "$goodmake" -ne "0" ] ; then
exit 7
fi
g++ ./$program ${@:3} &> /dev/null
goodcompile=$?
if [ "$goodcompile" -ne "0" ] ; then
        echo "Not compiled well"
        exit 7
fi
valgrind --tool=memcheck --leak-check=full --error-exitcode=1 -q  ./a.out &> /dev/null
memcheck=$?
valgrind --tool=helgrind -q ./a.out &> /dev/null
racecheck=$?
final=$goodcompile$memcheck$racecheck
if [ "$final" == "000" ] ; then
        echo -e "\n\t\tCompilation: \tMemory leak: \t Race check:\n"
        echo -e "\t\t $(tput setaf 2)Pass/$(tput setaf 7)Fail\t $(tput setaf 2)Pass/$(tput setaf 7)Fail\t  $(tput setaf 2)Pass/$(tput setaf 7)Fail\n"
        exit 0
elif [ "$final" == "010" ] ; then
        echo -e "\n\t\tCompilation: \tMemory leak: \t Race check: \n"
        echo -e "\t\t$(tput setaf 2)Pass/$(tput setaf 7)Fail\t $(tput setaf 7)Pass/$(tput setaf 1)Fail\t  $(tput setaf 2)Pass/$(tput setaf 7)Fail\n"
        exit 2
elif [ "$final" == "001" ] ; then
        echo -e "\n\t\tCompilation: \tMemory leak: \t Race check: \n"
        echo -e "\t\t$(tput setaf 2)Pass/$(tput setaf 7)Fail\t $(tput setaf 2)Pass/$(tput setaf 7)Fail\t  $(tput setaf 7)Pass/$(tput setaf 1)Fail\n"
        exit 1
elif [ "$final" == "011" ] ; then
        echo -e "\n\t\tCompilation: \tMemory leak: \t Race check: \n"
        echo -e "\t\t$(tput setaf 2)Pass/$(tput setaf 7)Fail\t $(tput setaf 7)Pass/$(tput setaf 1)Fail\t  $(tput setaf 7)Pass/$(tput setaf 1)Fail\n"
        exit 3
else
        echo -e "\nCode Is Wrong!"
        exit 8
fi