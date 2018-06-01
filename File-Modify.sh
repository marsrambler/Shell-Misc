#!/bin/sh
#
# Name: 	editFile.sh
# Description:	run this script to change "Param1" and/or "Param2" value in File.xml for dev test
# Usage:	editFile.sh -s [ sid ] 
#                          -f [ Param1 ]
#                          -p [ Param2 ]
#

# Files for Param1 change

File_A=(
           "200--001" "200--002" "200--003" "200--004"
           )

# Files for Param2 change

File_B=(
           )   

DEST_DIR=
POSTFIX=-File.xml

function usage()
{
  echo ""
  echo "USAGE: editFile.sh -s [ sid, e.g. 200--001 ]"
  echo "                  -f [ Param1, e.g. 10 ]"
  echo "                  -p [ Param2, e.g. 5 ]"
  echo ""
  exit
}

function get_cmd_args ()
{
  while getopts s:f:p: OPT ; do

    case $OPT in

      s )     TARGET_File=$OPTARG ;;
      f )     MAX_PARAM_1=$OPTARG ;;
      p )     MAX_PARAM_2=$OPTARG ;;
      * )     usage ;;
    esac

  done
}

function check_usage () 
{
  [[ -z "$TARGET_File" ]] && usage {}
  [[ -z "$MAX_PARAM_1" && -z "$MAX_PARAM_2" ]] && usage {}
}

function array_contain ()
{
  local array="$1[@]"
  local seeking=$2
  local in=0
  for element in "${!array}"; do
    if [[ $element == $seeking ]]; then
      in=1;
      break;
    fi
  done
  echo $in
}

function check_file () 
{
  local target_file=$1
  if [[ ! -f $target_file ]]; then
    echo ""
    echo "ERROR: $target_file does not exist. The runtime enviroment may be wrong"
    echo ""
    exit
  fi
}

##
#

get_cmd_args $*
check_usage  {}

fd_a=`array_contain File_A $TARGET_File`
fd_b=`array_contain File_B $TARGET_File`

if [[ $fd_a == "0" && $fd_b == "0" ]]; then
  echo ""
  echo "ERROR: not implement this functionality for $TARGET_File"
  echo ""
  exit
fi

if [[ $fd_a == "0" && -n "$MAX_PARAM_1" ]]; then
  echo ""
  echo "Waring: can not change Param1 for $TARGET_File, ignore -f"
  echo ""
  #exit
fi

if [[ $fd_b == "0" && -n "$MAX_PARAM_2" ]]; then
  echo ""
  echo "Warning: can not change Param2 for $TARGET_File, ignore -p"
  echo ""
  #exit
fi


DEST_FILE=$DEST_DIR$TARGET_File$POSTFIX

check_file $DEST_FILE

CURDIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
opsDate=`date '+%Y-%m-%d-%H-%M-%S'`

cp $DEST_FILE $CURDIR/$TARGET_File$POSTFIX-$opsDate


Changed="no"

if [[ $fd_a == "1" && -n "$MAX_PARAM_1" ]]; then
  
  tag_orig=`cat $DEST_FILE | grep Param1`
  
  sed -i "s/<Param1>.*<\/Param1>/<Param1>$MAX_PARAM_1<\/Param1>/g" $DEST_FILE
  
  tag_new=`cat $DEST_FILE | grep Param1`

  echo ""
  echo "$TARGET_File$POSTFIX modification:"
  echo "changed from" 
  echo "              $tag_orig"
  echo "to"
  echo "              $tag_new"
  echo ""

  Changed="yes"
fi

if [[ $fd_b == "1" && -n "$MAX_PARAM_2" ]]; then
  
  tag_orig=`cat $DEST_FILE | grep Param2`
  
  sed -i "s/<Param2>.*<\/Param2>/<Param2>$MAX_PARAM_2<\/Param2>/g" $DEST_FILE
  
  tag_new=`cat $DEST_FILE | grep Param2`

  echo ""
  echo "$TARGET_File$POSTFIX modification:"
  echo "changed from" 
  echo "              $tag_orig"
  echo "to"
  echo "              $tag_new"
  echo ""

  Changed="yes"
fi

if [[ $Changed == "no" ]]; then
  rm -rf $CURDIR/$TARGET_File$POSTFIX-$opsDate
  echo ""
  echo "operation was ignored"
  echo ""
  exit 
fi

echo ""
echo "$TARGET_File$POSTFIX has been backup as $TARGET_File$POSTFIX-$opsDate"
echo "You may need to restore it in future"

sed -i '1,5d' $DEST_FILE
sed -i '$d' $DEST_FILE
sed -i '$d' $DEST_FILE

java -jar $CURDIR/devSigner.jar $DEST_FILE $DEST_FILE

echo ""
echo "$TARGET_File$POSTFIX has been re-signed"
echo ""
echo "You need to mannualy restart tomcat to take effect"
echo ""
