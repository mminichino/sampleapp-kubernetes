#!/bin/sh
#
HOST=127.0.0.1
PORT=80
GETVC=0
LOGIN=0
QUIET=0

which jq > /dev/null 2>&1
if [ "$?" -ne 0 ]
then
   echo "jq utility is required.  Please install jq or add it to your PATH."
   exit 1
fi

while getopts "h:p:t:clq" opt
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
    l)
      LOGIN=1
      ;;
    q)
      QUIET=1
      ;;
    t)
      TOKEN=$OPTARG
      ;;
    \?)
      echo "Usage: $0 -l [ -h host -p port ] | $0 [ -h host -p port -t token -c ]"
      exit 1
      ;;
  esac
done

if [ "$LOGIN" -eq 1 ]
then
   if [ ! -d ${HOME}/.demo ]
   then
      mkdir -p ${HOME}/.demo
      if [ $? -ne 0 ]
      then
         echo "Can not create config directory ${HOME}/.demo"
         exit 1
      fi
   fi
   echo -n "Username: "
   read USERNAME
   echo -n "Password: "
   read -s PASSWORD
   echo
   TOKEN=$(curl -s -d "username=${USERNAME}&password=${PASSWORD}" -X POST http://${HOST}:${PORT}/v1/authorize | jq .token | sed -e 's/\"//g')

   if [ -z "$TOKEN" -o "$TOKEN" = "null" ]
   then
      echo "Login unsuccessful.  Please try again."
      exit 1
   fi

   echo "Login successful."
   echo "${HOST}:${PORT}:${TOKEN}" > ${HOME}/.demo/demo.token
   echo "Exported token.  Please rerun to query data."

   exit
fi

if [ -f ${HOME}/.demo/demo.token ]
then
   [ "$QUIET" -eq 0 ] && echo "Reading cached credentials from ${HOME}/.demo/demo.token"
   HOST=$(cat ${HOME}/.demo/demo.token | cut -d: -f1)
   PORT=$(cat ${HOME}/.demo/demo.token | cut -d: -f2)
   TOKEN=$(cat ${HOME}/.demo/demo.token | cut -d: -f3)

   if [ -z "$HOST" -o -z "$PORT" -o -z "$TOKEN" ]
   then
      echo "Can not read configuration from ${HOME}/.demo/demo.token"
      exit 1
   fi
fi

if [ -z "$TOKEN" ]
then
   echo "Authorization token not supplied.  Please login (-l) or supply a valid token (-t)."
   exit 1
fi

TEMPFILE=$(mktemp 2>/dev/null)

if [ -z "$TEMPFILE" ]
then
   echo "Something went wrong - can not create temp file with mktemp."
   exit 1
fi

if [ $GETVC -eq 1 ]
then
   curl -s -d "token=${TOKEN}" -X POST http://${HOST}:${PORT}/v1/visitors/count > $TEMPFILE
   if [ "$?" -ne 0 ]
   then
      echo "Error: can not get visitor count from ${HOST}:${PORT}"
      rm $TEMPFILE
      exit 1
   fi

   COUNT=$(cat $TEMPFILE | jq .result)

   if [ "$COUNT" = "null" ]
   then
      ERROR_STATUS=$(cat $TEMPFILE | jq -r .status)
      ERROR_MESSAGE=$(cat $TEMPFILE | jq -r .message.text)
      if [ ! -z "$ERROR_STATUS" ]
      then
         echo "Error: can not get visitor count: $ERROR_MESSAGE"
      else
         echo "Error: can not get visitor count."
      fi
      rm $TEMPFILE
      exit 1
   fi

echo "Visitor Count: $COUNT"
exit 0
fi

curl -s -d "token=${TOKEN}" -X POST http://${HOST}:${PORT}/v1/visitors/list > $TEMPFILE
if [ "$?" -ne 0 ]
then
   echo "Error: can not get visitor list from ${HOST}:${PORT}"
   rm $TEMPFILE
   exit 1
fi

COUNT=$(cat $TEMPFILE | jq '.results | length')

if [ "$COUNT" = "null" -o "$COUNT" -eq 0 ]
then
   ERROR_STATUS=$(cat $TEMPFILE | jq -r .status)
   ERROR_MESSAGE=$(cat $TEMPFILE | jq -r .message.text)
   if [ ! -z "$ERROR_STATUS" ]
   then
      echo "Error: can not get visitor list: $ERROR_MESSAGE"
   else
      echo "Error: can not get visitor list"
   fi
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
