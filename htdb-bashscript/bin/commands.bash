#!/bin/bash

__MY_RETURN_VAR=
__MY_HTDB_DIR='/usr/local/hatarakudb-bin/automatic'

mycmd()
{
  echo -e '\n==='
  echo -e 'COMMANDS:\nmycmd, htdb, htdb-copy, htdb-log, memclear, go, mydebug'
  echo -e '===\n'
}

go()
{
  local htdbDir=
  local cmd=

  case "$1" in
    'htdb' )
      htdbDir=$__MY_HTDB_DIR
      cmd="cd $htdbDir"
      $cmd
      ;;

    * )
      echo -e '\nI don''t know where to go! Feelings sad.\n'
      ;;
  esac

  # return path
  __MY_RETURN_VAR=$cmd
}

htdb-log()
{
  __htdb_func_echoRun 'tail -f /var/log/htdb/hatarakudb.log'
}

htdb()
{
  ##
  if [ -z "$1" ]; then
    echo -e '!!! Missing command name.'
    htdb help
    return 0
  fi

  ##
  local resultCode=1
  local prevDir=$(pwd)
  local batchDir=/htdocs/
  local cmdName=$1
  local cmd=

  ##
  case "$cmdName" in
    'cron' )
      go htdb
      cd ".$batchDir"
      __htdb_func_echoRun "php $(pwd)/indexCron.php"
      cd $prevDir
      ;;

    'timer' )
      go htdb
      cd ".$batchDir"
      __htdb_func_echoRun "php $(pwd)/indexTimer.php"
      cd $prevDir
      ;;

    'copy' )
      cmd="htdb-$@"
      $cmd
      ;;

    'log' )
      htdb-log
      ;;

    'debug'|'-d' )
      mydebug
      ;;

    'help'|'--help'|'-h' )
      __htdb_func_echoFileContent '~/scripts/htdb-help.txt'
      ;;

    * )
      resultCode=0
      echo -e '!!! Unknown command name.\nHint: htdb help'
      ;;
  esac

  ##
  return $resultCode
}

memclear()
{
  __htdb_func_echoRun '/etc/init.d/memcached restart'
}

mydebug()
{
  __htdb_func_echoRun 'tail -f /tmp/myDebug'
}

__htdb_func_echoRun()
{
  echo -e ">>> $1\n"
  $1
}

__htdb_func_echoFileContent()
{
  while IFS= read -r l; do
    echo "$l"
  done < $1
}

__htdb_func_sqlKillPgSessions()
{
  local dbName=$1
  echo "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = '$dbName'"
}

