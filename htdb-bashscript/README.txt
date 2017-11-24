INSTALL SOME COMMANDS IN YOUR SERVER

1. Login your server.
1. Copy folder "scripts" to user root folder.
2. Paste content of "bashrc.txt" file at the end of file ".bashrc" in user root folder.

Structure of my folder:

  /root/
       |-- scripts/
       |          |-- commands.sh
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
        cron       Thực thi lệnh "php indexCron.php" trong thư mục "..htdb-git/htdocs"
        timer      Thực thi lệnh "php indexTimer.php" trong thư mục "..htdb-git/htdocs"

    Ví dụ:
        htdb cron
        htdb timer

