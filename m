Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17218 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab1EZNTi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 09:19:38 -0400
Message-ID: <4DDE536E.8020805@panasas.com>
Date: Thu, 26 May 2011 16:19:42 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [RFC] pnfs: Send layoutreturn, if Return-On-Close is set
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Every thing was ready, in pnfs_roc(). The segments released
and the LO state blocked til after the close is done. All that
is needed is to send the actual layoutreturn synchronously.

RFC1: It looks like the close that comes afterwords is also sync
      So I assumed it would be always safe to wait here. Is that
      true?

RFC2: The ideal is if we could send the layoutreturn together
      with the close, in the same compound. The only little
      problem with that is that we will need, at error handling,
      to analyse if the error came from the layoutreturn part
      of the compound, re-encode the close with out the layoutreturn
      and resend.
      I mean, What stupid Server returns an error on layoutreturn?!
      really? why is it useful information to the client? what can
      he do differently. Any way ...

      So I'm more lazy to do the right thing, right now. I promise
      to put it on my TODO, and do it soon.

TODO:
	mark_lseg_invalid() should receive and collect the union
        *range* of all the segments that where ROC. And only send
	a layoutreturn on that collected range. (If lseg_list is empty
	then all-file return)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/nfs4proc.c       |   10 ++++++++-
 fs/nfs/pnfs.c           |   52 +++++++++++++++++++++++++++++-----------------
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 43 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5734009..f32cc46 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5745,6 +5745,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_layoutreturn_call_ops,
 		.callback_data = lrp,
+		.flags = RPC_TASK_ASYNC,
 	};
 	int status;
 
@@ -5753,8 +5754,15 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = task->tk_status;
-	dprintk("<-- %s status=%d\n", __func__, status);
+
+	if (!status && lrp->args.sync) {
+		status = nfs4_wait_for_completion_rpc_task(task);
+		if (status == 0)
+			status = task->tk_status;
+	}
+
 	rpc_put_task(task);
+	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9b749f2..7dc15d8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -620,6 +620,31 @@ out_err_free:
 	return NULL;
 }
 
+static int __send_layoutreturn(struct inode *ino, nfs4_stateid *stateid,
+			       bool sync)
+{
+	struct nfs4_layoutreturn *lrp = NULL;
+	int status;
+
+	/* lrp is freed in nfs4_layoutreturn_release */
+	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
+	if (unlikely(!lrp)) {
+		put_layout_hdr(NFS_I(ino)->layout);
+		status = -ENOMEM;
+		goto out;
+	}
+	lrp->args.sync = sync;
+	lrp->args.stateid = *stateid;
+	lrp->args.reclaim = 0;
+	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
+	lrp->args.inode = ino;
+	lrp->clp = NFS_SERVER(ino)->nfs_client;
+
+	status = nfs4_proc_layoutreturn(lrp);
+out:
+	dprintk("%s: ==> %d\n", __func__, status);
+	return status;
+}
 /* Initiates a LAYOUTRETURN(FILE) */
 int
 _pnfs_return_layout(struct inode *ino)
@@ -627,7 +652,6 @@ _pnfs_return_layout(struct inode *ino)
 	struct pnfs_layout_hdr *lo = NULL;
 	struct nfs_inode *nfsi = NFS_I(ino);
 	LIST_HEAD(tmp_list);
-	struct nfs4_layoutreturn *lrp = NULL;
 	nfs4_stateid stateid;
 	int status = 0;
 
@@ -647,37 +671,23 @@ _pnfs_return_layout(struct inode *ino)
 	pnfs_free_lseg_list(&tmp_list);
 
 	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
-
-	/* lrp is freed in nfs4_layoutreturn_release */
-	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
-	if (unlikely(!lrp)) {
-		put_layout_hdr(NFS_I(ino)->layout);
-		status = -ENOMEM;
-		goto out;
-	}
-	lrp->args.stateid = stateid;
-	lrp->args.reclaim = 0;
-	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
-	lrp->args.inode = ino;
-	lrp->clp = NFS_SERVER(ino)->nfs_client;
-
-	status = nfs4_proc_layoutreturn(lrp);
+	status = __send_layoutreturn(ino, &stateid, false);
 out:
-	if (unlikely(status))
-		kfree(lrp);
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
 }
 
 bool pnfs_roc(struct inode *ino)
 {
+	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg, *tmp;
 	LIST_HEAD(tmp_list);
 	bool found = false;
+	nfs4_stateid stateid;
 
 	spin_lock(&ino->i_lock);
-	lo = NFS_I(ino)->layout;
+	lo = nfsi->layout;
 	if (!lo || !test_and_clear_bit(NFS_LAYOUT_ROC, &lo->plh_flags) ||
 	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
 		goto out_nolayout;
@@ -689,9 +699,13 @@ bool pnfs_roc(struct inode *ino)
 	if (!found)
 		goto out_nolayout;
 	lo->plh_block_lgets++;
+	get_layout_hdr(lo); /* matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo); /* matched in pnfs_roc_release */
+	stateid = nfsi->layout->plh_stateid;
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
+	/* We ignore the return code from layoutreturn, layout is forgotten */
+	__send_layoutreturn(ino, &stateid, true);
 	return true;
 
 out_nolayout:
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index df99102..00b391a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -272,6 +272,7 @@ struct nfs4_layoutcommit_data {
 };
 
 struct nfs4_layoutreturn_args {
+	bool	sync;
 	__u32   reclaim;
 	__u32   layout_type;
 	struct inode *inode;
-- 
1.7.2.3

