Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33817 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946123AbdDTVWg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 17:22:36 -0400
Received: by mail-io0-f193.google.com with SMTP id h41so20981780ioi.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 Apr 2017 14:22:36 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] pNFS: Remove unused layout driver callbacks
Date: Thu, 20 Apr 2017 17:22:30 -0400
Message-Id: <20170420212232.88086-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170420212232.88086-1-trond.myklebust@primarydata.com>
References: <20170420212232.88086-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

encode_layoutreturn and encode_layoutcommit are now unused. Let's
remove them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 17 ++++-------------
 fs/nfs/pnfs.h    |  5 -----
 2 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 80ce289eea05..125212588115 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2005,16 +2005,10 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(0); /* Never send time_modify_changed */
 	*p++ = cpu_to_be32(NFS_SERVER(args->inode)->pnfs_curr_ld->id);/* type */
 
-	if (NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit) {
-		NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit(
-			NFS_I(inode)->layout, xdr, args);
-	} else {
-		encode_uint32(xdr, args->layoutupdate_len);
-		if (args->layoutupdate_pages) {
-			xdr_write_pages(xdr, args->layoutupdate_pages, 0,
-					args->layoutupdate_len);
-		}
-	}
+	encode_uint32(xdr, args->layoutupdate_len);
+	if (args->layoutupdate_pages)
+		xdr_write_pages(xdr, args->layoutupdate_pages, 0,
+				args->layoutupdate_len);
 
 	return 0;
 }
@@ -2024,7 +2018,6 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		    const struct nfs4_layoutreturn_args *args,
 		    struct compound_hdr *hdr)
 {
-	const struct pnfs_layoutdriver_type *lr_ops = NFS_SERVER(args->inode)->pnfs_curr_ld;
 	__be32 *p;
 
 	encode_op_hdr(xdr, OP_LAYOUTRETURN, decode_layoutreturn_maxsz, hdr);
@@ -2041,8 +2034,6 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	spin_unlock(&args->inode->i_lock);
 	if (args->ld_private->ops && args->ld_private->ops->encode)
 		args->ld_private->ops->encode(xdr, args, args->ld_private);
-	else if (lr_ops->encode_layoutreturn)
-		lr_ops->encode_layoutreturn(xdr, args);
 	else
 		encode_uint32(xdr, 0);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 590e1e35781f..825a1b8ddc4f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -173,14 +173,9 @@ struct pnfs_layoutdriver_type {
 			gfp_t gfp_flags);
 
 	int (*prepare_layoutreturn) (struct nfs4_layoutreturn_args *);
-	void (*encode_layoutreturn) (struct xdr_stream *xdr,
-				     const struct nfs4_layoutreturn_args *args);
 
 	void (*cleanup_layoutcommit) (struct nfs4_layoutcommit_data *data);
 	int (*prepare_layoutcommit) (struct nfs4_layoutcommit_args *args);
-	void (*encode_layoutcommit) (struct pnfs_layout_hdr *lo,
-				     struct xdr_stream *xdr,
-				     const struct nfs4_layoutcommit_args *args);
 	int (*prepare_layoutstats) (struct nfs42_layoutstat_args *args);
 };
 
-- 
2.9.3

