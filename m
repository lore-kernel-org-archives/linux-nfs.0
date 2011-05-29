Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51049 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589Ab1E2S3h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:29:37 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 31/32] NFSv4.1: define nfs_generic_pg_test
Date: Sun, 29 May 2011 21:29:25 +0300
Message-Id: <1306693765-8579-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

By default, unless pnfs is used coalesce pages until pg_bsize
(rsize or wsize) is reached.

pnfs layout drivers define their own pg_test methods that use
pnfs_generic_pg_test and need to define their own I/O size
limits (e.g. based on the file stripe size).

[Move a check from nfs_pageio_do_add_request to nfs_generic_pg_test]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pagelist.c |   44 ++++++++++++++++++++------------------------
 1 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 5344371..7913961 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -204,6 +204,21 @@ nfs_wait_on_request(struct nfs_page *req)
 			TASK_UNINTERRUPTIBLE);
 }
 
+static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
+{
+	/*
+	 * FIXME: ideally we should be able to coalesce all requests
+	 * that are not block boundary aligned, but currently this
+	 * is problematic for the case of bsize < PAGE_CACHE_SIZE,
+	 * since nfs_flush_multi and nfs_pagein_multi assume you
+	 * can have only one struct nfs_page.
+	 */
+	if (desc->pg_bsize < PAGE_SIZE)
+		return 0;
+
+	return desc->pg_count + req->wb_bytes <= desc->pg_bsize;
+}
+
 /**
  * nfs_pageio_init - initialise a page io descriptor
  * @desc: pointer to descriptor
@@ -229,7 +244,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
-	desc->pg_test = NULL;
+	desc->pg_test = nfs_generic_pg_test;
 	pnfs_pageio_init(desc, inode);
 }
 
@@ -260,13 +275,7 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 		return false;
 	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
 		return false;
-	/*
-	 * Non-whole file layouts need to check that req is inside of
-	 * pgio->pg_lseg.
-	 */
-	if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
-		return false;
-	return true;
+	return pgio->pg_test(pgio, prev, req);
 }
 
 /**
@@ -280,31 +289,18 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 				     struct nfs_page *req)
 {
-	size_t newlen = req->wb_bytes;
-
 	if (desc->pg_count != 0) {
 		struct nfs_page *prev;
 
-		/*
-		 * FIXME: ideally we should be able to coalesce all requests
-		 * that are not block boundary aligned, but currently this
-		 * is problematic for the case of bsize < PAGE_CACHE_SIZE,
-		 * since nfs_flush_multi and nfs_pagein_multi assume you
-		 * can have only one struct nfs_page.
-		 */
-		if (desc->pg_bsize < PAGE_SIZE)
-			return 0;
-		newlen += desc->pg_count;
-		if (newlen > desc->pg_bsize)
-			return 0;
 		prev = nfs_list_entry(desc->pg_list.prev);
 		if (!nfs_can_coalesce_requests(prev, req, desc))
 			return 0;
-	} else
+	} else {
 		desc->pg_base = req->wb_pgbase;
+	}
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &desc->pg_list);
-	desc->pg_count = newlen;
+	desc->pg_count += req->wb_bytes;
 	return 1;
 }
 
-- 
1.7.2.3

