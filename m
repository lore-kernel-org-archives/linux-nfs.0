Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63557 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980AbaCCQN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Mar 2014 11:13:56 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s23GDsBu011945
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 3 Mar 2014 11:13:56 -0500
Date: Mon, 3 Mar 2014 11:13:52 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC] Add simple backoff logic when reconnecting to a
 server that recently initiated a connection close
Message-ID: <20140303111352.736a7268@tlielax.poochiereds.net>
In-Reply-To: <20140228222956.GA1544@tonberry.usersys.redhat.com>
References: <20140228222956.GA1544@tonberry.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 28 Feb 2014 17:29:56 -0500
Scott Mayhew <smayhew@redhat.com> wrote:

> From 2e3902fc0c66bda360a8e40e3e64d82e312a20d4 Mon Sep 17 00:00:00 2001
> From: Scott Mayhew <smayhew@redhat.com>
> Date: Fri, 28 Feb 2014 15:23:50 -0500
> Subject: [PATCH] sunrpc: reintroduce xprt->shutdown with a new purpose (option
>  2)
> 
> If a server is behaving pathologically and accepting our connections
> only to close the socket on the first RPC operation it receives, then
> we should probably delay when trying to reconnect.
> 
> This patch reintroduces the xprt->shutdown field (this time as two
> bits).  Previously this field was used to indicate that the transport
> was in the process of being shutdown, but now it will just be used to
> indicate that a shutdown was initiated by the server.
> 
> If the server closes the connection 3 times without us having received
> an RPC reply in the interim, then we'll delay before attempting to
> connect again.
> ---
>  include/linux/sunrpc/xprt.h |  3 ++-
>  net/sunrpc/clnt.c           |  2 ++
>  net/sunrpc/xprtsock.c       | 13 +++++++++++++
>  3 files changed, 17 insertions(+), 1 deletion(-)
> 

This patch seems a little more reasonable than the other one if only
because it shouldn't cause artificial delays when there is some
temporary hiccup that causes the server to shut down the connection.

That said, this seems to be squarely a server-side bug so I'm not sure
we ought to go to any great lengths to work around it.

> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 8097b9d..621d583 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -173,7 +173,8 @@ struct rpc_xprt {
>  	unsigned int		min_reqs;	/* min number of slots */
>  	atomic_t		num_reqs;	/* total slots */
>  	unsigned long		state;		/* transport state */
> -	unsigned char		resvport   : 1; /* use a reserved port */
> +	unsigned char		shutdown   : 2, /* server initiated a shutdown */
> +				resvport   : 1; /* use a reserved port */

Hrm 2 bits...so you can go from 0..3. What happens when that wraps? I'd
be a little concerned that it might spill over into other bitfields
when that occurs. The K&R book seems to indicate that bitfield
semantics aren't well-defined so I'm not sure if that would happen or
not...

Even if it is safe, since this is only two bits, you'll only hit the
delay on non-zero multiples of '3', right? I don't think that's what
you're aiming for here.

So, it might be best not to use a bit-field there and use something
like a full char or something.

Also (nit) since "shutdown" used to have a completely different
meaning, I'd suggest not reusing that name. It'll be confusing for
people looking at old and new code. Maybe something like
"server_shutdowns" for the counter or something?

>  	unsigned int		swapper;	/* we're swapping over this
>  						   transport */
>  	unsigned int		bind_index;	/* bind function index */
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 0edada9..c32de98 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -515,6 +515,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
>  	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
>  		xprt->resvport = 0;
>  
> +	xprt->shutdown = 0;
> +
>  	clnt = rpc_new_client(args, xprt, NULL);
>  	if (IS_ERR(clnt))
>  		return clnt;
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 0addefc..35cdb63 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1295,6 +1295,7 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
>  		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
>  
>  	spin_unlock(&xprt->transport_lock);
> +	xprt->shutdown = 0;
>  	return 0;
>  }
>  
> @@ -1572,6 +1573,7 @@ static void xs_tcp_state_change(struct sock *sk)
>  	case TCP_CLOSE_WAIT:
>  		/* The server initiated a shutdown of the socket */
>  		xprt->connect_cookie++;
> +		xprt->shutdown++;
>  		clear_bit(XPRT_CONNECTED, &xprt->state);
>  		xs_tcp_force_close(xprt);
>  	case TCP_CLOSING:
> @@ -2332,6 +2334,17 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
>  			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
>  		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
>  			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
> +	} else if (xprt->shutdown > 2) {
> +		dprintk("RPC:       server previously initiated shutdown of the "
> +				"transport socket %d times\n", xprt->shutdown);
> +		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
> +			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
> +		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
> +				"seconds\n",
> +				xprt, xprt->reestablish_timeout / HZ);
> +		queue_delayed_work(rpciod_workqueue,
> +				   &transport->connect_worker,
> +				   xprt->reestablish_timeout);
>  	} else {
>  		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
>  		queue_delayed_work(rpciod_workqueue,


-- 
Jeff Layton <jlayton@redhat.com>
