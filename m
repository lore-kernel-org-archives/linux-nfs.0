From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/3] SUNRPC: Fix the TCP write space reservations for
 deferred requests
Date: Mon, 18 May 2009 17:47:56 -0400
Message-ID: <20090518214756.786.33956.stgit@heimdal.trondhjem.org>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Moyer <jmoyer@redhat.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbZERVv1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 17:51:27 -0400
In-Reply-To: <20090518214756.786.28129.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that deferred requests are accounted for correctly by the write
space reservation mechanism. In order to avoid double counting, remove the
reservation when we defer the request, and save any calculated value, so
that we can restore it when the request is requeued.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc_xprt.c      |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)


diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2a30775..2c373d8 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -341,6 +341,7 @@ struct svc_deferred_req {
 	union svc_addr_u	daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
 	size_t			xprt_hlen;
+	int			reserved_space;
 	int			argslen;
 	__be32			args[0];
 };
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c200d92..daa1f27 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -299,7 +299,6 @@ static void svc_thread_dequeue(struct svc_pool *pool, struct svc_rqst *rqstp)
  */
 void svc_xprt_enqueue(struct svc_xprt *xprt)
 {
-	struct svc_serv	*serv = xprt->xpt_server;
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
 	int cpu;
@@ -376,8 +375,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 				rqstp, rqstp->rq_xprt);
 		rqstp->rq_xprt = xprt;
 		svc_xprt_get(xprt);
-		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 		rqstp->rq_waking = 1;
 		pool->sp_nwaking++;
 		pool->sp_stats.threads_woken++;
@@ -657,8 +654,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	if (xprt) {
 		rqstp->rq_xprt = xprt;
 		svc_xprt_get(xprt);
-		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 	} else {
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);
@@ -741,6 +736,8 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
 			rqstp, pool->sp_id, xprt,
 			atomic_read(&xprt->xpt_ref.refcount));
+		rqstp->rq_reserved = serv->sv_max_mesg;
+		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
 		if (rqstp->rq_deferred) {
 			svc_xprt_received(xprt);
@@ -1006,6 +1003,8 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	}
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
+	dr->reserved_space = rqstp->rq_reserved;
+	svc_reserve(rqstp, 0);
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;
@@ -1018,6 +1017,7 @@ static int svc_deferred_recv(struct svc_rqst *rqstp)
 {
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
+	svc_reserve(rqstp, dr->reserved_space);
 	/* setup iov_base past transport header */
 	rqstp->rq_arg.head[0].iov_base = dr->args + (dr->xprt_hlen>>2);
 	/* The iov_len does not include the transport header bytes */

