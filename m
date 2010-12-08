Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59932 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755390Ab0LHTUV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 14:20:21 -0500
Subject: Re: NFSv4: "Viminfo file is not writable" -- stat(2) uid/gid
 incorrect
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Flynn <davidf@rd.bbc.co.uk>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101208153340.GD20844@rd.bbc.co.uk>
References: <20101208153340.GD20844@rd.bbc.co.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Dec 2010 14:19:59 -0500
Message-ID: <1291835999.3067.13.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-08 at 15:33 +0000, David Flynn wrote:
> Dear all;
> 
> On an NFS4 client (mounting a solaris ufs export), for a long time i've
> been experiencing vim complaining when exiting:
>   E137: Viminfo file is not writable: /home/davidf/.viminfo
> 
> Further examination has revealed this to occur when vim has been used on
> multiple systems using the same nfs filesystem.  Vim tries to identify if it
> has permission to modify .viminfo by stat'ing it, whereupon stat returns
> an incorrect st_uid/st_gid and vim gives up.

You really should file a bug with the vim folks on this. Checking
permissions using the above scheme is inherently racy (and quite
frankly, wrong). See the caveats in the 'access()' manpage for details.

If you want to find out if the file can be modified, then the only race
free way to do so, is to try to open() it.

> Assuming two systems (A and B) with clean caches:
>   A> vim
>   :q
>   B> vim
>   :q
>   A> vim
>   :q
>   E137: ...
>   A> vim
>   :q
>   E137: ...
> 
> It should be noted that:
>  - (A) must be using nfs4, although sec=sys/sec=krb5 do not affect behaviour.
>  - (B) can be nfs4 or nfs3 (or possibly anything else)
>  - Dropping caches on (A) will clear the fault
> 
> This fault is very reproducible using kernel 2.6.35.  I'm also able to
> reproduce on 2.6.32.11  I have not been able to reproduce on a 2.6.26 system.
> 
> More succinctly, the following transcript reproduces the problem.
>   - vcfe0 corresponds to (A) above.
>   - lxg1 corresponds to (B) above.
>   - ~/test-stat-open-stat is a program that does:
>        stat(argv[1], &st);
>        printf("stat(\".%s\"...), st_uid=%u, st_gid=%u\n",
>               argv[1], st.st_uid, st.st_gid);
> 
>        int fd = open(argv[1], O_RDONLY);
>        printf("open(\"%s\", O_RDONLY) = %d\n", argv[1], fd);
>        stat(argv[1], &st);
>        printf("stat(\".%s\"...), st_uid=%u, st_gid=%u\n",
>               argv[1], st.st_uid, st.st_gid);
> 
>        close(fd);
>        printf("close(%d)\n", fd);
>        stat(argv[1], &st);
>        printf("stat(\".%s\"...), st_uid=%u, st_gid=%u\n",
>               argv[1], st.st_uid, st.st_gid);
> 
> vcfe0:~/z$ bash <<EOF
> echo === truncate === ; \
> echo foo >.file ; \
> echo === remote unlink, create === ; \
> ssh lxg1 "rm $PWD/.file; echo barbar >$PWD/.file" ; \
> echo === 'stat(1)' === ; \
> stat .file ; \
> echo === stat,open,stat,close,stat === ; \
> ~/test-stat-open-stat .file ; \
> echo === 'stat(1)' === ; \
> stat .file
> EOF
> 
> === truncate ===
> === remote unlink, create ===
> === stat(1) ===
>   File: `.file'
>   Size: 4               Blocks: 0          IO Block: 1048576 regular file
> Device: 18h/24d Inode: 5678963     Links: 1
> Access: (0644/-rw-r--r--)  Uid: ( 1179/  davidf)   Gid: ( 1000/      rd)
> Access: 2010-11-29 16:50:03.414109000 +0000
> Modify: 2010-11-29 17:00:17.698839000 +0000
> Change: 2010-11-29 17:00:17.698839000 +0000
> === stat,open,stat,close,stat ===
> stat(".file"...), st_uid=1179, st_gid=1000
> open(".file", O_RDONLY) = 3
> stat(".file"...), st_uid=4294967294, st_gid=4294967294
> close(3)
> stat(".file"...), st_uid=4294967294, st_gid=4294967294
> === stat(1) ===
>   File: `.file'
>   Size: 7               Blocks: 2          IO Block: 1048576 regular file
> Device: 18h/24d Inode: 5678906     Links: 1
> Access: (0644/-rw-r--r--)  Uid: (4294967294/ UNKNOWN)   Gid: (4294967294/ UNKNOWN)
> Access: 2010-11-29 17:00:18.059076000 +0000
> Modify: 2010-11-29 17:00:18.064360000 +0000
> Change: 2010-11-29 17:00:18.064360000 +0000

Your idmapper appears to be mapping the user to 'nobody', which is
usually a sign that it is misconfigured. It may, however, also mean that
the username (or groupname) is missing in /etc/passwd (or /etc/groups).

I've no idea how to check the Solaris idmapper configuration, but on
Linux you want to look at /etc/idmapd.conf (specifically the 'Domain'
line).

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

