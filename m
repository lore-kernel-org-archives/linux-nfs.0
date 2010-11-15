Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27488 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756630Ab0KOTBC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Nov 2010 14:01:02 -0500
Received: from localhost.localdomain (vpn2ntap-136191.hq.netapp.com [10.58.56.111])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAFJ0f4c028248
	for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 11:00:41 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] pnfs-submit: remove unused stateid argument from pnfs_return_layout
Date: Mon, 15 Nov 2010 14:00:35 -0500
Message-Id: <1289847638-12175-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is a relic from the old CB_LAYOUTRECALL code.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c          |    2 +-
 fs/nfs/nfs4proc.c       |    5 -----
 fs/nfs/pnfs.c           |   14 ++------------
 fs/nfs/pnfs.h           |    5 +----
 include/linux/nfs_xdr.h |    1 -
 5 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8727ade..3bf7a42 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1419,7 +1419,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 void nfs4_evict_inode(struct inode *inode)
 {
-	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
+	pnfs_return_layout(inode, NULL, RETURN_FILE, true);
 	truncate_inode_pages(&inode->i_data, 0);
 	end_writeback(inode);
 	pnfs_destroy_layout(NFS_I(inode));
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 55505e4..bd234c4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5622,11 +5622,6 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 			return;
 		}
 	}
-	if (lrp->stateid) {
-		/* Forget the layout, without sending the return */
-		rpc_exit(task, 0);
-		return;
-	}
 	if (nfs41_setup_sequence(lrp->clp->cl_session, &lrp->args.seq_args,
 				&lrp->res.seq_res, 0, task))
 		return;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0b7fc1d..a62f518 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -693,7 +693,7 @@ out_nolayout:
 static int
 return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	      enum pnfs_layoutreturn_type type, struct pnfs_layout_hdr *lo,
-	      bool wait, const nfs4_stateid *stateid)
+	      bool wait)
 {
 	struct nfs4_layoutreturn *lrp;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -714,7 +714,6 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	lrp->args.return_type = type;
 	lrp->args.range = *range;
 	lrp->args.inode = ino;
-	lrp->stateid = stateid;
 	lrp->clp = server->nfs_client;
 
 	status = nfs4_proc_layoutreturn(lrp, wait);
@@ -725,7 +724,6 @@ out:
 
 int
 _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
-		    const nfs4_stateid *stateid, /* optional */
 		    enum pnfs_layoutreturn_type type,
 		    bool wait)
 {
@@ -766,11 +764,6 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 		pnfs_free_lseg_list(&tmp_list);
 
 		if (layoutcommit_needed(nfsi)) {
-			if (stateid && !wait) { /* callback */
-				dprintk("%s: layoutcommit pending\n", __func__);
-				status = -EAGAIN;
-				goto out_put;
-			}
 			status = pnfs_layoutcommit_inode(ino, wait);
 			if (status) {
 				/* Return layout even if layoutcommit fails */
@@ -779,14 +772,11 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 					__func__, status);
 			}
 		}
-		status = return_layout(ino, &arg, type, lo, wait, stateid);
+		status = return_layout(ino, &arg, type, lo, wait);
 	}
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
-out_put:
-	put_layout_hdr(ino);
-	goto out;
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c5b4282..46dab34 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -205,7 +205,6 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_layout_range *);
 int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *,
-			const nfs4_stateid *stateid, /* optional */
 			enum pnfs_layoutreturn_type, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
@@ -279,7 +278,6 @@ pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
 
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct pnfs_layout_range *range,
-				     const nfs4_stateid *stateid, /* optional */
 				     enum pnfs_layoutreturn_type type,
 				     bool wait)
 {
@@ -288,7 +286,7 @@ static inline int pnfs_return_layout(struct inode *ino,
 
 	if (pnfs_enabled_sb(nfss) &&
 	    (type != RETURN_FILE || has_layout(nfsi)))
-		return _pnfs_return_layout(ino, range, stateid, type, wait);
+		return _pnfs_return_layout(ino, range, type, wait);
 
 	return 0;
 }
@@ -383,7 +381,6 @@ pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
 
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct pnfs_layout_range *range,
-				     const nfs4_stateid *stateid, /* optional */
 				     enum pnfs_layoutreturn_type type,
 				     bool wait)
 {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d4c4804..7a19acb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -276,7 +276,6 @@ struct nfs4_layoutreturn {
 	struct nfs4_layoutreturn_args args;
 	struct nfs4_layoutreturn_res res;
 	struct rpc_cred *cred;
-	const nfs4_stateid *stateid;
 	struct nfs_client *clp;
 	int rpc_status;
 };
-- 
1.7.2.1

