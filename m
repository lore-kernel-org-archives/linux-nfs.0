From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: The recent kref_put warning (was: [PATCH] sunrpc: remove
	unnecessary svc_xprt_put)
Date: Sun, 28 Feb 2010 17:07:23 -0500
Message-ID: <20100228220723.GB27965@fieldses.org>
References: <19336.19524.469529.431210@notabene.brown> <20100226225416.GF26598@fieldses.org> <4B886A1A.7060106@opengridcomputing.com> <20100227123537.6289e326@notabene.brown> <20100227165913.53718449@notabene.brown> <20100228210553.GA27965@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45013 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032092Ab0B1WGS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Feb 2010 17:06:18 -0500
In-Reply-To: <20100228210553.GA27965@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 28, 2010 at 04:05:53PM -0500, J. Bruce Fields wrote:
> On Sat, Feb 27, 2010 at 04:59:13PM +1100, Neil Brown wrote:
> > I've made quite a few changes here - it might be worth splitting them
> > up.
> 
> Probably so.

So, if I first revert b292cf9 and then b0401d7, I get the following.

I don't understand the "return 0" in the XPT_CLOSE case.  Is it really
OK for the caller to try to process this request?

--b.

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 8f0f1fb..48f91fb 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -706,9 +706,11 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_unlock_bh(&pool->sp_lock);
 
 	len = 0;
+
 	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
 		dprintk("svc_recv: found XPT_CLOSE\n");
 		svc_delete_xprt(xprt);
+		return 0;
 	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
@@ -735,19 +737,20 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			svc_xprt_received(newxpt);
 		}
 		svc_xprt_received(xprt);
-	} else {
-		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
-			rqstp, pool->sp_id, xprt,
-			atomic_read(&xprt->xpt_ref.refcount));
-		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
-		if (rqstp->rq_deferred) {
-			svc_xprt_received(xprt);
-			len = svc_deferred_recv(rqstp);
-		} else
-			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
-		dprintk("svc: got len=%d\n", len);
+		return 0;
 	}
 
+	dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
+		rqstp, pool->sp_id, xprt,
+		atomic_read(&xprt->xpt_ref.refcount));
+	rqstp->rq_deferred = svc_deferred_dequeue(xprt);
+	if (rqstp->rq_deferred)
+		len = svc_deferred_recv(rqstp);
+	else
+		len = xprt->xpt_ops->xpo_recvfrom(rqstp);
+	dprintk("svc: got len=%d\n", len);
+	svc_xprt_received(xprt);
+
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {
 		rqstp->rq_res.len = 0;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 9e09391..cc68137 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -547,7 +547,6 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 			dprintk("svc: recvfrom returned error %d\n", -err);
 			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		}
-		svc_xprt_received(&svsk->sk_xprt);
 		return -EAGAIN;
 	}
 	len = svc_addr_len(svc_addr(rqstp));
@@ -562,11 +561,6 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	svsk->sk_sk->sk_stamp = skb->tstamp;
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be more data... */
 
-	/*
-	 * Maybe more packets - kick another thread ASAP.
-	 */
-	svc_xprt_received(&svsk->sk_xprt);
-
 	len  = skb->len - sizeof(struct udphdr);
 	rqstp->rq_arg.len = len;
 
@@ -917,7 +911,6 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 		if (len < want) {
 			dprintk("svc: short recvfrom while reading record "
 				"length (%d of %d)\n", len, want);
-			svc_xprt_received(&svsk->sk_xprt);
 			goto err_again; /* record header not complete */
 		}
 
@@ -953,7 +946,6 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	if (len < svsk->sk_reclen) {
 		dprintk("svc: incomplete TCP record (%d of %d)\n",
 			len, svsk->sk_reclen);
-		svc_xprt_received(&svsk->sk_xprt);
 		goto err_again;	/* record not complete */
 	}
 	len = svsk->sk_reclen;
@@ -961,10 +953,9 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 
 	return len;
  error:
-	if (len == -EAGAIN) {
+	if (len == -EAGAIN)
 		dprintk("RPC: TCP recv_record got EAGAIN\n");
-		svc_xprt_received(&svsk->sk_xprt);
-	}
+
 	return len;
  err_delete:
 	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
@@ -1109,18 +1100,14 @@ out:
 	svsk->sk_tcplen = 0;
 
 	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
-	svc_xprt_received(&svsk->sk_xprt);
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpcnt++;
 
 	return len;
 
 err_again:
-	if (len == -EAGAIN) {
+	if (len == -EAGAIN)
 		dprintk("RPC: TCP recvfrom got EAGAIN\n");
-		svc_xprt_received(&svsk->sk_xprt);
-		return len;
-	}
 error:
 	if (len != -EAGAIN) {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index f92e37e..0194de8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -566,7 +566,6 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 		ret, rqstp->rq_arg.len,	rqstp->rq_arg.head[0].iov_base,
 		rqstp->rq_arg.head[0].iov_len);
 
-	svc_xprt_received(rqstp->rq_xprt);
 	return ret;
 }
 
@@ -665,7 +664,6 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		rqstp->rq_arg.head[0].iov_len);
 	rqstp->rq_prot = IPPROTO_MAX;
 	svc_xprt_copy_addrs(rqstp, xprt);
-	svc_xprt_received(xprt);
 	return ret;
 
  close_out:
@@ -678,6 +676,5 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	 */
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
 defer:
-	svc_xprt_received(xprt);
 	return 0;
 }
