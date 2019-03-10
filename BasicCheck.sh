#!/bin/bash
folder=$1
program=$2
cd $folder
make &> /dev/null
goodmake=$?
if [ "$goodmake" -ne "0" ] ; then
        echo -e "\n\t\tCompilation: \tMemory leak: \t Race check: \n"
        echo -e "\t\t$(tput setaf 7)Pass/$(tput setaf 1)Fail\t $(tput setaf 7)Pass/$(tput setaf 1)Fail\t  $(tput setaf 7)Pass/$(tput setaf 1)Fail\n"
        exit 7
fi
valgrind --tool=memcheck ${@:3}  --leak-check=full --error-exitcode=1 -q  ./$program &> /dev/null
memcheck=$?
valgrind --tool=helgrind -q --error-exitcode=1 ./$program &> /dev/null
racecheck=$?
final=$goodmake$memcheck$racecheck
cd - &> /dev/null
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
