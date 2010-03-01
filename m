From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: The recent kref_put warning (was: [PATCH] sunrpc: remove
	unnecessary svc_xprt_put)
Date: Sun, 28 Feb 2010 22:48:46 -0500
Message-ID: <20100301034846.GB8462@fieldses.org>
References: <19336.19524.469529.431210@notabene.brown> <20100226225416.GF26598@fieldses.org> <4B886A1A.7060106@opengridcomputing.com> <20100227123537.6289e326@notabene.brown> <20100227165913.53718449@notabene.brown> <20100228210553.GA27965@fieldses.org> <20100228220723.GB27965@fieldses.org> <20100301105734.7fe935b0@notabene.brown> <20100301034647.GA8462@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33941 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649Ab0CADrk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Feb 2010 22:47:40 -0500
In-Reply-To: <20100301034647.GA8462@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For people that can test, the combined patch is just as follows.

--b.

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d7ec5ca..8f0f1fb 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -706,8 +706,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_unlock_bh(&pool->sp_lock);
 
 	len = 0;
-	if (test_bit(XPT_LISTENER, &xprt->xpt_flags) &&
-	    !test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+		dprintk("svc_recv: found XPT_CLOSE\n");
+		svc_delete_xprt(xprt);
+	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
@@ -733,7 +735,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			svc_xprt_received(newxpt);
 		}
 		svc_xprt_received(xprt);
-	} else if (!test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+	} else {
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
 			rqstp, pool->sp_id, xprt,
 			atomic_read(&xprt->xpt_ref.refcount));
@@ -746,11 +748,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		dprintk("svc: got len=%d\n", len);
 	}
 
-	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
-		dprintk("svc_recv: found XPT_CLOSE\n");
-		svc_delete_xprt(xprt);
-	}
-
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {
 		rqstp->rq_res.len = 0;
@@ -896,11 +893,8 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 	if (test_bit(XPT_TEMP, &xprt->xpt_flags))
 		serv->sv_tmpcnt--;
 
-	for (dr = svc_deferred_dequeue(xprt); dr;
-	     dr = svc_deferred_dequeue(xprt)) {
-		svc_xprt_put(xprt);
+	while ((dr = svc_deferred_dequeue(xprt)) != NULL)
 		kfree(dr);
-	}
 
 	svc_xprt_put(xprt);
 	spin_unlock_bh(&serv->sv_lock);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 9e09391..a29f259 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -968,6 +968,7 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	return len;
  err_delete:
 	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+	svc_xprt_received(&svsk->sk_xprt);
  err_again:
 	return -EAGAIN;
 }
