From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 06/33] svc: Add transport specific xpo_release function
Date: Thu, 27 Sep 2007 00:01:47 -0500
Message-ID: <20070927050147.12677.85535.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVU-0005bY-9P
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:48 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVY-0001gE-Lm
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:53 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


The svc_sock_release function releases pages allocated to a thread. For
UDP, this also returns the receive skb to the stack. For RDMA it will 
post a receive WR and bump the client credit count. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc.h      |    2 +-
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svcsock.c            |   16 +++++++++-------
 3 files changed, 11 insertions(+), 8 deletions(-)

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
index f0ba052..5871faa 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -12,6 +12,7 @@ #include <linux/sunrpc/svc.h>
 struct svc_xprt_ops {
 	int		(*xpo_recvfrom)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
+	void		(*xpo_release)(struct svc_rqst *);
 };
 
 struct svc_xprt_class {
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index cc8c7ce..e7d203a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -184,14 +184,14 @@ svc_thread_dequeue(struct svc_pool *pool
 /*
  * Release an skbuff after use
  */
-static inline void
+static void
 svc_release_skb(struct svc_rqst *rqstp)
 {
-	struct sk_buff *skb = rqstp->rq_skbuff;
+	struct sk_buff *skb = (struct sk_buff *)rqstp->rq_xprt_ctxt;
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
 	if (skb) {
-		rqstp->rq_skbuff = NULL;
+		rqstp->rq_xprt_ctxt = NULL;
 
 		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
 		skb_free_datagram(rqstp->rq_sock->sk_sk, skb);
@@ -394,7 +394,7 @@ svc_sock_release(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk = rqstp->rq_sock;
 
-	svc_release_skb(rqstp);
+	rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
 
 	svc_free_res_pages(rqstp);
 	rqstp->rq_res.page_len = 0;
@@ -866,7 +866,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 			skb_free_datagram(svsk->sk_sk, skb);
 			return 0;
 		}
-		rqstp->rq_skbuff = skb;
+		rqstp->rq_xprt_ctxt = skb;
 	}
 
 	rqstp->rq_arg.page_base = 0;
@@ -902,6 +902,7 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
+	.xpo_release = svc_release_skb,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1290,7 +1291,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
 	}
 
-	rqstp->rq_skbuff      = NULL;
+	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
 	/* Reset TCP read info */
@@ -1356,6 +1357,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
+	.xpo_release = svc_release_skb,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
@@ -1577,7 +1579,7 @@ svc_send(struct svc_rqst *rqstp)
 	}
 
 	/* release the receive skb before sending the reply */
-	svc_release_skb(rqstp);
+	rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
 
 	/* calculate over-all length */
 	xb = & rqstp->rq_res;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
