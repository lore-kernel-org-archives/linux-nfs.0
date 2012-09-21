Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20836 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756903Ab2IUUuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:50:54 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/26] NFS: Clean up the pNFS layoutget interface
Date: Fri, 21 Sep 2012 16:49:56 -0400
Message-Id: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we do return errors from nfs4_proc_layoutget() and that we
don't mark the layout as having failed if the error was due to a
signal or resource problem on the client side.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       | 14 +++++++++-----
 fs/nfs/pnfs.c           | 25 ++++++++++++++++---------
 fs/nfs/pnfs.h           |  4 ++--
 include/linux/nfs_xdr.h |  1 -
 4 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 645c450..b738577 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6286,7 +6286,8 @@ static const struct rpc_call_ops nfs4_layoutget_call_ops = {
 	.rpc_release = nfs4_layoutget_release,
 };
 
-void nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
+struct pnfs_layout_segment *
+nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 {
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 	size_t max_pages = max_response_pages(server);
@@ -6303,6 +6304,7 @@ void nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 		.callback_data = lgp,
 		.flags = RPC_TASK_ASYNC,
 	};
+	struct pnfs_layout_segment *lseg = NULL;
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
@@ -6310,7 +6312,7 @@ void nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 	lgp->args.layout.pages = nfs4_alloc_pages(max_pages, gfp_flags);
 	if (!lgp->args.layout.pages) {
 		nfs4_layoutget_release(lgp);
-		return;
+		return ERR_PTR(-ENOMEM);
 	}
 	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
 
@@ -6319,15 +6321,17 @@ void nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 	nfs41_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
-		return;
+		return ERR_CAST(task);
 	status = nfs4_wait_for_completion_rpc_task(task);
 	if (status == 0)
 		status = task->tk_status;
 	if (status == 0)
-		status = pnfs_layout_process(lgp);
+		lseg = pnfs_layout_process(lgp);
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
-	return;
+	if (status)
+		return ERR_PTR(status);
+	return lseg;
 }
 
 static void
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2e00fea..3a7ac97 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -582,7 +582,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	struct inode *ino = lo->plh_inode;
 	struct nfs_server *server = NFS_SERVER(ino);
 	struct nfs4_layoutget *lgp;
-	struct pnfs_layout_segment *lseg = NULL;
+	struct pnfs_layout_segment *lseg;
 
 	dprintk("--> %s\n", __func__);
 
@@ -599,16 +599,22 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	lgp->args.type = server->pnfs_curr_ld->id;
 	lgp->args.inode = ino;
 	lgp->args.ctx = get_nfs_open_context(ctx);
-	lgp->lsegpp = &lseg;
 	lgp->gfp_flags = gfp_flags;
 
 	/* Synchronously retrieve layout information from server and
 	 * store in lseg.
 	 */
-	nfs4_proc_layoutget(lgp, gfp_flags);
-	if (!lseg) {
-		/* remember that LAYOUTGET failed and suspend trying */
-		set_bit(lo_fail_bit(range->iomode), &lo->plh_flags);
+	lseg = nfs4_proc_layoutget(lgp, gfp_flags);
+	if (IS_ERR(lseg)) {
+		switch (PTR_ERR(lseg)) {
+		case -ENOMEM:
+		case -ERESTARTSYS:
+			break;
+		default:
+			/* remember that LAYOUTGET failed and suspend trying */
+			set_bit(lo_fail_bit(range->iomode), &lo->plh_flags);
+		}
+		return NULL;
 	}
 
 	return lseg;
@@ -1096,7 +1102,7 @@ out_unlock:
 }
 EXPORT_SYMBOL_GPL(pnfs_update_layout);
 
-int
+struct pnfs_layout_segment *
 pnfs_layout_process(struct nfs4_layoutget *lgp)
 {
 	struct pnfs_layout_hdr *lo = NFS_I(lgp->args.inode)->layout;
@@ -1129,7 +1135,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 	init_lseg(lo, lseg);
 	lseg->pls_range = res->range;
-	*lgp->lsegpp = get_lseg(lseg);
+	get_lseg(lseg);
 	pnfs_insert_layout(lo, lseg);
 
 	if (res->return_on_close) {
@@ -1140,8 +1146,9 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	/* Done processing layoutget. Set the layout stateid */
 	pnfs_set_layout_stateid(lo, &res->stateid, false);
 	spin_unlock(&ino->i_lock);
+	return lseg;
 out:
-	return status;
+	return ERR_PTR(status);
 
 out_forget_reply:
 	spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 745aa1b..d51ef88 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -172,7 +172,7 @@ extern int nfs4_proc_getdevicelist(struct nfs_server *server,
 				   struct pnfs_devicelist *devlist);
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
-extern void nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags);
+extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags);
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 
 /* pnfs.c */
@@ -192,7 +192,7 @@ void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *, struct nfs_page
 int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
 bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
 void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg);
-int pnfs_layout_process(struct nfs4_layoutget *lgp);
+struct pnfs_layout_segment *pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index be9cf3c..5da789f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -251,7 +251,6 @@ struct nfs4_layoutget_res {
 struct nfs4_layoutget {
 	struct nfs4_layoutget_args args;
 	struct nfs4_layoutget_res res;
-	struct pnfs_layout_segment **lsegpp;
 	gfp_t gfp_flags;
 };
 
-- 
1.7.11.4

