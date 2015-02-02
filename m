Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:64526 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965286AbbBBWlR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:41:17 -0500
Received: by mail-pa0-f43.google.com with SMTP id eu11so87911303pac.2
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:41:17 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 44/53] nfs41: introduce NFS_LAYOUT_RETURN_BEFORE_CLOSE
Date: Mon,  2 Feb 2015 14:38:58 -0800
Message-Id: <1422916747-86649-45-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

When it is set, generic pnfs would try to send layoutreturn right
before last close/delegation_return regard less NFS_LAYOUT_ROC is
set or not. LD can then make sure layoutreturn is always sent
rather than being omitted.

The difference against NFS_LAYOUT_RETURN is that
NFS_LAYOUT_RETURN_BEFORE_CLOSE does not block usage of the layout so
LD can set it and expect generic layer to try pnfs path at the
same time.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/nfs4proc.c |  2 ++
 fs/nfs/pnfs.c     | 40 +++++++++++++++++++++++++++++++++-------
 fs/nfs/pnfs.h     |  1 +
 3 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2397c0f..7e1a97a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7797,6 +7797,8 @@ static void nfs4_layoutreturn_release(void *calldata)
 	if (lrp->res.lrs_present)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
 	clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
+	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
+	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 	lo->plh_block_lgets--;
 	spin_unlock(&lo->plh_inode->i_lock);
 	pnfs_put_layout_hdr(lrp->args.layout);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0a0e209..d3c2ca7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -909,6 +909,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 		status = -ENOMEM;
 		spin_lock(&ino->i_lock);
 		lo->plh_block_lgets--;
+		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
 		spin_unlock(&ino->i_lock);
 		pnfs_put_layout_hdr(lo);
 		goto out;
@@ -926,11 +927,6 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 
 	status = nfs4_proc_layoutreturn(lrp, sync);
 out:
-	if (status) {
-		spin_lock(&ino->i_lock);
-		clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
-		spin_unlock(&ino->i_lock);
-	}
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
 }
@@ -1028,8 +1024,9 @@ bool pnfs_roc(struct inode *ino)
 {
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg, *tmp;
+	nfs4_stateid stateid;
 	LIST_HEAD(tmp_list);
-	bool found = false;
+	bool found = false, layoutreturn = false;
 
 	spin_lock(&ino->i_lock);
 	lo = NFS_I(ino)->layout;
@@ -1050,7 +1047,20 @@ bool pnfs_roc(struct inode *ino)
 	return true;
 
 out_nolayout:
+	if (lo) {
+		stateid = lo->plh_stateid;
+		layoutreturn =
+			test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+					   &lo->plh_flags);
+		if (layoutreturn) {
+			lo->plh_block_lgets++;
+			pnfs_get_layout_hdr(lo);
+		}
+	}
 	spin_unlock(&ino->i_lock);
+	if (layoutreturn)
+		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
+				       NFS4_MAX_UINT64, true);
 	return false;
 }
 
@@ -1085,8 +1095,9 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg;
+	nfs4_stateid stateid;
 	u32 current_seqid;
-	bool found = false;
+	bool found = false, layoutreturn = false;
 
 	spin_lock(&ino->i_lock);
 	list_for_each_entry(lseg, &nfsi->layout->plh_segs, pls_list)
@@ -1103,7 +1114,22 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
 	 */
 	*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
 out:
+	if (!found) {
+		stateid = lo->plh_stateid;
+		layoutreturn =
+			test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+					   &lo->plh_flags);
+		if (layoutreturn) {
+			lo->plh_block_lgets++;
+			pnfs_get_layout_hdr(lo);
+		}
+	}
 	spin_unlock(&ino->i_lock);
+	if (layoutreturn) {
+		rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
+		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
+				       NFS4_MAX_UINT64, false);
+	}
 	return found;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 443d199..c383dd5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -96,6 +96,7 @@ enum {
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_RETURN,		/* Return this layout ASAP */
+	NFS_LAYOUT_RETURN_BEFORE_CLOSE,	/* Return this layout before close */
 	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
 	NFS_LAYOUT_FIRST_LAYOUTGET,	/* Serialize first layoutget */
 };
-- 
1.9.3

