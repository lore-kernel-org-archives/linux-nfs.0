Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33027 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759718AbcLAWTi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:38 -0500
Received: by mail-io0-f196.google.com with SMTP id j92so3935434ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/26] pNFS: Get rid of unnecessary layout parameter in encode_layoutreturn callback
Date: Thu,  1 Dec 2016 17:19:09 -0500
Message-Id: <20161201221922.15657-14-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-13-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
 <20161201221922.15657-12-trond.myklebust@primarydata.com>
 <20161201221922.15657-13-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The parameter is already present in the "args" structure.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 4 ++--
 fs/nfs/nfs4xdr.c                       | 8 ++++----
 fs/nfs/objlayout/objlayout.c           | 4 ++--
 fs/nfs/objlayout/objlayout.h           | 1 -
 fs/nfs/pnfs.h                          | 3 +--
 5 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index a5c38889e7ae..90462a2a9237 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2012,10 +2012,10 @@ ff_layout_alloc_deviceid_node(struct nfs_server *server,
 }
 
 static void
-ff_layout_encode_layoutreturn(struct pnfs_layout_hdr *lo,
-			      struct xdr_stream *xdr,
+ff_layout_encode_layoutreturn(struct xdr_stream *xdr,
 			      const struct nfs4_layoutreturn_args *args)
 {
+	struct pnfs_layout_hdr *lo = args->layout;
 	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
 	__be32 *start;
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b54931503872..86f72ae605c8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2013,6 +2013,7 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		    const struct nfs4_layoutreturn_args *args,
 		    struct compound_hdr *hdr)
 {
+	const struct pnfs_layoutdriver_type *lr_ops = NFS_SERVER(args->inode)->pnfs_curr_ld;
 	__be32 *p;
 
 	encode_op_hdr(xdr, OP_LAYOUTRETURN, decode_layoutreturn_maxsz, hdr);
@@ -2027,10 +2028,9 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	spin_lock(&args->inode->i_lock);
 	encode_nfs4_stateid(xdr, &args->stateid);
 	spin_unlock(&args->inode->i_lock);
-	if (NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn) {
-		NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn(
-			NFS_I(args->inode)->layout, xdr, args);
-	} else
+	if (lr_ops->encode_layoutreturn)
+		lr_ops->encode_layoutreturn(xdr, args);
+	else
 		encode_uint32(xdr, 0);
 }
 
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 919efd4a1a23..2a4cdce939a0 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -504,10 +504,10 @@ encode_accumulated_error(struct objlayout *objlay, __be32 *p)
 }
 
 void
-objlayout_encode_layoutreturn(struct pnfs_layout_hdr *pnfslay,
-			      struct xdr_stream *xdr,
+objlayout_encode_layoutreturn(struct xdr_stream *xdr,
 			      const struct nfs4_layoutreturn_args *args)
 {
+	struct pnfs_layout_hdr *pnfslay = args->layout;
 	struct objlayout *objlay = OBJLAYOUT(pnfslay);
 	struct objlayout_io_res *oir, *tmp;
 	__be32 *start;
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 2641dbad345c..fc94a5872ed4 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -175,7 +175,6 @@ extern void objlayout_encode_layoutcommit(
 	const struct nfs4_layoutcommit_args *);
 
 extern void objlayout_encode_layoutreturn(
-	struct pnfs_layout_hdr *,
 	struct xdr_stream *,
 	const struct nfs4_layoutreturn_args *);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bc9a3aa31d3c..75ff9392127f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -172,8 +172,7 @@ struct pnfs_layoutdriver_type {
 			(struct nfs_server *server, struct pnfs_device *pdev,
 			gfp_t gfp_flags);
 
-	void (*encode_layoutreturn) (struct pnfs_layout_hdr *layoutid,
-				     struct xdr_stream *xdr,
+	void (*encode_layoutreturn) (struct xdr_stream *xdr,
 				     const struct nfs4_layoutreturn_args *args);
 
 	void (*cleanup_layoutcommit) (struct nfs4_layoutcommit_data *data);
-- 
2.9.3

