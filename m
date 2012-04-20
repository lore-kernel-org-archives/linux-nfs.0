Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34188 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757405Ab2DTSgw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:36:52 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v2 21/28] direct read
Date: Fri, 20 Apr 2012 14:36:03 -0400
Message-Id: <1334946970-27470-22-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
References: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d713234..4ba9a2c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -222,18 +222,17 @@ void nfs_direct_readpage_release(struct nfs_page *req)
 
 static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 {
-	unsigned long pos = req_offset(hdr->req);
+	unsigned long bytes = 0;
 	struct nfs_direct_req *dreq = hdr->dreq;
 
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
 		goto out_put;
 
 	spin_lock(&dreq->lock);
-	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
-	    (hdr->first_error == pos))
+	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) && (hdr->good_bytes == 0))
 		dreq->error = hdr->error;
 	else
-		dreq->count += (hdr->first_error - pos);
+		dreq->count += hdr->good_bytes;
 	spin_unlock(&dreq->lock);
 
 	if (!test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
@@ -241,6 +240,15 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 			struct page *page = req->wb_page;
 
+			if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
+				if (bytes > hdr->good_bytes)
+					zero_user(page, 0, PAGE_SIZE);
+				else if (hdr->good_bytes - bytes < PAGE_SIZE)
+					zero_user_segment(page,
+						hdr->good_bytes & ~PAGE_MASK,
+						PAGE_SIZE);
+			}
+			bytes += req->wb_bytes;
 			nfs_list_remove_request(req);
 			nfs_direct_readpage_release(req);
 			if (!PageCompound(page))
@@ -248,17 +256,16 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 			page_cache_release(page);
 		}
 	} else {
-		pos &= PAGE_MASK;
 		while (!list_empty(&hdr->pages)) {
 			struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 
-			if (pos < (hdr->first_error & PAGE_MASK))
+			if (bytes < hdr->good_bytes)
 				if (!PageCompound(req->wb_page))
 					set_page_dirty(req->wb_page);
+			bytes += req->wb_bytes;
 			page_cache_release(req->wb_page);
 			nfs_list_remove_request(req);
 			nfs_direct_readpage_release(req);
-			pos += PAGE_SIZE;
 		}
 	}
 out_put:
-- 
1.7.2.1

