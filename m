Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:54245 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725816AbeG3EMZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jul 2018 00:12:25 -0400
Received: by mail-it0-f67.google.com with SMTP id 72-v6so15241894itw.3
        for <linux-nfs@vger.kernel.org>; Sun, 29 Jul 2018 19:39:39 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs: Fix handling of NFS4ERR_OLD_STATEID replies to layoutreturn
Date: Sun, 29 Jul 2018 22:39:15 -0400
Message-Id: <20180730023915.27911-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180730023915.27911-1-trond.myklebust@hammerspace.com>
References: <20180730023915.27911-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server tells us that out layoutreturn raced with another layout
update, then we must ensure that the new layout segments are not in use
before we resend with an updated layout stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c |  6 +++---
 fs/nfs/pnfs.c     | 17 ++++++++++++++---
 fs/nfs/pnfs.h     |  4 ++--
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ca7e0939d21f..f73a8315933f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3243,7 +3243,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			calldata->res.lr_res = NULL;
 			break;
 		case -NFS4ERR_OLD_STATEID:
-			if (nfs4_refresh_layout_stateid(&calldata->arg.lr_args->stateid,
+			if (nfs4_layoutreturn_refresh_stateid(&calldata->arg.lr_args->stateid,
 						calldata->inode))
 				goto lr_restart;
 			/* Fallthrough */
@@ -5937,7 +5937,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 			data->res.lr_res = NULL;
 			break;
 		case -NFS4ERR_OLD_STATEID:
-			if (nfs4_refresh_layout_stateid(&data->args.lr_args->stateid,
+			if (nfs4_layoutreturn_refresh_stateid(&data->args.lr_args->stateid,
 						data->inode))
 				goto lr_restart;
 			/* Fallthrough */
@@ -8886,7 +8886,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	server = NFS_SERVER(lrp->args.inode);
 	switch (task->tk_status) {
 	case -NFS4ERR_OLD_STATEID:
-		if (nfs4_refresh_layout_stateid(&lrp->args.stateid,
+		if (nfs4_layoutreturn_refresh_stateid(&lrp->args.stateid,
 					lrp->args.inode))
 			goto out_restart;
 		/* Fallthrough */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7fdac8b504dd..7020f726275c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -361,18 +361,29 @@ pnfs_clear_lseg_state(struct pnfs_layout_segment *lseg,
 /*
  * Update the seqid of a layout stateid
  */
-bool nfs4_refresh_layout_stateid(nfs4_stateid *dst, struct inode *inode)
+bool nfs4_layoutreturn_refresh_stateid(nfs4_stateid *dst, struct inode *inode)
 {
 	struct pnfs_layout_hdr *lo;
+	struct pnfs_layout_range range = {
+		.iomode = IOMODE_ANY,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
 	bool ret = false;
+	LIST_HEAD(head);
+	int err;
 
 	spin_lock(&inode->i_lock);
 	lo = NFS_I(inode)->layout;
 	if (lo && nfs4_stateid_match_other(dst, &lo->plh_stateid)) {
-		dst->seqid = lo->plh_stateid.seqid;
-		ret = true;
+		err = pnfs_mark_matching_lsegs_return(lo, &head, &range, 0);
+		if (err != -EBUSY) {
+			dst->seqid = lo->plh_stateid.seqid;
+			ret = true;
+		}
 	}
 	spin_unlock(&inode->i_lock);
+	pnfs_free_lseg_list(&head);
 	return ret;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3fe81424337d..1a38a3b533b5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -259,7 +259,7 @@ int pnfs_destroy_layouts_byfsid(struct nfs_client *clp,
 		bool is_recall);
 int pnfs_destroy_layouts_byclid(struct nfs_client *clp,
 		bool is_recall);
-bool nfs4_refresh_layout_stateid(nfs4_stateid *dst, struct inode *inode);
+bool nfs4_layoutreturn_refresh_stateid(nfs4_stateid *dst, struct inode *inode);
 void pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *new,
@@ -780,7 +780,7 @@ static inline void nfs4_pnfs_v3_ds_connect_unload(void)
 {
 }
 
-static inline bool nfs4_refresh_layout_stateid(nfs4_stateid *dst,
+static inline bool nfs4_layoutreturn_refresh_stateid(nfs4_stateid *dst,
 		struct inode *inode)
 {
 	return false;
-- 
2.17.1

