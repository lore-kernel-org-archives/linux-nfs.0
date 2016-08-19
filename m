Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35110 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753973AbcHSUbU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2016 16:31:20 -0400
Received: by mail-it0-f68.google.com with SMTP id f6so1931933ith.2
        for <linux-nfs@vger.kernel.org>; Fri, 19 Aug 2016 13:30:27 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Handle NFS4ERR_OLD_STATEID correctly in LAYOUTSTAT calls
Date: Fri, 19 Aug 2016 16:29:58 -0400
Message-Id: <1471638598-20200-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We normally want to update the stateid and then retry,

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42proc.c | 34 +++++++++++++++++++++++++++++-----
 fs/nfs/pnfs.c      |  1 -
 2 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 3378ca1dde9f..74f638a81dc1 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -200,10 +200,22 @@ static void
 nfs42_layoutstat_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs42_layoutstat_data *data = calldata;
-	struct nfs_server *server = NFS_SERVER(data->args.inode);
+	struct inode *inode = data->inode;
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct pnfs_layout_hdr *lo;
 
+	spin_lock(&inode->i_lock);
+	lo = NFS_I(inode)->layout;
+	if (!pnfs_layout_is_valid(lo)) {
+		spin_unlock(&inode->i_lock);
+		rpc_exit(task, 0);
+		return;
+	}
+	nfs4_stateid_copy(&data->args.stateid, &lo->plh_stateid);
+	spin_unlock(&inode->i_lock);
 	nfs41_setup_sequence(nfs4_get_session(server), &data->args.seq_args,
 			     &data->res.seq_res, task);
+
 }
 
 static void
@@ -223,11 +235,11 @@ nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_DELEG_REVOKED:
 	case -NFS4ERR_STALE_STATEID:
-	case -NFS4ERR_OLD_STATEID:
 	case -NFS4ERR_BAD_STATEID:
 		spin_lock(&inode->i_lock);
 		lo = NFS_I(inode)->layout;
-		if (lo && nfs4_stateid_match(&data->args.stateid,
+		if (pnfs_layout_is_valid(lo) &&
+		    nfs4_stateid_match(&data->args.stateid,
 					     &lo->plh_stateid)) {
 			LIST_HEAD(head);
 
@@ -241,11 +253,23 @@ nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
 		} else
 			spin_unlock(&inode->i_lock);
 		break;
+	case -NFS4ERR_OLD_STATEID:
+		spin_lock(&inode->i_lock);
+		lo = NFS_I(inode)->layout;
+		if (pnfs_layout_is_valid(lo) &&
+		    nfs4_stateid_match_other(&data->args.stateid,
+					&lo->plh_stateid)) {
+			/* Do we need to delay before resending? */
+			if (!nfs4_stateid_is_newer(&lo->plh_stateid,
+						&data->args.stateid))
+				rpc_delay(task, HZ);
+			rpc_restart_call_prepare(task);
+		}
+		spin_unlock(&inode->i_lock);
+		break;
 	case -ENOTSUPP:
 	case -EOPNOTSUPP:
 		NFS_SERVER(inode)->caps &= ~NFS_CAP_LAYOUTSTATS;
-	default:
-		break;
 	}
 
 	dprintk("%s server returns %d\n", __func__, task->tk_status);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 000e83b49b0e..3972d7fa85c3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2487,7 +2487,6 @@ pnfs_report_layoutstat(struct inode *inode, gfp_t gfp_flags)
 
 	data->args.fh = NFS_FH(inode);
 	data->args.inode = inode;
-	nfs4_stateid_copy(&data->args.stateid, &hdr->plh_stateid);
 	status = ld->prepare_layoutstats(&data->args);
 	if (status)
 		goto out_free;
-- 
2.7.4

