Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6491 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab1DVIFB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 04:05:01 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] SQUASHME: remove wait parameter from the layoutreturn path.
Date: Fri, 22 Apr 2011 11:04:51 +0300
Message-Id: <1303459491-16357-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DB125BD.3040703@panasas.com>
References: <4DB125BD.3040703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

all call sites are sync now
squash into "pnfs: layoutreturn"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   11 ++++-------
 fs/nfs/pnfs.c     |   10 +++++-----
 fs/nfs/pnfs.h     |   12 +++++-------
 3 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3e1843d..4f637e9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2333,7 +2333,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	int status;
 
 	if (pnfs_ld_layoutret_on_setattr(inode))
-		pnfs_return_layout(inode, NULL, true);
+		pnfs_return_layout(inode, NULL);
 
 	nfs_fattr_init(fattr);
 	
@@ -5739,7 +5739,7 @@ static const struct rpc_call_ops nfs4_layoutreturn_call_ops = {
 	.rpc_release = nfs4_layoutreturn_release,
 };
 
-int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
+int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 {
 	struct rpc_task *task;
 	struct rpc_message msg = {
@@ -5752,22 +5752,19 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_layoutreturn_call_ops,
 		.callback_data = lrp,
-		.flags = RPC_TASK_ASYNC,
 	};
-	int status = 0;
+	int status;
 
 	dprintk("--> %s\n", __func__);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	if (!issync)
-		goto out;
 	status = nfs4_wait_for_completion_rpc_task(task);
 	if (status != 0)
 		goto out;
 	status = task->tk_status;
 out:
-	dprintk("<-- %s\n", __func__);
+	dprintk("<-- %s status=%d\n", __func__, status);
 	rpc_put_task(task);
 	return status;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bacde63..1ec5bb8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -667,7 +667,7 @@ out_err_free:
 }
 
 static int
-return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
+return_layout(struct inode *ino, struct pnfs_layout_range *range)
 {
 	struct nfs4_layoutreturn *lrp;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -687,7 +687,7 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
 	lrp->args.inode = ino;
 	lrp->clp = server->nfs_client;
 
-	status = nfs4_proc_layoutreturn(lrp, wait);
+	status = nfs4_proc_layoutreturn(lrp);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
@@ -695,7 +695,7 @@ out:
 
 /* Initiates a LAYOUTRETURN(FILE) */
 int
-_pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
+_pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range)
 {
 	struct pnfs_layout_hdr *lo = NULL;
 	struct nfs_inode *nfsi = NFS_I(ino);
@@ -722,11 +722,11 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wai
 	pnfs_free_lseg_list(&tmp_list);
 
 	/* Return layout even if layoutcommit fails */
-	status = pnfs_layoutcommit_inode(ino, wait);
+	status = pnfs_layoutcommit_inode(ino, true);
 	if (status)
 		dprintk("%s: layoutcommit failed, status=%d. Returning layout anyway\n",
 			__func__, status);
-	status = return_layout(ino, &arg, wait);
+	status = return_layout(ino, &arg);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b0f9b79..b5d1d22 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -164,7 +164,7 @@ extern int nfs4_proc_getdevicelist(struct nfs_server *server,
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
 extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
-extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool wait);
+extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
@@ -202,7 +202,7 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
-int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *, bool wait);
+int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *);
 int pnfs_write_done(struct nfs_write_data *);
 int pnfs_read_done(struct nfs_read_data *);
 
@@ -284,14 +284,13 @@ pnfs_ld_layoutret_on_setattr(struct inode *inode)
 }
 
 static inline int pnfs_return_layout(struct inode *ino,
-				     struct pnfs_layout_range *range,
-				     bool wait)
+				     struct pnfs_layout_range *range)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *nfss = NFS_SERVER(ino);
 
 	if (pnfs_enabled_sb(nfss) && nfsi->layout)
-		return _pnfs_return_layout(ino, range, wait);
+		return _pnfs_return_layout(ino, range);
 
 	return 0;
 }
@@ -338,8 +337,7 @@ pnfs_try_to_write_data(struct nfs_write_data *data,
 }
 
 static inline int pnfs_return_layout(struct inode *ino,
-				     struct pnfs_layout_range *range,
-				     bool wait)
+				     struct pnfs_layout_range *range)
 {
 	return 0;
 }
-- 
1.7.3.4

