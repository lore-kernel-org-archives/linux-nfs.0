Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:37447 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754742AbeCGU6l (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2018 15:58:41 -0500
Received: by mail-it0-f67.google.com with SMTP id k79so5174259ita.2
        for <linux-nfs@vger.kernel.org>; Wed, 07 Mar 2018 12:58:41 -0800 (PST)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id j130sm9248090ita.33.2018.03.07.12.58.39
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Mar 2018 12:58:39 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Record file size changes when doing O_DIRECT writes
Date: Wed,  7 Mar 2018 15:58:17 -0500
Message-Id: <20180307205817.5913-2-trond.myklebust@primarydata.com>
In-Reply-To: <20180307205817.5913-1-trond.myklebust@primarydata.com>
References: <20180307205817.5913-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we do update the file size when doing O_DIRECT writes
rather than relying on attribute updates. Those may not be
immediately forthcoming if this is a delegated file and/or we
are doing pNFS.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c   |  1 +
 fs/nfs/internal.h |  1 +
 fs/nfs/write.c    | 14 +++++---------
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 621c517b325c..aae35f87d4d0 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -938,6 +938,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 		return result < 0 ? result : -EIO;
 	}
 
+	nfs_grow_file(inode, dreq->io_start, requested_bytes);
 	if (put_dreq(dreq))
 		nfs_direct_write_complete(dreq);
 	return requested_bytes;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8357ff69962f..51ecc634f79a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -474,6 +474,7 @@ extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			const struct nfs_pgio_completion_ops *compl_ops);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_commit_free(struct nfs_commit_data *p);
+void nfs_grow_file(struct inode *inode, loff_t offset, unsigned int count);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_commit_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_initiate_commit(struct rpc_clnt *clnt,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7428a669d7a7..93460f1cf5a4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -216,18 +216,13 @@ static struct nfs_page *nfs_page_find_head_request(struct page *page)
 }
 
 /* Adjust the file length if we're writing beyond the end */
-static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int count)
+void nfs_grow_file(struct inode *inode, loff_t offset, unsigned int count)
 {
-	struct inode *inode = page_file_mapping(page)->host;
-	loff_t end, i_size;
-	pgoff_t end_index;
+	loff_t end = offset + count;
+	loff_t i_size;
 
 	spin_lock(&inode->i_lock);
 	i_size = i_size_read(inode);
-	end_index = (i_size - 1) >> PAGE_SHIFT;
-	if (i_size > 0 && page_index(page) < end_index)
-		goto out;
-	end = page_file_offset(page) + ((loff_t)offset+count);
 	if (i_size >= end)
 		goto out;
 	i_size_write(inode, end);
@@ -1170,13 +1165,14 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 		unsigned int offset, unsigned int count)
 {
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page	*req;
 
 	req = nfs_setup_write_request(ctx, page, offset, count);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 	/* Update file length */
-	nfs_grow_file(page, offset, count);
+	nfs_grow_file(inode, req_offset(req), req->wb_bytes);
 	nfs_mark_uptodate(req);
 	nfs_mark_request_dirty(req);
 	nfs_unlock_and_release_request(req);
-- 
2.14.3

