Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:43224 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965368AbbBBWlO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:41:14 -0500
Received: by mail-pa0-f45.google.com with SMTP id et14so87962771pad.4
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:41:14 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 43/53] nfs41: allow async version layoutreturn
Date: Mon,  2 Feb 2015 14:38:57 -0800
Message-Id: <1422916747-86649-44-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/nfs4proc.c | 11 +++++++++--
 fs/nfs/pnfs.c     | 11 ++++++-----
 fs/nfs/pnfs.h     |  2 +-
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e19b5db..2397c0f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7810,7 +7810,7 @@ static const struct rpc_call_ops nfs4_layoutreturn_call_ops = {
 	.rpc_release = nfs4_layoutreturn_release,
 };
 
-int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
+int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
 {
 	struct rpc_task *task;
 	struct rpc_message msg = {
@@ -7824,16 +7824,23 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_layoutreturn_call_ops,
 		.callback_data = lrp,
+		.flags = RPC_TASK_ASYNC,
 	};
-	int status;
+	int status = 0;
 
 	dprintk("--> %s\n", __func__);
 	nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
+	if (sync == false)
+		goto out;
+	status = nfs4_wait_for_completion_rpc_task(task);
+	if (status != 0)
+		goto out;
 	status = task->tk_status;
 	trace_nfs4_layoutreturn(lrp->args.inode, status);
+out:
 	dprintk("<-- %s status=%d\n", __func__, status);
 	rpc_put_task(task);
 	return status;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9549b89..0a0e209 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -52,7 +52,7 @@ static LIST_HEAD(pnfs_modules_tbl);
 
 static int
 pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
-		       enum pnfs_iomode iomode);
+		       enum pnfs_iomode iomode, bool sync);
 
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
@@ -392,7 +392,8 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 		spin_unlock(&inode->i_lock);
 		pnfs_free_lseg(lseg);
 		if (need_return)
-			pnfs_send_layoutreturn(lo, stateid, iomode);
+			pnfs_send_layoutreturn(lo, stateid, iomode,
+					       true);
 		else
 			pnfs_put_layout_hdr(lo);
 	}
@@ -897,7 +898,7 @@ static void pnfs_clear_layoutcommit(struct inode *inode,
 
 static int
 pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
-		       enum pnfs_iomode iomode)
+		       enum pnfs_iomode iomode, bool sync)
 {
 	struct inode *ino = lo->plh_inode;
 	struct nfs4_layoutreturn *lrp;
@@ -923,7 +924,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 	lrp->clp = NFS_SERVER(ino)->nfs_client;
 	lrp->cred = lo->plh_lc_cred;
 
-	status = nfs4_proc_layoutreturn(lrp);
+	status = nfs4_proc_layoutreturn(lrp, sync);
 out:
 	if (status) {
 		spin_lock(&ino->i_lock);
@@ -989,7 +990,7 @@ _pnfs_return_layout(struct inode *ino)
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
-	status = pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY);
+	status = pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, true);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9d176e1..443d199 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -219,7 +219,7 @@ extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev,
 				   struct rpc_cred *cred);
 extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags);
-extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
+extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync);
 
 /* pnfs.c */
 void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
-- 
1.9.3

