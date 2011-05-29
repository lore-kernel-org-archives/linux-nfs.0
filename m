Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46035 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab1E2Kbk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 06:31:40 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 7/8] SQUASHME: Move a check from nfs_pageio_do_add_request to nfs_generic_pg_test
Date: Sun, 29 May 2011 13:31:30 +0300
Message-Id: <1306665090-1155-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE21CD5.8070907@panasas.com>
References: <4DE21CD5.8070907@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

desc->pg_bsize is negotiated with the MDS. But if we are doing
pnfs-IO it is not relevent.

While at it cleanup nfs_pageio_do_add_request() in light of the
less things it needs to do.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pagelist.c |   27 +++++++++++++--------------
 1 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 36bb67f..624ec2c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -206,6 +206,16 @@ nfs_wait_on_request(struct nfs_page *req)
 
 static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
 {
+	/*
+	* FIXME: ideally we should be able to coalesce all requests
+	* that are not block boundary aligned, but currently this
+	* is problematic for the case of bsize < PAGE_CACHE_SIZE,
+	* since nfs_flush_multi and nfs_pagein_multi assume you
+	* can have only one struct nfs_page.
+	*/
+	if (desc->pg_bsize < PAGE_SIZE)
+		return 0;
+
 	return desc->pg_count + req->wb_bytes <= desc->pg_bsize;
 }
 
@@ -279,29 +289,18 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
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

