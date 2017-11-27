#!/bin/bash

__MY_RETURN_VAR=
__MY_SCRIPT_DIR='~/scripts'

htdb-copy()
{
  ##
  if [ -z "$1" ]; then
    echo -e '!!! Missing argument.'
    return 0
  fi

  ## Prepare something

  cd $__MY_SCRIPT_DIR

  local argsCount=$#
  local ipSrc=
  local ipDst=
  local dbSrc=
  local dbDst=
  local prevDir=$(pwd)

  ##
  case "$argsCount" in
    ## htdb-copy <source-ip> <destination-ip> <source-db> <destination-db>
    4 )
      ipSrc=$1
      ipDst=$2
      dbSrc=$3
      dbDst=$4
      ;;

    ## htdb-copy <source-ip> <source-db> <destination-db>
    3 )
      ipSrc=$1
      ipDst='127.0.0.1'
      dbSrc=$2
      dbDst=$3
      ;;

    ## htdb-copy <source-db> <destination-db>
    2 )
      ipSrc='127.0.0.1'
      ipDst='127.0.0.1'
      dbSrc=$1
      dbDst=$2
      ;;

    ## Bye
    * )
      if [ "help" == "$1" ]; then
        __htdbcopy_func_echoHelp
      fi
      echo ':)'
      return 0
      ;;
  esac

  ## Prevent important databases impact
  declare -a reservedDbNames=('postgres' 'template0' 'template1' 'htdb_admin' 'nguyen' 'nnnnnn')
  local dbName=
  for dbName in "${reservedDbNames[@]}"
  do
    [ "$dbName" == "$dbDst" ] && echo -e "!!! Dangerous !!! Cannot drop database '$dbDst'." && return 0
  done

  ## Checks DB destination first

  ## then, checks DB source

  ## Fireee!
  __htdbcopy_func_fireOnfly $ipSrc $ipDst $dbSrc $dbDst
  cd $prevDir
}

__htdbcopy_func_connStr()
{
  local ip=$1
  echo "-h $ip -p 5433 -U postgres"
}

__htdbcopy_func_fireOnfly()
{
  ##
  local ipSrc=$1
  local ipDst=$2
  local dbSrc=$3
  local dbDst=$4
  local dumpFile=
  local cmd=

  ##
  echo -e '\nKill postgresql sessions/connections ...'
  psql $(__htdbcopy_func_connStr $ipDst) -c $(__htdb_func_sqlKillPgSessions $dbDst) > /dev/null 2>&1

  echo -e "\nDrop database '$dbDst' if exists ..."
  __htdb_func_echoRun "dropdb --if-exists $(__htdbcopy_func_connStr $ipDst) $dbDst"

  echo -e "\nCreating database '$dbDst' ..."
  __htdb_func_echoRun "createdb $(__htdbcopy_func_connStr $ipDst) -E UTF8 $dbDst"

  ## Dump DB source
  dumpFile="$(pwd)/DUMP-$dbSrc.snapshot"
  echo -e "\nCreating '$dumpFile' from '$ipSrc' ..."
  __htdb_func_echoRun "pg_dump $(__htdbcopy_func_connStr $ipSrc) -Fp -d $dbSrc -f $dumpFile"

  ## Restore dump file to localhost
  echo -e '\nFinalizing ...'
  #cmd="pg_restore $(__htdbcopy_func_connStr $ipDst) -d $dbDst $dumpFile"
  cmd="psql $(__htdbcopy_func_connStr $ipDst) -d $dbDst -f $dumpFile"
  __htdb_func_echoRun "$cmd"

  echo -e '\nDone!'
}

__htdbcopy_func_echoHelp()
{
  __htdb_func_echoFileContent ~/scripts/htdb-copy-help.txt
}
