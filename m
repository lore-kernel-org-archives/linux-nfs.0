Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:64649 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaCLQvl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 12:51:41 -0400
Received: by mail-ie0-f172.google.com with SMTP id as1so10903256iec.3
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 09:51:40 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] SUNRPC: remove KERN_INFO from dprintk() call sites
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 12 Mar 2014 12:51:39 -0400
Message-ID: <20140312165139.15349.82103.stgit@manet.1015granger.net>
In-Reply-To: <20140312164620.15349.22643.stgit@manet.1015granger.net>
References: <20140312164620.15349.22643.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The use of KERN_INFO causes garbage characters to appear when
debugging is enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/transport.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 285dc08..1eb9c46 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -733,7 +733,7 @@ static void __exit xprt_rdma_cleanup(void)
 {
 	int rc;
 
-	dprintk(KERN_INFO "RPCRDMA Module Removed, deregister RPC RDMA transport\n");
+	dprintk("RPCRDMA Module Removed, deregister RPC RDMA transport\n");
 #ifdef RPC_DEBUG
 	if (sunrpc_table_header) {
 		unregister_sysctl_table(sunrpc_table_header);
@@ -755,14 +755,14 @@ static int __init xprt_rdma_init(void)
 	if (rc)
 		return rc;
 
-	dprintk(KERN_INFO "RPCRDMA Module Init, register RPC RDMA transport\n");
+	dprintk("RPCRDMA Module Init, register RPC RDMA transport\n");
 
-	dprintk(KERN_INFO "Defaults:\n");
-	dprintk(KERN_INFO "\tSlots %d\n"
+	dprintk("Defaults:\n");
+	dprintk("\tSlots %d\n"
 		"\tMaxInlineRead %d\n\tMaxInlineWrite %d\n",
 		xprt_rdma_slot_table_entries,
 		xprt_rdma_max_inline_read, xprt_rdma_max_inline_write);
-	dprintk(KERN_INFO "\tPadding %d\n\tMemreg %d\n",
+	dprintk("\tPadding %d\n\tMemreg %d\n",
 		xprt_rdma_inline_write_padding, xprt_rdma_memreg_strategy);
 
 #ifdef RPC_DEBUG

