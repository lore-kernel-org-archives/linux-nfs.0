Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45529 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756929Ab3AYSpY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2013 13:45:24 -0500
Date: Fri, 25 Jan 2013 13:45:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: sunrpc: socket buffer size tuneable
Message-ID: <20130125184522.GB29596@fieldses.org>
References: <20130125005930.GC30652@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130125005930.GC30652@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 24, 2013 at 06:59:30PM -0600, Ben Myers wrote:
> At 1020 threads the send buffer size wraps and becomes negative causing
> the nfs server to grind to a halt.

Actually this appears to be a problem in only one place:

> @@ -525,18 +575,17 @@ static int svc_udp_recvfrom(struct svc_r
>  	size_t len;
>  	int err;
>  
> -	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
> -	    /* udp sockets need large rcvbuf as all pending
> -	     * requests are still in that buffer.  sndbuf must
> -	     * also be large enough that there is enough space
> -	     * for one reply per thread.  We count all threads
> -	     * rather than threads in a particular pool, which
> -	     * provides an upper bound on the number of threads
> -	     * which will access the socket.
> -	     */
> -	    svc_sock_setbufsize(svsk->sk_sock,
> -				(serv->sv_nrthreads+3) * serv->sv_max_mesg,
> -				(serv->sv_nrthreads+3) * serv->sv_max_mesg);

Elsewhere it's not dependent on the number of threads:

>  	svc_sock_setbufsize(svsk->sk_sock,
> -			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
> -			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
...
> -		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
> -					4 * serv->sv_max_mesg);

Since sv_max_mesg is at most a megabyte, those won't overflow.

If you saw an overflow in the tcp case, I suspect that was with a kernel
before 9660439861aa8dbd5e2b8087f33e20760c2c9afc "svcrpc: take advantage
of tcp autotuning"?

Honestly I'm a bit mystified by the udp comment in the code above; do we
*really* need buffers that large?  And if so, why don't we set them to
that size at the start in svc_udp_init?

But in the udp case I'm inclined to do just the minimum to fix the
overflow and otherwise leave the code alone--it doesn't get as much use
and testing as it once did, so it's probably better to leave it alone.

So something like the below.

This still leaves the issue of tcp buffer size under memory pressure.

--b.

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0a148c9..f3a525c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -525,7 +525,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	size_t len;
 	int err;
 
-	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
+	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags)) {
 	    /* udp sockets need large rcvbuf as all pending
 	     * requests are still in that buffer.  sndbuf must
 	     * also be large enough that there is enough space
@@ -534,9 +534,13 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	     * provides an upper bound on the number of threads
 	     * which will access the socket.
 	     */
+	    unsigned int threads = serv->sv_nrthreads;
+	    /* arbitrary limit, mainly just to prevent overflow: */
+	    threads = min(threads, 128U);
 	    svc_sock_setbufsize(svsk->sk_sock,
-				(serv->sv_nrthreads+3) * serv->sv_max_mesg,
-				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
+				(threads+3) * serv->sv_max_mesg,
+				(threads+3) * serv->sv_max_mesg);
+	}
 
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	skb = NULL;
