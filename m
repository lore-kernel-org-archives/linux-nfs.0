Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34180 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757368Ab2DTSgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:36:50 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v2 16/28] paged writed
Date: Fri, 20 Apr 2012 14:35:58 -0400
Message-Id: <1334946970-27470-17-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
References: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 13b90b1..076075e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -560,7 +560,7 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 
 void nfs_write_completion(struct nfs_pgio_header *hdr)
 {
-	unsigned long pos = hdr->req->wb_index << PAGE_CACHE_SHIFT;
+	unsigned long bytes = 0;
 
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
 		goto out;
@@ -568,9 +568,10 @@ void nfs_write_completion(struct nfs_pgio_header *hdr)
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 		struct page *page = req->wb_page;
 
+		bytes += req->wb_bytes;
 		nfs_list_remove_request(req);
 		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
-		    (pos >= (hdr->first_error & PAGE_MASK))) {
+		    (hdr->good_bytes < bytes)) {
 			nfs_set_pageerror(page);
 			nfs_context_set_write_error(req->wb_context, hdr->error);
 			goto remove_req;
@@ -588,7 +589,6 @@ remove_req:
 next:
 		nfs_unlock_request(req);
 		nfs_end_page_writeback(page);
-		pos += PAGE_SIZE;
 	}
 out:
 	hdr->release(hdr);
-- 
1.7.2.1

