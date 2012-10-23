Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:53308 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933053Ab2JWNp5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2012 09:45:57 -0400
Received: by mail-yh0-f46.google.com with SMTP id m54so700694yhm.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2012 06:45:57 -0700 (PDT)
Date: Tue, 23 Oct 2012 09:45:51 -0400
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RPC Race Condition
Message-ID: <20121023134551.GB27191@nyc-qws-132.nyc.delacy.com>
References: <20121022180339.GC24763@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909289403@SACEXCMBX04-PRD.hq.netapp.com>
 <20121022202611.GA27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928AB39@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90928AB39@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 22, 2012 at 09:20:34PM +0000, Myklebust, Trond wrote:
> > This is what I changed:
> > 
> > --- a/net/sunrpc/xprtsock.c     2012-08-14 08:47:16.000000000 -0400
> > +++ b/net/sunrpc/xprtsock.c     2012-10-22 14:50:09.237725498 -0400
> > @@ -1571,7 +1571,8 @@
> >         dprintk("RPC:       %s client %p...\n"
> >                         "RPC:       error %d\n",
> >                         __func__, xprt, sk->sk_err);
> > -       xprt_wake_pending_tasks(xprt, -EAGAIN);
> > +       if (!xprt_connecting(xprt))
> > +               xprt_wake_pending_tasks(xprt, -EAGAIN);
> >  out:
> >         read_unlock_bh(&sk->sk_callback_lock);
> >  }
> > 
> > Unfortunately it does not resolve it.  It appears that does stop the wakeup
> > from happening where I detailed it before, but we still wake up too early.  The
> > following is the call stack from SystemTap catching the call to `rpc_make_runnable':
> > 
> >  0xffffffffa0434840 : rpc_make_runnable+0x0/0x80 [sunrpc]
> >  0xffffffffa0434b5e : rpc_wake_up_task_queue_locked+0x18e/0x270 [sunrpc]
> >  0xffffffffa0434c8e : rpc_wake_up_status+0x4e/0x80 [sunrpc]
> >  0xffffffffa042d8ec : xprt_wake_pending_tasks+0x2c/0x30 [sunrpc]
> >  0xffffffffa042da56 : xprt_disconnect_done+0x46/0x70 [sunrpc]
> >  0xffffffffa04305b0 : xs_tcp_setup_socket+0x330/0x4c0 [sunrpc]
> >  0xffffffff8108c760 : worker_thread+0x170/0x2a0 [kernel]
> >  0xffffffff81091d66 : kthread+0x96/0xa0 [kernel]
> >  0xffffffff8100c14a : child_rip+0xa/0x20 [kernel]
> > 
> > However, its mildly confusing to me since I cannot follow that exact
> > call stack in the code.  The nearest I can find to that is the
> > following:
> > 
> >   rpc_make_runnable
> >   rpc_wake_up_task_queue_locked
> >   rpc_wake_up_status
> >   xprt_wake_pending_tasks
> >   xprt_disconnect_done
> >   xs_sock_mark_closed
> >   xs_abort_connection
> >   xs_tcp_reuse_connection
> >   xs_tcp_setup_socket
> > 
> > As far as I can tell, we get here because the call to `kernel_connect'
> > from within `xs_abort_connection' by rpciod is returning 0 sometimes
> > (and EINPROGRESS others).  When it returns 0, we enter this block:
> > 
> >   if (!result)
> >           xs_sock_mark_closed(&transport->xprt);
> >   else
> >     dprintk("RPC:       AF_UNSPEC connect return code %d\n", result);
> > 
> > and that eventually gets us woken up via the call stack above.  The end
> > result is the same, we wake up and move on to `call_transmit' before
> > rpciod is done connecting the socket.
> > 
> > I'll do some more tracing and see what else I can come up with.
> > 
> > Chris
> 
> OK, then let's just get rid of xs_error_report(). All the cases that we
> care about will call tcp_done(), which will induce a state change when
> needed.
> 
> Cheers,
>   Trond
> 8<---------------------------------------------------------------------
> From 047ee9ea072698f1d35573c1f26dc02d13a4af7f Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Mon, 22 Oct 2012 17:14:36 -0400
> Subject: [PATCH] SUNRPC: Get rid of the xs_error_report socket callback
> 
> Chris Perl reports that we're seeing races between the wakeup call in
> xs_error_report and the connect attempts. Basically, Chris has shown
> that in certain circumstances, the call to xs_error_report causes the
> rpc_task that is responsible for reconnecting to wake up early, thus
> triggering a disconnect and retry.
> 
> Since the sk->sk_error_report() calls in the socket layer are always
> followed by a tcp_done() in the cases where we care about waking up
> the rpc_tasks, just let the state_change callbacks take responsibility
> for those wake ups.
> 
> Reported-by: Chris Perl <chris.perl@gmail.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  net/sunrpc/xprtsock.c | 25 -------------------------
>  1 file changed, 25 deletions(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index aaaadfb..89bde21 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -254,7 +254,6 @@ struct sock_xprt {
>  	void			(*old_data_ready)(struct sock *, int);
>  	void			(*old_state_change)(struct sock *);
>  	void			(*old_write_space)(struct sock *);
> -	void			(*old_error_report)(struct sock *);
>  };
>  
>  /*
> @@ -781,7 +780,6 @@ static void xs_save_old_callbacks(struct sock_xprt *transport, struct sock *sk)
>  	transport->old_data_ready = sk->sk_data_ready;
>  	transport->old_state_change = sk->sk_state_change;
>  	transport->old_write_space = sk->sk_write_space;
> -	transport->old_error_report = sk->sk_error_report;
>  }
>  
>  static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *sk)
> @@ -789,7 +787,6 @@ static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *s
>  	sk->sk_data_ready = transport->old_data_ready;
>  	sk->sk_state_change = transport->old_state_change;
>  	sk->sk_write_space = transport->old_write_space;
> -	sk->sk_error_report = transport->old_error_report;
>  }
>  
>  static void xs_reset_transport(struct sock_xprt *transport)
> @@ -1540,25 +1537,6 @@ static void xs_tcp_state_change(struct sock *sk)
>  	read_unlock_bh(&sk->sk_callback_lock);
>  }
>  
> -/**
> - * xs_error_report - callback mainly for catching socket errors
> - * @sk: socket
> - */
> -static void xs_error_report(struct sock *sk)
> -{
> -	struct rpc_xprt *xprt;
> -
> -	read_lock_bh(&sk->sk_callback_lock);
> -	if (!(xprt = xprt_from_sock(sk)))
> -		goto out;
> -	dprintk("RPC:       %s client %p...\n"
> -			"RPC:       error %d\n",
> -			__func__, xprt, sk->sk_err);
> -	xprt_wake_pending_tasks(xprt, -EAGAIN);
> -out:
> -	read_unlock_bh(&sk->sk_callback_lock);
> -}
> -
>  static void xs_write_space(struct sock *sk)
>  {
>  	struct socket *sock;
> @@ -1858,7 +1836,6 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
>  		sk->sk_user_data = xprt;
>  		sk->sk_data_ready = xs_local_data_ready;
>  		sk->sk_write_space = xs_udp_write_space;
> -		sk->sk_error_report = xs_error_report;
>  		sk->sk_allocation = GFP_ATOMIC;
>  
>  		xprt_clear_connected(xprt);
> @@ -1983,7 +1960,6 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>  		sk->sk_user_data = xprt;
>  		sk->sk_data_ready = xs_udp_data_ready;
>  		sk->sk_write_space = xs_udp_write_space;
> -		sk->sk_error_report = xs_error_report;
>  		sk->sk_no_check = UDP_CSUM_NORCV;
>  		sk->sk_allocation = GFP_ATOMIC;
>  
> @@ -2098,7 +2074,6 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>  		sk->sk_data_ready = xs_tcp_data_ready;
>  		sk->sk_state_change = xs_tcp_state_change;
>  		sk->sk_write_space = xs_tcp_write_space;
> -		sk->sk_error_report = xs_error_report;
>  		sk->sk_allocation = GFP_ATOMIC;
>  
>  		/* socket options */

Hi Trond,

First, thanks for being so responsive!  I never expected to get such
quick feedback and help.

I think perhaps you misread my last email.  Adding the check for
`xprt_connecting(xprt)' to `xs_error_report' _did_ stop the early wake
up from happening at that point in the code.  Removing the
entire call back with your patch works just as well.

I have confirmed that I can still reproduce the problem with this
patch.

Now that we're not waking up early because of `xs_error_report', we're
waking up early in another part of the code as I mentioned above.  I'm
not entirely clear about all the details here yet.

What I do know is that we're woken up with `tk_status' set to EGAIN, and
since `call_connect_status' doesn't do anything special for that, we move
on to `call_transmit'.  Meanwhile, rpciod is still trying to connect the
socket (eventually succeeding) and so we're racing.

Question: should `call_connect_status' treat EAGAIN specially and reset
`tk_action' to `call_connect' again (rather than just moving on to
`call_transmit')?  I don't think this alone would fix things properly,
but seems logical to me.  Perhaps I'm missing something.

Chris
