From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 29/40] svc: Make svc_sock_release svc_xprt_release
Date: Sun, 30 Dec 2007 21:08:14 -0600
Message-ID: <20071231030814.8430.31896.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41570 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752889AbXLaDIO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:08:14 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
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
index 298c95e..505336e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -368,10 +368,9 @@ void svc_reserve(struct svc_rqst *rqstp, int space)
 	}
 }
 
-static void
-svc_sock_release(struct svc_rqst *rqstp)
+static void svc_xprt_release(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_xprt	*xprt = rqstp->rq_xprt;
 
 	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
 
@@ -379,7 +378,6 @@ svc_sock_release(struct svc_rqst *rqstp)
 	rqstp->rq_res.page_len = 0;
 	rqstp->rq_res.page_base = 0;
 
-
 	/* Reset response buffer and release
 	 * the reservation.
 	 * But first, check that enough space was reserved
@@ -392,9 +390,9 @@ svc_sock_release(struct svc_rqst *rqstp)
 
 	rqstp->rq_res.head[0].iov_len = 0;
 	svc_reserve(rqstp, 0);
-	rqstp->rq_sock = NULL;
+	rqstp->rq_xprt = NULL;
 
-	svc_xprt_put(&svsk->sk_xprt);
+	svc_xprt_put(xprt);
 }
 
 /*
@@ -1593,7 +1591,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {
 		rqstp->rq_res.len = 0;
-		svc_sock_release(rqstp);
+		svc_xprt_release(rqstp);
 		return -EAGAIN;
 	}
 	clear_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags);
@@ -1613,7 +1611,7 @@ void
 svc_drop(struct svc_rqst *rqstp)
 {
 	dprintk("svc: socket %p dropped request\n", rqstp->rq_sock);
-	svc_sock_release(rqstp);
+	svc_xprt_release(rqstp);
 }
 
 /*
@@ -1646,7 +1644,7 @@ svc_send(struct svc_rqst *rqstp)
 	else
 		len = xprt->xpt_ops->xpo_sendto(rqstp);
 	mutex_unlock(&xprt->xpt_mutex);
-	svc_sock_release(rqstp);
+	svc_xprt_release(rqstp);
 
 	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
 		return 0;
