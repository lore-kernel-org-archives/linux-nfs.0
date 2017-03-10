Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3.molgen.mpg.de ([141.14.17.11]:52891 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965071AbdCJOCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 09:02:52 -0500
To: linux-nfs@vger.kernel.org
From: Donald Buczek <buczek@molgen.mpg.de>
Subject: open after unlink tries to open old file
Message-ID: <ae2f9a9e-65b0-9fe5-a148-4ec698df91d0@molgen.mpg.de>
Date: Fri, 10 Mar 2017 14:55:09 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see this code

     #include <stdlib.h>
     #include <stdio.h>
     #include <sys/types.h>
     #include <sys/stat.h>
     #include <fcntl.h>
     #include <unistd.h>

     #define FILENAME "test.dat"

     int main() {
         int i;
         int fd;
         unlink(FILENAME);
         for  (i=0;i<1000;i++) {
             printf("%d\n",i);
             if ((fd=open(FILENAME,O_WRONLY+O_CREAT,0))==-1) {
                 perror("open");
                 exit(1);
             }
             if (close(fd)==-1) {
                 perror("close");
                 exit(1);
             }
             if (unlink(FILENAME)==-1) {
                 perror("unlink");
                 exit(1);
             }
         }
     }

failing most of the time in NFS-mounted directories:

     buczek@theinternet:~$ uname -a
     Linux theinternet.molgen.mpg.de 4.4.52.mx64.142 #1 SMP Fri Mar 3 
21:25:00 CET 2017 x86_64 GNU/Linux
     buczek@theinternet:~$ nfs_test

     0
     1
     2
     3
     4
     open: Permission denied
     buczek@theinternet:~$

but I fail to find an answer to the question, whether this is supposed 
to work or not. Is this a bug or a caching feature?

Thanks
   Donald

-- 
Donald Buczek
buczek@molgen.mpg.de
Tel: +49 30 8413 1433





