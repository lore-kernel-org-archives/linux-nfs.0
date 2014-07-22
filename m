Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:62630 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757113AbaGVVsG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 17:48:06 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so4536484igb.15
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 14:48:05 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] svcrdma: Double the default credit limit
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 17:48:04 -0400
Message-ID: <20140722214804.3398.34829.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RDMA credit limit controls how many concurrent RPCs are allowed
per connection.

An NFS/RDMA client and server exchange their credit limits in the
RPC/RDMA headers. The Linux client and the Solaris client and server
allow 32 credits. The Linux server allows only 16, which limits its
performance.

Set the server's default credit limit to 32, like the other well-
known implementations, so the out-of-the-shrinkwrap performance of
the Linux server is better.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 5cf99a0..975da75 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -174,8 +174,7 @@ struct svcxprt_rdma {
  * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
 #define RPCRDMA_ORD             (64/4)
 #define RPCRDMA_SQ_DEPTH_MULT   8
-#define RPCRDMA_MAX_THREADS     16
-#define RPCRDMA_MAX_REQUESTS    16
+#define RPCRDMA_MAX_REQUESTS    32
 #define RPCRDMA_MAX_REQ_SIZE    4096
 
 /* svc_rdma_marshal.c */

