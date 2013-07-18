Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50474 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759348Ab3GRTfm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jul 2013 15:35:42 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 4/5] NFS avoid expired credential keys for buffered writes
Date: Thu, 18 Jul 2013 15:35:29 -0400
Message-ID: <1374176130-11657-5-git-send-email-andros@netapp.com>
In-Reply-To: <1374176130-11657-1-git-send-email-andros@netapp.com>
References: <1374176130-11657-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We must avoid buffering a WRITE that is using a credential key (e.g. a GSS
context key) that is about to expire.  We currently will paint ourselves
into a corner by returning success to the applciation for such a buffered
WRITE, only to discover that we do not have permission when
we attempt to flush the WRITE (and potentially associated COMMIT) to disk.

Use the RPC layer credential key timeout and expire routines which use a
a watermark, gss_key_expire_timeo. We test the key in nfs_file_write.

If a WRITE is using a credential with a key that will expire within
watermark seconds, flush the inode in nfs_write_end and send only
NFS_FILE_SYNC WRITEs by adding nfs_ctx_key_to_expire to nfs_need_sync_write.
Note that this results in single page NFS_FILE_SYNC WRITEs.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/file.c     | 19 ++++++++++++++++++-
 fs/nfs/internal.h |  2 ++
 fs/nfs/write.c    | 27 +++++++++++++++++++++++++++
 3 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 94e94bd..dfff8df 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -406,6 +406,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			struct page *page, void *fsdata)
 {
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	int status;
 
 	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
@@ -441,6 +442,17 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	if (status < 0)
 		return status;
 	NFS_I(mapping->host)->write_io += copied;
+
+	if (nfs_ctx_key_to_expire(ctx)) {
+		pr_warn_once("NFS:	Credential Key to expire. Flush %s/%s(%ld)\n",
+			file->f_path.dentry->d_parent->d_name.name,
+			file->f_path.dentry->d_name.name,
+			mapping->host->i_ino);
+		status = nfs_wb_all(mapping->host);
+		if (status < 0)
+			return status;
+	}
+
 	return copied;
 }
 
@@ -637,7 +649,8 @@ static int nfs_need_sync_write(struct file *filp, struct inode *inode)
 	if (IS_SYNC(inode) || (filp->f_flags & O_DSYNC))
 		return 1;
 	ctx = nfs_file_open_context(filp);
-	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags))
+	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags) ||
+	    nfs_ctx_key_to_expire(ctx))
 		return 1;
 	return 0;
 }
@@ -651,6 +664,10 @@ ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t result;
 	size_t count = iov_length(iov, nr_segs);
 
+	result = nfs_key_timeout_notify(iocb->ki_filp, inode);
+	if (result)
+		return result;
+
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_write(iocb, iov, nr_segs, pos, true);
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3c8373f..e86dc20 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -430,6 +430,8 @@ void nfs_request_remove_commit_list(struct nfs_page *req,
 void nfs_init_cinfo(struct nfs_commit_info *cinfo,
 		    struct inode *inode,
 		    struct nfs_direct_req *dreq);
+int nfs_key_timeout_notify(struct file *filp, struct inode *inode);
+bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx);
 
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 724c845..144085c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -874,6 +874,33 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 }
 
 /*
+ * Avoid buffered writes when a open context credential's key would
+ * expire soon.
+ *
+ * Returns -EACCES if the key will expire within RPC_KEY_EXPIRE_FAIL.
+ *
+ * Return 0 and set a credential flag which triggers the inode to flush
+ * and performs  NFS_FILE_SYNC writes if the key will expired within
+ * RPC_KEY_EXPIRE_TIMEO.
+ */
+int
+nfs_key_timeout_notify(struct file *filp, struct inode *inode)
+{
+	struct nfs_open_context *ctx = nfs_file_open_context(filp);
+	struct rpc_auth *auth = NFS_SERVER(inode)->client->cl_auth;
+
+	return rpcauth_key_timeout_notify(auth, ctx->cred);
+}
+
+/*
+ * Test if the open context credential key is marked to expire soon.
+ */
+bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx)
+{
+	return rpcauth_cred_key_to_expire(ctx->cred);
+}
+
+/*
  * If the page cache is marked as unsafe or invalid, then we can't rely on
  * the PageUptodate() flag. In this case, we will need to turn off
  * write optimisations that depend on the page contents being correct.
-- 
1.8.3.1

