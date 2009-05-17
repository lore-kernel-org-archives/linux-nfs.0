From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
 over NFS
Date: Sun, 17 May 2009 15:12:04 -0400
Message-ID: <1242587524.17796.3.camel@heimdal.trondhjem.org>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	 <20090508120119.8c93cfd7.akpm@linux-foundation.org>
	 <20090511081415.GL4694@kernel.dk>
	 <x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	 <20090511165826.GG4694@kernel.dk>
	 <x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	 <20090512204433.7eb69075.akpm@linux-foundation.org>
	 <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	 <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com>
	 <1242258338.5407.244.camel@heimdal.trondhjem.org>
	 <x49octv7qr8.fsf@segfault.boston.devel.redhat.com>
	 <1242311620.6560.14.camel@heimdal.trondhjem.org>
	 <x49ws8j686r.fsf@segfault.boston.devel.redhat.com>
	 <1242587454.17796.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1242587454.17796.2.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-05-17 at 15:11 -0400, Trond Myklebust wrote:
> On Thu, 2009-05-14 at 11:00 -0400, Jeff Moyer wrote:
> > Sorry for the previous, stupid question.  I applied the patch in
> > addition the last one and here are the results:
> > 
> > 70327
> > 71561
> > 68760
> > 69199
> > 65324
> > 
> > A packet capture for this run is available here:
> >   http://people.redhat.com/jmoyer/trond2.pcap.bz2
> > 
> > Any more ideas?  ;)
> 
> Yep. I've got 2 more patches for you. With both of them applied, I'm
> seeing decent performance on my own test rig. The first patch is
> appended. I'll send the second in another email (to avoid attachments).

Here is number 2. It is incremental to all the others...


-----------------------------------------------------------------------
>From 1d11caba8bcfc8fe718bfa9a957715bf3819af09 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sun, 17 May 2009 13:01:00 -0400
Subject: [PATCH] SUNRPC: Further congestion control tweaks...

Ensure that deferred requests are accounted for correctly by the write
space reservation mechanism. In order to avoid double counting, remove
the
reservation when we defer the request, and save any calculated value, so
that we can restore it when the request is requeued.

Also fix svc_tcp_has_wspace() so that it doesn't reserve twice the
memory
that we expect to require in order to write out the data.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc_xprt.c      |   10 +++++-----
 net/sunrpc/svcsock.c       |   19 +++++++------------
 3 files changed, 13 insertions(+), 17 deletions(-)

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
@@ -299,7 +299,6 @@ static void svc_thread_dequeue(struct svc_pool
*pool, struct svc_rqst *rqstp)
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
@@ -1006,6 +1003,8 @@ static struct cache_deferred_req *svc_defer(struct
cache_req *req)
 	}
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
+	dr->reserved_space = rqstp->rq_reserved;
+	svc_reserve(rqstp, 0);
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;
@@ -1018,6 +1017,7 @@ static int svc_deferred_recv(struct svc_rqst
*rqstp)
 {
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
+	svc_reserve(rqstp, dr->reserved_space);
 	/* setup iov_base past transport header */
 	rqstp->rq_arg.head[0].iov_base = dr->args + (dr->xprt_hlen>>2);
 	/* The iov_len does not include the transport header bytes */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 4837442..eed978e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -345,6 +345,7 @@ static void svc_sock_setbufsize(struct socket *sock,
unsigned int snd,
 	lock_sock(sock->sk);
 	sock->sk->sk_sndbuf = snd * 2;
 	sock->sk->sk_rcvbuf = rcv * 2;
+	sock->sk->sk_write_space(sock->sk);
 	release_sock(sock->sk);
 #endif
 }
@@ -626,6 +627,7 @@ static void svc_udp_init(struct svc_sock *svsk,
struct svc_serv *serv)
 	 * receive and respond to one request.
 	 * svc_udp_recvfrom will re-adjust if necessary
 	 */
+	svsk->sk_sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
 	svc_sock_setbufsize(svsk->sk_sock,
 			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
 			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
@@ -971,21 +973,14 @@ static void svc_tcp_prep_reply_hdr(struct svc_rqst
*rqstp)
 static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
-	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
-	int reserved;
+	struct svc_serv *serv = svsk->sk_xprt.xpt_server;
 	int required;
 
-	reserved = atomic_read(&xprt->xpt_reserved);
-	/* Always allow the server to process at least one request, whether
-	 * or not the TCP window is large enough
-	 */
-	if (reserved == 0)
+	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
+		return 1;
+	required = atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
+	if (sk_stream_wspace(svsk->sk_sk) >= required)
 		return 1;
-	required = (reserved + serv->sv_max_mesg) << 1;
-	if (sk_stream_wspace(svsk->sk_sk) < required)
-		goto out_nospace;
-	return 1;
-out_nospace:
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
 	return 0;
 }
-- 
1.6.0.4



