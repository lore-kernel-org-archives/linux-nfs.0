Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35213 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751292AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f196.google.com with SMTP id h133so6822007ioe.2
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:34 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/10] pNFS: Add a layoutreturn callback to performa layout-private setup
Date: Sat,  3 Dec 2016 15:57:20 -0500
Message-Id: <20161203205725.12961-6-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-5-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
 <20161203205725.12961-2-trond.myklebust@primarydata.com>
 <20161203205725.12961-3-trond.myklebust@primarydata.com>
 <20161203205725.12961-4-trond.myklebust@primarydata.com>
 <20161203205725.12961-5-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a callback to allow the flexfiles layout driver to initialise the
layout private payload.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 14 +++++++++++++-
 fs/nfs/pnfs.h |  1 +
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4631d15227ae..2a3431314c23 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1072,6 +1072,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, const nfs4_stateid *stateid,
 		       enum pnfs_iomode iomode, bool sync)
 {
 	struct inode *ino = lo->plh_inode;
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(ino)->pnfs_curr_ld;
 	struct nfs4_layoutreturn *lrp;
 	int status = 0;
 
@@ -1089,6 +1090,8 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, const nfs4_stateid *stateid,
 	lrp->args.ld_private = &lrp->ld_private;
 	lrp->clp = NFS_SERVER(ino)->nfs_client;
 	lrp->cred = lo->plh_lc_cred;
+	if (ld->prepare_layoutreturn)
+		ld->prepare_layoutreturn(&lrp->args);
 
 	status = nfs4_proc_layoutreturn(lrp, sync);
 out:
@@ -1310,9 +1313,15 @@ bool pnfs_roc(struct inode *ino,
 out_noroc:
 	spin_unlock(&ino->i_lock);
 	pnfs_layoutcommit_inode(ino, true);
+	if (roc) {
+		struct pnfs_layoutdriver_type *ld = NFS_SERVER(ino)->pnfs_curr_ld;
+		if (ld->prepare_layoutreturn)
+			ld->prepare_layoutreturn(args);
+		return true;
+	}
 	if (layoutreturn)
 		pnfs_send_layoutreturn(lo, &stateid, iomode, true);
-	return roc;
+	return false;
 }
 
 void pnfs_roc_release(struct nfs4_layoutreturn_args *args,
@@ -1322,6 +1331,7 @@ void pnfs_roc_release(struct nfs4_layoutreturn_args *args,
 	struct pnfs_layout_hdr *lo = args->layout;
 	const nfs4_stateid *arg_stateid = NULL;
 	const nfs4_stateid *res_stateid = NULL;
+	struct nfs4_xdr_opaque_data *ld_private = args->ld_private;
 
 	if (ret == 0) {
 		arg_stateid = &args->stateid;
@@ -1330,6 +1340,8 @@ void pnfs_roc_release(struct nfs4_layoutreturn_args *args,
 	}
 	pnfs_layoutreturn_free_lsegs(lo, arg_stateid, &args->range,
 			res_stateid);
+	if (ld_private && ld_private->ops && ld_private->ops->free)
+		ld_private->ops->free(ld_private);
 	pnfs_put_layout_hdr(lo);
 	trace_nfs4_layoutreturn_on_close(args->inode, 0);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 459ac2c74af8..d1e028175cd1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -172,6 +172,7 @@ struct pnfs_layoutdriver_type {
 			(struct nfs_server *server, struct pnfs_device *pdev,
 			gfp_t gfp_flags);
 
+	int (*prepare_layoutreturn) (struct nfs4_layoutreturn_args *);
 	void (*encode_layoutreturn) (struct xdr_stream *xdr,
 				     const struct nfs4_layoutreturn_args *args);
 
-- 
2.9.3

