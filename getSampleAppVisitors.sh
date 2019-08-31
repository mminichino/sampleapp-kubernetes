#!/bin/sh
#
HOST=127.0.0.1
PORT=80
GETVC=0

which jq > /dev/null 2>&1
if [ "$?" -ne 0 ]
then
   echo "jq utility is required.  Please install jq or add it to your PATH."
   exit 1
fi

while getopts "h:p:c" opt
do
  case $opt in
    h)
      HOST=$OPTARG
      ;;
    p)
      PORT=$OPTARG
      ;;
    c)
      GETVC=1
      ;;
    \?)
      echo "Usage: $0 -h host [ -p port -c ]"
      exit 1
      ;;
  esac
done

if [ $GETVC -eq 1 ]
then
   COUNT=$(wget -q http://${HOST}:${PORT}/v1/visitors/count -O - | jq .result)
   if [ ! $COUNT -eq $COUNT ]
   then
      echo "Output not properly formatted. Check the host and port and try again."
      exit 1
   fi
echo "Visitor Count: $COUNT"
exit 0
fi

TEMPFILE=$(mktemp 2>/dev/null)

if [ -z "$TEMPFILE" ]
then
   echo "Something went wrong - can not create temp file with mktemp."
   exit 1
fi

wget -q http://${HOST}:${PORT}/v1/visitors/list -O - > $TEMPFILE

if [ "$?" -ne 0 ]
then
   echo "Error: can not get visitor list from ${HOST}:${PORT}/v1/visitors/list"
   rm $TEMPFILE
   exit 1
fi

COUNT=$(cat $TEMPFILE | jq '.results | length')

if [ ! $COUNT -eq $COUNT ]
then
   echo "Output not properly formatted. Check the host and port and try again."
   rm $TEMPFILE
   exit 1
fi

for i in $(seq 1 $COUNT)
do
  i=$(($i-1))
  cat $TEMPFILE | jq -jr ".results[$i].id,\",\",.results[$i].visitornum,\",\",.results[$i].remoteip,\",\",.results[$i].browser,\",\",.results[$i].browserversion,\",\",.results[$i].devicetype,\",\",.results[$i].osname,\",\",.results[$i].kpodname,\",\",.results[$i].date,\"\\n\""
done

rm $TEMPFILE
exit 0
