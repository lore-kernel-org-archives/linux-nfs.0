Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38338 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424839AbcBRRow (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:44:52 -0500
Subject: [PATCH v3 08/10] svcrdma: Remove close_out exit path
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:44:51 -0500
Message-ID: <20160218174450.12825.74658.stgit@klimt.1015granger.net>
In-Reply-To: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
References: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: close_out is reached only when ctxt == NULL and XPT_CLOSE
is already set.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Devesh Sharma <devesh.sharma@broadcom.com>
Tested-by: Devesh Sharma <devesh.sharma@broadcom.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index f8b840b..d3718e9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -641,8 +641,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		 * transport list
 		 */
 		if (test_bit(XPT_CLOSE, &xprt->xpt_flags))
-			goto close_out;
-
+			goto defer;
 		goto out;
 	}
 	dprintk("svcrdma: processing ctxt=%p on xprt=%p, rqstp=%p, status=%d\n",
@@ -700,15 +699,6 @@ out_err:
 	svc_rdma_put_context(ctxt, 0);
 	return 0;
 
- close_out:
-	if (ctxt)
-		svc_rdma_put_context(ctxt, 1);
-	dprintk("svcrdma: transport %p is closing\n", xprt);
-	/*
-	 * Set the close bit and enqueue it. svc_recv will see the
-	 * close bit and call svc_xprt_delete
-	 */
-	set_bit(XPT_CLOSE, &xprt->xpt_flags);
 defer:
 	return 0;
 

