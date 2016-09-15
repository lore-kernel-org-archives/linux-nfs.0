Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32999 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbcIOO5e (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 10:57:34 -0400
Subject: [PATCH v3 19/22] xprtrdma: Support larger inline thresholds
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 15 Sep 2016 10:57:32 -0400
Message-ID: <20160915145732.11080.28375.stgit@manet.1015granger.net>
In-Reply-To: <20160915143440.11080.89241.stgit@manet.1015granger.net>
References: <20160915143440.11080.89241.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Version One default inline threshold is still 1KB. But allow
testing with thresholds up to 64KB.

This maximum is somewhat arbitrary. There's no fundamental
architectural limit I'm aware of, but it's good to keep the size of
Receive buffers reasonable. Now that Send can use a s/g list, a
Send buffer is only as large as each RPC requires. Receive buffers
are always the size of the inline threshold, however.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprtrdma.h |    4 ++--
 net/sunrpc/xprtrdma/transport.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 39267dc..221b7a2 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -53,8 +53,8 @@
 #define RPCRDMA_MAX_SLOT_TABLE	(256U)
 
 #define RPCRDMA_MIN_INLINE  (1024)	/* min inline thresh */
-#define RPCRDMA_DEF_INLINE  (1024)	/* default inline thresh */
-#define RPCRDMA_MAX_INLINE  (3068)	/* max inline thresh */
+#define RPCRDMA_DEF_INLINE  (4096)	/* default inline thresh */
+#define RPCRDMA_MAX_INLINE  (65536)	/* max inline thresh */
 
 /* Memory registration strategies, by number.
  * This is part of a kernel / user space API. Do not remove. */
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 6a358ab..ed5e285 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -97,7 +97,7 @@ static struct ctl_table xr_tunables_table[] = {
 		.data		= &xprt_rdma_max_inline_read,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &min_inline_size,
 		.extra2		= &max_inline_size,
 	},
@@ -106,7 +106,7 @@ static struct ctl_table xr_tunables_table[] = {
 		.data		= &xprt_rdma_max_inline_write,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &min_inline_size,
 		.extra2		= &max_inline_size,
 	},

