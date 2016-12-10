Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34949 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbcLJE04 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2016 23:26:56 -0500
Received: by mail-io0-f195.google.com with SMTP id f73so10800044ioe.2
        for <linux-nfs@vger.kernel.org>; Fri, 09 Dec 2016 20:26:56 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS/flexfiles: Remove a redundant parameter in ff_layout_encode_ioerr()
Date: Fri,  9 Dec 2016 23:26:51 -0500
Message-Id: <20161210042652.21731-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ef4c9d17d4a5..49954442173d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1946,8 +1946,7 @@ ff_layout_free_deviceid_node(struct nfs4_deviceid_node *d)
 						  id_node));
 }
 
-static int ff_layout_encode_ioerr(struct nfs4_flexfile_layout *flo,
-				  struct xdr_stream *xdr,
+static int ff_layout_encode_ioerr(struct xdr_stream *xdr,
 				  const struct nfs4_layoutreturn_args *args,
 				  const struct nfs4_flexfile_layoutreturn_args *ff_args)
 {
@@ -2049,16 +2048,15 @@ ff_layout_encode_layoutreturn(struct xdr_stream *xdr,
 		const struct nfs4_xdr_opaque_data *ff_opaque)
 {
 	const struct nfs4_layoutreturn_args *args = voidargs;
-	struct pnfs_layout_hdr *lo = args->layout;
-	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
+	struct nfs4_flexfile_layoutreturn_args *ff_args = ff_opaque->data;
 	__be32 *start;
 
 	dprintk("%s: Begin\n", __func__);
 	start = xdr_reserve_space(xdr, 4);
 	BUG_ON(!start);
 
-	ff_layout_encode_ioerr(flo, xdr, args, ff_opaque->data);
-	ff_layout_encode_iostats_array(xdr, args, ff_opaque->data);
+	ff_layout_encode_ioerr(xdr, args, ff_args);
+	ff_layout_encode_iostats_array(xdr, args, ff_args);
 
 	*start = cpu_to_be32((xdr->p - start - 1) * 4);
 	dprintk("%s: Return\n", __func__);
-- 
2.9.3

