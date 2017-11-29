INSTALL SOME COMMANDS IN YOUR SERVER

1. Login your server.
2. Get scripts by following command:

    git clone git@git01.mdomain:hataraku/rv-development-tools.git ~/rv-development-tools

3. Copy content below & paste at the end of file ".bashrc" in your home folder.

    [[ -f ~/rv-development-tools/htdb-bashscript/etc/bashrc ]] \
      && . ~/rv-development-tools/htdb-bashscript/etc/bashrc

4. Structure of my folder:

  /root/
       |-- rv-development-tools/
       |          |-- bin
       |          |    |-- commands.bash
       |          |    |-- htdb-copy.bash
       |          |
       |          |-- etc
       |          |    |-- bashrc
       |          |    |-- git-prompt.sh
       |          |
       |          |-- share
       |
       |-- .bashrc


HƯỚNG DẪN MỘT SỐ COMMAND

mycmd
    Liệt kê danh sách commands.

htdb-log
    Chạy log đề án Hatarakudb.

mydebug
    Chạy mydebug đề án Hatarakudb.

memclear
    Khởi động lại memcached.

go htdb
    Đi đến thư mục htdb-git

htdb <command-name>

    Một số command name bên dưới:
        cron       Thực thi lệnh "php indexCron.php" trong thư mục "hatarakudb-bin/automatic/htdocs"
        timer      Thực thi lệnh "php indexTimer.php" trong thư mục "hatarakudb-bin/automatic/htdocs"

    Ví dụ:
        htdb cron
        htdb timer

