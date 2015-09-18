Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:33908 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051AbbIRQv6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Sep 2015 12:51:58 -0400
Received: by ykdg206 with SMTP id g206so51945215ykd.1
        for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2015 09:51:57 -0700 (PDT)
Message-ID: <1442595095.11370.13.camel@primarydata.com>
Subject: Re: [PATCHv2] SUNRPC: Fix a race in xs_reset_transport
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Marc Zyngier <Marc.Zyngier@arm.com>
Date: Fri, 18 Sep 2015 12:51:35 -0400
In-Reply-To: <55FBF32C.7030107@arm.com>
References: <1442394280-24280-1-git-send-email-suzuki.poulose@arm.com>
		<1442396149-24775-1-git-send-email-suzuki.poulose@arm.com>
	 <20150916071730.052af53d@tlielax.poochiereds.net>
	 <55FBF32C.7030107@arm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2015-09-18 at 12:19 +0100, Suzuki K. Poulose wrote:
> On 16/09/15 12:17, Jeff Layton wrote:
> > On Wed, 16 Sep 2015 10:35:49 +0100
> > "Suzuki K. Poulose" <suzuki.poulose@arm.com> wrote:
> > 
> > > From: "Suzuki K. Poulose" <suzuki.poulose@arm.com>
> > > 
> 
> ...
> 
> > > +		write_unlock_bh(&sk->sk_callback_lock);
> > > +		return;
> > > +	}
> > > +	sock = transport->sock;
> > > +
> > >   	transport->inet = NULL;
> > >   	transport->sock = NULL;
> > > 
> > > @@ -833,6 +838,10 @@ static void xs_reset_transport(struct
> > > sock_xprt *transport)
> > >   	xs_restore_old_callbacks(transport, sk);
> > >   	xprt_clear_connected(xprt);
> > >   	write_unlock_bh(&sk->sk_callback_lock);
> > > +
> > > +	if (sock)
> > > +		kernel_sock_shutdown(sock, SHUT_RDWR);
> > > +
> > >   	xs_sock_reset_connection_flags(xprt);
> > > 
> > >   	trace_rpc_socket_close(xprt, sock);
> > 
> > Better, but now I'm wondering...is it problematic to restore the
> > old
> > callbacks before calling kernel_sock_shutdown? I can't quite tell
> > whether it matters in all cases.
> > 
> > It might be best to just go ahead and take the spinlock twice here.
> > Do
> > it once to clear the transport->sock pointer, call
> > kernel_sock_shutdown, and then take it again to restore the old
> > callbacks, etc.
> > 
> > I don't know though...I get the feeling there are races all over
> > the
> > place in this code. It seems like there's a similar one wrt to the
> > transport->inet pointer. It seems a little silly that we clear it
> > under
> > the sk->sk_callback_lock. You have to dereference that pointer
> > in order to get to the lock.
> > 
> > Maybe the right solution is to use an xchg to swap the inet pointer
> > with NULL so it can act as a gatekeeper. Whoever gets there first
> > does
> > the rest of the shutdown.
> > 
> > Something like this maybe? Would this also fix the original
> > problem?
> > Note that this patch is untested...
> > 
> > [PATCH] sunrpc: use xchg to fetch and clear the transport->inet
> > pointer in xs_reset_transport
> > 
> > Reported-by: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> >   net/sunrpc/xprtsock.c | 4 ++--
> >   1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 7be90bc1a7c2..57f79dcab493 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -813,9 +813,10 @@ static void xs_error_report(struct sock *sk)
> >   static void xs_reset_transport(struct sock_xprt *transport)
> >   {
> >   	struct socket *sock = transport->sock;
> > -	struct sock *sk = transport->inet;
> > +	struct sock *sk;
> >   	struct rpc_xprt *xprt = &transport->xprt;
> > 
> > +	sk = xchg(&transport->inet, NULL);
> >   	if (sk == NULL)
> >   		return;
> > 
> > @@ -825,7 +826,6 @@ static void xs_reset_transport(struct sock_xprt
> > *transport)
> >   	kernel_sock_shutdown(sock, SHUT_RDWR);
> > 
> >   	write_lock_bh(&sk->sk_callback_lock);
> > -	transport->inet = NULL;
> >   	transport->sock = NULL;
> > 
> >   	sk->sk_user_data = NULL;
> > 
> 
> 
> This one seemed to fix it, so if it matters :
> 
> Tested-by: Suzuki K. Poulose <suzuki.poulose@arm.com>


I don't think it does. It addresses a symptom, but the actual problem
is that we're running 2 parallel close() calls on the same socket
during a shutdown. That must not happen because it means we have
something else trying to use the socket while it is being freed.

I think what is happening is that we're triggering the socket autoclose
mechanism from the state change callback. You're seeing the problem
more frequently because we added the call to kernel_sock_shutdown() as
part of the socket shutdown, but AFAICS, it could still be triggered
from some external event such as a server-initiated shutdown that
happened at the same time.
In fact, looking at the code, it could even be triggered from the data
receive side of things.
Both of these things are bad, because autoclose puts the transport
struct that is being freed onto a workqueue. That again can lead to a
really bad use-after-free situation if the timing is just a little
different.

So how about the following patch? It should apply cleanly on top of the
first one (which is still needed, btw).

8<--------------------------------------------------------------------
