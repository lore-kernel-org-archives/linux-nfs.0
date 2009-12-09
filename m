From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 4/4] SQUASHME: pnfsd: use only RETURN_* constants
Date: Wed,  9 Dec 2009 12:27:46 +0200
Message-ID: <1260354466-12216-1-git-send-email-bhalevy@panasas.com>
References: <4B1F7AF6.2080305@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:28939 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754016AbZLIK1m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 05:27:42 -0500
In-Reply-To: <4B1F7AF6.2080305@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    4 ++--
 fs/nfsd/nfs4pnfsd.c    |   32 ++++++++++++++++----------------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0bc800d..c5d2a29 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -328,7 +328,7 @@ encode_cb_layout(struct xdr_stream *xdr, struct nfs4_layoutrecall *clr,
 	WRITE32(clr->cb.cbl_seg.iomode);
 	WRITE32(clr->cb.cbl_layoutchanged);
 	WRITE32(clr->cb.cbl_recall_type);
-	if (unlikely(clr->cb.cbl_recall_type == RECALL_FSID)) {
+	if (unlikely(clr->cb.cbl_recall_type == RETURN_FSID)) {
 		struct nfs4_fsid fsid = clr->cb.cbl_fsid;
 
 		RESERVE_SPACE(16);
@@ -339,7 +339,7 @@ encode_cb_layout(struct xdr_stream *xdr, struct nfs4_layoutrecall *clr,
 			__func__, clr->cb.cbl_seg.layout_type,
 			clr->cb.cbl_seg.iomode, clr->cb.cbl_layoutchanged,
 			clr->cb.cbl_recall_type, fsid.major, fsid.minor);
-	} else if (clr->cb.cbl_recall_type == RECALL_FILE) {
+	} else if (clr->cb.cbl_recall_type == RETURN_FILE) {
 		int len = clr->clr_file->fi_fhlen;
 
 		RESERVE_SPACE(20 + len);
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index e1e8062..a98d71b 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -586,15 +586,15 @@ is_layout_recalled(struct nfs4_client *clp,
 	list_for_each_entry (clr, &clp->cl_layoutrecalls, clr_perclnt) {
 		if (clr->cb.cbl_seg.layout_type != seg->layout_type)
 			continue;
-		if (clr->cb.cbl_recall_type == RECALL_ALL)
+		if (clr->cb.cbl_recall_type == RETURN_ALL)
 			goto found;
-		if (clr->cb.cbl_recall_type == RECALL_FSID) {
+		if (clr->cb.cbl_recall_type == RETURN_FSID) {
 			if (same_fsid(&clr->cb.cbl_fsid, current_fh))
 				goto found;
 			else
 				continue;
 		}
-		BUG_ON(clr->cb.cbl_recall_type != RECALL_FILE);
+		BUG_ON(clr->cb.cbl_recall_type != RETURN_FILE);
 		if (clr->cb.cbl_seg.clientid == seg->clientid &&
 		    lo_seg_overlapping(&clr->cb.cbl_seg, seg))
 			goto found;
@@ -889,15 +889,15 @@ recall_return_perfect_match(struct nfs4_layoutrecall *clr,
 	    clr->cb.cbl_recall_type != lrp->args.lr_return_type)
 		return 0;
 
-	return (clr->cb.cbl_recall_type == RECALL_FILE &&
+	return (clr->cb.cbl_recall_type == RETURN_FILE &&
 		clr->clr_file == fp &&
 		clr->cb.cbl_seg.offset == lrp->args.lr_seg.offset &&
 		clr->cb.cbl_seg.length == lrp->args.lr_seg.length) ||
 
-		(clr->cb.cbl_recall_type == RECALL_FSID &&
+		(clr->cb.cbl_recall_type == RETURN_FSID &&
 		 same_fsid(&clr->cb.cbl_fsid, current_fh)) ||
 
-		clr->cb.cbl_recall_type == RECALL_ALL;
+		clr->cb.cbl_recall_type == RETURN_ALL;
 }
 
 static int
@@ -912,12 +912,12 @@ recall_return_partial_match(struct nfs4_layoutrecall *clr,
 	    lrp->args.lr_seg.iomode != IOMODE_ANY)
 		return 0;
 
-	if (clr->cb.cbl_recall_type == RECALL_ALL ||
+	if (clr->cb.cbl_recall_type == RETURN_ALL ||
 	    lrp->args.lr_return_type == RETURN_ALL)
 		return 1;
 
 	/* fsid matches? */
-	if (clr->cb.cbl_recall_type == RECALL_FSID ||
+	if (clr->cb.cbl_recall_type == RETURN_FSID ||
 	    lrp->args.lr_return_type == RETURN_FSID)
 		return same_fsid(&clr->cb.cbl_fsid, current_fh);
 
@@ -1123,9 +1123,9 @@ cl_has_layout(struct nfs4_client *clp, struct nfsd4_pnfs_cb_layout *cbl,
 	      struct nfs4_file *lrfile, stateid_t *lsid)
 {
 	switch (cbl->cbl_recall_type) {
-	case RECALL_FILE:
+	case RETURN_FILE:
 		return cl_has_file_layout(clp, lrfile, lsid);
-	case RECALL_FSID:
+	case RETURN_FSID:
 		return cl_has_fsid_layout(clp, &cbl->cbl_fsid);
 	default:
 		return cl_has_any_layout(clp);
@@ -1156,7 +1156,7 @@ nomatching_layout(struct nfs4_layoutrecall *clr)
 	dprintk("%s: clp %p fp %p: simulating layout_return\n", __func__,
 		clr->clr_client, clr->clr_file);
 
-	if (clr->cb.cbl_recall_type == RECALL_FILE)
+	if (clr->cb.cbl_recall_type == RETURN_FILE)
 		pnfs_return_file_layouts(clr->clr_client, clr->clr_file, &lr);
 	else
 		pnfs_return_client_layouts(clr->clr_client, &lr,
@@ -1398,10 +1398,10 @@ int nfsd_layout_recall_cb(struct super_block *sb, struct inode *inode,
 
 	dprintk("NFSD nfsd_layout_recall_cb: inode %p cbl %p\n", inode, cbl);
 	BUG_ON(!cbl);
-	BUG_ON(cbl->cbl_recall_type != RECALL_FILE &&
-	       cbl->cbl_recall_type != RECALL_FSID &&
-	       cbl->cbl_recall_type != RECALL_ALL);
-	BUG_ON(cbl->cbl_recall_type == RECALL_FILE && !inode);
+	BUG_ON(cbl->cbl_recall_type != RETURN_FILE &&
+	       cbl->cbl_recall_type != RETURN_FSID &&
+	       cbl->cbl_recall_type != RETURN_ALL);
+	BUG_ON(cbl->cbl_recall_type == RETURN_FILE && !inode);
 	BUG_ON(cbl->cbl_seg.iomode != IOMODE_READ &&
 	       cbl->cbl_seg.iomode != IOMODE_RW &&
 	       cbl->cbl_seg.iomode != IOMODE_ANY);
@@ -1420,7 +1420,7 @@ int nfsd_layout_recall_cb(struct super_block *sb, struct inode *inode,
 				"nfs4_file not found\n");
 			goto err;
 		}
-		if (cbl->cbl_recall_type == RECALL_FSID)
+		if (cbl->cbl_recall_type == RETURN_FSID)
 			cbl->cbl_fsid = lrfile->fi_fsid;
 	}
 
-- 
1.6.5.1

