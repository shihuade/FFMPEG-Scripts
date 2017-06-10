#!/bin/bash


runUsage()
{
echo "**********************************************"
echo "**********************************************"


}


runInit()
{

    OutputFile=""


}


runCheck()
{
    if [ ! -e ${InputCSVFile} ]
    then
        echo "  InputCSVFile ${InputCSVFile} does not exist, please double check!"
        exit 1
    fi


}


runFilter()
{
    let "HeaderNum = 2"
    let "LineNum =0"
    FilterPattern="$OptionVal"
    CSVFileName=`echo $InputCSVFile | awk 'BEGIN {FS="."} {print $1}'`
    OutputFile="${CSVFileName}_${FilterPattern}.csv"

    echo "**********************************************"
    echo "  InputCSVFile  is: ${InputCSVFile}"
    echo "  FilterPattern is: ${FilterPattern}"
    echo "  OutputFile    is: ${OutputFile}"
    echo "**********************************************"

    while read line
    do
        [ ${LineNum} -eq 0 ] && echo "$line" >${OutputFile} && let "LineNum ++" && continue
        [ ${LineNum} -lt ${HeaderNum} ] && echo "$line" >>${OutputFile} && let "LineNum ++" && continue

        [[ "${line}" =~ "${FilterPattern}" ]] && echo "$line" >>${OutputFile}

        let "LineNum ++"
    done <${InputCSVFile}

    if [  ${LineNum} -le ${HeaderNum} ]
    then
        echo "**********************************************"
        echo " no data matched ${FilterPattern}"
        echo "**********************************************"

    fi
}

runCombineTwoCSVs()
{
    InputSCVFile01=${InputCSVFile}
    InputSCVFile02=${OptionVal}
    OutputFile="StaticCombine2CSVfiles.csv"

    Data01=""
    Data02=""
    DataName=""
    let "HeaderNum = 1"
    let "LineNum01 = 0"
    let "LineNum02 = 0"

    while read line01
    do
        if [ ${LineNum01} -eq 0 ]
        then
            echo "$line01,$InputSCVFile02" >${OutputFile}
        elif [ ${LineNum01} -lt ${HeaderNum} ]
        then
            echo "$line, $InputSCVFile02" >>${OutputFile}
            let "LineNum01 ++"
        else
            DataName=`echo $line01 | awk 'BEGIN {FS=","} {print $1}'`
            Data01=`echo $line01   | awk 'BEGIN {FS=","} {print $2}'`

            let "LineNum02 = 0"
            while read line02
            do
                if [ ${LineNum02} -eq ${LineNum01} ]
                then
                    Data02=`echo $line02 | awk 'BEGIN {FS=","} {print $2}'`
                    break
                fi

                let "LineNum02 ++"

            done <${InputSCVFile02}
        fi

        echo "$DataName, $Data01, $Data02" >>${OutputFile}
        let "LineNum01 ++"

    done <${InputSCVFile01}
}


runMain()
{

runInit
runCheck
#runFilter
runCombineTwoCSVs

}


#***************************
if [ $# -lt 3 ]
then
    runUsage
    exit 1
fi

InputCSVFile=$1
Option=$2
OptionVal=$3

runMain

