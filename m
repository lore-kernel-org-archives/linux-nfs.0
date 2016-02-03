Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36686 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756337AbcBCPvk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Feb 2016 10:51:40 -0500
Subject: [PATCH v1 02/10] svcrdma: Make svc_rdma_get_frmr() not sleep
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 03 Feb 2016 10:51:38 -0500
Message-ID: <20160203155138.13868.38423.stgit@klimt.1015granger.net>
In-Reply-To: <20160203154411.13868.48268.stgit@klimt.1015granger.net>
References: <20160203154411.13868.48268.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Want to call it in a context that cannot sleep. So pre-alloc
the memory and the MRs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   44 ++++++++++++++++++++++++++----
 1 file changed, 38 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 5763825..02eee12 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -949,7 +949,7 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
 	return ERR_PTR(-ENOMEM);
 }
 
-static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
+static void svc_rdma_destroy_frmrs(struct svcxprt_rdma *xprt)
 {
 	struct svc_rdma_fastreg_mr *frmr;
 
@@ -963,6 +963,37 @@ static void rdma_dealloc_frmr_q(struct svcxprt_rdma *xprt)
 	}
 }
 
+static bool svc_rdma_prealloc_frmrs(struct svcxprt_rdma *xprt)
+{
+	struct ib_device *dev = xprt->sc_cm_id->device;
+	unsigned int i;
+
+	/* Pre-allocate based on the maximum amount of payload
+	 * the server's HCA can handle per RDMA Read, to keep
+	 * the number of MRs per connection in check.
+	 *
+	 * If a client sends small Read chunks (eg. it may be
+	 * using physical registration), more RDMA Reads per
+	 * NFS WRITE will be needed.  svc_rdma_get_frmr() dips
+	 * into its reserve in that case. Better would be for
+	 * the server to reduce the connection's credit limit.
+	 */
+	i = 1 + RPCSVC_MAXPAGES / dev->attrs.max_fast_reg_page_list_len;
+	i *= xprt->sc_max_requests;
+
+	while (i--) {
+		struct svc_rdma_fastreg_mr *frmr;
+
+		frmr = rdma_alloc_frmr(xprt);
+		if (!frmr) {
+			dprintk("svcrdma: No memory for request map\n");
+			return false;
+		}
+		list_add(&frmr->frmr_list, &xprt->sc_frmr_q);
+	}
+	return true;
+}
+
 struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
 {
 	struct svc_rdma_fastreg_mr *frmr = NULL;
@@ -975,10 +1006,9 @@ struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *rdma)
 		frmr->sg_nents = 0;
 	}
 	spin_unlock_bh(&rdma->sc_frmr_q_lock);
-	if (frmr)
-		return frmr;
-
-	return rdma_alloc_frmr(rdma);
+	if (!frmr)
+		return ERR_PTR(-ENOMEM);
+	return frmr;
 }
 
 void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
@@ -1149,6 +1179,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 			dev->attrs.max_fast_reg_page_list_len;
 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
 		newxprt->sc_reader = rdma_read_chunk_frmr;
+		if (!svc_rdma_prealloc_frmrs(newxprt))
+			goto errout;
 	}
 
 	/*
@@ -1310,7 +1342,7 @@ static void __svc_rdma_free(struct work_struct *work)
 		xprt->xpt_bc_xprt = NULL;
 	}
 
-	rdma_dealloc_frmr_q(rdma);
+	svc_rdma_destroy_frmrs(rdma);
 	svc_rdma_destroy_ctxts(rdma);
 	svc_rdma_destroy_maps(rdma);
 

