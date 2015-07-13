Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:33690 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbGMFUf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:20:35 -0400
Received: by laem6 with SMTP id m6so2580741lae.0
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:20:34 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] pNFS: Fix races between return-on-close and layoutreturn.
Date: Mon, 13 Jul 2015 07:20:03 +0200
Message-Id: <1436764805-2893-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1436764805-2893-2-git-send-email-trond.myklebust@primarydata.com>
References: <1436764805-2893-1-git-send-email-trond.myklebust@primarydata.com>
 <1436764805-2893-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If one or more of the layout segments reports an error during I/O, then
we may have to send a layoutreturn to report the error back to the NFS
metadata server.
This patch ensures that the return-on-close code can detect the
outstanding layoutreturn, and not preempt it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c |  2 --
 fs/nfs/pnfs.c     | 63 ++++++++++++++++++++++++++++++-------------------------
 2 files changed, 35 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 671498ca36d7..c5c9e0d070f8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7972,8 +7972,6 @@ static void nfs4_layoutreturn_release(void *calldata)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
 	pnfs_mark_matching_lsegs_invalid(lo, &freeme, &lrp->args.range);
 	pnfs_clear_layoutreturn_waitbit(lo);
-	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
-	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 	lo->plh_block_lgets--;
 	spin_unlock(&lo->plh_inode->i_lock);
 	pnfs_free_lseg_list(&freeme);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8e9f467e409c..27e2bcaa88da 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -352,7 +352,7 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
 {
 	struct pnfs_layout_segment *s;
 
-	if (!test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
+	if (!test_and_clear_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
 		return false;
 
 	list_for_each_entry(s, &lo->plh_segs, pls_list)
@@ -362,6 +362,18 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
 	return true;
 }
 
+static bool
+pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo)
+{
+	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+		return false;
+	lo->plh_return_iomode = 0;
+	lo->plh_block_lgets++;
+	pnfs_get_layout_hdr(lo);
+	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
+	return true;
+}
+
 static void pnfs_layoutreturn_before_put_lseg(struct pnfs_layout_segment *lseg,
 		struct pnfs_layout_hdr *lo, struct inode *inode)
 {
@@ -372,17 +384,16 @@ static void pnfs_layoutreturn_before_put_lseg(struct pnfs_layout_segment *lseg,
 	if (pnfs_layout_need_return(lo, lseg)) {
 		nfs4_stateid stateid;
 		enum pnfs_iomode iomode;
+		bool send;
 
 		stateid = lo->plh_stateid;
 		iomode = lo->plh_return_iomode;
-		/* decreased in pnfs_send_layoutreturn() */
-		lo->plh_block_lgets++;
-		lo->plh_return_iomode = 0;
+		send = pnfs_prepare_layoutreturn(lo);
 		spin_unlock(&inode->i_lock);
-		pnfs_get_layout_hdr(lo);
-
-		/* Send an async layoutreturn so we dont deadlock */
-		pnfs_send_layoutreturn(lo, stateid, iomode, false);
+		if (send) {
+			/* Send an async layoutreturn so we dont deadlock */
+			pnfs_send_layoutreturn(lo, stateid, iomode, false);
+		}
 	} else
 		spin_unlock(&inode->i_lock);
 }
@@ -924,6 +935,7 @@ void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
 	clear_bit_unlock(NFS_LAYOUT_RETURN, &lo->plh_flags);
 	smp_mb__after_atomic();
 	wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
+	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 }
 
 static int
@@ -978,6 +990,7 @@ _pnfs_return_layout(struct inode *ino)
 	LIST_HEAD(tmp_list);
 	nfs4_stateid stateid;
 	int status = 0, empty;
+	bool send;
 
 	dprintk("NFS: %s for inode %lu\n", __func__, ino->i_ino);
 
@@ -1007,17 +1020,18 @@ _pnfs_return_layout(struct inode *ino)
 	/* Don't send a LAYOUTRETURN if list was initially empty */
 	if (empty) {
 		spin_unlock(&ino->i_lock);
-		pnfs_put_layout_hdr(lo);
 		dprintk("NFS: %s no layout segments to return\n", __func__);
-		goto out;
+		goto out_put_layout_hdr;
 	}
 
 	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-	lo->plh_block_lgets++;
+	send = pnfs_prepare_layoutreturn(lo);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
-
-	status = pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, true);
+	if (send)
+		status = pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, true);
+out_put_layout_hdr:
+	pnfs_put_layout_hdr(lo);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
@@ -1097,13 +1111,9 @@ bool pnfs_roc(struct inode *ino)
 out_noroc:
 	if (lo) {
 		stateid = lo->plh_stateid;
-		layoutreturn =
-			test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
-					   &lo->plh_flags);
-		if (layoutreturn) {
-			lo->plh_block_lgets++;
-			pnfs_get_layout_hdr(lo);
-		}
+		if (test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+					   &lo->plh_flags))
+			layoutreturn = pnfs_prepare_layoutreturn(lo);
 	}
 	spin_unlock(&ino->i_lock);
 	if (layoutreturn) {
@@ -1163,16 +1173,14 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
 	 */
 	*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
 	stateid = lo->plh_stateid;
-	layoutreturn = test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
-					   &lo->plh_flags);
-	if (layoutreturn) {
-		lo->plh_block_lgets++;
-		pnfs_get_layout_hdr(lo);
-	}
+	if (test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+					   &lo->plh_flags))
+		layoutreturn = pnfs_prepare_layoutreturn(lo);
+	if (test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+		rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
 
 	spin_unlock(&ino->i_lock);
 	if (layoutreturn) {
-		rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
 		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, false);
 		return true;
 	}
@@ -1693,7 +1701,6 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	spin_lock(&inode->i_lock);
 	/* set failure bit so that pnfs path will be retried later */
 	pnfs_layout_set_fail_bit(lo, iomode);
-	set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
 	if (lo->plh_return_iomode == 0)
 		lo->plh_return_iomode = range.iomode;
 	else if (lo->plh_return_iomode != range.iomode)
-- 
2.4.3

