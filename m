Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail222c50.megamailservers.eu ([91.136.10.232]:37038 "EHLO
        mail33c50.megamailservers.eu" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726234AbeG2MkL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jul 2018 08:40:11 -0400
Received: from mail.kenjo.org (c-4b63235c.042-336-73746f34.bbcust.telenor.se [92.35.99.75])
        (authenticated bits=0)
        by mail33c50.megamailservers.eu (8.14.9/8.13.1) with ESMTP id w6TAmtxx029527
        for <linux-nfs@vger.kernel.org>; Sun, 29 Jul 2018 10:48:57 +0000
Received: from brix.kenjo.org ([172.16.2.16])
        by mail.kenjo.org with esmtp (Exim 4.89)
        (envelope-from <ken@kenjo.org>)
        id 1fjjFv-0004sL-12
        for linux-nfs@vger.kernel.org; Sun, 29 Jul 2018 12:48:55 +0200
To: linux-nfs@vger.kernel.org
From: Kenneth Johansson <ken@kenjo.org>
Subject: F_SETLK blocks on nfsv4
Message-ID: <df5a7061-cc69-f90a-2d24-292e52d1f198@kenjo.org>
Date: Sun, 29 Jul 2018 12:48:55 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was trying to change over to using nfsv4 from nfsv3 and hit a problem 
with VLC. after some strace digging I came up with a test program that 
has the same effect and works on nfs3 but hangs on nfsv4.

Even more interesting when run on a nfsv4 mounted home directory it is 
no longer possible to open new connections in google-chrome so the error 
is visible not only for the test program but probably all program that 
does locking after this program is started on the same mount. or 
something I have not investigated what really happens.

anyway the program is below and it hangs on last the line "ret = 
"fcntl(fd, F_SETLK, &fl);" if run on a nfsv4 mount.

server; debain 9.5 with kernel version 4.9 or 4.17.0-0.bpo.1-amd64.

client: ubuntu 18.04. kernel 4.18.0-041800rc6-generic

--------------

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/file.h>
#include <string.h>

char *lfile="lock";

int main(int argc, char *argv[])
{
         int fd;
         int ret;
         struct flock fl;

         fd = openat(AT_FDCWD, lfile, O_RDWR|O_CREAT|O_EXCL|O_CLOEXEC, 
0600);
         if (fd <0) {perror("");exit(1);}

         ret = fcntl(fd, F_SETFD, FD_CLOEXEC);
         if (ret <0) {perror("");exit(1);}

         ret = flock(fd, LOCK_EX|LOCK_NB);
         if (ret <0) {perror("");exit(1);}

         memset(&fl,0,sizeof(fl));
         fl.l_type = F_WRLCK;
         fl.l_whence=SEEK_SET;
         ret = fcntl(fd, F_SETLK, &fl);
         if (ret <0) {perror("");exit(1);}

         printf("done\n");
}


