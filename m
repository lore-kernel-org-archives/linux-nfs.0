Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55427 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750807AbdHRHN7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 03:13:59 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Aug 2017 17:12:51 +1000
Subject: [PATCH 4/8] NFS: flush out dirty data on file fput().
Cc: linux-nfs@vger.kernel.org
Message-ID: <150304037195.30218.15740287358704674869.stgit@noble>
In-Reply-To: <150304014011.30218.1636255532744321171.stgit@noble>
References: <150304014011.30218.1636255532744321171.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any dirty NFS page holds an s_active reference on the superblock,
because page_private() references an nfs_page, which references an
open context, which references the superblock.

So if there are any dirty pages when the filesystem is unmounted, the
unmount will act like a "lazy" unmount and not call ->kill_sb().
Background write-back can then write out the pages *after* the filesystem
unmount has apparently completed.

This contrasts with other filesystems which do not hold extra s_active
references, so ->kill_sb() is reliably called on unmount, and
generic_shutdown_super() will call sync_filesystem() to flush
everything out before the unmount completes.

When open/write/close is used to modify files, the final close causes
f_op->flush to be called, which flushes all dirty pages.  However if
open/mmap/close/modify-memory/unmap is used, dirty pages can remain in
memory after the application has dropped all references to the file.
Similarly if a loop-mount is done with a NFS file, there is no final
flush when the loop device is destroyed and the file can have dirty
data after the last "close".

Also, a loop-back mount of a device does not "close" the file when the
loop device is destroyed.  This can leave dirty page cache pages too.

Fix this by calling vfs_fsync() in nfs_file_release (aka
f_op->release()).  This means that on the final unmap of a file (or
destruction of a loop device), all changes are flushed, and ensures that
when unmount is requested there will be no dirty pages to delay the
final unmount.

Without this patch, it is not safe to stop or disconnect the NFS
server after all clients have unmounted.  They need to unmount and
call "sync".

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/file.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index af330c31f627..aa883d8b24e6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -81,6 +81,12 @@ nfs_file_release(struct inode *inode, struct file *filp)
 {
 	dprintk("NFS: release(%pD2)\n", filp);
 
+	if (filp->f_mode & FMODE_WRITE)
+		/* Ensure dirty mmapped pages are flushed
+		 * so there will be no dirty pages to
+		 * prevent an unmount from completing.
+		 */
+		vfs_fsync(filp, 0);
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
 	nfs_file_clear_open_context(filp);
 	return 0;


