Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65354 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755825Ab0KLItZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:25 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fM025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:15 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/22] pnfs_submit: nfs4_layoutreturn_release should not reference results
Date: Fri, 12 Nov 2010 03:48:34 -0500
Message-Id: <1289551724-18575-13-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Since the release function may be called without sending any RPC,
it must not refer to any of the result fields.  This is
better accomplished in the rpc_done function.

In the process, this basically reimplements the commit
"pnfs: do not change layout stateid when dropping layouts."

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |   24 ++++++++++++++++++++++--
 fs/nfs/nfs4xdr.c        |    1 -
 fs/nfs/pnfs.c           |   26 ++------------------------
 fs/nfs/pnfs.h           |    3 ++-
 include/linux/nfs_xdr.h |    1 -
 5 files changed, 26 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5ccde2a..fe79872 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5578,9 +5578,20 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		server = NFS_SERVER(lrp->args.inode);
 	else
 		server = NULL;
-	if (nfs4_async_handle_error(task, server, NULL, lrp->clp) == -EAGAIN)
+	if (nfs4_async_handle_error(task, server, NULL, lrp->clp) == -EAGAIN) {
 		nfs_restart_rpc(task, lrp->clp);
+		return;
+	}
+	if ((task->tk_status == 0) && (lrp->args.return_type == RETURN_FILE)) {
+		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
 
+		spin_lock(&lo->inode->i_lock);
+		if (lrp->res.lrs_present)
+			pnfs_set_layout_stateid(lo, &lrp->res.stateid);
+		else
+			pnfs_invalidate_layout_stateid(lo);
+		spin_unlock(&lo->inode->i_lock);
+	}
 	dprintk("<-- %s\n", __func__);
 }
 
@@ -5589,8 +5600,17 @@ static void nfs4_layoutreturn_release(void *calldata)
 	struct nfs4_layoutreturn *lrp = calldata;
 
 	dprintk("--> %s return_type %d\n", __func__, lrp->args.return_type);
+	if (lrp->args.return_type == RETURN_FILE) {
+		struct inode *ino = lrp->args.inode;
+		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
 
-	pnfs_layoutreturn_release(lrp);
+		spin_lock(&ino->i_lock);
+		lo->plh_block_lgets--;
+		if (!pnfs_layoutgets_blocked(lo))
+			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
+		spin_unlock(&ino->i_lock);
+		put_layout_hdr(lrp->args.inode);
+	}
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 550e457..328cca5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5287,7 +5287,6 @@ static int decode_layoutreturn(struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	res->valid = true;
 	res->lrs_present = be32_to_cpup(p);
 	if (res->lrs_present)
 		status = decode_stateid(xdr, &res->stateid);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1147eb3..353c674 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -449,7 +449,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
  *
  * lo->stateid could be the open stateid, in which case we just use what given.
  */
-static void
+void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			const nfs4_stateid *new)
 {
@@ -580,28 +580,6 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 	return ret;
 }
 
-void
-pnfs_layoutreturn_release(struct nfs4_layoutreturn *lrp)
-{
-	struct pnfs_layout_hdr *lo;
-
-	if (lrp->args.return_type != RETURN_FILE)
-		return;
-	lo = NFS_I(lrp->args.inode)->layout;
-	spin_lock(&lrp->args.inode->i_lock);
-	lo->plh_block_lgets--;
-	if (!pnfs_layoutgets_blocked(lo))
-		rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
-	if (!lrp->res.valid)
-		;	/* forgetful model internal release */
-	else if (!lrp->res.lrs_present)
-		pnfs_invalidate_layout_stateid(lo);
-	else 
-		pnfs_set_layout_stateid(lo, &lrp->res.stateid);
-	put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
-	spin_unlock(&lrp->args.inode->i_lock);
-}
-
 static int
 return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	      enum pnfs_layoutreturn_type type, struct pnfs_layout_hdr *lo,
@@ -672,7 +650,7 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 		list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
 			if (should_free_lseg(&lseg->range, &arg))
 				mark_lseg_invalid(lseg, &tmp_list);
-		/* Reference matched in pnfs_layoutreturn_release */
+		/* Reference matched in nfs4_layoutreturn_release */
 		get_layout_hdr_locked(lo);
 		spin_unlock(&ino->i_lock);
 		pnfs_free_lseg_list(&tmp_list);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a9a3bea..4f2c541 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -203,10 +203,11 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
-void pnfs_layoutreturn_release(struct nfs4_layoutreturn *lpr);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
 void put_layout_hdr(struct inode *inode);
+void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
+			     const nfs4_stateid *new);
 void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			     struct nfs4_state *open_state);
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 23a4519..f472405 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -269,7 +269,6 @@ struct nfs4_layoutreturn_args {
 
 struct nfs4_layoutreturn_res {
 	struct nfs4_sequence_res seq_res;
-	bool valid;	/* internal, true if received reply */
 	u32 lrs_present;
 	nfs4_stateid stateid;
 };
-- 
1.7.2.1

