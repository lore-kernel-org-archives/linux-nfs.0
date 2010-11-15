Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27488 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757345Ab0KOTBC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Nov 2010 14:01:02 -0500
Received: from localhost.localdomain (vpn2ntap-136191.hq.netapp.com [10.58.56.111])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAFJ0f4d028248
	for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 11:00:42 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] pnfs-submit: remove type argument from pnfs_return_layout
Date: Mon, 15 Nov 2010 14:00:36 -0500
Message-Id: <1289847638-12175-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289847638-12175-1-git-send-email-iisaman@netapp.com>
References: <1289847638-12175-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

pnfs_return_layout is only called with type=RETURN_FILE, so remove as argument

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c |    2 +-
 fs/nfs/pnfs.c  |   76 ++++++++++++++++++++++++-------------------------------
 fs/nfs/pnfs.h  |   10 ++-----
 3 files changed, 37 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3bf7a42..bbeb337 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1419,7 +1419,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 void nfs4_evict_inode(struct inode *inode)
 {
-	pnfs_return_layout(inode, NULL, RETURN_FILE, true);
+	pnfs_return_layout(inode, NULL, true);
 	truncate_inode_pages(&inode->i_data, 0);
 	end_writeback(inode);
 	pnfs_destroy_layout(NFS_I(inode));
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a62f518..eefa440 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -691,9 +691,7 @@ out_nolayout:
 }
 
 static int
-return_layout(struct inode *ino, struct pnfs_layout_range *range,
-	      enum pnfs_layoutreturn_type type, struct pnfs_layout_hdr *lo,
-	      bool wait)
+return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
 {
 	struct nfs4_layoutreturn *lrp;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -701,17 +699,14 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range,
 
 	dprintk("--> %s\n", __func__);
 
-	BUG_ON(type != RETURN_FILE);
-
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (lrp == NULL) {
-		if (lo && (type == RETURN_FILE))
-			put_layout_hdr(lo->inode);
+		put_layout_hdr(ino);
 		goto out;
 	}
 	lrp->args.reclaim = 0;
 	lrp->args.layout_type = server->pnfs_curr_ld->id;
-	lrp->args.return_type = type;
+	lrp->args.return_type = RETURN_FILE;
 	lrp->args.range = *range;
 	lrp->args.inode = ino;
 	lrp->clp = server->nfs_client;
@@ -722,58 +717,53 @@ out:
 	return status;
 }
 
+/* Initiates a LAYOUTRETURN(FILE) */
 int
 _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
-		    enum pnfs_layoutreturn_type type,
 		    bool wait)
 {
 	struct pnfs_layout_hdr *lo = NULL;
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_range arg;
+	LIST_HEAD(tmp_list);
+	struct pnfs_layout_segment *lseg, *tmp;
 	int status = 0;
 
-	dprintk("--> %s type %d\n", __func__, type);
-
+	dprintk("--> %s\n", __func__);
 
 	arg.iomode = range ? range->iomode : IOMODE_ANY;
 	arg.offset = 0;
 	arg.length = NFS4_MAX_UINT64;
 
-	/* probably should BUGON if type != RETURN_FILE */
-	if (type == RETURN_FILE) {
-		LIST_HEAD(tmp_list);
-		struct pnfs_layout_segment *lseg, *tmp;
+	spin_lock(&ino->i_lock);
+	lo = nfsi->layout;
+	if (lo && !has_layout_to_return(lo, &arg))
+		lo = NULL;
+	if (!lo) {
+		spin_unlock(&ino->i_lock);
+		dprintk("%s: no layout segments to return\n", __func__);
+		goto out;
+	}
 
-		spin_lock(&ino->i_lock);
-		lo = nfsi->layout;
-		if (lo && !has_layout_to_return(lo, &arg))
-			lo = NULL;
-		if (!lo) {
-			spin_unlock(&ino->i_lock);
-			dprintk("%s: no layout segments to return\n", __func__);
-			goto out;
-		}
+	lo->plh_block_lgets++;
+	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
+		if (should_free_lseg(&lseg->range, &arg))
+			mark_lseg_invalid(lseg, &tmp_list);
+	/* Reference matched in nfs4_layoutreturn_release */
+	get_layout_hdr(lo);
+	spin_unlock(&ino->i_lock);
+	pnfs_free_lseg_list(&tmp_list);
 
-		lo->plh_block_lgets++;
-		list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
-			if (should_free_lseg(&lseg->range, &arg))
-				mark_lseg_invalid(lseg, &tmp_list);
-		/* Reference matched in nfs4_layoutreturn_release */
-		get_layout_hdr(lo);
-		spin_unlock(&ino->i_lock);
-		pnfs_free_lseg_list(&tmp_list);
-
-		if (layoutcommit_needed(nfsi)) {
-			status = pnfs_layoutcommit_inode(ino, wait);
-			if (status) {
-				/* Return layout even if layoutcommit fails */
-				dprintk("%s: layoutcommit failed, status=%d. "
-					"Returning layout anyway\n",
-					__func__, status);
-			}
+	if (layoutcommit_needed(nfsi)) {
+		status = pnfs_layoutcommit_inode(ino, wait);
+		if (status) {
+			/* Return layout even if layoutcommit fails */
+			dprintk("%s: layoutcommit failed, status=%d. "
+				"Returning layout anyway\n",
+				__func__, status);
 		}
-		status = return_layout(ino, &arg, type, lo, wait);
 	}
+	status = return_layout(ino, &arg, wait);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 46dab34..a124ad2 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -204,8 +204,7 @@ struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_layout_range *);
-int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *,
-			enum pnfs_layoutreturn_type, bool wait);
+int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
@@ -278,15 +277,13 @@ pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
 
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct pnfs_layout_range *range,
-				     enum pnfs_layoutreturn_type type,
 				     bool wait)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *nfss = NFS_SERVER(ino);
 
-	if (pnfs_enabled_sb(nfss) &&
-	    (type != RETURN_FILE || has_layout(nfsi)))
-		return _pnfs_return_layout(ino, range, type, wait);
+	if (pnfs_enabled_sb(nfss) && has_layout(nfsi))
+		return _pnfs_return_layout(ino, range, wait);
 
 	return 0;
 }
@@ -381,7 +378,6 @@ pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
 
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct pnfs_layout_range *range,
-				     enum pnfs_layoutreturn_type type,
 				     bool wait)
 {
 	return 0;
-- 
1.7.2.1

