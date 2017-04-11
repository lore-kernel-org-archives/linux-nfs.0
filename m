Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33484 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752236AbdDKRXs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Apr 2017 13:23:48 -0400
Subject: [PATCH v3 08/13] xprtrdma: Restore transport after device removal
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 11 Apr 2017 13:23:26 -0400
Message-ID: <20170411172326.11300.54402.stgit@manet.1015granger.net>
In-Reply-To: <20170411171820.11300.55637.stgit@manet.1015granger.net>
References: <20170411171820.11300.55637.stgit@manet.1015granger.net>
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
index 6479ad3..b69daa3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -69,6 +69,7 @@
 /*
  * internal functions
  */
+static void rpcrdma_create_mrs(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_destroy_mrs(struct rpcrdma_buffer *buf);
 static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
 
@@ -711,6 +712,48 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
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
@@ -785,6 +828,11 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
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

