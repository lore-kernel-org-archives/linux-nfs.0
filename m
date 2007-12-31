From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 06/40] svc: Add transport specific xpo_release function
Date: Sun, 30 Dec 2007 21:07:25 -0600
Message-ID: <20071231030725.8430.56046.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41483 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752362AbXLaDH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:26 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The svc_sock_release function releases pages allocated to a thread. For
UDP this frees the receive skb. For RDMA it will post a receive WR
and bump the client credit count. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc.h      |    2 +-
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svcsock.c            |   17 +++++++++--------
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 37f7448..cfb2652 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -217,7 +217,7 @@ struct svc_rqst {
 	struct auth_ops *	rq_authop;	/* authentication flavour */
 	u32			rq_flavor;	/* pseudoflavor */
 	struct svc_cred		rq_cred;	/* auth info */
-	struct sk_buff *	rq_skbuff;	/* fast recv inet buffer */
+	void *			rq_xprt_ctxt;	/* transport specific context ptr */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
 
 	struct xdr_buf		rq_arg;
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 7ae6c85..01ee7bc 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -12,6 +12,7 @@
 struct svc_xprt_ops {
 	int		(*xpo_recvfrom)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
+	void		(*xpo_release_rqst)(struct svc_rqst *);
 };
 
 struct svc_xprt_class {
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7817c7e..d46abc8 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -185,14 +185,13 @@ svc_thread_dequeue(struct svc_pool *pool, struct svc_rqst *rqstp)
 /*
  * Release an skbuff after use
  */
-static inline void
-svc_release_skb(struct svc_rqst *rqstp)
+static void svc_release_skb(struct svc_rqst *rqstp)
 {
-	struct sk_buff *skb = rqstp->rq_skbuff;
+	struct sk_buff *skb = rqstp->rq_xprt_ctxt;
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
 	if (skb) {
-		rqstp->rq_skbuff = NULL;
+		rqstp->rq_xprt_ctxt = NULL;
 
 		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
 		skb_free_datagram(rqstp->rq_sock->sk_sk, skb);
@@ -395,7 +394,7 @@ svc_sock_release(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk = rqstp->rq_sock;
 
-	svc_release_skb(rqstp);
+	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
 
 	svc_free_res_pages(rqstp);
 	rqstp->rq_res.page_len = 0;
@@ -867,7 +866,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 			skb_free_datagram(svsk->sk_sk, skb);
 			return 0;
 		}
-		rqstp->rq_skbuff = skb;
+		rqstp->rq_xprt_ctxt = skb;
 	}
 
 	rqstp->rq_arg.page_base = 0;
@@ -903,6 +902,7 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
+	.xpo_release_rqst = svc_release_skb,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1291,7 +1291,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
 	}
 
-	rqstp->rq_skbuff      = NULL;
+	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
 	/* Reset TCP read info */
@@ -1357,6 +1357,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
+	.xpo_release_rqst = svc_release_skb,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
@@ -1578,7 +1579,7 @@ svc_send(struct svc_rqst *rqstp)
 	}
 
 	/* release the receive skb before sending the reply */
-	svc_release_skb(rqstp);
+	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
 
 	/* calculate over-all length */
 	xb = & rqstp->rq_res;
