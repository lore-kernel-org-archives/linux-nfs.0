Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32450 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932842Ab2DTSsW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:22 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 24/25] NFS: avoid some stat gathering for direct io
Date: Fri, 20 Apr 2012 14:47:56 -0400
Message-Id: <1334947677-28864-25-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 44a93d8..56db9e7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -472,9 +472,13 @@ nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
 	nfs_list_add_request(req, dst);
 	cinfo->mds->ncommit++;
 	spin_unlock(cinfo->lock);
-	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
-	__mark_inode_dirty(req->wb_context->dentry->d_inode, I_DIRTY_DATASYNC);
+	if (!cinfo->dreq) {
+		inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		inc_bdi_stat(req->wb_page->mapping->backing_dev_info,
+			     BDI_RECLAIMABLE);
+		__mark_inode_dirty(req->wb_context->dentry->d_inode,
+				   I_DIRTY_DATASYNC);
+	}
 }
 EXPORT_SYMBOL_GPL(nfs_request_add_commit_list);
 
@@ -1455,9 +1459,11 @@ void nfs_retry_commit(struct list_head *page_list,
 		req = nfs_list_entry(page_list->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req, lseg, cinfo);
-		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
-			     BDI_RECLAIMABLE);
+		if (!cinfo->dreq) {
+			dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+			dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+				     BDI_RECLAIMABLE);
+		}
 		nfs_unlock_request(req);
 	}
 }
-- 
1.7.2.1

