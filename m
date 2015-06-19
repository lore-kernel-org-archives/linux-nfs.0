Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0069.hostedemail.com ([216.40.44.69]:40191 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753326AbbFSV4e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 17:56:34 -0400
Date: Fri, 19 Jun 2015 17:56:28 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bruce James Fields <bfields@fieldses.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Message-ID: <20150619175628.31e62ef7@gandalf.local.home>
In-Reply-To: <1434745818.8838.1.camel@primarydata.com>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
	<20150618185051.2b2828c3@tlielax.poochiereds.net>
	<20150618210843.4b09c31c@grimm.local.home>
	<20150618213702.33f64b20@synchrony.poochiereds.net>
	<20150619122553.43d2d86c@gandalf.local.home>
	<20150619131759.7b38d9de@gandalf.local.home>
	<CAHQdGtRCYoeToxyDHjnd+6f40J8SrScmQKKOW5O8AzJo3NefAA@mail.gmail.com>
	<20150619155226.7c5d6637@synchrony.poochiereds.net>
	<1434745818.8838.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Jun 2015 16:30:18 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Steven, how about something like the following patch?

Building it now. Will let you know in a bit.


> 
> 8<-----------------------------------------------------------------
> >From 9a0bcfdbdbc793eae1ed6d901a6396b6c66f9513 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Fri, 19 Jun 2015 16:17:57 -0400
> Subject: [PATCH] SUNRPC: Ensure we release the TCP socket once it has been
>  closed
> 
> This fixes a regression introduced by commit caf4ccd4e88cf2 ("SUNRPC:
> Make xs_tcp_close() do a socket shutdown rather than a sock_release").
> Prior to that commit, the autoclose feature would ensure that an
> idle connection would result in the socket being both disconnected and
> released, whereas now only gets disconnected.
> 
> While the current behaviour is harmless, it does leave the port bound
> until either RPC traffic resumes or the RPC client is shut down.

Hmm, is this true? The port is bound, but the socket has been freed.
That is sk->sk_socket points to garbage. As my portlist.c module
verified.

It doesn't seem that anything can attach to that port again that I
know of. Is there a way to verify that something can attach to it again?

-- Steve


> 
> Reported-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprt.c     | 2 +-
>  net/sunrpc/xprtsock.c | 8 ++++++--
>  2 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 3ca31f20b97c..ab5dd621ae0c 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -611,8 +611,8 @@ static void xprt_autoclose(struct work_struct *work)
>  	struct rpc_xprt *xprt =
>  		container_of(work, struct rpc_xprt, task_cleanup);
>  
> -	xprt->ops->close(xprt);
>  	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> +	xprt->ops->close(xprt);
>  	xprt_release_write(xprt, NULL);
>  }
>  
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index fda8ec8c74c0..75dcdadf0269 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -634,10 +634,13 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
>  	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
>  	struct socket *sock = transport->sock;
>  
> -	if (sock != NULL) {
> +	if (sock == NULL)
> +		return;
> +	if (xprt_connected(xprt)) {
>  		kernel_sock_shutdown(sock, SHUT_RDWR);
>  		trace_rpc_socket_shutdown(xprt, sock);
> -	}
> +	} else
> +		xs_reset_transport(transport);
>  }
>  
>  /**
> @@ -786,6 +789,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
>  	xs_sock_reset_connection_flags(xprt);
>  	/* Mark transport as closed and wake up all pending tasks */
>  	xprt_disconnect_done(xprt);
> +	xprt_force_disconnect(xprt);
>  }
>  
>  /**

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
