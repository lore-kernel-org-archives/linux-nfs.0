Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:44545 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbBSGC6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Feb 2015 01:02:58 -0500
Received: by pdbnh10 with SMTP id nh10so6550832pdb.11
        for <linux-nfs@vger.kernel.org>; Wed, 18 Feb 2015 22:02:58 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] pnfs: Refactor the *_layout_mark_request_commit to use pnfs_layout_mark_request_commit
Date: Wed, 18 Feb 2015 22:02:52 -0800
Message-Id: <1424325772-2851-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Haynes <thomas.haynes@primarydata.com>

The File Layout's filelayout_mark_request_commit() is almost the
Flex File Layout's ff_layout_mark_request_commit(). And that can
be reduced by calling into nfs_request_add_commit_list().

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c         | 48 +++++++---------------------------
 fs/nfs/flexfilelayout/flexfilelayout.c | 38 +--------------------------
 fs/nfs/pnfs.h                          |  4 +++
 fs/nfs/pnfs_nfs.c                      | 30 +++++++++++++++++++++
 4 files changed, 45 insertions(+), 75 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index e1e5ea2..91e88a7 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -960,48 +960,20 @@ filelayout_mark_request_commit(struct nfs_page *req,
 {
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 	u32 i, j;
-	struct list_head *list;
-	struct pnfs_commit_bucket *buckets;
 
 	if (fl->commit_through_mds) {
-		list = &cinfo->mds->list;
-		spin_lock(cinfo->lock);
-		goto mds_commit;
-	}
-
-	/* Note that we are calling nfs4_fl_calc_j_index on each page
-	 * that ends up being committed to a data server.  An attractive
-	 * alternative is to add a field to nfs_write_data and nfs_page
-	 * to store the value calculated in filelayout_write_pagelist
-	 * and just use that here.
-	 */
-	j = nfs4_fl_calc_j_index(lseg, req_offset(req));
-	i = select_bucket_index(fl, j);
-	spin_lock(cinfo->lock);
-	buckets = cinfo->ds->buckets;
-	list = &buckets[i].written;
-	if (list_empty(list)) {
-		/* Non-empty buckets hold a reference on the lseg.  That ref
-		 * is normally transferred to the COMMIT call and released
-		 * there.  It could also be released if the last req is pulled
-		 * off due to a rewrite, in which case it will be done in
-		 * pnfs_generic_clear_request_commit
+		nfs_request_add_commit_list(req, &cinfo->mds->list, cinfo);
+	} else {
+		/* Note that we are calling nfs4_fl_calc_j_index on each page
+		 * that ends up being committed to a data server.  An attractive
+		 * alternative is to add a field to nfs_write_data and nfs_page
+		 * to store the value calculated in filelayout_write_pagelist
+		 * and just use that here.
 		 */
-		buckets[i].wlseg = pnfs_get_lseg(lseg);
+		j = nfs4_fl_calc_j_index(lseg, req_offset(req));
+		i = select_bucket_index(fl, j);
+		pnfs_layout_mark_request_commit(req, lseg, cinfo, i);
 	}
-	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
-	cinfo->ds->nwritten++;
-
-mds_commit:
-	/* nfs_request_add_commit_list(). We need to add req to list without
-	 * dropping cinfo lock.
-	 */
-	set_bit(PG_CLEAN, &(req)->wb_flags);
-	nfs_list_add_request(req, list);
-	cinfo->mds->ncommit++;
-	spin_unlock(cinfo->lock);
-	if (!cinfo->dreq)
-		nfs_mark_page_unstable(req->wb_page);
 }
 
 static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 423c2bc..315cc68 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1332,42 +1332,6 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	return PNFS_ATTEMPTED;
 }
 
-static void
-ff_layout_mark_request_commit(struct nfs_page *req,
-			      struct pnfs_layout_segment *lseg,
-			      struct nfs_commit_info *cinfo,
-			      u32 ds_commit_idx)
-{
-	struct list_head *list;
-	struct pnfs_commit_bucket *buckets;
-
-	spin_lock(cinfo->lock);
-	buckets = cinfo->ds->buckets;
-	list = &buckets[ds_commit_idx].written;
-	if (list_empty(list)) {
-		/* Non-empty buckets hold a reference on the lseg.  That ref
-		 * is normally transferred to the COMMIT call and released
-		 * there.  It could also be released if the last req is pulled
-		 * off due to a rewrite, in which case it will be done in
-		 * pnfs_common_clear_request_commit
-		 */
-		WARN_ON_ONCE(buckets[ds_commit_idx].wlseg != NULL);
-		buckets[ds_commit_idx].wlseg = pnfs_get_lseg(lseg);
-	}
-	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
-	cinfo->ds->nwritten++;
-
-	/* nfs_request_add_commit_list(). We need to add req to list without
-	 * dropping cinfo lock.
-	 */
-	set_bit(PG_CLEAN, &(req)->wb_flags);
-	nfs_list_add_request(req, list);
-	cinfo->mds->ncommit++;
-	spin_unlock(cinfo->lock);
-	if (!cinfo->dreq)
-		nfs_mark_page_unstable(req->wb_page);
-}
-
 static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
 {
 	return i;
@@ -1535,7 +1499,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.pg_write_ops		= &ff_layout_pg_write_ops,
 	.get_ds_info		= ff_layout_get_ds_info,
 	.free_deviceid_node	= ff_layout_free_deveiceid_node,
-	.mark_request_commit	= ff_layout_mark_request_commit,
+	.mark_request_commit	= pnfs_layout_mark_request_commit,
 	.clear_request_commit	= pnfs_generic_clear_request_commit,
 	.scan_commit_lists	= pnfs_generic_scan_commit_lists,
 	.recover_commit_reqs	= pnfs_generic_recover_commit_reqs,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 797cd62..635f086 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -344,6 +344,10 @@ void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
 						 struct xdr_stream *xdr,
 						 gfp_t gfp_flags);
+void pnfs_layout_mark_request_commit(struct nfs_page *req,
+				     struct pnfs_layout_segment *lseg,
+				     struct nfs_commit_info *cinfo,
+				     u32 ds_commit_idx);
 
 static inline bool nfs_have_layout(struct inode *inode)
 {
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index fdc4f65..54e36b3 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -838,3 +838,33 @@ out_err:
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(nfs4_decode_mp_ds_addr);
+
+void
+pnfs_layout_mark_request_commit(struct nfs_page *req,
+				struct pnfs_layout_segment *lseg,
+				struct nfs_commit_info *cinfo,
+				u32 ds_commit_idx)
+{
+	struct list_head *list;
+	struct pnfs_commit_bucket *buckets;
+
+	spin_lock(cinfo->lock);
+	buckets = cinfo->ds->buckets;
+	list = &buckets[ds_commit_idx].written;
+	if (list_empty(list)) {
+		/* Non-empty buckets hold a reference on the lseg.  That ref
+		 * is normally transferred to the COMMIT call and released
+		 * there.  It could also be released if the last req is pulled
+		 * off due to a rewrite, in which case it will be done in
+		 * pnfs_common_clear_request_commit
+		 */
+		WARN_ON_ONCE(buckets[ds_commit_idx].wlseg != NULL);
+		buckets[ds_commit_idx].wlseg = pnfs_get_lseg(lseg);
+	}
+	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
+	cinfo->ds->nwritten++;
+	spin_unlock(cinfo->lock);
+
+	nfs_request_add_commit_list(req, list, cinfo);
+}
+EXPORT_SYMBOL_GPL(pnfs_layout_mark_request_commit);
-- 
1.9.3

