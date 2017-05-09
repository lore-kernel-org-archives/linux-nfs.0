Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50838 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752038AbdEIJUd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:33 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/32] sunrpc: properly type argument to kxdrdproc_t
Date: Tue,  9 May 2017 11:19:45 +0200
Message-Id: <20170509092010.30752-8-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass struct rpc_request as the first argument instead of an untyped blob.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/xdr.h | 3 ++-
 net/sunrpc/clnt.c          | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 290f189de200..ed0fbf0d8d0f 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -226,7 +226,8 @@ struct xdr_stream {
  */
 typedef void	(*kxdreproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 		const void *obj);
-typedef int	(*kxdrdproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
+typedef int	(*kxdrdproc_t)(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+		void *obj);
 
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 38bab2da4155..bdb75f7488e9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2489,7 +2489,8 @@ static void rpcproc_encode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 {
 }
 
-static int rpcproc_decode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
+static int rpcproc_decode_null(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
+		void *obj)
 {
 	return 0;
 }
-- 
2.11.0

