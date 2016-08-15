Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35421 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182AbcHOUw7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 16:52:59 -0400
Subject: [PATCH v1 20/22] xprtrdma: Support larger inline thresholds
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 15 Aug 2016 16:52:57 -0400
Message-ID: <20160815205257.11652.42036.stgit@manet.1015granger.net>
In-Reply-To: <20160815195649.11652.32252.stgit@manet.1015granger.net>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPC-over-RDMA Version Two will likely require at least a 4KB inline
threshold by default. The Version One inline threshold is still 1KB,
and it's automatically negotiated down to in
rpcrdma_update_connect_private.

The maximum is somewhat arbitrary. There's no fundamental
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
index 1762f59..7eb5864 100644
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

