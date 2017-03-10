Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36558 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932724AbdCJQHM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Mar 2017 11:07:12 -0500
Subject: [PATCH v1 10/11] xprtrdma: Restore transport after device removal
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 10 Mar 2017 11:07:09 -0500
Message-ID: <20170310160709.6314.25670.stgit@manet.1015granger.net>
In-Reply-To: <20170310154131.6314.35201.stgit@manet.1015granger.net>
References: <20170310154131.6314.35201.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After a device removal, enable the transport connect worker to
restore normal operation if there is another device with
connectivity to the server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   48 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6a12386..ef3ceec 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -69,6 +69,7 @@
 /*
  * internal functions
  */
+static void rpcrdma_create_mrs(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_destroy_mrs(struct rpcrdma_buffer *buf);
 static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
 
@@ -710,6 +711,48 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	ib_free_cq(ep->rep_attr.send_cq);
 }
 
+/* Re-establish a connection after a device removal event.
+ * Unlike a normal reconnection, a fresh PD and a new set
+ * of MRs and buffers is needed.
+ */
+static int
+rpcrdma_ep_recreate_xprt(struct rpcrdma_xprt *r_xprt,
+			 struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
+{
+	struct sockaddr *sap = (struct sockaddr *)&r_xprt->rx_data.addr;
+	int rc, err;
+
+	pr_info("%s: r_xprt = %p\n", __func__, r_xprt);
+
+	rc = -EHOSTUNREACH;
+	if (rpcrdma_ia_open(r_xprt, sap))
+		goto out1;
+
+	rc = -ENOMEM;
+	err = rpcrdma_ep_create(ep, ia, &r_xprt->rx_data);
+	if (err) {
+		pr_err("rpcrdma: rpcrdma_ep_create returned %d\n", err);
+		goto out2;
+	}
+
+	rc = -ENETUNREACH;
+	err = rdma_create_qp(ia->ri_id, ia->ri_pd, &ep->rep_attr);
+	if (err) {
+		pr_err("rpcrdma: rdma_create_qp returned %d\n", err);
+		goto out3;
+	}
+
+	rpcrdma_create_mrs(r_xprt);
+	return 0;
+
+out3:
+	rpcrdma_ep_destroy(ep, ia);
+out2:
+	rpcrdma_ia_close(ia);
+out1:
+	return rc;
+}
+
 static int
 rpcrdma_ep_reconnect(struct rpcrdma_xprt *r_xprt, struct rpcrdma_ep *ep,
 		     struct rpcrdma_ia *ia)
@@ -784,6 +827,11 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 			goto out_noupdate;
 		}
 		break;
+	case -ENODEV:
+		rc = rpcrdma_ep_recreate_xprt(r_xprt, ep, ia);
+		if (rc)
+			goto out_noupdate;
+		break;
 	default:
 		rc = rpcrdma_ep_reconnect(r_xprt, ep, ia);
 		if (rc)

