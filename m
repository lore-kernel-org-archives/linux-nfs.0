From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 16/21] nfs: nfs4xdr: introduce decode_verifier helper
Date: Fri, 14 Aug 2009 17:19:56 +0300
Message-ID: <1250259596-13993-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:30539
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932146AbZHNOUD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:20:03 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 86e6983..b835dcc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3320,17 +3320,19 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
 	return status;
 }
 
+static int decode_verifier(struct xdr_stream *xdr, void *verifier)
+{
+	return decode_opaque_fixed(xdr, verifier, 8);
+}
+
 static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
 {
-	__be32 *p;
 	int status;
 
 	status = decode_op_hdr(xdr, OP_COMMIT);
-	if (status)
-		return status;
-	READ_BUF(8);
-	COPYMEM(res->verf->verifier, 8);
-	return 0;
+	if (!status)
+		status = decode_verifier(xdr, res->verf->verifier);
+	return status;
 }
 
 static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
@@ -3852,10 +3854,10 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	int		status;
 
 	status = decode_op_hdr(xdr, OP_READDIR);
-	if (status)
+	if (!status)
+		status = decode_verifier(xdr, readdir->verifier.data);
+	if (unlikely(status))
 		return status;
-	READ_BUF(8);
-	COPYMEM(readdir->verifier.data, 8);
 	dprintk("%s: verifier = %08x:%08x\n",
 			__func__,
 			((u32 *)readdir->verifier.data)[0],
-- 
1.6.4

