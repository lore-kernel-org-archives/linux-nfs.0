From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 27/38] svc: Make svc_sock_release svc_xprt_release
Date: Tue, 11 Dec 2007 17:32:54 -0600
Message-ID: <20071211233254.15718.35562.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35444 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755553AbXLKXcy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:32:54 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The svc_sock_release function only touches transport independent fields.
Change the function to manipulate svc_xprt directly instead of the transport
dependent svc_sock structure. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8828c74..378c970 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -365,10 +365,9 @@ void svc_reserve(struct svc_rqst *rqstp, int space)
 	}
 }
 
-static void
-svc_sock_release(struct svc_rqst *rqstp)
+static void svc_xprt_release(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_xprt	*xprt = rqstp->rq_xprt;
 
 	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
 
@@ -376,7 +375,6 @@ svc_sock_release(struct svc_rqst *rqstp)
 	rqstp->rq_res.page_len = 0;
 	rqstp->rq_res.page_base = 0;
 
-
 	/* Reset response buffer and release
 	 * the reservation.
 	 * But first, check that enough space was reserved
@@ -389,9 +387,9 @@ svc_sock_release(struct svc_rqst *rqstp)
 
 	rqstp->rq_res.head[0].iov_len = 0;
 	svc_reserve(rqstp, 0);
-	rqstp->rq_sock = NULL;
+	rqstp->rq_xprt = NULL;
 
-	svc_xprt_put(&svsk->sk_xprt);
+	svc_xprt_put(xprt);
 }
 
 /*
@@ -1595,7 +1593,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {
 		rqstp->rq_res.len = 0;
-		svc_sock_release(rqstp);
+		svc_xprt_release(rqstp);
 		return -EAGAIN;
 	}
 	clear_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags);
@@ -1615,7 +1613,7 @@ void
 svc_drop(struct svc_rqst *rqstp)
 {
 	dprintk("svc: socket %p dropped request\n", rqstp->rq_sock);
-	svc_sock_release(rqstp);
+	svc_xprt_release(rqstp);
 }
 
 /*
@@ -1648,7 +1646,7 @@ svc_send(struct svc_rqst *rqstp)
 	else
 		len = xprt->xpt_ops->xpo_sendto(rqstp);
 	mutex_unlock(&xprt->xpt_mutex);
-	svc_sock_release(rqstp);
+	svc_xprt_release(rqstp);
 
 	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
 		return 0;
