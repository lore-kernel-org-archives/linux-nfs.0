From: Nick Wilson <njw@osdl.org>
Subject: [PATCH] NFS: fix client hang due to race condition
Date: Wed, 6 Jul 2005 14:27:44 -0700
Message-ID: <20050706212744.GC20698@njw.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DqHOI-0003RG-O0
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 14:25:10 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DqHOH-0000z8-AG
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 14:25:10 -0700
To: trond.myklebust@fys.uio.no
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

The flags field in struct nfs_inode is protected by the BKL.  The
following two code paths (there may be more, but my test program only
hits these two) modify the flags without obtaining the lock:

    nfs_end_data_update
    nfs_release
    nfs_file_release
    __fput
    fput
    filp_close
    sys_close
    syscall_call

    nfs_revalidate_mapping
    nfs_file_write
    do_sync_write
    vfs_write
    sys_write
    syscall_call

Running multiple instances of a simple program [1] that opens, writes
to, and closes NFS mounted files eventually results in the programs
hanging on an SMP system (see kernel .config [3]).

I've been testing this with 100 instances of the program:
    $ ./breaknfs 100 &

Usually within 10 minutes, all instances of breaknfs will hang.  They
disappear from the output of 'top' and there is no NFS activity between
the client and server.

/proc/*/wchan shows 22 instances of breaknfs are waiting on
nfs_wait_on_inode, and 78 on .text.lock.namei

echo t > /proc/sysrq-trigger output [2] shows 22 instances of breaknfs
similar to this...:
    breaknfs      S 00100100  5060  5530   5523          5531  5529 (NOTLB)
    de0d1e24 00000086 c01178e0 00100100 de0d1de4 00000000 00000000 de0d1e14
    de0d1dec c0309513 de0d1e0c c0127c7e 00000000 dfaff020 c140e400 000004c3
    b37f50b5 0000003a c140e8c0 de7815b0 de7816d8 dbb5963c dbb59650 de0d0000
    Call Trace:
    [<c01eac01>] nfs_wait_on_inode+0x1b1/0x1c0
    [<c01eb2ac>] __nfs_revalidate_inode+0x2cc/0x340
    [<c01e8b1c>] nfs_file_flush+0x8c/0xc0
    [<c0159366>] filp_close+0x56/0x70
    [<c01593e9>] sys_close+0x69/0x90
    [<c0103039>] syscall_call+0x7/0xb

... and 78 similar to this:
    breaknfs      D 00000310  5060  5523   5466  5524               (NOTLB)
    ddcafebc 00000082 c0369810 00000310 ddcaff58 ddcafe90 db975690 00000000
    ddcafee0 ddcafe94 c0170a75 ddcaff58 00000000 dfaff020 c140e400 00000178
    b2b3096d 0000003a c140e8c0 df839550 df839678 dbb59e70 dbb59e78 00000286
    Call Trace:
    [<c03075b3>] __down+0x83/0xe0
    [<c030772e>] __down_failed+0xa/0x10
    [<c016b295>] .text.lock.namei+0xaa/0x1e5
    [<c0158e5d>] filp_open+0x2d/0x50
    [<c01592ad>] sys_open+0x4d/0x80
    [<c0103039>] syscall_call+0x7/0xb

NFS mount options from /proc/mounts:
    rw,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=njw

I've reproduced this bug on 2.6.11.10, 2.6.12-mm2, and 2.6.13-rc2.

With my patch against 2.6.13-rc2 below, I ran 100 instances of breaknfs
with this patch for 14 hours and I was unable to get the client to hang.

Thanks,

Nick Wilson

[1] http://developer.osdl.org/njw/nfs-bug/breaknfs.c
[2] http://developer.osdl.org/njw/nfs-bug/alt-sysrq-t.txt
[3] http://developer.osdl.org/njw/nfs-bug/kernel-config



The flags field in struct nfs_inode is protected by the BKL. This patch
fixes a couple places where the lock is not obtained before changing the
flags.

Signed-off-by: Nick Wilson <njw@osdl.org>
---

 inode.c |    4 ++++
 1 files changed, 4 insertions(+)

--- linux.orig/fs/nfs/inode.c	2005-07-06 11:08:27.000000000 -0700
+++ linux/fs/nfs/inode.c	2005-07-06 11:20:19.000000000 -0700
@@ -1118,7 +1118,9 @@ void nfs_revalidate_mapping(struct inode
 			nfs_wb_all(inode);
 		}
 		invalidate_inode_pages2(mapping);
+		lock_kernel();
 		nfsi->flags &= ~NFS_INO_INVALID_DATA;
+		unlock_kernel();
 		if (S_ISDIR(inode->i_mode)) {
 			memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
 			/* This ensures we revalidate child dentries */
@@ -1153,10 +1155,12 @@ void nfs_end_data_update(struct inode *i
 
 	if (!nfs_have_delegation(inode, FMODE_READ)) {
 		/* Mark the attribute cache for revalidation */
+		lock_kernel();
 		nfsi->flags |= NFS_INO_INVALID_ATTR;
 		/* Directories and symlinks: invalidate page cache too */
 		if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode))
 			nfsi->flags |= NFS_INO_INVALID_DATA;
+		unlock_kernel();
 	}
 	nfsi->cache_change_attribute ++;
 	atomic_dec(&nfsi->data_updates);
_


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
