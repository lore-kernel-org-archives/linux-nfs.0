Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34916 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab1EPQYP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 12:24:15 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com
Subject: [PATCH v3 26/29] pnfs: encode_layoutcommit
Date: Mon, 16 May 2011 09:24:12 -0700
Message-Id: <1305563052-8244-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD14D8E.1070701@panasas.com>
References: <4DD14D8E.1070701@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add a layout driver method to encode the layout type specific
opaque part of layout commit in-line in the xdr stream.

Currently, the pnfs-objects layout driver uses it to encode metadata hints
to the MDS and the blocks layout driver to commit provisionally allocated
extents to the file.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   16 +++++++++++++---
 fs/nfs/pnfs.h    |    4 ++++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 515eb38..c821c9c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1884,6 +1884,7 @@ encode_layoutget(struct xdr_stream *xdr,
 
 static int
 encode_layoutcommit(struct xdr_stream *xdr,
+		    struct inode *inode,
 		    const struct nfs4_layoutcommit_args *args,
 		    struct compound_hdr *hdr)
 {
@@ -1892,7 +1893,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	dprintk("%s: lbw: %llu type: %d\n", __func__, args->lastbytewritten,
 		NFS_SERVER(args->inode)->pnfs_curr_ld->id);
 
-	p = reserve_space(xdr, 48 + NFS4_STATEID_SIZE);
+	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
 	/* Only whole file layouts */
 	p = xdr_encode_hyper(p, 0); /* offset */
@@ -1903,7 +1904,14 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->lastbytewritten);
 	*p++ = cpu_to_be32(0); /* Never send time_modify_changed */
 	*p++ = cpu_to_be32(NFS_SERVER(args->inode)->pnfs_curr_ld->id);/* type */
-	*p++ = cpu_to_be32(0); /* no file layout payload */
+
+	if (NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit)
+		NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit(
+			NFS_I(inode)->layout, xdr, args);
+	else {
+		p = reserve_space(xdr, 4);
+		*p = cpu_to_be32(0); /* no layout-type payload */
+	}
 
 	hdr->nops++;
 	hdr->replen += decode_layoutcommit_maxsz;
@@ -2760,6 +2768,8 @@ static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
 				      struct nfs4_layoutcommit_args *args)
 {
+	struct nfs4_layoutcommit_data *data =
+		container_of(args, struct nfs4_layoutcommit_data, args);
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2767,7 +2777,7 @@ static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
-	encode_layoutcommit(xdr, args, &hdr);
+	encode_layoutcommit(xdr, data->args.inode, args, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 798861c..0c33d57 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -110,6 +110,10 @@ struct pnfs_layoutdriver_type {
 	void (*encode_layoutreturn) (struct pnfs_layout_hdr *layoutid,
 				     struct xdr_stream *xdr,
 				     const struct nfs4_layoutreturn_args *args);
+
+	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
+				     struct xdr_stream *xdr,
+				     const struct nfs4_layoutcommit_args *args);
 };
 
 struct pnfs_layout_hdr {
-- 
1.7.3.4

