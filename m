Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56608 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750815AbdEHP5m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 May 2017 11:57:42 -0400
Date: Mon, 8 May 2017 11:57:41 -0400
To: linux-nfs@vger.kernel.org
Cc: Ari Kauppi <Ari.Kauppi@synopsys.com>
Subject: [PATCH] nfsd: encoders mustn't use unitialized values in error cases
Message-ID: <20170508155741.GC2644@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In error cases, lgp->lg_layout_type may be out of bounds; so we
shouldn't be using it until after the check of nfserr.

This was seen to crash nfsd threads when the server receives a LAYOUTGET
request with a large layout type.

GETDEVICEINFO has the same problem.

Reported-by: Ari Kauppi <Ari.Kauppi@synopsys.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 33017d652b1d..8e9652f37f1f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4119,8 +4119,7 @@ nfsd4_encode_getdeviceinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 		struct nfsd4_getdeviceinfo *gdev)
 {
 	struct xdr_stream *xdr = &resp->xdr;
-	const struct nfsd4_layout_ops *ops =
-		nfsd4_layout_ops[gdev->gd_layout_type];
+	const struct nfsd4_layout_ops *ops;
 	u32 starting_len = xdr->buf->len, needed_len;
 	__be32 *p;
 
@@ -4137,6 +4136,7 @@ nfsd4_encode_getdeviceinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	/* If maxcount is 0 then just update notifications */
 	if (gdev->gd_maxcount != 0) {
+		ops = nfsd4_layout_ops[gdev->gd_layout_type];
 		nfserr = ops->encode_getdeviceinfo(xdr, gdev);
 		if (nfserr) {
 			/*
@@ -4189,8 +4189,7 @@ nfsd4_encode_layoutget(struct nfsd4_compoundres *resp, __be32 nfserr,
 		struct nfsd4_layoutget *lgp)
 {
 	struct xdr_stream *xdr = &resp->xdr;
-	const struct nfsd4_layout_ops *ops =
-		nfsd4_layout_ops[lgp->lg_layout_type];
+	const struct nfsd4_layout_ops *ops;
 	__be32 *p;
 
 	dprintk("%s: err %d\n", __func__, nfserr);
@@ -4213,6 +4212,7 @@ nfsd4_encode_layoutget(struct nfsd4_compoundres *resp, __be32 nfserr,
 	*p++ = cpu_to_be32(lgp->lg_seg.iomode);
 	*p++ = cpu_to_be32(lgp->lg_layout_type);
 
+	ops = nfsd4_layout_ops[lgp->lg_layout_type];
 	nfserr = ops->encode_layoutget(xdr, lgp);
 out:
 	kfree(lgp->lg_content);
-- 
2.9.3

