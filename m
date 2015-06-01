Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55856 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753547AbbFAVXS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jun 2015 17:23:18 -0400
Date: Mon, 1 Jun 2015 17:23:17 -0400
To: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>
Cc: linux-nfs@vger.kernel.org, Vasily Isaenko <vasily.isaenko@oracle.com>,
        "SHUANG.QIU" <shuang.qiu@oracle.com>
Subject: Re: nfsd: EACCES vs EPERM on utime()/utimes() calls
Message-ID: <20150601212317.GF26972@fieldses.org>
References: <556C73AE.4090900@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <556C73AE.4090900@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 01, 2015 at 06:01:02PM +0300, Stanislav Kholmanskikh wrote:
> Hello.
> 
> As the man page for utime/utimes states [1], EPERM is returned if
> the second argument of utime/utimes is not NULL and:
>  * the caller's effective user id does not match the owner of the file
>  * the caller does not have write access to the file
>  * the caller is not privileged
> 
> However, I don't see this behavior with NFS, I see EACCES is
> generated instead.

Agreed that it's probably a server bug.  (Have you run across a case
where this makes a difference?)

Looking at nfsd_setattr()....  The main work is done by notify_change(),
which is probably doing the right thing.  But before that there's an
fh_verify()--looks like that is expected to fail in your case.  I bet
that's the cause.

--b.

> 
> Please, consider this test:
> 
> #include <stdio.h>
> #include <sys/types.h>
> #include <sys/time.h>
> #include <utime.h>
> 
> int main(int argc, char *argv[])
> {
> 	struct utimbuf u = { .actime = 0, .modtime = 0 };
> 	struct timeval tv = { .tv_sec = 0, .tv_usec = 0 };
> 
> 	if (utime(argv[1], &u))
> 		perror("utime() failed");
> 
> 	if (utimes(argv[1], &tv))
> 		perror("utimes() failed");
> 	
> 	return 0;
> }
> 
> In my environment the kernel is 4.1.0-rc6 x86_64, and there are 2
> NFS mounted directories:
> 127.0.0.1:/opt/export/disk0 on /mnt/lin type nfs (rw,vers=3,addr=127.0.0.1)
> 192.168.0.12:/export/bla on /mnt/sol type nfs (rw,vers=3,addr=192.168.0.12)
> 
> /mnt/sol is from Solaris 11.2 x86_64. /opt/export/disk0 is handled
> by the in-kernel nfs server.
> 
> Execution of the above test program gives:
> 
> * the server is Linux -> EACCES is generated:
> 
> [stas@ol6-x64 tmp]$ ls -l /mnt/lin/test_file
> -rw-r--r-- 1 root root 0 Jun  1 17:28 /mnt/lin/test_file
> [stas@ol6-x64 tmp]$ strace -e utime,utimes ./utime_test /mnt/lin/test_file
> utime("/mnt/lin/test_file", [0, 0])     = -1 EACCES (Permission denied)
> utime() failed: Permission denied
> utimes("/mnt/lin/test_file", {{0, 0}, {0, 0}}) = -1 EACCES
> (Permission denied)
> utimes() failed: Permission denied
> 
> * the server is Solaris 11.2 -> EPERM is generated
> 
> [stas@ol6-x64 tmp]$ ls -l /mnt/sol/test_file
> -rw-r--r--+ 1 root root 0 Jun  1  2015 /mnt/sol/test_file
> [stas@ol6-x64 tmp]$ strace -e utime,utimes ./utime_test /mnt/sol/test_file
> utime("/mnt/sol/test_file", [0, 0])     = -1 EPERM (Operation not permitted)
> utime() failed: Operation not permitted
> utimes("/mnt/sol/test_file", {{0, 0}, {0, 0}}) = -1 EPERM (Operation
> not permitted)
> utimes() failed: Operation not permitted
> 
> * on a local ext4 file system EPERM is generated:
> 
> [stas@ol6-x64 tmp]$ ls -l /tmp/test_file
> -rw-r--r-- 1 root root 0 Jun  1 17:51 /tmp/test_file
> [stas@ol6-x64 tmp]$ strace -e utime,utimes ./utime_test /tmp/test_file
> utime("/tmp/test_file", [0, 0])         = -1 EPERM (Operation not permitted)
> utime() failed: Operation not permitted
> utimes("/tmp/test_file", {{0, 0}, {0, 0}}) = -1 EPERM (Operation not
> permitted)
> utimes() failed: Operation not permitted
> 
> Plus EPERM is generated when the NFS server is FreeBSD 9.1.
> 
> Could anybody, clarify, if the described behavior a bug in the Linux
> NFS server implementation or not?
> 
> Thank you.
> 
> [1] http://man7.org/linux/man-pages/man2/utime.2.html
> 
> PS: this all was found using utime06, utimes01 LTP test cases.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
