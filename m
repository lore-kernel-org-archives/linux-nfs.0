Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:33931 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbbIEXHC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Sep 2015 19:07:02 -0400
Received: by qgez77 with SMTP id z77so41158044qge.1
        for <linux-nfs@vger.kernel.org>; Sat, 05 Sep 2015 16:07:01 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Respect the server imposed limit on how many changes we may cache
Date: Sat,  5 Sep 2015 19:06:58 -0400
Message-Id: <1441494418-53583-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1441494418-53583-1-git-send-email-trond.myklebust@primarydata.com>
References: <1441494418-53583-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 delegation spec allows the server to tell a client to limit how
much data it cache after the file is closed. In return, the server
guarantees enough free space to avoid ENOSPC situations, etc.
Prior to this patch, we assumed we could always cache aggressively after
close. Unfortunately, this causes problems with servers that set the
limit to 0 and therefore do not offer any ENOSPC guarantees.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 25 +++++++++++++++++++++++++
 fs/nfs/delegation.h |  1 +
 fs/nfs/file.c       | 10 +---------
 fs/nfs/internal.h   |  1 -
 fs/nfs/nfs4file.c   | 29 ++++++++++++++++++++++++++++-
 5 files changed, 55 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 4817f66c8d47..a08c5c2ebddd 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -901,3 +901,28 @@ bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode,
 	rcu_read_unlock();
 	return ret;
 }
+
+/**
+ * nfs4_delegation_flush_on_close - Check if we must flush file on close
+ * @inode: inode to check
+ *
+ * This function checks the number of outstanding writes to the file
+ * against the delegation 'space_limit' field to see if
+ * the spec requires us to flush the file on close.
+ */
+bool nfs4_delegation_flush_on_close(const struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_delegation *delegation;
+	bool ret = true;
+
+	rcu_read_lock();
+	delegation = rcu_dereference(nfsi->delegation);
+	if (delegation == NULL || !(delegation->type & FMODE_WRITE))
+		goto out;
+	if (nfsi->nrequests < delegation->pagemod_limit)
+		ret = false;
+out:
+	rcu_read_unlock();
+	return ret;
+}
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 554178a17376..a44829173e57 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -61,6 +61,7 @@ bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode, fmode_
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs4_have_delegation(struct inode *inode, fmode_t flags);
 int nfs4_check_delegation(struct inode *inode, fmode_t flags);
+bool nfs4_delegation_flush_on_close(const struct inode *inode);
 
 #endif
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 526a2681d975..c0f9b1ed12b9 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -142,7 +142,7 @@ EXPORT_SYMBOL_GPL(nfs_file_llseek);
 /*
  * Flush all dirty pages, and check for write errors.
  */
-int
+static int
 nfs_file_flush(struct file *file, fl_owner_t id)
 {
 	struct inode	*inode = file_inode(file);
@@ -153,17 +153,9 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 	if ((file->f_mode & FMODE_WRITE) == 0)
 		return 0;
 
-	/*
-	 * If we're holding a write delegation, then just start the i/o
-	 * but don't wait for completion (or send a commit).
-	 */
-	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
-		return filemap_fdatawrite(file->f_mapping);
-
 	/* Flush writes to the server and return any errors */
 	return vfs_fsync(file, 0);
 }
-EXPORT_SYMBOL_GPL(nfs_file_flush);
 
 ssize_t
 nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9ab3b1c21bb4..56cfde26fb9c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -360,7 +360,6 @@ int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *)
 /* file.c */
 int nfs_file_fsync_commit(struct file *, loff_t, loff_t, int);
 loff_t nfs_file_llseek(struct file *, loff_t, int);
-int nfs_file_flush(struct file *, fl_owner_t);
 ssize_t nfs_file_read(struct kiocb *, struct iov_iter *);
 ssize_t nfs_file_splice_read(struct file *, loff_t *, struct pipe_inode_info *,
 			     size_t, unsigned int);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 43f1590b9240..b0dbe0abed53 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -6,7 +6,9 @@
 #include <linux/fs.h>
 #include <linux/falloc.h>
 #include <linux/nfs_fs.h>
+#include "delegation.h"
 #include "internal.h"
+#include "iostat.h"
 #include "fscache.h"
 #include "pnfs.h"
 
@@ -99,6 +101,31 @@ out_drop:
 	goto out_put_ctx;
 }
 
+/*
+ * Flush all dirty pages, and check for write errors.
+ */
+static int
+nfs4_file_flush(struct file *file, fl_owner_t id)
+{
+	struct inode	*inode = file_inode(file);
+
+	dprintk("NFS: flush(%pD2)\n", file);
+
+	nfs_inc_stats(inode, NFSIOS_VFSFLUSH);
+	if ((file->f_mode & FMODE_WRITE) == 0)
+		return 0;
+
+	/*
+	 * If we're holding a write delegation, then check if we're required
+	 * to flush the i/o on close. If not, then just start the i/o now.
+	 */
+	if (!nfs4_delegation_flush_on_close(inode))
+		return filemap_fdatawrite(file->f_mapping);
+
+	/* Flush writes to the server and return any errors */
+	return vfs_fsync(file, 0);
+}
+
 static int
 nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 {
@@ -177,7 +204,7 @@ const struct file_operations nfs4_file_operations = {
 	.write_iter	= nfs_file_write,
 	.mmap		= nfs_file_mmap,
 	.open		= nfs4_file_open,
-	.flush		= nfs_file_flush,
+	.flush		= nfs4_file_flush,
 	.release	= nfs_file_release,
 	.fsync		= nfs4_file_fsync,
 	.lock		= nfs_lock,
-- 
2.4.3

