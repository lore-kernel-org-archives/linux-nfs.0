From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] NFS: Improve NFS iostat byte count accuracy for writes
Date: Mon, 01 Feb 2010 14:17:41 -0500
Message-ID: <20100201191741.20189.50000.stgit@localhost.localdomain>
References: <20100201191415.20189.39710.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:57104 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755580Ab0BATRv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2010 14:17:51 -0500
In-Reply-To: <20100201191415.20189.39710.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The bytes counted by the performance counters for NFS writes should
reflect write and sync errors.  If the write(2) system call reports
an error, the bytes should not be counted.  And, if the write is
short, the actual number of bytes that was written should be counted,
not the number of bytes that was requested.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/file.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 64278c8..1fc8175 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -599,6 +599,7 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 {
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
+	unsigned long written = 0;
 	ssize_t result;
 	size_t count = iov_length(iov, nr_segs);
 
@@ -625,14 +626,18 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!count)
 		goto out;
 
-	nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, count);
 	result = generic_file_aio_write(iocb, iov, nr_segs, pos);
+	if (result > 0)
+		written = result;
+
 	/* Return error values for O_DSYNC and IS_SYNC() */
 	if (result >= 0 && nfs_need_sync_write(iocb->ki_filp, inode)) {
 		int err = nfs_do_fsync(nfs_file_open_context(iocb->ki_filp), inode);
 		if (err < 0)
 			result = err;
 	}
+	if (result > 0)
+		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
 out:
 	return result;
 
@@ -647,6 +652,7 @@ static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 {
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
+	unsigned long written = 0;
 	ssize_t ret;
 
 	dprintk("NFS splice_write(%s/%s, %lu@%llu)\n",
@@ -657,14 +663,17 @@ static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 	 * The combination of splice and an O_APPEND destination is disallowed.
 	 */
 
-	nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, count);
-
 	ret = generic_file_splice_write(pipe, filp, ppos, count, flags);
+	if (ret > 0)
+		written = ret;
+
 	if (ret >= 0 && nfs_need_sync_write(filp, inode)) {
 		int err = nfs_do_fsync(nfs_file_open_context(filp), inode);
 		if (err < 0)
 			ret = err;
 	}
+	if (ret > 0)
+		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
 	return ret;
 }
 

