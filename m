Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:33717 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648AbcEBSku (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:40:50 -0400
Subject: [PATCH v3 04/20] xprtrdma: Bound the inline threshold values
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:40:48 -0400
Message-ID: <20160502184048.10798.11350.stgit@manet.1015granger.net>
In-Reply-To: <20160502183144.10798.99847.stgit@manet.1015granger.net>
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the sysctls that allow setting the inline threshold allow
any value to be set.

Small values only make the transport run slower. The default 1KB
setting is as low as is reasonable. And the logic that decides how
to divide a Send buffer between RPC-over-RDMA header and RPC message
assumes (but does not check) that the lower bound is not crazy (say,
57 bytes).

Send and receive buffers share a page with some control information.
Values larger than about 3KB can't be supported, currently.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 include/linux/sunrpc/xprtrdma.h |    4 +++-
 net/sunrpc/xprtrdma/transport.c |    6 ++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 767190b..39267dc 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -52,7 +52,9 @@
 #define RPCRDMA_DEF_SLOT_TABLE	(128U)
 #define RPCRDMA_MAX_SLOT_TABLE	(256U)
 
-#define RPCRDMA_DEF_INLINE  (1024)	/* default inline max */
+#define RPCRDMA_MIN_INLINE  (1024)	/* min inline thresh */
+#define RPCRDMA_DEF_INLINE  (1024)	/* default inline thresh */
+#define RPCRDMA_MAX_INLINE  (3068)	/* max inline thresh */
 
 /* Memory registration strategies, by number.
  * This is part of a kernel / user space API. Do not remove. */
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 9954342..16595ff 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -73,6 +73,8 @@ static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
 
 static unsigned int min_slot_table_size = RPCRDMA_MIN_SLOT_TABLE;
 static unsigned int max_slot_table_size = RPCRDMA_MAX_SLOT_TABLE;
+static unsigned int min_inline_size = RPCRDMA_MIN_INLINE;
+static unsigned int max_inline_size = RPCRDMA_MAX_INLINE;
 static unsigned int zero;
 static unsigned int max_padding = PAGE_SIZE;
 static unsigned int min_memreg = RPCRDMA_BOUNCEBUFFERS;
@@ -96,6 +98,8 @@ static struct ctl_table xr_tunables_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.extra1		= &min_inline_size,
+		.extra2		= &max_inline_size,
 	},
 	{
 		.procname	= "rdma_max_inline_write",
@@ -103,6 +107,8 @@ static struct ctl_table xr_tunables_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.extra1		= &min_inline_size,
+		.extra2		= &max_inline_size,
 	},
 	{
 		.procname	= "rdma_inline_write_padding",

