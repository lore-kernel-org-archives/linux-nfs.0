From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH] [RESEND] nfs: add support for splice writes
Date: Mon, 25 May 2009 12:32:08 +0530
Message-ID: <4A1A4270.2020207@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:43651 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbZEYHCN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 May 2009 03:02:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adds support for splice writes. It effectively calls
generic_file_splice_write() to do the writes.

We need not worry about O_APPEND case as the combination of splice()
writes and O_APPEND is disallowed. This patch propagates NFS write
errors back to the caller. The number of bytes written via splice are
being added to NFSIO_NORMALWRITTENBYTES as these are effectively
cached writes.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 fs/nfs/file.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index ec7e27d..3f80c5e 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -48,6 +48,9 @@ static ssize_t nfs_file_splice_read(struct file *filp, loff_t *ppos,
 					size_t count, unsigned int flags);
 static ssize_t nfs_file_read(struct kiocb *, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos);
+static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
+					struct file *filp, loff_t *ppos,
+					size_t count, unsigned int flags);
 static ssize_t nfs_file_write(struct kiocb *, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos);
 static int  nfs_file_flush(struct file *, fl_owner_t id);
@@ -73,6 +76,7 @@ const struct file_operations nfs_file_operations = {
 	.lock		= nfs_lock,
 	.flock		= nfs_flock,
 	.splice_read	= nfs_file_splice_read,
+	.splice_write	= nfs_file_splice_write,
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
@@ -587,6 +591,33 @@ out_swapfile:
 	goto out;
 }
 
+static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
+				     struct file *filp, loff_t *ppos,
+				     size_t count, unsigned int flags)
+{
+	struct dentry *dentry = filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	ssize_t ret;
+
+	dprintk("NFS splice_write(%s/%s, %lu@%llu)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		(unsigned long) count, (unsigned long long) *ppos);
+
+	/*
+	 * The combination of splice and an O_APPEND destination is disallowed.
+	 */
+
+	nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, count);
+
+	ret = generic_file_splice_write(pipe, filp, ppos, count, flags);
+	if (ret >= 0 && nfs_need_sync_write(filp, inode)) {
+		int err = nfs_do_fsync(nfs_file_open_context(filp), inode);
+		if (err < 0)
+			ret = err;
+	}
+	return ret;
+}
+
 static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
