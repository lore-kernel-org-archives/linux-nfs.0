Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33308 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725925AbeHPEbD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2018 00:31:03 -0400
Received: by mail-io0-f196.google.com with SMTP id z20-v6so2611888iol.0
        for <linux-nfs@vger.kernel.org>; Wed, 15 Aug 2018 18:36:10 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] pNFS: When updating the stateid in layoutreturn, also update the recall range
Date: Wed, 15 Aug 2018 21:35:46 -0400
Message-Id: <20180816013546.118511-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180816013546.118511-1-trond.myklebust@hammerspace.com>
References: <20180816013546.118511-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we update the layout stateid in nfs4_layoutreturn_refresh_stateid, we
should also update the range in order to let the server know we're actually
returning everything.

Fixes: 16c278dbfa63 ("pnfs: Fix handling of NFS4ERR_OLD_STATEID replies...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
v2:
 - fix the !CONFIG_NFS_V4_1 compile

 fs/nfs/nfs4proc.c | 3 +++
 fs/nfs/pnfs.c     | 5 ++++-
 fs/nfs/pnfs.h     | 5 ++++-
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9a349587d077..a5f0de68e710 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3246,6 +3246,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			break;
 		case -NFS4ERR_OLD_STATEID:
 			if (nfs4_layoutreturn_refresh_stateid(&calldata->arg.lr_args->stateid,
+						&calldata->arg.lr_args->range,
 						calldata->inode))
 				goto lr_restart;
 			/* Fallthrough */
@@ -5950,6 +5951,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 			break;
 		case -NFS4ERR_OLD_STATEID:
 			if (nfs4_layoutreturn_refresh_stateid(&data->args.lr_args->stateid,
+						&data->args.lr_args->range,
 						data->inode))
 				goto lr_restart;
 			/* Fallthrough */
@@ -8899,6 +8901,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	switch (task->tk_status) {
 	case -NFS4ERR_OLD_STATEID:
 		if (nfs4_layoutreturn_refresh_stateid(&lrp->args.stateid,
+					&lrp->args.range,
 					lrp->args.inode))
 			goto out_restart;
 		/* Fallthrough */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8f03bdb191aa..8ef3c1feee92 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -361,7 +361,9 @@ pnfs_clear_lseg_state(struct pnfs_layout_segment *lseg,
 /*
  * Update the seqid of a layout stateid
  */
-bool nfs4_layoutreturn_refresh_stateid(nfs4_stateid *dst, struct inode *inode)
+bool nfs4_layoutreturn_refresh_stateid(nfs4_stateid *dst,
+		struct pnfs_layout_range *dst_range,
+		struct inode *inode)
 {
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_range range = {
@@ -379,6 +381,7 @@ bool nfs4_layoutreturn_refresh_stateid(nfs4_stateid *dst, struct inode *inode)
 		err = pnfs_mark_matching_lsegs_return(lo, &head, &range, 0);
 		if (err != -EBUSY) {
 			dst->seqid = lo->plh_stateid.seqid;
+			*dst_range = range;
 			ret = true;
 		}
 	}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1a38a3b533b5..ece367ebde69 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -259,7 +259,9 @@ int pnfs_destroy_layouts_byfsid(struct nfs_client *clp,
 		bool is_recall);
 int pnfs_destroy_layouts_byclid(struct nfs_client *clp,
 		bool is_recall);
-bool nfs4_layoutreturn_refresh_stateid(nfs4_stateid *dst, struct inode *inode);
+bool nfs4_layoutreturn_refresh_stateid(nfs4_stateid *dst,
+		struct pnfs_layout_range *dst_range,
+		struct inode *inode);
 void pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *new,
@@ -781,6 +783,7 @@ static inline void nfs4_pnfs_v3_ds_connect_unload(void)
 }
 
 static inline bool nfs4_layoutreturn_refresh_stateid(nfs4_stateid *dst,
+		struct pnfs_layout_range *dst_range,
 		struct inode *inode)
 {
 	return false;
-- 
2.17.1
