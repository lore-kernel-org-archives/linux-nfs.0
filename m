Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:42842 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754635AbdLOB4o (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:56:44 -0500
Subject: [PATCH v1 06/16] xprtrdma: Remove unused padding variables
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:56:42 -0500
Message-ID: <20171215015642.13776.19472.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. Remove fields that should have been removed by
commit b3221d6a53c4 ("xprtrdma: Remove logic that constructs
RDMA_MSGP type calls").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    9 +++------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 7db063f..dc9000d 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -67,7 +67,6 @@
 static unsigned int xprt_rdma_slot_table_entries = RPCRDMA_DEF_SLOT_TABLE;
 unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
-static unsigned int xprt_rdma_inline_write_padding;
 unsigned int xprt_rdma_memreg_strategy		= RPCRDMA_FRMR;
 int xprt_rdma_pad_optimize;
 
@@ -81,6 +80,7 @@
 static unsigned int max_padding = PAGE_SIZE;
 static unsigned int min_memreg = RPCRDMA_BOUNCEBUFFERS;
 static unsigned int max_memreg = RPCRDMA_LAST - 1;
+static unsigned int dummy;
 
 static struct ctl_table_header *sunrpc_table_header;
 
@@ -114,7 +114,7 @@
 	},
 	{
 		.procname	= "rdma_inline_write_padding",
-		.data		= &xprt_rdma_inline_write_padding,
+		.data		= &dummy,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
@@ -387,8 +387,6 @@
 	if (cdata.inline_rsize > cdata.rsize)
 		cdata.inline_rsize = cdata.rsize;
 
-	cdata.padding = xprt_rdma_inline_write_padding;
-
 	/*
 	 * Create new transport instance, which includes initialized
 	 *  o ia
@@ -895,8 +893,7 @@ int xprt_rdma_init(void)
 		"\tMaxInlineRead %d\n\tMaxInlineWrite %d\n",
 		xprt_rdma_slot_table_entries,
 		xprt_rdma_max_inline_read, xprt_rdma_max_inline_write);
-	dprintk("\tPadding %d\n\tMemreg %d\n",
-		xprt_rdma_inline_write_padding, xprt_rdma_memreg_strategy);
+	dprintk("\tPadding 0\n\tMemreg %d\n", xprt_rdma_memreg_strategy);
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	if (!sunrpc_table_header)
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 80ea3db..375df3d 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -437,7 +437,6 @@ struct rpcrdma_create_data_internal {
 	unsigned int	wsize;		/* mount wsize - max write hdr+data */
 	unsigned int	inline_rsize;	/* max non-rdma read data payload */
 	unsigned int	inline_wsize;	/* max non-rdma write data payload */
-	unsigned int	padding;	/* non-rdma write header padding */
 };
 
 /*

