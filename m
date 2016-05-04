Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35156 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcEDOxd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2016 10:53:33 -0400
Subject: [PATCH v2 6/9] svcrdma: Drain QP before freeing svcrdma_xprt
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 04 May 2016 10:53:30 -0400
Message-ID: <20160504145330.6602.53005.stgit@klimt.1015granger.net>
In-Reply-To: <20160504144730.6602.89073.stgit@klimt.1015granger.net>
References: <20160504144730.6602.89073.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server has forced a disconnect, the associated QP has not
been moved to the Error state, and thus Receives are still posted.

Ensure Receives (and any other outstanding WRs) are drained to
release resources that can be freed during teardown of the
svcrdma_xprt.

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

