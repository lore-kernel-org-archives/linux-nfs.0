Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36947 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907AbcD1PPU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 11:15:20 -0400
Subject: [PATCH 06/10] svcrdma: Drain QP before freeing svcrdma_xprt
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 28 Apr 2016 11:15:17 -0400
Message-ID: <20160428151517.13068.28377.stgit@klimt.1015granger.net>
In-Reply-To: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
References: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server is forcing the connection disconnect, the QP has not
been moved to the Error state, meaning Receives are still posted.

Ensure Receives (and any other outstanding WRs) are flushed to free
up resources that can be freed during teardown of an svcrdma_xprt.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 02a112c..dd94401 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1180,6 +1180,9 @@ static void __svc_rdma_free(struct work_struct *work)
 
 	dprintk("svcrdma: %s(%p)\n", __func__, rdma);
 
+	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))
+		ib_drain_qp(rdma->sc_qp);
+
 	/* We should only be called from kref_put */
 	if (atomic_read(&xprt->xpt_ref.refcount) != 0)
 		pr_err("svcrdma: sc_xprt still in use? (%d)\n",

