Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f67.google.com ([209.85.166.67]:47034 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726418AbeJBBEr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:04:47 -0400
Subject: [PATCH v2 07/20] sunrpc: Report connect_time in seconds
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:25:41 -0400
Message-ID: <20181001182541.18578.99674.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The way connection-oriented transports report connect_time is wrong:
it's supposed to be in seconds, not in jiffies.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtsock.c           |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 087acfc..289d13c 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -776,7 +776,7 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		   0,	/* need a local port? */
 		   xprt->stat.bind_count,
 		   xprt->stat.connect_count,
-		   xprt->stat.connect_time,
+		   xprt->stat.connect_time / HZ,
 		   idle_time,
 		   xprt->stat.sends,
 		   xprt->stat.recvs,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index e146caa..9bbc395 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2563,7 +2563,7 @@ static void xs_local_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 			"%llu %llu %lu %llu %llu\n",
 			xprt->stat.bind_count,
 			xprt->stat.connect_count,
-			xprt->stat.connect_time,
+			xprt->stat.connect_time / HZ,
 			idle_time,
 			xprt->stat.sends,
 			xprt->stat.recvs,
@@ -2618,7 +2618,7 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 			transport->srcport,
 			xprt->stat.bind_count,
 			xprt->stat.connect_count,
-			xprt->stat.connect_time,
+			xprt->stat.connect_time / HZ,
 			idle_time,
 			xprt->stat.sends,
 			xprt->stat.recvs,
