Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:58378 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbaIDMi4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:38:56 -0400
Received: by mail-qc0-f170.google.com with SMTP id r5so10561193qcx.1
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:38:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Steven Whitehouse <swhiteho@redhat.com>, <cluster-devel@redhat.com>
Subject: [PATCH v2 01/17] locks: consolidate "nolease" routines
Date: Thu,  4 Sep 2014 08:38:27 -0400
Message-Id: <1409834323-7171-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

GFS2 and NFS have setlease routines that always just return -EINVAL.
Turn that into a generic routine that can live in fs/libfs.c.

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: <linux-nfs@vger.kernel.org>
Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: <cluster-devel@redhat.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/gfs2/file.c     | 22 +---------------------
 fs/libfs.c         | 16 ++++++++++++++++
 fs/nfs/file.c      | 13 +------------
 fs/nfs/internal.h  |  1 -
 fs/nfs/nfs4file.c  |  2 +-
 include/linux/fs.h |  1 +
 6 files changed, 20 insertions(+), 35 deletions(-)

diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 26b3f952e6b1..2c02478a86b0 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -913,26 +913,6 @@ out_uninit:
 #ifdef CONFIG_GFS2_FS_LOCKING_DLM
 
 /**
- * gfs2_setlease - acquire/release a file lease
- * @file: the file pointer
- * @arg: lease type
- * @fl: file lock
- *
- * We don't currently have a way to enforce a lease across the whole
- * cluster; until we do, disable leases (by just returning -EINVAL),
- * unless the administrator has requested purely local locking.
- *
- * Locking: called under i_lock
- *
- * Returns: errno
- */
-
-static int gfs2_setlease(struct file *file, long arg, struct file_lock **fl)
-{
-	return -EINVAL;
-}
-
-/**
  * gfs2_lock - acquire/release a posix lock on a file
  * @file: the file pointer
  * @cmd: either modify or retrieve lock state, possibly wait
@@ -1069,7 +1049,7 @@ const struct file_operations gfs2_file_fops = {
 	.flock		= gfs2_flock,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= iter_file_splice_write,
-	.setlease	= gfs2_setlease,
+	.setlease	= simple_nosetlease,
 	.fallocate	= gfs2_fallocate,
 };
 
diff --git a/fs/libfs.c b/fs/libfs.c
index 88e3e00e2eca..29012a303ef8 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -1075,3 +1075,19 @@ struct inode *alloc_anon_inode(struct super_block *s)
 	return inode;
 }
 EXPORT_SYMBOL(alloc_anon_inode);
+
+/**
+ * simple_nosetlease - generic helper for prohibiting leases
+ * @filp: file pointer
+ * @arg: type of lease to obtain
+ * @flp: new lease supplied for insertion
+ *
+ * Generic helper for filesystems that do not wish to allow leases to be set.
+ * All arguments are ignored and it just returns -EINVAL.
+ */
+int
+simple_nosetlease(struct file *filp, long arg, struct file_lock **flp)
+{
+	return -EINVAL;
+}
+EXPORT_SYMBOL(simple_nosetlease);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 524dd80d1898..8c4048ecdad1 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -891,17 +891,6 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 }
 EXPORT_SYMBOL_GPL(nfs_flock);
 
-/*
- * There is no protocol support for leases, so we have no way to implement
- * them correctly in the face of opens by other clients.
- */
-int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
-{
-	dprintk("NFS: setlease(%pD2, arg=%ld)\n", file, arg);
-	return -EINVAL;
-}
-EXPORT_SYMBOL_GPL(nfs_setlease);
-
 const struct file_operations nfs_file_operations = {
 	.llseek		= nfs_file_llseek,
 	.read		= new_sync_read,
@@ -918,6 +907,6 @@ const struct file_operations nfs_file_operations = {
 	.splice_read	= nfs_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 	.check_flags	= nfs_check_flags,
-	.setlease	= nfs_setlease,
+	.setlease	= simple_nosetlease,
 };
 EXPORT_SYMBOL_GPL(nfs_file_operations);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9056622d2230..94d922ebb5ac 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -346,7 +346,6 @@ int nfs_file_release(struct inode *, struct file *);
 int nfs_lock(struct file *, int, struct file_lock *);
 int nfs_flock(struct file *, int, struct file_lock *);
 int nfs_check_flags(int);
-int nfs_setlease(struct file *, long, struct file_lock **);
 
 /* inode.c */
 extern struct workqueue_struct *nfsiod_workqueue;
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index a816f0627a6c..3e987ad9ae25 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -131,5 +131,5 @@ const struct file_operations nfs4_file_operations = {
 	.splice_read	= nfs_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 	.check_flags	= nfs_check_flags,
-	.setlease	= nfs_setlease,
+	.setlease	= simple_nosetlease,
 };
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 458f733c96bd..435e3d9ec5cf 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2599,6 +2599,7 @@ extern int simple_write_end(struct file *file, struct address_space *mapping,
 			struct page *page, void *fsdata);
 extern int always_delete_dentry(const struct dentry *);
 extern struct inode *alloc_anon_inode(struct super_block *);
+extern int simple_nosetlease(struct file *, long, struct file_lock **);
 extern const struct dentry_operations simple_dentry_operations;
 
 extern struct dentry *simple_lookup(struct inode *, struct dentry *, unsigned int flags);
-- 
1.9.3

