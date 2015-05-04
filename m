Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:34618 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbbEDQTl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 12:19:41 -0400
Received: by qcyk17 with SMTP id k17so74326726qcy.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 May 2015 09:19:41 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:be5f:f4ff:fed6:c3ba])
        by mx.google.com with ESMTPSA id w67sm10162569qgw.41.2015.05.04.09.19.40
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 09:19:40 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 7/8] svcrdma: Add a separate "max data segs macro for
	svcrdma
To: linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 12:19:39 -0400
Message-ID: <20150504161939.16870.31923.stgit@klimt.1015granger.net>
In-Reply-To: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
References: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
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

