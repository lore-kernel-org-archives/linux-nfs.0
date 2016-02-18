Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36126 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425604AbcBRRbB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:31:01 -0500
Subject: [PATCH v2 08/12] xprtrdma: Properly handle RDMA_ERROR replies
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:30:59 -0500
Message-ID: <20160218173059.14009.32747.stgit@manet.1015granger.net>
In-Reply-To: <20160218172449.14009.47311.stgit@manet.1015granger.net>
References: <20160218172449.14009.47311.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These are shorter than RPCRDMA_HDRLEN_MIN, and they need to
complete the waiting RPC.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/rpc_rdma.h |   11 +++++---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   51 +++++++++++++++++++++++++++++++++------
 2 files changed, 49 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index 8c6d23c..3b1ff38 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -93,6 +93,12 @@ struct rpcrdma_msg {
 			__be32 rm_pempty[3];	/* 3 empty chunk lists */
 		} rm_padded;
 
+		struct {
+			__be32 rm_err;
+			__be32 rm_vers_low;
+			__be32 rm_vers_high;
+		} rm_error;
+
 		__be32 rm_chunks[0];	/* read, write and reply chunks */
 
 	} rm_body;
@@ -109,11 +115,6 @@ enum rpcrdma_errcode {
 	ERR_CHUNK = 2
 };
 
-struct rpcrdma_err_vers {
-	uint32_t rdma_vers_low;	/* Version range supported by peer */
-	uint32_t rdma_vers_high;
-};
-
 enum rpcrdma_proc {
 	RDMA_MSG = 0,		/* An RPC call or reply msg */
 	RDMA_NOMSG = 1,		/* An RPC call or reply msg - separate body */
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 0607391..35f8108 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -795,7 +795,7 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 	__be32 *iptr;
-	int rdmalen, status;
+	int rdmalen, status, rmerr;
 	unsigned long cwnd;
 	u32 credits;
 
@@ -803,12 +803,10 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 
 	if (rep->rr_len == RPCRDMA_BAD_LEN)
 		goto out_badstatus;
-	if (rep->rr_len < RPCRDMA_HDRLEN_MIN)
+	if (rep->rr_len < RPCRDMA_HDRLEN_ERR)
 		goto out_shortreply;
 
 	headerp = rdmab_to_msg(rep->rr_rdmabuf);
-	if (headerp->rm_vers != rpcrdma_version)
-		goto out_badversion;
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	if (rpcrdma_is_bcall(headerp))
 		goto out_bcall;
@@ -838,6 +836,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	req->rl_reply = rep;
 	xprt->reestablish_timeout = 0;
 
+	if (headerp->rm_vers != rpcrdma_version)
+		goto out_badversion;
+
 	/* check for expected message types */
 	/* The order of some of these tests is important. */
 	switch (headerp->rm_type) {
@@ -898,6 +899,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 		status = rdmalen;
 		break;
 
+	case rdma_error:
+		goto out_rdmaerr;
+
 badheader:
 	default:
 		dprintk("%s: invalid rpcrdma reply header (type %d):"
@@ -913,6 +917,7 @@ badheader:
 		break;
 	}
 
+out:
 	/* Invalidate and flush the data payloads before waking the
 	 * waiting application. This guarantees the memory region is
 	 * properly fenced from the server before the application
@@ -955,13 +960,43 @@ out_bcall:
 	return;
 #endif
 
-out_shortreply:
-	dprintk("RPC:       %s: short/invalid reply\n", __func__);
-	goto repost;
-
+/* If the incoming reply terminated a pending RPC, the next
+ * RPC call will post a replacement receive buffer as it is
+ * being marshaled.
+ */
 out_badversion:
 	dprintk("RPC:       %s: invalid version %d\n",
 		__func__, be32_to_cpu(headerp->rm_vers));
+	status = -EIO;
+	r_xprt->rx_stats.bad_reply_count++;
+	goto out;
+
+out_rdmaerr:
+	rmerr = be32_to_cpu(headerp->rm_body.rm_error.rm_err);
+	switch (rmerr) {
+	case ERR_VERS:
+		pr_err("%s: server reports header version error (%u-%u)\n",
+		       __func__,
+		       be32_to_cpu(headerp->rm_body.rm_error.rm_vers_low),
+		       be32_to_cpu(headerp->rm_body.rm_error.rm_vers_high));
+		break;
+	case ERR_CHUNK:
+		pr_err("%s: server reports header decoding error\n",
+		       __func__);
+		break;
+	default:
+		pr_err("%s: server reports unknown error %d\n",
+		       __func__, rmerr);
+	}
+	status = -EREMOTEIO;
+	r_xprt->rx_stats.bad_reply_count++;
+	goto out;
+
+/* If no pending RPC transaction was matched, post a replacement
+ * receive buffer before returning.
+ */
+out_shortreply:
+	dprintk("RPC:       %s: short/invalid reply\n", __func__);
 	goto repost;
 
 out_nomatch:

