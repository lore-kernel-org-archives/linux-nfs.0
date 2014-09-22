Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:35306 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754171AbaIVSpp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2014 14:45:45 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] svcrdma: Advertise the correct max payload
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 22 Sep 2014 13:36:53 -0500
Message-ID: <20140922183653.19376.14276.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Svcrdma currently advertises 1MB, which is too large.  The correct value
is the max scatter-gather allowed in an NFSRDMA IO chunk * the host page
size. This bug is usually benign because the Linux X64 NFSRDMA client
correctly limits the payload size to the correct value (64*4096 = 256KB).
But if the Linux client is PPC64 with a 64KB page size, then the client
will indeed use a payload size that will overflow the server.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
 net/sunrpc/xprtrdma/xprt_rdma.h          |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 374feb4..4e61880 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -91,7 +91,7 @@ struct svc_xprt_class svc_rdma_class = {
 	.xcl_name = "rdma",
 	.xcl_owner = THIS_MODULE,
 	.xcl_ops = &svc_rdma_ops,
-	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD_RDMA,
 	.xcl_ident = XPRT_TRANSPORT_RDMA,
 };
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c419498..467a77c 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -392,4 +392,6 @@ extern struct kmem_cache *svc_rdma_ctxt_cachep;
 /* Workqueue created in svc_rdma.c */
 extern struct workqueue_struct *svc_rdma_wq;
 
+#define RPCSVC_MAXPAYLOAD_RDMA	(RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)
+
 #endif				/* _LINUX_SUNRPC_XPRT_RDMA_H */

