Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33439 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449Ab0KDPWw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:52 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMR029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:41 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/18] pnfs-submit: layoutreturn' rpc_call_op functions need to handle bulk returns
Date: Thu,  4 Nov 2010 11:22:18 -0400
Message-Id: <1288884151-11128-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

nfs4_proc_layoutreturn and its descendants were assuming that
inode and lo were always available, but that is not true in the
case of a bulk return.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c  |    1 +
 fs/nfs/nfs4proc.c       |   37 ++++++++++++++++++-------------------
 fs/nfs/pnfs.c           |    4 +++-
 include/linux/nfs_xdr.h |    1 +
 4 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 3e022a8..53a85648 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -284,6 +284,7 @@ static int pnfs_recall_layout(void *data)
 	lrp->args.reclaim = 0;
 	lrp->args.layout_type = rl.cbl_layout_type;
 	lrp->args.return_type = rl.cbl_recall_type;
+	lrp->clp = clp;
 	lrp->args.range = rl.cbl_seg;
 	lrp->args.inode = inode;
 	nfs4_proc_layoutreturn(lrp, true);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 73bd44e..8d3965c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5557,23 +5557,23 @@ static void
 nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
-	struct inode *ino = lrp->args.inode;
-	struct nfs_inode *nfsi = NFS_I(ino);
-	struct nfs_server *server = NFS_SERVER(ino);
 
 	dprintk("--> %s\n", __func__);
-	if ((lrp->args.return_type == RETURN_FILE) &&
-	    pnfs_return_layout_barrier(nfsi, &lrp->args.range)) {
-		dprintk("%s: waiting on barrier\n", __func__);
-		rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
-		return;
+	if (lrp->args.return_type == RETURN_FILE) {
+		struct nfs_inode *nfsi = NFS_I(lrp->args.inode);
+
+		if (pnfs_return_layout_barrier(nfsi, &lrp->args.range)) {
+			dprintk("%s: waiting on barrier\n", __func__);
+			rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
+			return;
+		}
 	}
 	if (lrp->stateid) {
 		/* Forget the layout, without sending the return */
 		rpc_exit(task, 0);
 		return;
 	}
-	if (nfs4_setup_sequence(server, NULL, &lrp->args.seq_args,
+	if (nfs41_setup_sequence(lrp->clp->cl_session, &lrp->args.seq_args,
 				&lrp->res.seq_res, 0, task))
 		return;
 	rpc_call_start(task);
@@ -5582,8 +5582,7 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
-	struct inode *ino = lrp->args.inode;
-	struct nfs_server *server = NFS_SERVER(ino);
+	struct nfs_server *server;
 
 	dprintk("--> %s\n", __func__);
 
@@ -5593,8 +5592,12 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	if (RPC_ASSASSINATED(task))
 		return;
 
-	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
-		nfs_restart_rpc(task, server->nfs_client);
+	if (lrp->args.return_type == RETURN_FILE)
+		server = NFS_SERVER(lrp->args.inode);
+	else
+		server = NULL;
+	if (nfs4_async_handle_error(task, server, NULL, lrp->clp) == -EAGAIN)
+		nfs_restart_rpc(task, lrp->clp);
 
 	dprintk("<-- %s\n", __func__);
 }
@@ -5602,10 +5605,8 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 static void nfs4_layoutreturn_release(void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
-	struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
 
-	dprintk("--> %s return_type %d lo %p\n", __func__,
-		lrp->args.return_type, lo);
+	dprintk("--> %s return_type %d\n", __func__, lrp->args.return_type);
 
 	pnfs_layoutreturn_release(lrp);
 	kfree(calldata);
@@ -5620,8 +5621,6 @@ static const struct rpc_call_ops nfs4_layoutreturn_call_ops = {
 
 int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
 {
-	struct inode *ino = lrp->args.inode;
-	struct nfs_server *server = NFS_SERVER(ino);
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTRETURN],
@@ -5629,7 +5628,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
 		.rpc_resp = &lrp->res,
 	};
 	struct rpc_task_setup task_setup_data = {
-		.rpc_client = server->client,
+		.rpc_client = lrp->clp->cl_rpcclient,
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_layoutreturn_call_ops,
 		.callback_data = lrp,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 01ecb95..34f6914 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -590,10 +590,11 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 void
 pnfs_layoutreturn_release(struct nfs4_layoutreturn *lrp)
 {
-	struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
+	struct pnfs_layout_hdr *lo;
 
 	if (lrp->args.return_type != RETURN_FILE)
 		return;
+	lo = NFS_I(lrp->args.inode)->layout;
 	spin_lock(&lrp->args.inode->i_lock);
 	if (!lrp->res.valid)
 		;	/* forgetful model internal release */
@@ -630,6 +631,7 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	lrp->args.range = *range;
 	lrp->args.inode = ino;
 	lrp->stateid = stateid;
+	lrp->clp = server->nfs_client;
 
 	status = nfs4_proc_layoutreturn(lrp, wait);
 out:
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1ff6cb0..0ee7cce 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -280,6 +280,7 @@ struct nfs4_layoutreturn {
 	struct nfs4_layoutreturn_res res;
 	struct rpc_cred *cred;
 	const nfs4_stateid *stateid;
+	struct nfs_client *clp;
 	int rpc_status;
 };
 
-- 
1.7.2.1

