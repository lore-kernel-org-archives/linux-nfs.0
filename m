Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36798 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbcFWUBc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2016 16:01:32 -0400
Received: by mail-io0-f195.google.com with SMTP id s63so13252725ioi.3
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jun 2016 13:01:32 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 12/17] NFS: Move buffered I/O locking into nfs_file_write()
Date: Thu, 23 Jun 2016 16:00:44 -0400
Message-Id: <1466712049-5326-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466712049-5326-11-git-send-email-trond.myklebust@primarydata.com>
References: <1466712049-5326-1-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-2-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-3-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-4-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-5-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-6-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-7-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-8-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-9-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-10-git-send-email-trond.myklebust@primarydata.com>
 <1466712049-5326-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Preparation for the patch that de-serialises O_DIRECT reads and
writes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c26847c84d00..46cf0afe3c0f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -623,7 +623,6 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	struct inode *inode = file_inode(file);
 	unsigned long written = 0;
 	ssize_t result;
-	size_t count = iov_iter_count(from);
 
 	result = nfs_key_timeout_notify(file, inode);
 	if (result)
@@ -633,9 +632,8 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 		return nfs_file_direct_write(iocb, from);
 
 	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
-		file, count, (long long) iocb->ki_pos);
+		file, iov_iter_count(from), (long long) iocb->ki_pos);
 
-	result = -EBUSY;
 	if (IS_SWAPFILE(inode))
 		goto out_swapfile;
 	/*
@@ -647,28 +645,33 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 			goto out;
 	}
 
-	result = count;
-	if (!count)
+	inode_lock(inode);
+	result = generic_write_checks(iocb, from);
+	if (result > 0) {
+		current->backing_dev_info = inode_to_bdi(inode);
+		result = generic_perform_write(file, from, iocb->ki_pos);
+		current->backing_dev_info = NULL;
+	}
+	inode_unlock(inode);
+	if (result <= 0)
 		goto out;
 
-	result = generic_file_write_iter(iocb, from);
-	if (result > 0)
-		written = result;
+	written = generic_write_sync(iocb, result);
+	iocb->ki_pos += written;
 
 	/* Return error values */
-	if (result >= 0 && nfs_need_check_write(file, inode)) {
+	if (nfs_need_check_write(file, inode)) {
 		int err = vfs_fsync(file, 0);
 		if (err < 0)
 			result = err;
 	}
-	if (result > 0)
-		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
+	nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
 out:
 	return result;
 
 out_swapfile:
 	printk(KERN_INFO "NFS: attempt to write to active swap file!\n");
-	goto out;
+	return -EBUSY;
 }
 EXPORT_SYMBOL_GPL(nfs_file_write);
 
-- 
2.7.4

