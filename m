Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6492 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab1DVIFT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 04:05:19 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] SQUASHME: remove return_type field from nfs4_layoutreturn_args
Date: Fri, 22 Apr 2011 11:05:06 +0300
Message-Id: <1303459506-16393-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DB125BD.3040703@panasas.com>
References: <4DB125BD.3040703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Currently, we only send layoutreturns for single file.

squash into "pnfs: layoutreturn"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |   24 ++++++++----------------
 fs/nfs/nfs4xdr.c        |   32 ++++++++++++++------------------
 fs/nfs/pnfs.c           |    1 -
 include/linux/nfs_xdr.h |    1 -
 4 files changed, 22 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4f637e9..059a74c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5697,23 +5697,20 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	if (!nfs4_sequence_done(task, &lrp->res.seq_res))
 		return;
 
-	if (lrp->args.return_type == RETURN_FILE)
-		server = NFS_SERVER(lrp->args.inode);
-	else
-		server = NULL;
+	server = NFS_SERVER(lrp->args.inode);
 	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
 		nfs_restart_rpc(task, lrp->clp);
 		return;
 	}
-	if ((task->tk_status == 0) && (lrp->args.return_type == RETURN_FILE)) {
+	if (task->tk_status == 0) {
 		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
 
-		spin_lock(&lo->plh_inode->i_lock);
-		if (lrp->res.lrs_present)
+		if (lrp->res.lrs_present) {
+			spin_lock(&lo->plh_inode->i_lock);
 			pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-		else
+			spin_unlock(&lo->plh_inode->i_lock);
+		} else
 			BUG_ON(!list_empty(&lo->plh_segs));
-		spin_unlock(&lo->plh_inode->i_lock);
 	}
 	dprintk("<-- %s\n", __func__);
 }
@@ -5722,13 +5719,8 @@ static void nfs4_layoutreturn_release(void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
 
-	dprintk("--> %s return_type %d\n", __func__, lrp->args.return_type);
-	if (lrp->args.return_type == RETURN_FILE) {
-		struct inode *ino = lrp->args.inode;
-		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
-
-		put_layout_hdr(lo);
-	}
+	dprintk("--> %s\n", __func__);
+	put_layout_hdr(NFS_I(lrp->args.inode)->layout);
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a21bbbe..8c0e589 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1963,24 +1963,20 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(args->reclaim);
 	*p++ = cpu_to_be32(args->layout_type);
 	*p++ = cpu_to_be32(args->range.iomode);
-	*p = cpu_to_be32(args->return_type);
-	if (args->return_type == RETURN_FILE) {
-		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
-		p = xdr_encode_hyper(p, args->range.offset);
-		p = xdr_encode_hyper(p, args->range.length);
-		spin_lock(&args->inode->i_lock);
-		memcpy(stateid.data, NFS_I(args->inode)->layout->plh_stateid.data,
-		       NFS4_STATEID_SIZE);
-		spin_unlock(&args->inode->i_lock);
-		p = xdr_encode_opaque_fixed(p, &stateid.data,
-					    NFS4_STATEID_SIZE);
-		if (NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn) {
-			NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn(
-				NFS_I(args->inode)->layout, xdr, args);
-		} else {
-			p = reserve_space(xdr, 4);
-			*p = cpu_to_be32(0);
-		}
+	*p = cpu_to_be32(RETURN_FILE);
+	p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
+	p = xdr_encode_hyper(p, args->range.offset);
+	p = xdr_encode_hyper(p, args->range.length);
+	spin_lock(&args->inode->i_lock);
+	memcpy(stateid.data, NFS_I(args->inode)->layout->plh_stateid.data, NFS4_STATEID_SIZE);
+	spin_unlock(&args->inode->i_lock);
+	p = xdr_encode_opaque_fixed(p, &stateid.data, NFS4_STATEID_SIZE);
+	if (NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn) {
+		NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn(
+			NFS_I(args->inode)->layout, xdr, args);
+	} else {
+		p = reserve_space(xdr, 4);
+		*p = cpu_to_be32(0);
 	}
 	hdr->nops++;
 	hdr->replen += decode_layoutreturn_maxsz;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1ec5bb8..b2066d2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -682,7 +682,6 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range)
 	}
 	lrp->args.reclaim = 0;
 	lrp->args.layout_type = server->pnfs_curr_ld->id;
-	lrp->args.return_type = RETURN_FILE;
 	lrp->args.range = *range;
 	lrp->args.inode = ino;
 	lrp->clp = server->nfs_client;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0f9dc74..6506432 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -272,7 +272,6 @@ struct nfs4_layoutcommit_data {
 struct nfs4_layoutreturn_args {
 	__u32   reclaim;
 	__u32   layout_type;
-	__u32   return_type;
 	struct pnfs_layout_range range;
 	struct inode *inode;
 	struct nfs4_sequence_args seq_args;
-- 
1.7.3.4

