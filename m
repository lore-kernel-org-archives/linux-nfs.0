Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:39724 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbbAGXNf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 18:13:35 -0500
Received: by mail-ie0-f174.google.com with SMTP id at20so6680107iec.5
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 15:13:34 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id e63sm1443062ioe.15.2015.01.07.15.13.33
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 15:13:34 -0800 (PST)
Subject: [PATCH v1 13/20] xprtrdma: Simplify synopsis of
 rpcrdma_buffer_create()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 07 Jan 2015 18:13:33 -0500
Message-ID: <20150107231333.13466.7599.stgit@manet.1015granger.net>
In-Reply-To: <20150107230859.13466.67723.stgit@manet.1015granger.net>
References: <20150107230859.13466.67723.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: There is one call site for rpcrdma_buffer_create(). All of
the arguments there are fields of an rpcrdma_xprt.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    3 +--
 net/sunrpc/xprtrdma/verbs.c     |    7 +++++--
 net/sunrpc/xprtrdma/xprt_rdma.h |    4 +---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index a487bde..808b3c5 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -364,8 +364,7 @@ xprt_setup_rdma(struct xprt_create *args)
 	 * any inline data. Also specify any padding which will be provided
 	 * from a preregistered zero buffer.
 	 */
-	rc = rpcrdma_buffer_create(&new_xprt->rx_buf, new_ep, &new_xprt->rx_ia,
-				&new_xprt->rx_data);
+	rc = rpcrdma_buffer_create(new_xprt);
 	if (rc)
 		goto out3;
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 958b372..fd71501 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1161,9 +1161,11 @@ out_free:
 }
 
 int
-rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
-	struct rpcrdma_ia *ia, struct rpcrdma_create_data_internal *cdata)
+rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 {
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
 	char *p;
 	size_t len, rlen, wlen;
 	int i, rc;
@@ -1200,6 +1202,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	 * Register the zeroed pad buffer, if any.
 	 */
 	if (cdata->padding) {
+		struct rpcrdma_ep *ep = &r_xprt->rx_ep;
 		rc = rpcrdma_register_internal(ia, p, cdata->padding,
 					    &ep->rep_pad_mr, &ep->rep_pad);
 		if (rc)
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 2b4e778..5c2fac3 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -354,9 +354,7 @@ int rpcrdma_ep_post_recv(struct rpcrdma_ia *, struct rpcrdma_ep *,
 /*
  * Buffer calls - xprtrdma/verbs.c
  */
-int rpcrdma_buffer_create(struct rpcrdma_buffer *, struct rpcrdma_ep *,
-				struct rpcrdma_ia *,
-				struct rpcrdma_create_data_internal *);
+int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
 
 struct rpcrdma_req *rpcrdma_buffer_get(struct rpcrdma_buffer *);

