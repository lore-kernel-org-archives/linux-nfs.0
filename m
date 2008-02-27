From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] SVC: Guard call to xpo_release_rqst in svc_send
Date: Wed, 27 Feb 2008 13:58:59 -0600
Message-ID: <1204142339.24762.94.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
	jaschut <jaschut@sandia.gov>, swise@opengridcomputing.com
To: bfields <bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48238 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757015AbYB0TtV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Feb 2008 14:49:21 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

    
The svc_send path is calling xpo_release_rqst without checking
the XPT_DEAD bit. It is illegal to call transport methods on a dead
transport. In practice, if the transport gets an error and shuts down
while there are still RPC in svc_process the resulting svc_send could
crash calling into a transport that is being shut down.
    
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ea377e0..467c1c0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -729,9 +729,6 @@ int svc_send(struct svc_rqst *rqstp)
 	if (!xprt)
 		return -EFAULT;
 
-	/* release the receive skb before sending the reply */
-	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
-
 	/* calculate over-all length */
 	xb = &rqstp->rq_res;
 	xb->len = xb->head[0].iov_len +
@@ -742,8 +739,11 @@ int svc_send(struct svc_rqst *rqstp)
 	mutex_lock(&xprt->xpt_mutex);
 	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
 		len = -ENOTCONN;
-	else
+	else {
+		/* release the receive skb before sending the reply */
+		rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
 		len = xprt->xpt_ops->xpo_sendto(rqstp);
+	}
 	mutex_unlock(&xprt->xpt_mutex);
 	svc_xprt_release(rqstp);
 

