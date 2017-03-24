Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3.molgen.mpg.de ([141.14.17.11]:41764 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757589AbdCXPWs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Mar 2017 11:22:48 -0400
Subject: Re: open after unlink tries to open old file
To: linux-nfs@vger.kernel.org
References: <ae2f9a9e-65b0-9fe5-a148-4ec698df91d0@molgen.mpg.de>
From: Donald Buczek <buczek@molgen.mpg.de>
Message-ID: <e7675ce0-b4bb-ea75-ef71-a07ce0d835fb@molgen.mpg.de>
Date: Fri, 24 Mar 2017 16:22:44 +0100
MIME-Version: 1.0
In-Reply-To: <ae2f9a9e-65b0-9fe5-a148-4ec698df91d0@molgen.mpg.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/10/17 14:55, Donald Buczek wrote:
> I see this code
>
>     #include <stdlib.h>
>     #include <stdio.h>
>     #include <sys/types.h>
>     #include <sys/stat.h>
>     #include <fcntl.h>
>     #include <unistd.h>
>
>     #define FILENAME "test.dat"
>
>     int main() {
>         int i;
>         int fd;
>         unlink(FILENAME);
>         for  (i=0;i<1000;i++) {
>             printf("%d\n",i);
>             if ((fd=open(FILENAME,O_WRONLY+O_CREAT,0))==-1) {
>                 perror("open");
>                 exit(1);
>             }
>             if (close(fd)==-1) {
>                 perror("close");
>                 exit(1);
>             }
>             if (unlink(FILENAME)==-1) {
>                 perror("unlink");
>                 exit(1);
>             }
>         }
>     }
>
> failing most of the time in NFS-mounted directories:
>
>     buczek@theinternet:~$ uname -a
>     Linux theinternet.molgen.mpg.de 4.4.52.mx64.142 #1 SMP Fri Mar 3 
> 21:25:00 CET 2017 x86_64 GNU/Linux
>     buczek@theinternet:~$ nfs_test
>
>     0
>     1
>     2
>     3
>     4
>     open: Permission denied
>     buczek@theinternet:~$
>
> but I fail to find an answer to the question, whether this is supposed 
> to work or not. Is this a bug or a caching feature?
>
> Thanks
>   Donald

With some bisect work I discovered, that this was just a different 
manifestation of Bug 109771 [1] reported by myself and fixed by Trond 
[2] for Linux v4.5. Many of my clients are back on Linux v4.4 longterm 
because of unrelated issues with other releases and I wrongly thought, 
the fix was backported.

Donald


[1] https://bugzilla.kernel.org/show_bug.cgi?id=109771
[2] 
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=762674f

-- 
Donald Buczek
buczek@molgen.mpg.de
Tel: +49 30 8413 1433

