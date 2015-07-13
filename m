Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:35835 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbbGMQb6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 12:31:58 -0400
Subject: [PATCH v2 14/14] xprtrdma: Count RDMA_NOMSG type calls
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 13 Jul 2015 12:31:55 -0400
Message-ID: <20150713163155.17630.77239.stgit@manet.1015granger.net>
In-Reply-To: <20150713160617.17630.97475.stgit@manet.1015granger.net>
References: <20150713160617.17630.97475.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RDMA_NOMSG type calls are less efficient than RDMA_MSG. Count NOMSG
calls so administrators can tell if they happen to be used more than
expected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    1 +
 net/sunrpc/xprtrdma/transport.c |    5 +++--
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 2721586..bc8bd65 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -489,6 +489,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	} else if (rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
 		rtype = rpcrdma_readch;
 	} else {
+		r_xprt->rx_stats.nomsg_call_count++;
 		headerp->rm_type = htonl(RDMA_NOMSG);
 		rtype = rpcrdma_areadch;
 		rpclen = 0;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 0985b2b..64443eb 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -659,7 +659,7 @@ static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		   xprt->stat.bad_xids,
 		   xprt->stat.req_u,
 		   xprt->stat.bklog_u);
-	seq_printf(seq, "%lu %lu %lu %llu %llu %llu %llu %lu %lu %lu\n",
+	seq_printf(seq, "%lu %lu %lu %llu %llu %llu %llu %lu %lu %lu %lu\n",
 		   r_xprt->rx_stats.read_chunk_count,
 		   r_xprt->rx_stats.write_chunk_count,
 		   r_xprt->rx_stats.reply_chunk_count,
@@ -669,7 +669,8 @@ static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		   r_xprt->rx_stats.fixup_copy_count,
 		   r_xprt->rx_stats.hardway_register_count,
 		   r_xprt->rx_stats.failed_marshal_count,
-		   r_xprt->rx_stats.bad_reply_count);
+		   r_xprt->rx_stats.bad_reply_count,
+		   r_xprt->rx_stats.nomsg_call_count);
 }
 
 static int
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0b50103..886f8c8 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -340,6 +340,7 @@ struct rpcrdma_stats {
 	unsigned long		hardway_register_count;
 	unsigned long		failed_marshal_count;
 	unsigned long		bad_reply_count;
+	unsigned long		nomsg_call_count;
 };
 
 /*

