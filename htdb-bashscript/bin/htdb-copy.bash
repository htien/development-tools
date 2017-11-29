#!/bin/bash

__MY_RETURN_VAR=
__MY_APP_DIR=$__APP_DIR

htdb-copy()
{
  ##
  if [ -z "$1" ]; then
    echo -e '!!! Missing argument.'
    return 0
  fi

  ## Prepare something
  local argsCount=$#
  local ipSrc=
  local ipDst=
  local dbSrc=
  local dbDst=
  local __MY_PREV_DIR=$(pwd)

  cd $__MY_APP_DIR

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
  cd $__MY_PREV_DIR
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

  ## Kill sessions, drop & create database

  echo -e '\nKill postgresql sessions/connections ...'
  __htdb_func_killPgSessions $ipDst $dbDst

  echo -e "\nDrop database '$dbDst' ($ipDst) if exists ..."
  __htdb_func_dropDatabase $ipDst $dbDst

  echo -e "\nCreating database '$dbDst' ($ipDst) ..."
  __htdb_func_createDatabase $ipDst $dbDst

  ## Dump DB source

  dumpFile="$__MY_APP_DIR/DUMP_${ipSrc}_$dbSrc.snapshot"
  echo -e "\nCreating '$dumpFile' from '$ipSrc' ..."
  __htdb_func_dumpDatabase $ipSrc $dbSrc $dumpFile

  ## Restore dump file to localhost

  echo -e '\nFinalizing ...'
  __htdb_func_restoreDatabase $ipDst $dbDst $dumpFile

  echo -e '\nDone!'
}

__htdb_func_killPgSessions()
{
  local ip=$1
  local db=$2
  psql $(__htdbcopy_func_connStr $ip) -c $(__htdb_func_sqlKillPgSessions $db) > /dev/null 2>&1
}

__htdb_func_dropDatabase()
{
  local ip=$1
  local db=$2
  __htdb_func_echoRun "dropdb --if-exists $(__htdbcopy_func_connStr $ip) $db"
}

__htdb_func_createDatabase()
{
  local ip=$1
  local db=$2
  local opts='-T template0 -E UTF8'
  __htdb_func_echoRun "createdb $(__htdbcopy_func_connStr $ip) $opts $db"
}

__htdb_func_dumpDatabase()
{
  local ip=$1
  local db=$2
  local dumpFile=$3
  local opts='-Fp --clean --if-exists --column-inserts --inserts'
  __htdb_func_echoRun "pg_dump $(__htdbcopy_func_connStr $ip) $opts -d $db -f $dumpFile"
}

__htdb_func_restoreDatabase()
{
  local ip=$1
  local db=$2
  local dumpFile=$3
  local cmd=
  local opts='--quiet'

  #cmd="pg_restore $(__htdbcopy_func_connStr $ip) -d $db $dumpFile"
  cmd="psql $opts $(__htdbcopy_func_connStr $ip) -d $db -f $dumpFile"
  __htdb_func_echoRun "$cmd"
}

__htdbcopy_func_echoHelp()
{
  __htdb_func_echoFileContent "$__APP_DIR/share/htdb-copy-help.txt"
}
