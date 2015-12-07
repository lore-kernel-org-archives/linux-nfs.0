Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33104 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263AbbLGBzS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Dec 2015 20:55:18 -0500
Received: by pabfh17 with SMTP id fh17so119519957pab.0
        for <linux-nfs@vger.kernel.org>; Sun, 06 Dec 2015 17:55:18 -0800 (PST)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond.Myklebust@primarydata.com, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] NFS42: handle layoutstats stateid error
Date: Sun,  6 Dec 2015 20:55:09 -0500
Message-Id: <1449453309-7192-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When server returns layoutstats stateid error, we should
invalidate client's layout so that next IO can trigger new
layoutget.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs42proc.c | 29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 6b1ce98..6e81749 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -204,6 +204,8 @@ static void
 nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs42_layoutstat_data *data = calldata;
+	struct inode *inode = data->inode;
+	struct pnfs_layout_hdr *lo;
 
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return;
@@ -211,12 +213,35 @@ nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
 	switch (task->tk_status) {
 	case 0:
 		break;
+	case -NFS4ERR_EXPIRED:
+	case -NFS4ERR_STALE_STATEID:
+	case -NFS4ERR_OLD_STATEID:
+	case -NFS4ERR_BAD_STATEID:
+		spin_lock(&inode->i_lock);
+		lo = NFS_I(inode)->layout;
+		if (lo && nfs4_stateid_match(&data->args.stateid,
+					     &lo->plh_stateid)) {
+			LIST_HEAD(head);
+
+			/*
+			 * Mark the bad layout state as invalid, then retry
+			 * with the current stateid.
+			 */
+			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL);
+			spin_unlock(&inode->i_lock);
+			pnfs_free_lseg_list(&head);
+		} else
+			spin_unlock(&inode->i_lock);
+		break;
 	case -ENOTSUPP:
 	case -EOPNOTSUPP:
-		NFS_SERVER(data->inode)->caps &= ~NFS_CAP_LAYOUTSTATS;
+		NFS_SERVER(inode)->caps &= ~NFS_CAP_LAYOUTSTATS;
 	default:
-		dprintk("%s server returns %d\n", __func__, task->tk_status);
+		break;
 	}
+
+	dprintk("%s server returns %d\n", __func__, task->tk_status);
 }
 
 static void
-- 
1.8.3.1

