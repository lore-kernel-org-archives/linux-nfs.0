Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33226 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726255AbeG2Nv6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 29 Jul 2018 09:51:58 -0400
Message-ID: <ab37550077df094ad61a7e8fcbf61cecc614e408.camel@kernel.org>
Subject: Re: F_SETLK blocks on nfsv4
From: Jeff Layton <jlayton@kernel.org>
To: Kenneth Johansson <ken@kenjo.org>, linux-nfs@vger.kernel.org,
        Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Sun, 29 Jul 2018 08:21:39 -0400
In-Reply-To: <df5a7061-cc69-f90a-2d24-292e52d1f198@kenjo.org>
References: <df5a7061-cc69-f90a-2d24-292e52d1f198@kenjo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2018-07-29 at 12:48 +0200, Kenneth Johansson wrote:
> I was trying to change over to using nfsv4 from nfsv3 and hit a problem 
> with VLC. after some strace digging I came up with a test program that 
> has the same effect and works on nfs3 but hangs on nfsv4.
> 
> Even more interesting when run on a nfsv4 mounted home directory it is 
> no longer possible to open new connections in google-chrome so the error 
> is visible not only for the test program but probably all program that 
> does locking after this program is started on the same mount. or 
> something I have not investigated what really happens.
> 
> anyway the program is below and it hangs on last the line "ret = 
> "fcntl(fd, F_SETLK, &fl);" if run on a nfsv4 mount.
> 
> server; debain 9.5 with kernel version 4.9 or 4.17.0-0.bpo.1-amd64.
> 
> client: ubuntu 18.04. kernel 4.18.0-041800rc6-generic
> 
> --------------
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <errno.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <sys/file.h>
> #include <string.h>
> 
> char *lfile="lock";
> 
> int main(int argc, char *argv[])
> {
>          int fd;
>          int ret;
>          struct flock fl;
> 
>          fd = openat(AT_FDCWD, lfile, O_RDWR|O_CREAT|O_EXCL|O_CLOEXEC, 
> 0600);
>          if (fd <0) {perror("");exit(1);}
> 
>          ret = fcntl(fd, F_SETFD, FD_CLOEXEC);
>          if (ret <0) {perror("");exit(1);}
> 
>          ret = flock(fd, LOCK_EX|LOCK_NB);
>          if (ret <0) {perror("");exit(1);}
> 
>          memset(&fl,0,sizeof(fl));
>          fl.l_type = F_WRLCK;
>          fl.l_whence=SEEK_SET;
>          ret = fcntl(fd, F_SETLK, &fl);
>          if (ret <0) {perror("");exit(1);}
> 
>          printf("done\n");
> }
> 
> 

Thanks for the report. This looks like a client-side regression in
v4.18. On a hunch, I just backed out this patch and it seems to fix the
problem:

    commit a3cf9bca2ace0351c4a4c17fbca4d652c323d5e5
    Author: Benjamin Coddington <bcodding@redhat.com>
    Date:   Thu May 3 07:12:57 2018 -0400

        NFSv4: Don't add a new lock on an interrupted wait for LOCK

Ben, can you take a look?
-- 
Jeff Layton <jlayton@kernel.org>

