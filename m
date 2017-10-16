Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:45847 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756862AbdJPTBI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 15:01:08 -0400
Subject: [PATCH 1 1/5] xprtrdma: Throw away reply when version is
 unrecognized
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 16 Oct 2017 15:01:06 -0400
Message-ID: <20171016190106.13594.2302.stgit@manet.1015granger.net>
In-Reply-To: <20171016185641.13594.5374.stgit@manet.1015granger.net>
References: <20171016185641.13594.5374.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A reply with an unrecognized value in the version field means the
transport header is potentially garbled and therefore all the fields
are untrustworthy.

Fixes: 59aa1f9a3cce3 ("xprtrdma: Properly handle RDMA_ERROR ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index f1889f4..20c9e4c 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1248,6 +1248,9 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 	p++;	/* credits */
 	proc = *p++;
 
+	if (vers != rpcrdma_version)
+		goto out_badversion;
+
 	if (rpcrdma_is_bcall(r_xprt, rep, xid, proc))
 		return;
 
@@ -1280,8 +1283,6 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 	}
 
 	xprt->reestablish_timeout = 0;
-	if (vers != rpcrdma_version)
-		goto out_badversion;
 
 	switch (proc) {
 	case rdma_msg:
@@ -1321,17 +1322,15 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 	}
 	return;
 
-/* If the incoming reply terminated a pending RPC, the next
- * RPC call will post a replacement receive buffer as it is
- * being marshaled.
- */
 out_badversion:
 	dprintk("RPC:       %s: invalid version %d\n",
 		__func__, be32_to_cpu(vers));
-	status = -EIO;
-	r_xprt->rx_stats.bad_reply_count++;
-	goto out;
+	goto repost;
 
+/* If the incoming reply terminated a pending RPC, the next
+ * RPC call will post a replacement receive buffer as it is
+ * being marshaled.
+ */
 out_badheader:
 	dprintk("RPC: %5u %s: invalid rpcrdma reply (type %u)\n",
 		rqst->rq_task->tk_pid, __func__, be32_to_cpu(proc));

