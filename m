Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:38108 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbaDXSPk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:15:40 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so2764236iec.4
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:15:40 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 03/18 v2] nfs: remove unused arg from nfs_create_request
Date: Thu, 24 Apr 2014 14:15:13 -0400
Message-Id: <1398363328-7100-4-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-1-git-send-email-dros@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

@inode is passed but not used.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/direct.c          | 6 ++----
 fs/nfs/pagelist.c        | 4 +---
 fs/nfs/read.c            | 5 ++---
 fs/nfs/write.c           | 2 +-
 include/linux/nfs_page.h | 1 -
 5 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 164b016..1dd8c62 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -380,8 +380,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 			struct nfs_page *req;
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 			/* XXX do we need to do the eof zeroing found in async_filler? */
-			req = nfs_create_request(dreq->ctx, dreq->inode,
-						 pagevec[i],
+			req = nfs_create_request(dreq->ctx, pagevec[i],
 						 pgbase, req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
@@ -750,8 +749,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 			struct nfs_page *req;
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 
-			req = nfs_create_request(dreq->ctx, dreq->inode,
-						 pagevec[i],
+			req = nfs_create_request(dreq->ctx, pagevec[i],
 						 pgbase, req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8221706..30c221c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -136,7 +136,6 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
 /**
  * nfs_create_request - Create an NFS read/write request.
  * @ctx: open context to use
- * @inode: inode to which the request is attached
  * @page: page to write
  * @offset: starting offset within the page for the write
  * @count: number of bytes to read/write
@@ -146,8 +145,7 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
  * User should ensure it is safe to sleep in this function.
  */
 struct nfs_page *
-nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
-		   struct page *page,
+nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 		   unsigned int offset, unsigned int count)
 {
 	struct nfs_page		*req;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index d7e9460..a48b909 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -85,7 +85,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	new = nfs_create_request(ctx, inode, page, 0, len);
+	new = nfs_create_request(ctx, page, 0, len);
 	if (IS_ERR(new)) {
 		unlock_page(page);
 		return PTR_ERR(new);
@@ -303,7 +303,6 @@ static int
 readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
-	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *new;
 	unsigned int len;
 	int error;
@@ -312,7 +311,7 @@ readpage_async_filler(void *data, struct page *page)
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	new = nfs_create_request(desc->ctx, inode, page, 0, len);
+	new = nfs_create_request(desc->ctx, page, 0, len);
 	if (IS_ERR(new))
 		goto out_error;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3483dd4..5f1c965 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -761,7 +761,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 	req = nfs_try_to_update_request(inode, page, offset, bytes);
 	if (req != NULL)
 		goto out;
-	req = nfs_create_request(ctx, inode, page, offset, bytes);
+	req = nfs_create_request(ctx, page, offset, bytes);
 	if (IS_ERR(req))
 		goto out;
 	nfs_inode_add_request(inode, req);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 91ac4d4..8cb2640 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -85,7 +85,6 @@ struct nfs_pageio_descriptor {
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
 
 extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
-					    struct inode *inode,
 					    struct page *page,
 					    unsigned int offset,
 					    unsigned int count);
-- 
1.8.5.2 (Apple Git-48)

