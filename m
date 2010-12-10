Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56510 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979Ab0LJGIk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:40 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLe023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:36 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/22] Revert "SQUASHME: make roc patches compile without v4.1"
Date: Thu,  9 Dec 2010 20:22:38 -0500
Message-Id: <1291944177-7819-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit a512f09586628b295c960e8df35d42726180f96f.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |   55 ++++++++++++++++++++++++++++++++--------------------
 fs/nfs/nfs4xdr.c  |   34 --------------------------------
 fs/nfs/pnfs.h     |   24 -----------------------
 3 files changed, 34 insertions(+), 79 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dbe518c..3a1e578 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -74,6 +74,8 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs4_state *state);
+static void nfs4_layoutreturn_set_stateid(struct inode *ino,
+					  struct nfs4_layoutreturn_res *res);
 
 /* Prevent leaks of NFSv4 errors into userland */
 static int nfs4_map_errors(int err)
@@ -1842,8 +1844,17 @@ static void nfs4_free_closedata(void *data)
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
 	path_put(&calldata->path);
-	if (calldata->res.op_bitmask & NFS4_HAS_LAYOUTRETURN)
-		nfs4_layoutreturn_file_release(calldata->inode);
+	if (calldata->res.op_bitmask & NFS4_HAS_LAYOUTRETURN) {
+		struct pnfs_layout_hdr *lo = NFS_I(calldata->inode)->layout;
+
+		spin_lock(&lo->inode->i_lock);
+		lo->plh_block_lgets--;
+		lo->plh_outstanding--;
+		if (!pnfs_layoutgets_blocked(lo, NULL))
+			rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
+		spin_unlock(&lo->inode->i_lock);
+		put_layout_hdr(lo->inode);
+	}
 	kfree(calldata);
 }
 
@@ -1932,13 +1943,18 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		/* Are there layout segments to return on close? */
 		if (pnfs_roc(calldata)) {
 			struct nfs_inode *nfsi = NFS_I(calldata->inode);
-
 			if (pnfs_return_layout_barrier(nfsi,
 						&calldata->arg.lr_args.range)) {
 				dprintk("%s: waiting on barrier\n", __func__);
 				/* FIXME race with wake here */
 				rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
-				nfs4_layoutreturn_file_release(calldata->inode);
+				spin_lock(&calldata->inode->i_lock);
+				nfsi->layout->plh_block_lgets--;
+				nfsi->layout->plh_outstanding--;
+				if (!pnfs_layoutgets_blocked(nfsi->layout, NULL))
+					rpc_wake_up(&nfsi->lo_rpcwaitq_stateid);
+				spin_unlock(&calldata->inode->i_lock);
+				put_layout_hdr(calldata->inode);
 				return;
 			}
 		}
@@ -5620,8 +5636,8 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 	rpc_call_start(task);
 }
 
-void nfs4_layoutreturn_set_stateid(struct inode *ino,
-				   struct nfs4_layoutreturn_res *res)
+static void nfs4_layoutreturn_set_stateid(struct inode *ino,
+					  struct nfs4_layoutreturn_res *res)
 {
 	struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
 
@@ -5656,26 +5672,23 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	dprintk("<-- %s\n", __func__);
 }
 
-void nfs4_layoutreturn_file_release(struct inode *ino)
-{
-	struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
-
-	spin_lock(&ino->i_lock);
-	lo->plh_block_lgets--;
-	lo->plh_outstanding--;
-	if (!pnfs_layoutgets_blocked(lo, NULL))
-		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
-	spin_unlock(&ino->i_lock);
-	put_layout_hdr(ino);
-}
-
 static void nfs4_layoutreturn_release(void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
 
 	dprintk("--> %s return_type %d\n", __func__, lrp->args.return_type);
-	if (lrp->args.return_type == RETURN_FILE)
-		nfs4_layoutreturn_file_release(lrp->args.inode);
+	if (lrp->args.return_type == RETURN_FILE) {
+		struct inode *ino = lrp->args.inode;
+		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
+
+		spin_lock(&ino->i_lock);
+		lo->plh_block_lgets--;
+		lo->plh_outstanding--;
+		if (!pnfs_layoutgets_blocked(lo, NULL))
+			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
+		spin_unlock(&ino->i_lock);
+		put_layout_hdr(ino);
+	}
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8dbfbb0..b9fe438 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -338,10 +338,6 @@ static int nfs4_stat_to_errno(int);
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
-#define encode_layoutcommit_maxsz 0
-#define decode_layoutcommit_maxsz 0
-#define encode_layoutreturn_maxsz 0
-#define decode_layoutreturn_maxsz 0
 #endif /* CONFIG_NFS_V4_1 */
 
 #define NFS4_enc_compound_sz	(1024)  /* XXX: large enough? */
@@ -1933,22 +1929,6 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	hdr->nops++;
 	hdr->replen += decode_layoutreturn_maxsz;
 }
-#else
-static int
-encode_layoutcommit(struct xdr_stream *xdr,
-		    const struct nfs4_layoutcommit_op_args *args,
-		    struct compound_hdr *hdr)
-{
-	return 0;
-}
-
-static void
-encode_layoutreturn(struct xdr_stream *xdr,
-		    const struct nfs4_layoutreturn_args *args,
-		    struct compound_hdr *hdr)
-{
-}
-
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -5352,20 +5332,6 @@ out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
-
-#else
-
-static int decode_layoutcommit(struct xdr_stream *xdr)
-{
-	return 0;
-}
-
-static int decode_layoutreturn(struct xdr_stream *xdr,
-			       struct nfs4_layoutreturn_res *res)
-{
-	return 0;
-}
-
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c527e55..8ef47e9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -188,9 +188,6 @@ extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
 				   int issync);
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool wait);
-extern void nfs4_layoutreturn_file_release(struct inode *ino);
-extern void nfs4_layoutreturn_set_stateid(struct inode *ino,
-					  struct nfs4_layoutreturn_res *res);
 
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
@@ -393,27 +390,6 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *ino)
 	pgio->pg_lseg = NULL;
 }
 
-static inline void nfs4_layoutreturn_file_release(struct inode *ino)
-{
-}
-
-static inline bool pnfs_roc(struct nfs4_closedata *data)
-{
-	return false;
-}
-
-static inline bool pnfs_return_layout_barrier(struct nfs_inode *nfsi,
-					      struct pnfs_layout_range *range)
-{
-	BUG();
-	return false;
-}
-
-static inline void nfs4_layoutreturn_set_stateid(struct inode *ino,
-				struct nfs4_layoutreturn_res *res)
-{
-}
-
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
-- 
1.7.2.1

