Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48577 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932832Ab1KDRb2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 13:31:28 -0400
Received: by mail-vw0-f46.google.com with SMTP id 1so2106332vws.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 Nov 2011 10:31:28 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: move nfs_file_operations declaration to bottom of file.c (try #2)
Date: Fri,  4 Nov 2011 13:31:22 -0400
Message-Id: <1320427882-9102-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1320427882-9102-1-git-send-email-jlayton@redhat.com>
References: <1320427882-9102-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...a remove a set of forward declarations.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/file.c |   59 ++++++++++++++++++--------------------------------------
 1 files changed, 19 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index fedf176..531a3ba 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -40,48 +40,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
-static int nfs_file_open(struct inode *, struct file *);
-static int nfs_file_release(struct inode *, struct file *);
-static loff_t nfs_file_llseek(struct file *file, loff_t offset, int origin);
-static int  nfs_file_mmap(struct file *, struct vm_area_struct *);
-static ssize_t nfs_file_splice_read(struct file *filp, loff_t *ppos,
-					struct pipe_inode_info *pipe,
-					size_t count, unsigned int flags);
-static ssize_t nfs_file_read(struct kiocb *, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos);
-static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
-					struct file *filp, loff_t *ppos,
-					size_t count, unsigned int flags);
-static ssize_t nfs_file_write(struct kiocb *, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos);
-static int  nfs_file_flush(struct file *, fl_owner_t id);
-static int  nfs_file_fsync(struct file *, loff_t, loff_t, int datasync);
-static int nfs_check_flags(int flags);
-static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl);
-static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl);
-static int nfs_setlease(struct file *file, long arg, struct file_lock **fl);
-
 static const struct vm_operations_struct nfs_file_vm_ops;
 
-const struct file_operations nfs_file_operations = {
-	.llseek		= nfs_file_llseek,
-	.read		= do_sync_read,
-	.write		= do_sync_write,
-	.aio_read	= nfs_file_read,
-	.aio_write	= nfs_file_write,
-	.mmap		= nfs_file_mmap,
-	.open		= nfs_file_open,
-	.flush		= nfs_file_flush,
-	.release	= nfs_file_release,
-	.fsync		= nfs_file_fsync,
-	.lock		= nfs_lock,
-	.flock		= nfs_flock,
-	.splice_read	= nfs_file_splice_read,
-	.splice_write	= nfs_file_splice_write,
-	.check_flags	= nfs_check_flags,
-	.setlease	= nfs_setlease,
-};
-
 const struct inode_operations nfs_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
@@ -890,6 +850,25 @@ static int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 	return -EINVAL;
 }
 
+const struct file_operations nfs_file_operations = {
+	.llseek		= nfs_file_llseek,
+	.read		= do_sync_read,
+	.write		= do_sync_write,
+	.aio_read	= nfs_file_read,
+	.aio_write	= nfs_file_write,
+	.mmap		= nfs_file_mmap,
+	.open		= nfs_file_open,
+	.flush		= nfs_file_flush,
+	.release	= nfs_file_release,
+	.fsync		= nfs_file_fsync,
+	.lock		= nfs_lock,
+	.flock		= nfs_flock,
+	.splice_read	= nfs_file_splice_read,
+	.splice_write	= nfs_file_splice_write,
+	.check_flags	= nfs_check_flags,
+	.setlease	= nfs_setlease,
+};
+
 #ifdef CONFIG_NFS_V4
 static int
 nfs4_file_open(struct inode *inode, struct file *filp)
-- 
1.7.6.4

