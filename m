Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43579 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171Ab1EWACQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 20:02:16 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 33/38] SQUASHME: pnfs: fix layout stateid in layoutreturn args
Date: Mon, 23 May 2011 03:02:04 +0300
Message-Id: <1306108924-29165-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c        |    2 +-
 fs/nfs/pnfs.c           |   42 ++++++++++++++++--------------------------
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e53d7d8..882c8f9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1918,7 +1918,7 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, 0);
 	p = xdr_encode_hyper(p, NFS4_MAX_UINT64);
 	spin_lock(&args->inode->i_lock);
-	xdr_encode_opaque_fixed(p, &NFS_I(args->inode)->layout->plh_stateid.data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, &args->stateid.data, NFS4_STATEID_SIZE);
 	spin_unlock(&args->inode->i_lock);
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(0);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 040219b..d3315c7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -619,31 +619,6 @@ out_err_free:
 	return NULL;
 }
 
-static int
-return_layout(struct inode *ino)
-{
-	struct nfs4_layoutreturn *lrp;
-	struct nfs_server *server = NFS_SERVER(ino);
-	int status = -ENOMEM;
-
-	dprintk("--> %s\n", __func__);
-
-	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
-	if (lrp == NULL) {
-		put_layout_hdr(NFS_I(ino)->layout);
-		goto out;
-	}
-	lrp->args.reclaim = 0;
-	lrp->args.layout_type = server->pnfs_curr_ld->id;
-	lrp->args.inode = ino;
-	lrp->clp = server->nfs_client;
-
-	status = nfs4_proc_layoutreturn(lrp);
-out:
-	dprintk("<-- %s status: %d\n", __func__, status);
-	return status;
-}
-
 /* Initiates a LAYOUTRETURN(FILE) */
 int
 _pnfs_return_layout(struct inode *ino)
@@ -651,17 +626,22 @@ _pnfs_return_layout(struct inode *ino)
 	struct pnfs_layout_hdr *lo = NULL;
 	struct nfs_inode *nfsi = NFS_I(ino);
 	LIST_HEAD(tmp_list);
+	struct nfs4_layoutreturn *lrp;
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
 
+	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
+
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
 	if (!lo || !mark_matching_lsegs_invalid(lo, &tmp_list, NULL)) {
 		spin_unlock(&ino->i_lock);
 		dprintk("%s: no layout segments to return\n", __func__);
+		kfree(lrp);
 		goto out;
 	}
+	lrp->args.stateid = nfsi->layout->plh_stateid;
 	/* Reference matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo);
 	spin_unlock(&ino->i_lock);
@@ -669,7 +649,17 @@ _pnfs_return_layout(struct inode *ino)
 
 	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
 
-	status = return_layout(ino);
+	if (lrp == NULL) {
+		put_layout_hdr(NFS_I(ino)->layout);
+		status = -ENOMEM;
+		goto out;
+	}
+	lrp->args.reclaim = 0;
+	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
+	lrp->args.inode = ino;
+	lrp->clp = NFS_SERVER(ino)->nfs_client;
+
+	status = nfs4_proc_layoutreturn(lrp);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1629b69..22a3d03 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -273,6 +273,7 @@ struct nfs4_layoutreturn_args {
 	__u32   reclaim;
 	__u32   layout_type;
 	struct inode *inode;
+	nfs4_stateid stateid;
 	struct nfs4_sequence_args seq_args;
 };
 
-- 
1.7.3.4

