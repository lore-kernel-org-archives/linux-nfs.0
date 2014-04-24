Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33921 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbaDXSPn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:15:43 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so1242038igc.2
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:15:43 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 05/18 v2] nfs: call nfs_can_coalesce_requests for every req
Date: Thu, 24 Apr 2014 14:15:15 -0400
Message-Id: <1398363328-7100-6-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-1-git-send-email-dros@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Call nfs_can_coalesce_requests for every request, even the first one.
This is needed for future patches to give pg_test a way to inform
add_request to reduce the size of the request.

Now @prev can be null in nfs_can_coalesce_requests and pg_test functions.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/nfs4filelayout.c |  3 +++
 fs/nfs/pagelist.c       | 34 +++++++++++++++++++---------------
 2 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index ba9a9aa..9319427 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -929,6 +929,9 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	    !nfs_generic_pg_test(pgio, prev, req))
 		return 0;
 
+	if (!prev)
+		return req->wb_bytes;
+
 	p_stripe = (u64)req_offset(prev);
 	r_stripe = (u64)req_offset(req);
 	stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 4cd7a2a..b120728 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -289,6 +289,8 @@ nfs_wait_on_request(struct nfs_page *req)
 size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 			   struct nfs_page *prev, struct nfs_page *req)
 {
+	if (!prev)
+		return req->wb_bytes;
 	/*
 	 * FIXME: ideally we should be able to coalesce all requests
 	 * that are not block boundary aligned, but currently this
@@ -370,17 +372,20 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 {
 	size_t size;
 
-	if (!nfs_match_open_context(req->wb_context, prev->wb_context))
-		return false;
-	if (req->wb_context->dentry->d_inode->i_flock != NULL &&
-	    !nfs_match_lock_context(req->wb_lock_context, prev->wb_lock_context))
-		return false;
-	if (req->wb_pgbase != 0)
-		return false;
-	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
-		return false;
-	if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
-		return false;
+	if (prev) {
+		if (!nfs_match_open_context(req->wb_context, prev->wb_context))
+			return false;
+		if (req->wb_context->dentry->d_inode->i_flock != NULL &&
+		    !nfs_match_lock_context(req->wb_lock_context,
+					    prev->wb_lock_context))
+			return false;
+		if (req->wb_pgbase != 0)
+			return false;
+		if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
+			return false;
+		if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
+			return false;
+	}
 	size = pgio->pg_ops->pg_test(pgio, prev, req);
 	WARN_ON_ONCE(size && size != req->wb_bytes);
 	return size > 0;
@@ -397,17 +402,16 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 				     struct nfs_page *req)
 {
+	struct nfs_page *prev = NULL;
 	if (desc->pg_count != 0) {
-		struct nfs_page *prev;
-
 		prev = nfs_list_entry(desc->pg_list.prev);
-		if (!nfs_can_coalesce_requests(prev, req, desc))
-			return 0;
 	} else {
 		if (desc->pg_ops->pg_init)
 			desc->pg_ops->pg_init(desc, req);
 		desc->pg_base = req->wb_pgbase;
 	}
+	if (!nfs_can_coalesce_requests(prev, req, desc))
+		return 0;
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &desc->pg_list);
 	desc->pg_count += req->wb_bytes;
-- 
1.8.5.2 (Apple Git-48)

