Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23855 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757673Ab2IFTyL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 15:54:11 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/4] NFS avoid expired credential keys for buffered writes
Date: Thu,  6 Sep 2012 15:54:11 -0400
Message-Id: <1346961251-2554-5-git-send-email-andros@netapp.com>
In-Reply-To: <1346961251-2554-1-git-send-email-andros@netapp.com>
References: <1346961251-2554-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We must avoid buffering a WRITE that is using a credential key (e.g. a GSS
context key) that is about to expire or has expired.  We currently will
paint ourselves into a corner by returning success to the applciation
for such a buffered WRITE, only to discover that we do not have permission when
we attempt to flush the WRITE (and potentially associated COMMIT) to disk.

Use the RPC layer credential key timeout and expire routines which use a
high and and a low watermark - RPC_KEY_EXPIRE_TIMEO and RPC_KEY_EXPIRE_FAIL.
We test the key in nfs_write_begin.

If a buffered WRITE is using a credential with a key that will expire within
high watermark seconds, flush the inode in nfs_write_end and send only
NFS_FILE_SYNC WRITEs. Note that this results in single page NFS_FILE_SYNC WRITEs.

If the buffered WRITE is using a credential key that will expire within low
watermark seconds, fail the WRITE in nfs_write_begin _before_ the WRITE is
buffered and return -EACCES to the application.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/file.c     |   10 ++++++++++
 fs/nfs/internal.h |    2 ++
 fs/nfs/write.c    |   29 +++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 75d6d0a..df776e5 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -345,6 +345,7 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 	int ret;
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 	struct page *page;
+	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	int once_thru = 0;
 
 	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
@@ -362,6 +363,10 @@ start:
 	if (ret)
 		return ret;
 
+	ret = nfs_ctx_key_timeout_notify(ctx);
+	if (ret)
+		return ret;
+
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
@@ -387,6 +392,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			struct page *page, void *fsdata)
 {
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	int status;
 
 	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
@@ -422,6 +428,10 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	if (status < 0)
 		return status;
 	NFS_I(mapping->host)->write_io += copied;
+
+	if (nfs_ctx_key_to_expire(ctx))
+		nfs_wb_all(mapping->host);
+
 	return copied;
 }
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31fdb03..cf4764e 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -449,6 +449,8 @@ void nfs_request_remove_commit_list(struct nfs_page *req,
 void nfs_init_cinfo(struct nfs_commit_info *cinfo,
 		    struct inode *inode,
 		    struct nfs_direct_req *dreq);
+int nfs_ctx_key_timeout_notify(struct nfs_open_context *ctx);
+bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx);
 
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e3b5537..9fa538f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -872,6 +872,32 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
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
+nfs_ctx_key_timeout_notify(struct nfs_open_context *ctx)
+{
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
@@ -1024,6 +1050,9 @@ static void nfs_write_rpcsetup(struct nfs_write_data *data,
 		data->args.stable = NFS_FILE_SYNC;
 	}
 
+	if (nfs_ctx_key_to_expire(data->args.context))
+		data->args.stable = NFS_FILE_SYNC;
+
 	data->res.fattr   = &data->fattr;
 	data->res.count   = count;
 	data->res.verf    = &data->verf;
-- 
1.7.7.6

