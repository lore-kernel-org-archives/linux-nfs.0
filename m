Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:53256 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbaJPTi5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:38:57 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn15so253548igb.15
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:38:56 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id j194sm3181519ioe.10.2014.10.16.12.38.55
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:38:55 -0700 (PDT)
Subject: [PATCH v1 05/16] xprtrdma: unmap all FMRs during transport
 disconnect
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:38:55 -0400
Message-ID: <20141016193855.13414.95504.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using RPCRDMA_MTHCAFMR memory registration, after a few
transport disconnect / reconnect cycles, ib_map_phys_fmr() starts to
return EINVAL because the provider has exhausted its map pool.

Make sure that all FMRs are unmapped during transport disconnect,
and that ->send_request remarshals them during an RPC retransmit.
This resets the transport's MRs to ensure that none are leaked
during a disconnect.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtrdma/verbs.c     |   40 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 6e9d0a7..61be0a0 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -601,7 +601,7 @@ xprt_rdma_send_request(struct rpc_task *task)
 
 	if (req->rl_niovs == 0)
 		rc = rpcrdma_marshal_req(rqst);
-	else if (r_xprt->rx_ia.ri_memreg_strategy == RPCRDMA_FRMR)
+	else if (r_xprt->rx_ia.ri_memreg_strategy != RPCRDMA_ALLPHYSICAL)
 		rc = rpcrdma_marshal_chunks(rqst, 0);
 	if (rc < 0)
 		goto failed_marshal;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6fadb90..9105524 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -62,6 +62,7 @@
 #endif
 
 static void rpcrdma_reset_frmrs(struct rpcrdma_ia *);
+static void rpcrdma_reset_fmrs(struct rpcrdma_ia *);
 
 /*
  * internal functions
@@ -884,8 +885,17 @@ retry:
 		rpcrdma_ep_disconnect(ep, ia);
 		rpcrdma_flush_cqs(ep);
 
-		if (ia->ri_memreg_strategy == RPCRDMA_FRMR)
+		switch (ia->ri_memreg_strategy) {
+		case RPCRDMA_FRMR:
 			rpcrdma_reset_frmrs(ia);
+			break;
+		case RPCRDMA_MTHCAFMR:
+			rpcrdma_reset_fmrs(ia);
+			break;
+		default:
+			rc = -EIO;
+			goto out;
+		}
 
 		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
 		id = rpcrdma_create_id(xprt, ia,
@@ -1305,6 +1315,34 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 	kfree(buf->rb_pool);
 }
 
+/* After a disconnect, unmap all FMRs.
+ *
+ * This is invoked only in the transport connect worker in order
+ * to serialize with rpcrdma_register_fmr_external().
+ */
+static void
+rpcrdma_reset_fmrs(struct rpcrdma_ia *ia)
+{
+	struct rpcrdma_xprt *r_xprt =
+				container_of(ia, struct rpcrdma_xprt, rx_ia);
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct list_head *pos;
+	struct rpcrdma_mw *r;
+	LIST_HEAD(l);
+	int rc;
+
+	list_for_each(pos, &buf->rb_all) {
+		r = list_entry(pos, struct rpcrdma_mw, mw_all);
+
+		INIT_LIST_HEAD(&l);
+		list_add(&r->r.fmr->list, &l);
+		rc = ib_unmap_fmr(&l);
+		if (rc)
+			dprintk("RPC:       %s: ib_unmap_fmr failed %i\n",
+				__func__, rc);
+	}
+}
+
 /* After a disconnect, a flushed FAST_REG_MR can leave an FRMR in
  * an unusable state. Find FRMRs in this state and dereg / reg
  * each.  FRMRs that are VALID and attached to an rpcrdma_req are

