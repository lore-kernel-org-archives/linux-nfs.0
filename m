Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38656 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754469AbcBVUla (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 15:41:30 -0500
Subject: [PATCH v4 05/13] svcrdma: Close connection when a send error occurs
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 22 Feb 2016 15:41:28 -0500
Message-ID: <20160222204128.3274.64201.stgit@sisley.1015granger.net>
In-Reply-To: <20160222203550.3274.82777.stgit@sisley.1015granger.net>
References: <20160222203550.3274.82777.stgit@sisley.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index a8fab99..0f8798d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -314,7 +314,6 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
  err:
 	svc_rdma_unmap_dma(ctxt);
 	svc_rdma_put_context(ctxt, 0);
-	/* Fatal error, close transport */
 	return -EIO;
 }
 
@@ -571,6 +570,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
  err:
 	svc_rdma_unmap_dma(ctxt);
 	svc_rdma_put_context(ctxt, 1);
+	pr_err("svcrdma: failed to send reply, rc=%d\n", ret);
 	return -EIO;
 }
 
@@ -642,6 +642,9 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 
 	ret = send_reply(rdma, rqstp, res_page, rdma_resp, ctxt, vec,
 			 inline_bytes);
+	if (ret < 0)
+		goto err1;
+
 	svc_rdma_put_req_map(rdma, vec);
 	dprintk("svcrdma: send_reply returns %d\n", ret);
 	return ret;
@@ -651,5 +654,6 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
  err0:
 	svc_rdma_put_req_map(rdma, vec);
 	svc_rdma_put_context(ctxt, 0);
-	return ret;
+	set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
+	return -ENOTCONN;
 }

