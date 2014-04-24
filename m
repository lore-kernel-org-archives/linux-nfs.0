Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:60033 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbaDXSP5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:15:57 -0400
Received: by mail-ie0-f172.google.com with SMTP id as1so2810805iec.3
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:15:56 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 13/18 v2] nfs: use > 1 request to handle bsize < PAGE_SIZE
Date: Thu, 24 Apr 2014 14:15:23 -0400
Message-Id: <1398363328-7100-14-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-1-git-send-email-dros@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the newly added support for multiple requests per page for
rsize/wsize < PAGE_SIZE, instead of having multiple read / write
data structures per pageio header.

This allows us to get rid of nfs_pgio_multi.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pageio.c   | 56 ++-----------------------------------------------------
 fs/nfs/pagelist.c | 22 ++++++++--------------
 2 files changed, 10 insertions(+), 68 deletions(-)

diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index b9d06c8..1899977 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -218,50 +218,6 @@ static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
 }
 
 /*
- * Generate multiple small requests to read or write a single
- * contiguous dirty on one page.
- */
-static int nfs_pgio_multi(struct nfs_pageio_descriptor *desc,
-			  struct nfs_pgio_header *hdr)
-{
-	struct nfs_page *req = hdr->req;
-	struct page *page = req->wb_page;
-	struct nfs_pgio_data *data;
-	size_t wsize = desc->pg_bsize, nbytes;
-	unsigned int offset;
-	int requests = 0;
-	struct nfs_commit_info cinfo;
-
-	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
-
-	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
-	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo) ||
-	     desc->pg_count > wsize))
-		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
-
-	offset = 0;
-	nbytes = desc->pg_count;
-	do {
-		size_t len = min(nbytes, wsize);
-
-		data = nfs_pgio_data_alloc(hdr, 1);
-		if (!data)
-			return nfs_pgio_error(desc, hdr);
-		data->pages.pagevec[0] = page;
-		nfs_pgio_rpcsetup(data, len, offset, desc->pg_ioflags, &cinfo);
-		list_add(&data->list, &hdr->rpc_list);
-		requests++;
-		nbytes -= len;
-		offset += len;
-	} while (nbytes != 0);
-
-	nfs_list_remove_request(req);
-	nfs_list_add_request(req, &hdr->pages);
-	desc->pg_rpc_callops = &nfs_pgio_common_ops;
-	return 0;
-}
-
-/*
  * Create an RPC task for the given write request and kick it.
  * The page must have been locked by the caller.
  *
@@ -269,8 +225,8 @@ static int nfs_pgio_multi(struct nfs_pageio_descriptor *desc,
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_pgio_one(struct nfs_pageio_descriptor *desc,
-			struct nfs_pgio_header *hdr)
+int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
+		     struct nfs_pgio_header *hdr)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
@@ -302,14 +258,6 @@ static int nfs_pgio_one(struct nfs_pageio_descriptor *desc,
 	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
 }
-
-int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
-		     struct nfs_pgio_header *hdr)
-{
-	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		return nfs_pgio_multi(desc, hdr);
-	return nfs_pgio_one(desc, hdr);
-}
 EXPORT_SYMBOL_GPL(nfs_generic_pgio);
 
 static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 6257f31..78933ac 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -440,21 +440,13 @@ nfs_wait_on_request(struct nfs_page *req)
 size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 			   struct nfs_page *prev, struct nfs_page *req)
 {
-	if (!prev)
-		return req->wb_bytes;
-	/*
-	 * FIXME: ideally we should be able to coalesce all requests
-	 * that are not block boundary aligned, but currently this
-	 * is problematic for the case of bsize < PAGE_CACHE_SIZE,
-	 * since nfs_flush_multi and nfs_pagein_multi assume you
-	 * can have only one struct nfs_page.
-	 */
-	if (desc->pg_bsize < PAGE_SIZE)
+	if (desc->pg_count > desc->pg_bsize) {
+		/* should never happen */
+		WARN_ON_ONCE(1);
 		return 0;
+	}
 
-	if (desc->pg_count + req->wb_bytes <= desc->pg_bsize)
-		return req->wb_bytes;
-	return 0;
+	return min(desc->pg_bsize - desc->pg_count, (size_t)req->wb_bytes);
 }
 EXPORT_SYMBOL_GPL(nfs_generic_pg_test);
 
@@ -534,7 +526,9 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 			return false;
 	}
 	size = pgio->pg_ops->pg_test(pgio, prev, req);
-	WARN_ON_ONCE(size && size != req->wb_bytes);
+	WARN_ON_ONCE(size > req->wb_bytes);
+	if (size && size < req->wb_bytes)
+		req->wb_bytes = size;
 	return size > 0;
 }
 
-- 
1.8.5.2 (Apple Git-48)

