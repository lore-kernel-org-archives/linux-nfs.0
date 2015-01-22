Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:50355 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442AbbAVXh7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:37:59 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so4875742pad.7
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:37:58 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 34/51] pnfs: pass ds_commit_idx through the commit path
Date: Thu, 22 Jan 2015 15:36:06 -0800
Message-Id: <1421969783-92997-35-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

Pass ds_commit_idx through the nfs commit path. It's used to select
the commit bucket when using pnfs and is ignored when not using pnfs.
Several functions had to be changed: nfs_retry_commit,
nfs_mark_request_commit, pnfs_mark_request_commit and the pnfs layout
driver .mark_request_commit functions.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/direct.c                |  5 +++--
 fs/nfs/filelayout/filelayout.c |  3 ++-
 fs/nfs/internal.h              |  6 ++++--
 fs/nfs/pnfs.h                  |  9 +++++----
 fs/nfs/pnfs_nfs.c              |  4 ++--
 fs/nfs/write.c                 | 14 ++++++++------
 6 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d7c2d43..1ee41d7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -649,7 +649,7 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 		nfs_list_remove_request(req);
 		if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES) {
 			/* Note the rewrite will go through mds */
-			nfs_mark_request_commit(req, NULL, &cinfo);
+			nfs_mark_request_commit(req, NULL, &cinfo, 0);
 		} else
 			nfs_release_request(req);
 		nfs_unlock_and_release_request(req);
@@ -748,7 +748,8 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 		nfs_list_remove_request(req);
 		if (request_commit) {
 			kref_get(&req->wb_kref);
-			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
+			nfs_mark_request_commit(req, hdr->lseg, &cinfo,
+				hdr->ds_commit_idx);
 		}
 		nfs_unlock_and_release_request(req);
 	}
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 520cbc5..3c97694 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -954,7 +954,8 @@ static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
 static void
 filelayout_mark_request_commit(struct nfs_page *req,
 			       struct pnfs_layout_segment *lseg,
-			       struct nfs_commit_info *cinfo)
+			       struct nfs_commit_info *cinfo,
+			       u32 ds_commit_idx)
 
 {
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e9305e9..05f9a87 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -450,13 +450,15 @@ int nfs_scan_commit(struct inode *inode, struct list_head *dst,
 		    struct nfs_commit_info *cinfo);
 void nfs_mark_request_commit(struct nfs_page *req,
 			     struct pnfs_layout_segment *lseg,
-			     struct nfs_commit_info *cinfo);
+			     struct nfs_commit_info *cinfo,
+			     u32 ds_commit_idx);
 int nfs_write_need_commit(struct nfs_pgio_header *);
 int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
 			    int how, struct nfs_commit_info *cinfo);
 void nfs_retry_commit(struct list_head *page_list,
 		      struct pnfs_layout_segment *lseg,
-		      struct nfs_commit_info *cinfo);
+		      struct nfs_commit_info *cinfo,
+		      u32 ds_commit_idx);
 void nfs_commitdata_release(struct nfs_commit_data *data);
 void nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
 				 struct nfs_commit_info *cinfo);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c146ed8..3d4a83b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -137,7 +137,8 @@ struct pnfs_layoutdriver_type {
 	struct pnfs_ds_commit_info *(*get_ds_info) (struct inode *inode);
 	void (*mark_request_commit) (struct nfs_page *req,
 				     struct pnfs_layout_segment *lseg,
-				     struct nfs_commit_info *cinfo);
+				     struct nfs_commit_info *cinfo,
+				     u32 ds_commit_idx);
 	void (*clear_request_commit) (struct nfs_page *req,
 				      struct nfs_commit_info *cinfo);
 	int (*scan_commit_lists) (struct nfs_commit_info *cinfo,
@@ -388,14 +389,14 @@ pnfs_generic_mark_devid_invalid(struct nfs4_deviceid_node *node)
 
 static inline bool
 pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
-			 struct nfs_commit_info *cinfo)
+			 struct nfs_commit_info *cinfo, u32 ds_commit_idx)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 
 	if (lseg == NULL || ld->mark_request_commit == NULL)
 		return false;
-	ld->mark_request_commit(req, lseg, cinfo);
+	ld->mark_request_commit(req, lseg, cinfo, ds_commit_idx);
 	return true;
 }
 
@@ -573,7 +574,7 @@ pnfs_get_ds_info(struct inode *inode)
 
 static inline bool
 pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
-			 struct nfs_commit_info *cinfo)
+			 struct nfs_commit_info *cinfo, u32 ds_commit_idx)
 {
 	return false;
 }
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 9822e86..6c37e02 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -187,7 +187,7 @@ static void pnfs_generic_retry_commit(struct nfs_commit_info *cinfo, int idx)
 		bucket = &fl_cinfo->buckets[i];
 		if (list_empty(&bucket->committing))
 			continue;
-		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
+		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo, i);
 		spin_lock(cinfo->lock);
 		freeme = bucket->clseg;
 		bucket->clseg = NULL;
@@ -246,7 +246,7 @@ pnfs_generic_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			list_add(&data->pages, &list);
 			nreq++;
 		} else {
-			nfs_retry_commit(mds_pages, NULL, cinfo);
+			nfs_retry_commit(mds_pages, NULL, cinfo, 0);
 			pnfs_generic_retry_commit(cinfo, 0);
 			cinfo->completion_ops->error_cleanup(NFS_I(inode));
 			return -ENOMEM;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e997457..2bee165 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -847,9 +847,9 @@ EXPORT_SYMBOL_GPL(nfs_init_cinfo);
  */
 void
 nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
-			struct nfs_commit_info *cinfo)
+			struct nfs_commit_info *cinfo, u32 ds_commit_idx)
 {
-	if (pnfs_mark_request_commit(req, lseg, cinfo))
+	if (pnfs_mark_request_commit(req, lseg, cinfo, ds_commit_idx))
 		return;
 	nfs_request_add_commit_list(req, &cinfo->mds->list, cinfo);
 }
@@ -905,7 +905,8 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 		}
 		if (nfs_write_need_commit(hdr)) {
 			memcpy(&req->wb_verf, &hdr->verf.verifier, sizeof(req->wb_verf));
-			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
+			nfs_mark_request_commit(req, hdr->lseg, &cinfo,
+				0);
 			goto next;
 		}
 remove_req:
@@ -1560,14 +1561,15 @@ EXPORT_SYMBOL_GPL(nfs_init_commit);
 
 void nfs_retry_commit(struct list_head *page_list,
 		      struct pnfs_layout_segment *lseg,
-		      struct nfs_commit_info *cinfo)
+		      struct nfs_commit_info *cinfo,
+		      u32 ds_commit_idx)
 {
 	struct nfs_page *req;
 
 	while (!list_empty(page_list)) {
 		req = nfs_list_entry(page_list->next);
 		nfs_list_remove_request(req);
-		nfs_mark_request_commit(req, lseg, cinfo);
+		nfs_mark_request_commit(req, lseg, cinfo, ds_commit_idx);
 		if (!cinfo->dreq) {
 			dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 			dec_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
@@ -1598,7 +1600,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how,
 	return nfs_initiate_commit(NFS_CLIENT(inode), data, NFS_PROTO(inode),
 				   data->mds_ops, how, 0);
  out_bad:
-	nfs_retry_commit(head, NULL, cinfo);
+	nfs_retry_commit(head, NULL, cinfo, 0);
 	cinfo->completion_ops->error_cleanup(NFS_I(inode));
 	return -ENOMEM;
 }
-- 
1.9.3

