Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34602 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbbLZXVm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:42 -0500
Received: by mail-io0-f179.google.com with SMTP id e126so280361770ioa.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:42 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/14] nfs: handle request add failure properly
Date: Sat, 26 Dec 2015 18:20:51 -0500
Message-Id: <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

When we fail to queue a read page to IO descriptor,
we need to clean it up otherwise it is hanging around
preventing nfs module from being removed.

When we fail to queue a write page to IO descriptor,
we need to clean it up and also save the failure status
to open context. Then at file close, we can try to write
pages back again and drop the page if it fails to writeback
in .launder_page, which will be done in the next patch.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c    |  6 ++++++
 fs/nfs/internal.h | 14 ++++++++++++++
 fs/nfs/pnfs.c     | 15 +++------------
 fs/nfs/read.c     | 41 +++++++++++++++++++++++------------------
 fs/nfs/write.c    | 22 +++++++++++++++++++++-
 5 files changed, 67 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c7e8b87da5b2..74fb1223c2f5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -912,6 +912,12 @@ void nfs_file_clear_open_context(struct file *filp)
 	if (ctx) {
 		struct inode *inode = d_inode(ctx->dentry);
 
+		/*
+		 * We fatal error on write before. Try to writeback
+		 * every page again.
+		 */
+		if (ctx->error < 0)
+			invalidate_inode_pages2(inode->i_mapping);
 		filp->private_data = NULL;
 		spin_lock(&inode->i_lock);
 		list_move_tail(&ctx->list, &NFS_I(inode)->open_files);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index df3556570123..c6c4b6e23074 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -717,3 +717,17 @@ static inline u32 nfs_stateid_hash(nfs4_stateid *stateid)
 	return 0;
 }
 #endif
+
+static inline bool nfs_error_is_fatal(int err)
+{
+	switch (err) {
+	case -ERESTARTSYS:
+	case -EIO:
+	case -ENOSPC:
+	case -EROFS:
+	case -E2BIG:
+		return true;
+	default:
+		return false;
+	}
+}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0fb3552ccfbe..580207bc52a5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -904,18 +904,9 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 		lseg = nfs4_proc_layoutget(lgp, gfp_flags);
 	} while (lseg == ERR_PTR(-EAGAIN));
 
-	if (IS_ERR(lseg)) {
-		switch (PTR_ERR(lseg)) {
-		case -ERESTARTSYS:
-		case -EIO:
-		case -ENOSPC:
-		case -EROFS:
-		case -E2BIG:
-			break;
-		default:
-			return NULL;
-		}
-	} else
+	if (IS_ERR(lseg) && !nfs_error_is_fatal(PTR_ERR(lseg)))
+		lseg = NULL;
+	else
 		pnfs_layout_clear_fail_bit(lo,
 				pnfs_iomode_to_fail_bit(range->iomode));
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 0bb580174cb3..eb31e23e7def 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -85,6 +85,23 @@ void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
 
+static void nfs_readpage_release(struct nfs_page *req)
+{
+	struct inode *inode = d_inode(req->wb_context->dentry);
+
+	dprintk("NFS: read done (%s/%llu %d@%lld)\n", inode->i_sb->s_id,
+		(unsigned long long)NFS_FILEID(inode), req->wb_bytes,
+		(long long)req_offset(req));
+
+	if (nfs_page_group_sync_on_bit(req, PG_UNLOCKPAGE)) {
+		if (PageUptodate(req->wb_page))
+			nfs_readpage_to_fscache(inode, req->wb_page, 0);
+
+		unlock_page(req->wb_page);
+	}
+	nfs_release_request(req);
+}
+
 int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		       struct page *page)
 {
@@ -106,7 +123,10 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 
 	nfs_pageio_init_read(&pgio, inode, false,
 			     &nfs_async_read_completion_ops);
-	nfs_pageio_add_request(&pgio, new);
+	if (!nfs_pageio_add_request(&pgio, new)) {
+		nfs_list_remove_request(new);
+		nfs_readpage_release(new);
+	}
 	nfs_pageio_complete(&pgio);
 
 	/* It doesn't make sense to do mirrored reads! */
@@ -118,23 +138,6 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	return pgio.pg_error < 0 ? pgio.pg_error : 0;
 }
 
-static void nfs_readpage_release(struct nfs_page *req)
-{
-	struct inode *inode = d_inode(req->wb_context->dentry);
-
-	dprintk("NFS: read done (%s/%llu %d@%lld)\n", inode->i_sb->s_id,
-		(unsigned long long)NFS_FILEID(inode), req->wb_bytes,
-		(long long)req_offset(req));
-
-	if (nfs_page_group_sync_on_bit(req, PG_UNLOCKPAGE)) {
-		if (PageUptodate(req->wb_page))
-			nfs_readpage_to_fscache(inode, req->wb_page, 0);
-
-		unlock_page(req->wb_page);
-	}
-	nfs_release_request(req);
-}
-
 static void nfs_page_group_set_uptodate(struct nfs_page *req)
 {
 	if (nfs_page_group_sync_on_bit(req, PG_UPTODATE))
@@ -361,6 +364,8 @@ readpage_async_filler(void *data, struct page *page)
 	if (len < PAGE_CACHE_SIZE)
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 	if (!nfs_pageio_add_request(desc->pgio, new)) {
+		nfs_list_remove_request(new);
+		nfs_readpage_release(new);
 		error = desc->pgio->pg_error;
 		goto out_unlock;
 	}
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 00a5d3c90acb..58fa3eb5c11c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -548,6 +548,15 @@ try_again:
 	return head;
 }
 
+static void nfs_write_error_remove_page(struct nfs_page *req)
+{
+	nfs_unlock_request(req);
+	nfs_end_page_writeback(req);
+	nfs_release_request(req);
+	generic_error_remove_page(page_file_mapping(req->wb_page),
+				  req->wb_page);
+}
+
 /*
  * Find an associated nfs write request, and prepare to flush it out
  * May return an error if the user signalled nfs_wait_on_request().
@@ -570,8 +579,19 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 
 	ret = 0;
 	if (!nfs_pageio_add_request(pgio, req)) {
-		nfs_redirty_request(req);
 		ret = pgio->pg_error;
+		/*
+		 * Remove the problematic req upon fatal errors,
+		 * while other dirty pages can still be around
+		 * until they get flushed.
+		 */
+		if (nfs_error_is_fatal(ret)) {
+			nfs_context_set_write_error(req->wb_context, ret);
+			nfs_write_error_remove_page(req);
+		} else {
+			nfs_redirty_request(req);
+			ret = -EAGAIN;
+		}
 	} else
 		nfs_add_stats(page_file_mapping(page)->host,
 				NFSIOS_WRITEPAGES, 1);
-- 
2.5.0

