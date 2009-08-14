From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 14/21] nfs: nfs4xdr: introduce print_overflow_msg
Date: Fri, 14 Aug 2009 17:19:48 +0300
Message-ID: <1250259588-13929-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:27235
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932118AbZHNOTz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:55 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Part fo the nfs4xdr cleanup.  READ_BUF will go away.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0c26bb2..8255ec7 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2441,14 +2441,18 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
 #define READ_BUF(nbytes)  do { \
 	p = xdr_inline_decode(xdr, nbytes); \
 	if (unlikely(!p)) { \
-		dprintk("nfs: %s: prematurely hit end of receive" \
-				" buffer\n", __func__); \
-		dprintk("nfs: %s: xdr->p=%p, bytes=%u, xdr->end=%p\n", \
-				__func__, xdr->p, nbytes, xdr->end); \
+		print_overflow_msg(__func__, xdr); \
 		return -EIO; \
 	} \
 } while (0)
 
+static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
+{
+	dprintk("nfs: %s: prematurely hit end of receive buffer. "
+		"Remaining buffer length is %tu words.\n",
+		func, xdr->end - xdr->p);
+}
+
 static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char **string)
 {
 	__be32 *p;
-- 
1.6.4

