Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755345Ab0JROQH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Oct 2010 10:16:07 -0400
Date: Mon, 18 Oct 2010 10:10:59 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Ian Munsie <imunsie@au1.ibm.com>
Cc: Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Scott Romanowski <romansc@us.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NFS sillyrename side effect
Message-ID: <20101018101059.574b715a@corrin.poochiereds.net>
In-Reply-To: <1287362142-sup-777@au1.ibm.com>
References: <1287362142-sup-777@au1.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 18 Oct 2010 12:20:19 +1100
Ian Munsie <imunsie@au1.ibm.com> wrote:

> Hi Trond,
> 
> I'm currently investigating a bug report related to NFS for an internal
> project, and I wanted to get your input as I've been able to reproduce
> it on an upstream 2.6.36-rc7 kernel on Power7 hardware. I have tracked
> it down to a side effect of the nfs_sillyrename function.
> 
> I'm not very familiar with the inner workings of the nfs layer, is the
> purpose of the sillyrename function to work around a limitation of nfs
> if a file is unlinked while in use?
> 

See:

http://nfs.sourceforge.net/

...section D2. The faq mentions that NFSv4 could do away with it
because it's stateful, but that's not really the case either.

> It seems to me that if the sillyrename function is indeed necessary that
> we should not reveal the temporary filename it produces to userspace,
> but I wonder if that might create issues (say if userspace thinks a
> directory is empty when it acutally has a sillyrename file in it)?
> 
> Basically I want to know if the behaviour I've outlined below is
> the expected behaviour of NFS, or if you considder this a bug?
> 


It's expected. Sillyrenaming sucks, but there really is no great
alternative to it. It's one of the prices we pay for having NFSv2/3 be
stateless.

I suppose in principle we could do things like hide silly-renamed
dentries from userspace, but that might also be problematic. You'd
still be unable to remove a directory that has a silly-renamed file in
it, for instance even though it looks empty. There would also be
inconsistencies as other machines and the server would still see
the .nfsXXXXX files.

The bottom line is that you need to be really careful with programs
that use delete-on-last-close when running on NFS.

> 
> 
> The gist of the original bug report is that running the syscalls test
> suite from the Linux Test Project on an nfsroot would emit warnings on
> the recvmsg01 test, however that test never emits warnings when run
> individually. The particular warning in question is:
> 
> tst_rmdir(): rmobj(/tmp/ltp-Url7aJLwfH/recZ7XHW6) failed:
> unlink(/tmp/ltp-Url7aJLwfH/recZ7XHW6/.nfs00000000019f12d80000002e) failed;
> errno=16: Device or resource busy
> 
> However removing a number of preceding tests would instead produce a
> warning like the following:
> 
> recvmsg01    0  TWARN  :  tst_rmdir():
> rmobj(/tmp/ltp-eenc4irncU/recRpxeMd) failed:
> lstat(/tmp/ltp-eenc4irncU/recRpxeMd/.nfs00000000400a0e9a0000023c) failed;
> errno=2: No such file or directory
> 
> 
> Scott (on CC), the original reporter produced that second behaviour by
> commenting out the first 475 tests and all the tests after recvmsg01.
> I've been able to produce it over 50% of the time with just the
> following two test cases:
> 
> foo echo
> recvmsg01 recvmsg01
> 
> Presumably this is a race and the exact conditions necessary to
> reproduce it will vary depending on network, hardware, etc.
> Scott reported that this behaviour only began after transitioning from
> 2.6.31 to 2.6.32 - I haven't checked 2.6.31 to determine if the issue
> may have existed and just have been harder to produce or if 2.6.31
> really did not exhibit this behaviour.
> 
> 
> 
> The recvmsg01 testcase sets up a temporary directory, performs a mkstemp
> to generate a temporary file within that directory which it promptly
> unlinks and creates a unix socket with that filename to perform it's
> tests. That all seems to work fine.
> 
> When it cleans up it kills it's server, unlinks that unix socket then
> calls tst_rmdir() which recursively removes (by calling it's rmobj
> function) the temporary directory and it's contents.
> 
> The race seems to be that when the socket is unlinked it's still in use,
> so the nfs layer performs a sillyrename on it to asynchronously unlink
> it, but before that completes the tst_rmdir function has already read
> the contents of the directory and spotted the .nfs00000... file from the
> sillyrename, which depending on the exact timing of the unlink will
> cause one of the above two warnings.
> 
> 
> A somewhat filtered (grep -v permission) output of the race after
> activating nfs_debug is below:
> 
> setup:
> NFS: lookup(recRpxeMd/udsockOxmZAh)
> NFS: create(0:d/1074400921), udsockOxmZAh
> NFS: nfs_fhget(0:d/1074400922 ct=1)
> NFS: dentry_delete(recRpxeMd/udsockOxmZAh, 0)
> NFS: nfs_update_inode(0:d/1074400921 ct=1 info=0x7d7f)
> NFS: isize change on server for file 0:d/1074400921
> NFS: unlink(0:d/1074400921, udsockOxmZAh)
> NFS: safe_remove(recRpxeMd/udsockOxmZAh)
> NFS: dentry_delete(recRpxeMd/udsockOxmZAh, 18)
> NFS: nfs_update_inode(0:d/1074400921 ct=1 info=0x7d7f)
> NFS: isize change on server for file 0:d/1074400921
> NFS: lookup(recRpxeMd/udsockOxmZAh)
> NFS: mknod(0:d/1074400921), udsockOxmZAh
> ...
> cleanup:
> NFS: unlink(0:d/1074400921, udsockOxmZAh)
> NFS: silly-rename(recRpxeMd/udsockOxmZAh, ct=3)
> NFS: trying to rename udsockOxmZAh to .nfs00000000400a0e9a0000023c
> NFS: lookup(recRpxeMd/.nfs00000000400a0e9a0000023c)
> NFS: dentry_delete(recRpxeMd/.nfs00000000400a0e9a0000023c, 10)
> NFS: nfs_update_inode(0:d/1074400921 ct=1 info=0x7d7f)
> NFS: isize change on server for file 0:d/1074400921
> NFS: nfs_update_inode(0:d/3758724786 ct=2 info=0x1fdff)
> NFS: nfs_update_inode(0:d/1074400921 ct=1 info=0x7d7f)
> NFS: dentry_delete(recRpxeMd/.nfs00000000400a0e9a0000023c, 102)
> NFS: dentry_delete(recRpxeMd/smtAmobkv, 8)
> NFS: dentry_delete(recRpxeMd/smtAmobkv, 8)
> NFS: unlink(0:d/1074400921, smtAmobkv)
> NFS: safe_remove(recRpxeMd/smtAmobkv)
> NFS: dentry_delete(recRpxeMd/smtAmobkv, 18)
> NFS: nfs_update_inode(0:d/1074400921 ct=1 info=0x7d7f)
> NFS: mtime change on server for file 0:d/1074400921
> NFS: isize change on server for file 0:d/1074400921
> NFS: lookup(recRpxeMd/.nfs00000000400a0e9a0000023c)
> NFS: dentry_delete(recRpxeMd/.nfs00000000400a0e9a0000023c, 0)
> NFS: dentry_delete(bin/recvmsg02, 8)
> 
> 
> Cheers,
> -Ian
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>
