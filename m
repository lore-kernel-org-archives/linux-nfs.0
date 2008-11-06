From: Alex Sidorenko <asid@hp.com>
Subject: FLushing cached writes in nfs_getattr() and stat() delay
Date: Thu, 6 Nov 2008 10:34:06 -0500
Message-ID: <200811061034.06486.asid@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:11248 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924AbYKFPeH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2008 10:34:07 -0500
Received: from g5t0034.atlanta.hp.com (l3107tux.atl.hp.com [15.195.192.24])
	by g4t0015.houston.hp.com (Postfix) with ESMTP id 0A8AC840B
	for <linux-nfs@vger.kernel.org>; Thu,  6 Nov 2008 15:34:07 +0000 (UTC)
Received: from [16.212.7.162] (unknown [16.212.7.162])
	by g5t0034.atlanta.hp.com (Postfix) with ESMTP id AAB95541F5
	for <linux-nfs@vger.kernel.org>; Thu,  6 Nov 2008 15:34:06 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I am an HP engineer participating in L3 Linux support. Recently we have found 
that current design of nfs_getattr() might create huge delays in stat() on 
the file we are writing to (this is important for big files only, >2Gb).

The problem
-----------

Assuming that /nfs is an NFS-mounted FS:

1. In one shell, start
$ dd if=/dev/zero of=/nfs/dir/big bs=1G count=20

2. In another shell, start

$ ls -l /nfs/dir

or

$ ls -l /nfs/dir/big

'ls' does not return until the whole /nfs/dir/big is written.

Analysis
--------

Kernel 2.6.16 has introduced the following change in nfs_getattr():


    NFS: Make stat() return updated mtimes after a write()

    The SuS states that a call to write() will cause mtime to be updated on
    the file. In order to satisfy that requirement, we need to flush out
    any cached writes in nfs_getattr().
    Speed things up slightly by not committing the writes.

    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

+	/* Flush out writes to the server in order to update c/mtime */
+	nfs_sync_inode(inode, 0, 0, FLUSH_WAIT|FLUSH_NOCOMMIT);

Then later:

2.6.16-rc6:

http://www.linux-nfs.org/Linux-2.6.x/2.6.16-rc6/linux-2.6.16-99-fix_nfs_sync_inode_race.dif

 	/* Flush out writes to the server in order to update c/mtime */
-	nfs_sync_inode(inode, 0, 0, FLUSH_WAIT|FLUSH_NOCOMMIT);
+	nfs_sync_inode_wait(inode, 0, 0, FLUSH_NOCOMMIT);


I understand the reasoning behind that. From application point of view, NFS 
file/directory should behave the same as on local FS. If we have queued many 
writes, without this patch stat() will return incorrect results, both for 
mtime and file length. Some applications may depend on stat() results being 
correct.

At the same time, the fact that we have to wait forever while copying big 
files and doing 'ls -l' on that directory (or on the file being written) is 
not very good either (two HP customers have complained about this after 
migrating from RHEL4 to RHEL5).

The problem is still there in 2.6.27. I am not sure what can be done to both 
reduce the stat() delay and guarantee reasonable stat() results. 

It is interesting that with 'noac' stat() returns much faster (just 1-3s 
delay).

Best regards,
Alex

-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: asid@hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
