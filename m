Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45747 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757504Ab3GYUSI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jul 2013 16:18:08 -0400
Date: Thu, 25 Jul 2013 16:18:05 -0400
From: "J.Bruce Fields" <bfields@citi.umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Ben Myers <bpm@sgi.com>, Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD/sunrpc: avoid deadlock on TCP connection due to
 memory pressure.
Message-ID: <20130725201805.GB17962@fieldses.org>
References: <20130710022735.GI8281@fieldses.org>
 <20130710143233.77e35721@notabene.brown>
 <20130710190727.GA22305@fieldses.org>
 <20130715143203.51bc583b@notabene.brown>
 <20130716015803.GA5271@fieldses.org>
 <20130716140021.312b5b07@notabene.brown>
 <20130716142430.GA11977@fieldses.org>
 <20130718000319.GL1681@sgi.com>
 <20130724210746.GB5777@fieldses.org>
 <20130725113023.7bcbc347@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130725113023.7bcbc347@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 25, 2013 at 11:30:23AM +1000, NeilBrown wrote:
> 
> Since we enabled auto-tuning for sunrpc TCP connections we do not
> guarantee that there is enough write-space on each connection to
> queue a reply.
> 
> If memory pressure causes the window to shrink too small, the request
> throttling in sunrpc/svc will not accept any requests so no more requests
> will be handled.  Even when pressure decreases the window will not
> grow again until data is sent on the connection.
> This means we get a deadlock:  no requests will be handled until there
> is more space, and no space will be allocated until a request is
> handled.
> 
> This can be simulated by modifying svc_tcp_has_wspace to inflate the
> number of byte required and removing the 'svc_sock_setbufsize' calls
> in svc_setup_socket.

Ah-hah!

> I found that multiplying by 16 was enough to make the requirement
> exceed the default allocation.  With this modification in place:
>    mount -o vers=3,proto=tcp 127.0.0.1:/home /mnt
> would block and eventually time out because the nfs server could not
> accept any requests.

So, this?:

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 305374d..36de50d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1193,6 +1193,7 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
 		return 1;
 	required = atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
+	required *= 16;
 	if (sk_stream_wspace(svsk->sk_sk) >= required)
 		return 1;
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
@@ -1378,14 +1379,8 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
 		svc_udp_init(svsk, serv);
-	else {
-		/* initialise setting must have enough space to
-		 * receive and respond to one request.
-		 */
-		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
-					4 * serv->sv_max_mesg);
+	else
 		svc_tcp_init(svsk, serv);
-	}
 
 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
 				svsk, svsk->sk_sk);

> This patch relaxes the request throttling to always allow at least one
> request through per connection.  It does this by checking both
>   sk_stream_min_wspace() and xprt->xpt_reserved
> are zero.
> The first is zero when the TCP transmit queue is empty.
> The second is zero when there are no RPC requests being processed.
> When both of these are zero the socket is idle and so one more
> request can safely be allowed through.
> 
> Applying this patch allows the above mount command to succeed cleanly.
> Tracing shows that the allocated write buffer space quickly grows and
> after a few requests are handled, the extra tests are no longer needed
> to permit further requests to be processed.
> 
> The main purpose of request throttling is to handle the case when one
> client is slow at collecting replies and the send queue gets full of
> replies that the client hasn't acknowledged (at the TCP level) yet.
> As we only change behaviour when the send queue is empty this main
> purpose is still preserved.
> 
> Reported-by: Ben Myers <bpm@sgi.com>
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> --
> As you can see I've changed the patch.  While writing up the above 
> description realised there was a weakness and so added the sk_stream_min_wspace
> test.  That allowed me to write the final paragraph.

This is great, thanks!

Inclined to queue it up for 3.11 and stable....

--b.

> 
> NeilBrown
> 
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 305374d..7762b9f 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1193,7 +1193,9 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
>  	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
>  		return 1;
>  	required = atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
> -	if (sk_stream_wspace(svsk->sk_sk) >= required)
> +	if (sk_stream_wspace(svsk->sk_sk) >= required ||
> +	    (sk_stream_min_wspace(svsk->sk_sk) == 0 &&
> +	     atomic_read(&xprt->xpt_reserved) == 0))
>  		return 1;
>  	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>  	return 0;


