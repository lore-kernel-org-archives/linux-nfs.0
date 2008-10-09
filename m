From: Michal Sojka <sojkam1-jQs2MHkdoM/twjQa/ONI9g@public.gmane.org>
Subject: Case sensitivity in NFS files
Date: Thu, 9 Oct 2008 18:39:49 +0200
Message-ID: <200810091839.49445.sojkam1@fel.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from max.feld.cvut.cz ([147.32.192.36]:41324 "EHLO max.feld.cvut.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754495AbYJIQvE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 12:51:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm experiencing strange problem with case sensitivity of files on NFS3 
filesystem. I want to backup my server to a NAS device. The server is:
Linux rtime 2.6.25-gentoo-r8 #6 SMP Thu Oct 9 13:00:08 CEST 2008 i686
and NAS is:
Linux RtimeBackup 2.6.15 #722 Fri Sep 19 20:23:15 CST 2008 armv5tejl unknown

I would like to use rdiff-backup tool, which checks for case sensitivity of 
the target filesystem. The technique it uses to check this is the same as in 
this file:

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
        int fd;
        struct stat st;
        fd = open("A", O_WRONLY|O_CREAT|O_TRUNC, 0666);
        perror("1. open(A)"); errno=0;
        if (fd == -1) {
                exit(1);
        }
        close(fd);
        lstat("A", &st);
        perror("2. lstat(A)"); errno=0;
        lstat("a", &st);
        perror("3. lstat(a)"); errno=0;
        unlink("a");
        perror("4. unlink(a)"); errno=0;
        lstat("A", &st);
        perror("5. lstat(A)"); errno=0;
        lstat("a", &st);
        perror("6. lstat(a)"); errno=0;
}

The expected output of this program is:

1. open(A): Success
2. lstat(A): Success
3. lstat(a): No such file or directory
4. unlink(a): No such file or directory
5. lstat(A): Success
6. lstat(a): No such file or directory

On NFS, I sometimes get the following (neither "A" nor "a" files existed 
before execution):

1. open(A): Success
2. lstat(A): Success
3. lstat(a): Success
4. unlink(a): Success
5. lstat(A): Stale NFS file handle
6. lstat(a): No such file or directory

This happens when the program is run for the first time. When I run it for the 
second time, I get the expected output and file "A" is created. After I 
remove the A file, I get the "wrong" output again.

Does anybody know, what is causing this behavior?

Thanks
Michal

P.S.: Please CC me when replying.
