Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:36932 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbbAMQZS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:25:18 -0500
Subject: [PATCH v2 04/20] xprtrdma: Clean up hdrlen
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Jan 2015 11:25:16 -0500
Message-ID: <20150113162516.14086.54951.stgit@manet.1015granger.net>
In-Reply-To: <20150113161440.14086.24801.stgit@manet.1015granger.net>
References: <20150113161440.14086.24801.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Replace naked integers with a documenting macro.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/rpc_rdma.h |    5 ++++-
 net/sunrpc/xprtrdma/rpc_rdma.c  |   12 +++++++-----
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index 1578ed2..f33c5a4 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -98,7 +98,10 @@ struct rpcrdma_msg {
 	} rm_body;
 };
 
-#define RPCRDMA_HDRLEN_MIN	28
+/*
+ * Smallest RPC/RDMA header: rm_xid through rm_type, then rm_nochunks
+ */
+#define RPCRDMA_HDRLEN_MIN	(sizeof(__be32) * 7)
 
 enum rpcrdma_errcode {
 	ERR_VERS = 1,
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 150dd76..dcf5ebc 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -472,7 +472,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 		return -EIO;
 	}
 
-	hdrlen = 28; /*sizeof *headerp;*/
+	hdrlen = RPCRDMA_HDRLEN_MIN;
 	padlen = 0;
 
 	/*
@@ -748,7 +748,7 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 		}
 		return;
 	}
-	if (rep->rr_len < 28) {
+	if (rep->rr_len < RPCRDMA_HDRLEN_MIN) {
 		dprintk("RPC:       %s: short/invalid reply\n", __func__);
 		goto repost;
 	}
@@ -830,8 +830,9 @@ repost:
 		} else {
 			/* else ordinary inline */
 			rdmalen = 0;
-			iptr = (__be32 *)((unsigned char *)headerp + 28);
-			rep->rr_len -= 28; /*sizeof *headerp;*/
+			iptr = (__be32 *)((unsigned char *)headerp +
+							RPCRDMA_HDRLEN_MIN);
+			rep->rr_len -= RPCRDMA_HDRLEN_MIN;
 			status = rep->rr_len;
 		}
 		/* Fix up the rpc results for upper layer */
@@ -845,7 +846,8 @@ repost:
 		    headerp->rm_body.rm_chunks[2] != xdr_one ||
 		    req->rl_nchunks == 0)
 			goto badheader;
-		iptr = (__be32 *)((unsigned char *)headerp + 28);
+		iptr = (__be32 *)((unsigned char *)headerp +
+							RPCRDMA_HDRLEN_MIN);
 		rdmalen = rpcrdma_count_chunks(rep, req->rl_nchunks, 0, &iptr);
 		if (rdmalen < 0)
 			goto badheader;

