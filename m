Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47582 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbaELBXi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 21:23:38 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 12 May 2014 11:22:47 +1000
Subject: [PATCH 1/2] SUNRPC: track whether a request is coming from a
 loop-back interface.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140512012247.20840.30589.stgit@notabene.brown>
In-Reply-To: <20140512012120.20840.68685.stgit@notabene.brown>
References: <20140512012120.20840.68685.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an incoming NFS request is coming from the local host, then
nfsd will need to perform some special handling.  So detect that
possibility and make the source visible in rq_local.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/svc.h      |    1 +
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/sunrpc.h             |   13 +++++++++++++
 net/sunrpc/svcsock.c            |    5 +++++
 4 files changed, 20 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 04e763221246..a0dbbd1e00e9 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -254,6 +254,7 @@ struct svc_rqst {
 	u32			rq_prot;	/* IP protocol */
 	unsigned short
 				rq_secure  : 1;	/* secure port */
+	unsigned short		rq_local   : 1;	/* local request */
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index b05963f09ebf..b99bdfb0fcf9 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -63,6 +63,7 @@ struct svc_xprt {
 #define	XPT_DETACHED	10		/* detached from tempsocks list */
 #define XPT_LISTENER	11		/* listening endpoint */
 #define XPT_CACHE_AUTH	12		/* cache auth info */
+#define XPT_LOCAL	13		/* connection from loopback interface */
 
 	struct svc_serv		*xpt_server;	/* service for transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index 14c9f6d1c5ff..f2b7cb540e61 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -43,6 +43,19 @@ static inline int rpc_reply_expected(struct rpc_task *task)
 		(task->tk_msg.rpc_proc->p_decode != NULL);
 }
 
+static inline int sock_is_loopback(struct sock *sk)
+{
+	struct dst_entry *dst;
+	int loopback = 0;
+	rcu_read_lock();
+	dst = rcu_dereference(sk->sk_dst_cache);
+	if (dst && dst->dev &&
+	    (dst->dev->features & NETIF_F_LOOPBACK))
+		loopback = 1;
+	rcu_read_unlock();
+	return loopback;
+}
+
 int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 		    struct page *headpage, unsigned long headoffset,
 		    struct page *tailpage, unsigned long tailoffset);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 43bcb4699d69..95684986c372 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -867,6 +867,10 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	}
 	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
 
+	if (sock_is_loopback(newsock->sk))
+		set_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
+	else
+		clear_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
 
@@ -1112,6 +1116,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
+	rqstp->rq_local	      = !!test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags);
 
 	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	calldir = p[1];


