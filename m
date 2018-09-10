Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35029 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728357AbeIJUER (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:04:17 -0400
Subject: [PATCH v1 09/22] sunrpc: Report connect_time in seconds
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:43 -0400
Message-ID: <20180910150943.10564.48685.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
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
