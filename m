Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30151 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756932Ab2EITSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 15:18:51 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/5] NFS: nfs_set_page_writeback no longer needs to reference the page
Date: Wed,  9 May 2012 15:18:40 -0400
Message-Id: <1336591123-23400-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1336591123-23400-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1336591123-23400-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We now hold a reference to the nfs_page across the calls to
nfs_set_page_writeback and nfs_end_page_writeback, and that
means we already have a reference to the struct page.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fd36b31..8382329 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -230,7 +230,6 @@ static int nfs_set_page_writeback(struct page *page)
 		struct inode *inode = page->mapping->host;
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
-		page_cache_get(page);
 		if (atomic_long_inc_return(&nfss->writeback) >
 				NFS_CONGESTION_ON_THRESH) {
 			set_bdi_congested(&nfss->backing_dev_info,
@@ -246,7 +245,6 @@ static void nfs_end_page_writeback(struct page *page)
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
-	page_cache_release(page);
 	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
 		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
 }
@@ -607,13 +605,12 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 	nfs_init_cinfo_from_inode(&cinfo, hdr->inode);
 	while (!list_empty(&hdr->pages)) {
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
-		struct page *page = req->wb_page;
 
 		bytes += req->wb_bytes;
 		nfs_list_remove_request(req);
 		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
 		    (hdr->good_bytes < bytes)) {
-			nfs_set_pageerror(page);
+			nfs_set_pageerror(req->wb_page);
 			nfs_context_set_write_error(req->wb_context, hdr->error);
 			goto remove_req;
 		}
@@ -629,7 +626,7 @@ remove_req:
 		nfs_inode_remove_request(req);
 next:
 		nfs_unlock_request_dont_release(req);
-		nfs_end_page_writeback(page);
+		nfs_end_page_writeback(req->wb_page);
 		nfs_release_request(req);
 	}
 out:
@@ -1040,11 +1037,9 @@ static int nfs_do_multiple_writes(struct list_head *head,
  */
 static void nfs_redirty_request(struct nfs_page *req)
 {
-	struct page *page = req->wb_page;
-
 	nfs_mark_request_dirty(req);
 	nfs_unlock_request_dont_release(req);
-	nfs_end_page_writeback(page);
+	nfs_end_page_writeback(req->wb_page);
 	nfs_release_request(req);
 }
 
-- 
1.7.7.6

