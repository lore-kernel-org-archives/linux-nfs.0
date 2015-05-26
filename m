Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34838 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbbEZRtj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2015 13:49:39 -0400
Received: by qkdn188 with SMTP id n188so95778846qkd.2
        for <linux-nfs@vger.kernel.org>; Tue, 26 May 2015 10:49:38 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 07/10] svcrdma: Add a separate "max data segs macro for
	svcrdma
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 May 2015 13:49:36 -0400
Message-ID: <20150526174936.7061.22593.stgit@klimt.1015granger.net>
In-Reply-To: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
References: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server and client maximum are architecturally independent.
Allow changing one without affecting the other.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h          |    7 +++++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
 net/sunrpc/xprtrdma/xprt_rdma.h          |    6 ------
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index d26384b..cb94ee4 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -172,6 +172,13 @@ struct svcxprt_rdma {
 #define RDMAXPRT_SQ_PENDING	2
 #define RDMAXPRT_CONN_PENDING	3
 
+#define RPCRDMA_MAX_SVC_SEGS	(64)	/* server max scatter/gather */
+#if RPCSVC_MAXPAYLOAD < (RPCRDMA_MAX_SVC_SEGS << PAGE_SHIFT)
+#define RPCRDMA_MAXPAYLOAD	RPCSVC_MAXPAYLOAD
+#else
+#define RPCRDMA_MAXPAYLOAD	(RPCRDMA_MAX_SVC_SEGS << PAGE_SHIFT)
+#endif
+
 #define RPCRDMA_LISTEN_BACKLOG  10
 /* The default ORD value is based on two outstanding full-size writes with a
  * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 1ed4740..3b4c2ff 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -91,7 +91,7 @@ struct svc_xprt_class svc_rdma_class = {
 	.xcl_name = "rdma",
 	.xcl_owner = THIS_MODULE,
 	.xcl_ops = &svc_rdma_ops,
-	.xcl_max_payload = RPCSVC_MAXPAYLOAD_RDMA,
+	.xcl_max_payload = RPCRDMA_MAXPAYLOAD,
 	.xcl_ident = XPRT_TRANSPORT_RDMA,
 };
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 78e0b8b..e60907b 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -487,10 +487,4 @@ extern struct kmem_cache *svc_rdma_ctxt_cachep;
 /* Workqueue created in svc_rdma.c */
 extern struct workqueue_struct *svc_rdma_wq;
 
-#if RPCSVC_MAXPAYLOAD < (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)
-#define RPCSVC_MAXPAYLOAD_RDMA RPCSVC_MAXPAYLOAD
-#else
-#define RPCSVC_MAXPAYLOAD_RDMA (RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)
-#endif
-
 #endif				/* _LINUX_SUNRPC_XPRT_RDMA_H */

