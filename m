Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36343 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbbGMQbs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 12:31:48 -0400
Subject: [PATCH v2 13/14] xprtrdma: Clean up xprt_rdma_print_stats()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 13 Jul 2015 12:31:45 -0400
Message-ID: <20150713163145.17630.96103.stgit@manet.1015granger.net>
In-Reply-To: <20150713160617.17630.97475.stgit@manet.1015granger.net>
References: <20150713160617.17630.97475.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

checkpatch.pl complained about the seq_printf() format string split
across lines and the use of %Lu.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   48 +++++++++++++++++++--------------------
 1 file changed, 23 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d737300..0985b2b 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -647,31 +647,29 @@ static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 	if (xprt_connected(xprt))
 		idle_time = (long)(jiffies - xprt->last_used) / HZ;
 
-	seq_printf(seq,
-	  "\txprt:\trdma %u %lu %lu %lu %ld %lu %lu %lu %Lu %Lu "
-	  "%lu %lu %lu %Lu %Lu %Lu %Lu %lu %lu %lu\n",
-
-	   0,	/* need a local port? */
-	   xprt->stat.bind_count,
-	   xprt->stat.connect_count,
-	   xprt->stat.connect_time,
-	   idle_time,
-	   xprt->stat.sends,
-	   xprt->stat.recvs,
-	   xprt->stat.bad_xids,
-	   xprt->stat.req_u,
-	   xprt->stat.bklog_u,
-
-	   r_xprt->rx_stats.read_chunk_count,
-	   r_xprt->rx_stats.write_chunk_count,
-	   r_xprt->rx_stats.reply_chunk_count,
-	   r_xprt->rx_stats.total_rdma_request,
-	   r_xprt->rx_stats.total_rdma_reply,
-	   r_xprt->rx_stats.pullup_copy_count,
-	   r_xprt->rx_stats.fixup_copy_count,
-	   r_xprt->rx_stats.hardway_register_count,
-	   r_xprt->rx_stats.failed_marshal_count,
-	   r_xprt->rx_stats.bad_reply_count);
+	seq_puts(seq, "\txprt:\trdma ");
+	seq_printf(seq, "%u %lu %lu %lu %ld %lu %lu %lu %llu %llu ",
+		   0,	/* need a local port? */
+		   xprt->stat.bind_count,
+		   xprt->stat.connect_count,
+		   xprt->stat.connect_time,
+		   idle_time,
+		   xprt->stat.sends,
+		   xprt->stat.recvs,
+		   xprt->stat.bad_xids,
+		   xprt->stat.req_u,
+		   xprt->stat.bklog_u);
+	seq_printf(seq, "%lu %lu %lu %llu %llu %llu %llu %lu %lu %lu\n",
+		   r_xprt->rx_stats.read_chunk_count,
+		   r_xprt->rx_stats.write_chunk_count,
+		   r_xprt->rx_stats.reply_chunk_count,
+		   r_xprt->rx_stats.total_rdma_request,
+		   r_xprt->rx_stats.total_rdma_reply,
+		   r_xprt->rx_stats.pullup_copy_count,
+		   r_xprt->rx_stats.fixup_copy_count,
+		   r_xprt->rx_stats.hardway_register_count,
+		   r_xprt->rx_stats.failed_marshal_count,
+		   r_xprt->rx_stats.bad_reply_count);
 }
 
 static int

