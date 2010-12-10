Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47852 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318Ab0LJGIk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:40 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLc023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:33 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/22] Revert "pnfs-submit: handle NFS4ERR_DELEG_REVOKED for LAYOUTRETURN"
Date: Thu,  9 Dec 2010 20:22:36 -0500
Message-Id: <1291944177-7819-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit ed527fc7fba08f0665cc6b59d9130a6bd09a2659.

Conflicts:

	fs/nfs/pnfs.c
	fs/nfs/pnfs.h

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |   39 +++------------------------------------
 fs/nfs/pnfs.c     |    6 ++----
 fs/nfs/pnfs.h     |   14 --------------
 3 files changed, 5 insertions(+), 54 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2811d97..dbe518c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1880,16 +1880,6 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			nfs4_close_clear_stateid_flags(state,
 					calldata->arg.fmode);
 			break;
-		case -NFS4ERR_DELEG_REVOKED:
-			if (calldata->res.op_bitmask & (NFS4_HAS_LAYOUTCOMMIT |
-							NFS4_HAS_LAYOUTRETURN)) {
-				pnfs_mark_layout_revoked(calldata->inode);
-				/* Retry without layout operations as
-				 * pnfs_roc will find roc_iomode==0 next time around
-				 */
-				rpc_restart_call_prepare(task);
-				break;
-			}
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_OLD_STATEID:
 		case -NFS4ERR_BAD_STATEID:
@@ -5646,7 +5636,6 @@ void nfs4_layoutreturn_set_stateid(struct inode *ino,
 static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
-	struct inode *ino = lrp->args.inode;
 	struct nfs_server *server;
 
 	dprintk("--> %s\n", __func__);
@@ -5655,50 +5644,28 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		return;
 
 	if (lrp->args.return_type == RETURN_FILE)
-		server = NFS_SERVER(ino);
+		server = NFS_SERVER(lrp->args.inode);
 	else
 		server = NULL;
 	if (nfs4_async_handle_error(task, server, NULL, lrp->clp) == -EAGAIN) {
 		nfs_restart_rpc(task, lrp->clp);
 		return;
 	}
-	switch (task->tk_status) {
-	case -NFS4ERR_DELEG_REVOKED:
-		task->tk_status = 0;	/* TODO: revalidate remaining layouts? */
-		if (lrp->args.return_type == RETURN_FILE)
-			pnfs_mark_layout_revoked(ino);
-		break;
-	case 0:
-		if (lrp->args.return_type == RETURN_FILE)
-			nfs4_layoutreturn_set_stateid(lrp->args.inode, &lrp->res);
-	}
+	if ((task->tk_status == 0) && (lrp->args.return_type == RETURN_FILE))
+		nfs4_layoutreturn_set_stateid(lrp->args.inode, &lrp->res);
 	dprintk("<-- %s\n", __func__);
 }
 
 void nfs4_layoutreturn_file_release(struct inode *ino)
 {
 	struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
-	LIST_HEAD(tmp_list);
 
 	spin_lock(&ino->i_lock);
-	if (test_bit(NFS_LAYOUT_REVOKED, &lo->plh_flags)) {
-		struct pnfs_layout_range range = {
-			.iomode = IOMODE_ANY,
-			.offset = 0,
-			.length = NFS4_MAX_UINT64,
-		};
-
-		/* layout driver's free_lseg may block, hence we don't
-		 * call pnfs_free_lseg_list under the spin_lock */
-		pnfs_clear_lseg_list(lo, &tmp_list, &range);
-		clear_bit(NFS_LAYOUT_REVOKED, &lo->plh_flags);
-	}
 	lo->plh_block_lgets--;
 	lo->plh_outstanding--;
 	if (!pnfs_layoutgets_blocked(lo, NULL))
 		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
 	spin_unlock(&ino->i_lock);
-	pnfs_free_lseg_list(&tmp_list);
 	put_layout_hdr(ino);
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a21debe..d3ce095 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -376,7 +376,7 @@ static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 }
 
 /* Returns false if there was nothing to do, true otherwise */
-bool
+static bool
 pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 		     struct pnfs_layout_range *range)
 {
@@ -629,12 +629,10 @@ pnfs_roc(struct nfs4_closedata *data)
 	spin_lock(&data->inode->i_lock);
 	lo = NFS_I(data->inode)->layout;
 	if (!lo || lo->roc_iomode == 0 ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-	    test_bit(NFS_LAYOUT_REVOKED, &lo->plh_flags))
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
 		goto out_nolayout;
 
 	range.iomode = lo->roc_iomode;
-	lo->roc_iomode = 0;
 	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
 		if (should_free_lseg(&lseg->range, &range)) {
 			mark_lseg_invalid(lseg, &tmp_list);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 12fe7ab..c527e55 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -56,7 +56,6 @@ enum {
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_NEED_LCOMMIT,	/* LAYOUTCOMMIT needed */
-	NFS_LAYOUT_REVOKED,		/* layout revoked by the server */
 };
 
 /* Per-layout driver specific registration structure */
@@ -220,8 +219,6 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
-bool pnfs_clear_lseg_list(struct pnfs_layout_hdr *, struct list_head *tmp_list,
-			  struct pnfs_layout_range *);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
@@ -293,12 +290,6 @@ layoutcommit_needed(struct nfs_inode *nfsi)
 	       test_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags);
 }
 
-static inline void
-pnfs_mark_layout_revoked(struct inode *ino)
-{
-	set_bit(NFS_LAYOUT_REVOKED, &NFS_I(ino)->layout->plh_flags);
-}
-
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
@@ -423,11 +414,6 @@ static inline void nfs4_layoutreturn_set_stateid(struct inode *ino,
 {
 }
 
-static inline void
-pnfs_mark_layout_revoked(struct inode *ino)
-{
-}
-
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
-- 
1.7.2.1

