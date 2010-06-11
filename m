From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 07/26] pnfs-submit: filelayout: remove some dead code from filelayout_commit
Date: Fri, 11 Jun 2010 03:31:34 -0400
Message-ID: <1276241513-17942-8-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
 <1276241513-17942-7-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30552 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757393Ab0FKHcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:20 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3u0024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:10 -0700 (PDT)
In-Reply-To: <1276241513-17942-7-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 2ffca74..c15b90a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -562,7 +562,6 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 	struct nfs_page *req, *reqt;
 	struct list_head *pos, *tmp, head, head2;
 	loff_t file_offset, comp_offset;
-	size_t stripesz, cbytes;
 	enum pnfs_try_status trypnfs = PNFS_ATTEMPTED;
 	u32 idx1, idx2;
 
@@ -577,9 +576,6 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 		return PNFS_NOT_ATTEMPTED;
 	}
 
-	stripesz = filelayout_get_stripesize(layoutid);
-	dprintk("%s stripesize %Zd\n", __func__, stripesz);
-
 	INIT_LIST_HEAD(&head);
 	INIT_LIST_HEAD(&head2);
 	list_add(&head, &data->pages);
@@ -587,7 +583,6 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 
 	/* COMMIT to each Data Server */
 	while (!list_empty(&head)) {
-		cbytes = 0;
 		req = nfs_list_entry(head.next);
 
 		file_offset = (loff_t)req->wb_index << PAGE_CACHE_SHIFT;
@@ -613,7 +608,6 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 			if (idx1 == idx2) {
 				nfs_list_remove_request(reqt);
 				nfs_list_add_request(reqt, &head2);
-				cbytes += reqt->wb_bytes;
 			}
 		}
 
@@ -637,8 +631,8 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 		dsdata->fldata.ds_nfs_client = ds->ds_clp;
 		dsdata->args.fh = nfs4_fl_select_ds_fh(nfslay, idx1);
 
-		dprintk("%s: Initiating commit: %Zu@%llu USE DS:\n",
-			__func__, cbytes, file_offset);
+		dprintk("%s: Initiating commit: %llu USE DS:\n",
+			__func__, file_offset);
 		print_ds(ds);
 
 		/* Send COMMIT to data server */
-- 
1.6.6.1

