Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:49180 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752770AbdEIJUR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:17 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 01/32] sunrpc: properly type argument to kxdreproc_t
Date: Tue,  9 May 2017 11:19:39 +0200
Message-Id: <20170509092010.30752-2-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass struct rpc_request as the first argument instead of an untyped blob,
and mark the data object as const.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/xdr.h | 5 ++++-
 net/sunrpc/clnt.c          | 3 ++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 054c8cde18f3..290f189de200 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -17,6 +17,8 @@
 #include <asm/unaligned.h>
 #include <linux/scatterlist.h>
 
+struct rpc_rqst;
+
 /*
  * Buffer adjustment
  */
@@ -222,7 +224,8 @@ struct xdr_stream {
 /*
  * These are the xdr_stream style generic XDR encode and decode functions.
  */
-typedef void	(*kxdreproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
+typedef void	(*kxdreproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+		const void *obj);
 typedef int	(*kxdrdproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
 
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 52da3ce54bb5..38bab2da4155 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2484,7 +2484,8 @@ rpc_verify_header(struct rpc_task *task)
 	goto out_garbage;
 }
 
-static void rpcproc_encode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
+static void rpcproc_encode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+		const void *obj)
 {
 }
 
-- 
2.11.0

