Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0198.hostedemail.com ([216.40.44.198]:47717 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754796AbbFTB1K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 21:27:10 -0400
Date: Fri, 19 Jun 2015 21:27:06 -0400
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
Message-ID: <20150619212706.2f13a44e@gandalf.local.home>
In-Reply-To: <1434756359.8498.2.camel@primarydata.com>
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
	<20150619181440.22f54e6a@gandalf.local.home>
	<1434756359.8498.2.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Jun 2015 19:25:59 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:


> 8<--------------------------------------------------------------
> >From 4876cc779ff525b9c2376d8076edf47815e71f2c Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Fri, 19 Jun 2015 16:17:57 -0400
> Subject: [PATCH v2] SUNRPC: Ensure we release the TCP socket once it has been
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

Is there a way to test RPC traffic resuming? I'd like to try that before
declaring this bug harmless.

> 
> Reported-by: Steven Rostedt <rostedt@goodmis.org>

The problem appears to go away with this patch.

Tested-by: Steven Rostedt <rostedt@goodmis.org>

Thanks a lot!

-- Steve

> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprt.c     |  2 +-
>  net/sunrpc/xprtsock.c | 40 ++++++++++++++++++++++------------------
>  2 files changed, 23 insertions(+), 19 deletions(-)
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
> index fda8ec8c74c0..ee0715dfc3c7 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -623,24 +623,6 @@ process_status:
>  }
>  
>  /**
> - * xs_tcp_shutdown - gracefully shut down a TCP socket
> - * @xprt: transport
> - *
> - * Initiates a graceful shutdown of the TCP socket by calling the
> - * equivalent of shutdown(SHUT_RDWR);
> - */
> -static void xs_tcp_shutdown(struct rpc_xprt *xprt)
> -{
> -	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> -	struct socket *sock = transport->sock;
> -
> -	if (sock != NULL) {
> -		kernel_sock_shutdown(sock, SHUT_RDWR);
> -		trace_rpc_socket_shutdown(xprt, sock);
> -	}
> -}
> -
> -/**
>   * xs_tcp_send_request - write an RPC request to a TCP socket
>   * @task: address of RPC task that manages the state of an RPC request
>   *
> @@ -786,6 +768,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
>  	xs_sock_reset_connection_flags(xprt);
>  	/* Mark transport as closed and wake up all pending tasks */
>  	xprt_disconnect_done(xprt);
> +	xprt_force_disconnect(xprt);
>  }
>  
>  /**
> @@ -2103,6 +2086,27 @@ out:
>  	xprt_wake_pending_tasks(xprt, status);
>  }
>  
> +/**
> + * xs_tcp_shutdown - gracefully shut down a TCP socket
> + * @xprt: transport
> + *
> + * Initiates a graceful shutdown of the TCP socket by calling the
> + * equivalent of shutdown(SHUT_RDWR);
> + */
> +static void xs_tcp_shutdown(struct rpc_xprt *xprt)
> +{
> +	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> +	struct socket *sock = transport->sock;
> +
> +	if (sock == NULL)
> +		return;
> +	if (xprt_connected(xprt)) {
> +		kernel_sock_shutdown(sock, SHUT_RDWR);
> +		trace_rpc_socket_shutdown(xprt, sock);
> +	} else
> +		xs_reset_transport(transport);
> +}
> +
>  static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>  {
>  	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
