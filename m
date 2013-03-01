Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:29862 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751571Ab3CABaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2013 20:30:15 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/3] NFSv4.1: LAYOUTGET EDELAY loops timeout to the MDS
Date: Thu, 28 Feb 2013 20:30:10 -0500
Message-Id: <1362101410-22544-3-git-send-email-dros@netapp.com>
In-Reply-To: <1362101410-22544-1-git-send-email-dros@netapp.com>
References: <1362101410-22544-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client will currently try LAYOUTGETs forever if a server is returning
NFS4ERR_LAYOUTTRYLATER or NFS4ERR_RECALLCONFLICT - even if the client no
longer needs the layout (ie process killed, unmounted).

This patch uses the DS timeout value (module parameter 'dataserver_timeo'
via rpc layer) to set an upper limit of how long the client tries LATOUTGETs
in this situation.  Once the timeout is reached, IO is redirected to the MDS.

This also changes how the client checks if a layout is on the clp list
to avoid a double list_add.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c       | 9 ++++++++-
 fs/nfs/pnfs.c           | 7 +++----
 include/linux/nfs_xdr.h | 1 +
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 37eb385..b2671cb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -93,6 +93,8 @@ static int nfs4_map_errors(int err)
 		return err;
 	switch (err) {
 	case -NFS4ERR_RESOURCE:
+	case -NFS4ERR_LAYOUTTRYLATER:
+	case -NFS4ERR_RECALLCONFLICT:
 		return -EREMOTEIO;
 	case -NFS4ERR_WRONGSEC:
 		return -EPERM;
@@ -6046,6 +6048,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layout_hdr *lo;
 	struct nfs4_state *state = NULL;
+	unsigned long timeo, giveup;
 
 	dprintk("--> %s\n", __func__);
 
@@ -6057,7 +6060,10 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 		goto out;
 	case -NFS4ERR_LAYOUTTRYLATER:
 	case -NFS4ERR_RECALLCONFLICT:
-		task->tk_status = -NFS4ERR_DELAY;
+		timeo = rpc_get_timeout(task->tk_client);
+		giveup = lgp->args.timestamp + timeo;
+		if (time_after(giveup, jiffies))
+			task->tk_status = -NFS4ERR_DELAY;
 		break;
 	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_BAD_STATEID:
@@ -6178,6 +6184,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 		return ERR_PTR(-ENOMEM);
 	}
 	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
+	lgp->args.timestamp = jiffies;
 
 	lgp->res.layoutp = &lgp->args.layout;
 	lgp->res.seq_res.sr_slot = NULL;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 97767c8..7e9e897 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1181,7 +1181,7 @@ pnfs_update_layout(struct inode *ino,
 	struct nfs_client *clp = server->nfs_client;
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
-	bool first = false;
+	bool first;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		goto out;
@@ -1215,10 +1215,9 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 
-	if (list_empty(&lo->plh_segs))
-		first = true;
-
+	first = list_empty(&lo->plh_layouts);
 	spin_unlock(&ino->i_lock);
+
 	if (first) {
 		/* The lo must be on the clp list if there is any
 		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 29adb12..2250cab 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -233,6 +233,7 @@ struct nfs4_layoutget_args {
 	struct inode *inode;
 	struct nfs_open_context *ctx;
 	nfs4_stateid stateid;
+	unsigned long timestamp;
 	struct nfs4_layoutdriver_data layout;
 };
 
-- 
1.7.12.4 (Apple Git-37)

