Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37421 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757883AbaDVV3Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 17:29:16 -0400
Received: by mail-ig0-f169.google.com with SMTP id h18so3388324igc.0
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 14:29:15 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 12/17] nfs: use > 1 request to handle bsize < PAGE_SIZE
Date: Tue, 22 Apr 2014 17:29:20 -0400
Message-Id: <1398202165-78897-13-git-send-email-dros@primarydata.com>
In-Reply-To: <1398202165-78897-1-git-send-email-dros@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the newly added support for multiple requests per page for
rsize/wsize < PAGE_SIZE, instead of having multiple read / write
data structures per pageio header.

This allows us to get rid of nfs_flush_multi and nfs_pagein_multi.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c | 22 +++++++------------
 fs/nfs/read.c     | 63 ++++++------------------------------------------------
 fs/nfs/write.c    | 64 ++++++-------------------------------------------------
 3 files changed, 22 insertions(+), 127 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b5c4c13..e819b1b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -434,21 +434,13 @@ nfs_wait_on_request(struct nfs_page *req)
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
 
@@ -526,7 +518,9 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 			return false;
 	}
 	size = pgio->pg_ops->pg_test(pgio, prev, req);
-	WARN_ON_ONCE(size && size != req->wb_bytes);
+	WARN_ON_ONCE(size > req->wb_bytes);
+	if (size && size < req->wb_bytes)
+		req->wb_bytes = size;
 	return size > 0;
 }
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c774810..daeff0c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -336,56 +336,12 @@ static void nfs_pagein_error(struct nfs_pageio_descriptor *desc,
 	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 }
 
-/*
- * Generate multiple requests to fill a single page.
- *
- * We optimize to reduce the number of read operations on the wire.  If we
- * detect that we're reading a page, or an area of a page, that is past the
- * end of file, we do not generate NFS read operations but just clear the
- * parts of the page that would have come back zero from the server anyway.
- *
- * We rely on the cached value of i_size to make this determination; another
- * client can fill pages on the server past our cached end-of-file, but we
- * won't see the new data until our attribute cache is updated.  This is more
- * or less conventional NFS client behavior.
- */
-static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
-			    struct nfs_pgio_header *hdr)
-{
-	struct nfs_page *req = hdr->req;
-	struct page *page = req->wb_page;
-	struct nfs_read_data *data;
-	size_t rsize = desc->pg_bsize, nbytes;
-	unsigned int offset;
-
-	offset = 0;
-	nbytes = desc->pg_count;
-	do {
-		size_t len = min(nbytes,rsize);
-
-		data = nfs_readdata_alloc(hdr, 1);
-		if (!data) {
-			nfs_pagein_error(desc, hdr);
-			return -ENOMEM;
-		}
-		data->pages.pagevec[0] = page;
-		nfs_read_rpcsetup(data, len, offset);
-		list_add(&data->list, &hdr->rpc_list);
-		nbytes -= len;
-		offset += len;
-	} while (nbytes != 0);
-
-	nfs_list_remove_request(req);
-	nfs_list_add_request(req, &hdr->pages);
-	desc->pg_rpc_callops = &nfs_read_common_ops;
-	return 0;
-}
-
-static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
-			  struct nfs_pgio_header *hdr)
+int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
+		       struct nfs_pgio_header *hdr)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
+	struct page		*last_page;
 	struct nfs_read_data    *data;
 	struct list_head *head = &desc->pg_list;
 
@@ -397,11 +353,14 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 	}
 
 	pages = data->pages.pagevec;
+	last_page = NULL;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &hdr->pages);
-		*pages++ = req->wb_page;
+		if (last_page != req->wb_page)
+			*pages++ = req->wb_page;
+		last_page = req->wb_page;
 	}
 
 	nfs_read_rpcsetup(data, desc->pg_count, 0);
@@ -409,14 +368,6 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 	desc->pg_rpc_callops = &nfs_read_common_ops;
 	return 0;
 }
-
-int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
-		       struct nfs_pgio_header *hdr)
-{
-	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		return nfs_pagein_multi(desc, hdr);
-	return nfs_pagein_one(desc, hdr);
-}
 EXPORT_SYMBOL_GPL(nfs_generic_pagein);
 
 static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 43892e0..f40db93 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1233,52 +1233,6 @@ static void nfs_flush_error(struct nfs_pageio_descriptor *desc,
 }
 
 /*
- * Generate multiple small requests to write out a single
- * contiguous dirty area on one page.
- */
-static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
-			   struct nfs_pgio_header *hdr)
-{
-	struct nfs_page *req = hdr->req;
-	struct page *page = req->wb_page;
-	struct nfs_write_data *data;
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
-
-	offset = 0;
-	nbytes = desc->pg_count;
-	do {
-		size_t len = min(nbytes, wsize);
-
-		data = nfs_writedata_alloc(hdr, 1);
-		if (!data) {
-			nfs_flush_error(desc, hdr);
-			return -ENOMEM;
-		}
-		data->pages.pagevec[0] = page;
-		nfs_write_rpcsetup(data, len, offset, desc->pg_ioflags, &cinfo);
-		list_add(&data->list, &hdr->rpc_list);
-		requests++;
-		nbytes -= len;
-		offset += len;
-	} while (nbytes != 0);
-	nfs_list_remove_request(req);
-	nfs_list_add_request(req, &hdr->pages);
-	desc->pg_rpc_callops = &nfs_write_common_ops;
-	return 0;
-}
-
-/*
  * Create an RPC task for the given write request and kick it.
  * The page must have been locked by the caller.
  *
@@ -1286,11 +1240,12 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
  * This is the case if nfs_updatepage detects a conflicting request
  * that has been written but not committed.
  */
-static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
-			 struct nfs_pgio_header *hdr)
+int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
+		      struct nfs_pgio_header *hdr)
 {
 	struct nfs_page		*req;
 	struct page		**pages;
+	struct page		*last_page;
 	struct nfs_write_data	*data;
 	struct list_head *head = &desc->pg_list;
 	struct nfs_commit_info cinfo;
@@ -1304,11 +1259,14 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
 	pages = data->pages.pagevec;
+	last_page = NULL;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &hdr->pages);
-		*pages++ = req->wb_page;
+		if (last_page != req->wb_page)
+			*pages++ = req->wb_page;
+		last_page = req->wb_page;
 	}
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
@@ -1321,14 +1279,6 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 	desc->pg_rpc_callops = &nfs_write_common_ops;
 	return 0;
 }
-
-int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
-		      struct nfs_pgio_header *hdr)
-{
-	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		return nfs_flush_multi(desc, hdr);
-	return nfs_flush_one(desc, hdr);
-}
 EXPORT_SYMBOL_GPL(nfs_generic_flush);
 
 static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
-- 
1.8.5.2 (Apple Git-48)

