Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55468 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755375Ab2INVLg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 17:11:36 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 4/5] NFS avoid expired credential keys for buffered writes
Date: Fri, 14 Sep 2012 17:11:48 -0400
Message-Id: <1347657109-2180-5-git-send-email-andros@netapp.com>
In-Reply-To: <1347657109-2180-1-git-send-email-andros@netapp.com>
References: <1347657109-2180-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We must avoid buffering a WRITE that is using a credential key (e.g. a GSS
context key) that is about to expire or has expired.  We currently will
paint ourselves into a corner by returning success to the applciation
for such a buffered WRITE, only to discover that we do not have permission when
we attempt to flush the WRITE (and potentially associated COMMIT) to disk.

Use the RPC layer credential key timeout and expire routines which use a
a watermark, RPC_KEY_EXPIRE_TIMEO. We test the key in nfs_file_write.

If a WRITE is using a credential with a key that will expire within
watermark seconds, flush the inode in nfs_write_end and send only
NFS_FILE_SYNC WRITEs by adding nfs_ctx_key_to_expire to nfs_need_sync_write.
Note that this results in single page NFS_FILE_SYNC WRITEs.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/file.c     |   15 ++++++++++++++-
 fs/nfs/internal.h |    2 ++
 fs/nfs/write.c    |   27 +++++++++++++++++++++++++++
 3 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6a7fcab..e2937f2 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -389,6 +389,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			struct page *page, void *fsdata)
 {
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	int status;
 
 	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
@@ -424,6 +425,13 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	if (status < 0)
 		return status;
 	NFS_I(mapping->host)->write_io += copied;
+
+	if (nfs_ctx_key_to_expire(ctx)) {
+		status = nfs_wb_all(mapping->host);
+		if (status < 0)
+			return status;
+	}
+
 	return copied;
 }
 
@@ -587,7 +595,8 @@ static int nfs_need_sync_write(struct file *filp, struct inode *inode)
 	if (IS_SYNC(inode) || (filp->f_flags & O_DSYNC))
 		return 1;
 	ctx = nfs_file_open_context(filp);
-	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags))
+	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags) ||
+	    nfs_ctx_key_to_expire(ctx))
 		return 1;
 	return 0;
 }
@@ -601,6 +610,10 @@ ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t result;
 	size_t count = iov_length(iov, nr_segs);
 
+	result = nfs_key_timeout_notify(iocb->ki_filp);
+	if (result)
+		return result;
+
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_write(iocb, iov, nr_segs, pos, true);
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31fdb03..52e06e0 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -449,6 +449,8 @@ void nfs_request_remove_commit_list(struct nfs_page *req,
 void nfs_init_cinfo(struct nfs_commit_info *cinfo,
 		    struct inode *inode,
 		    struct nfs_direct_req *dreq);
+int nfs_key_timeout_notify(struct file *filp);
+bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx);
 
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e3b5537..1029c07 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -872,6 +872,33 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
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
+nfs_key_timeout_notify(struct file *filp)
+{
+	struct nfs_open_context *ctx = nfs_file_open_context(filp);
+	struct rpc_auth *auth = NFS_SERVER(ctx->state->inode)->client->cl_auth;
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
1.7.7.6

