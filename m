From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [PATCH] sunrpc: xprt is not connected until after sock is set
Date: Fri, 27 Feb 2009 21:07:08 -0800
Message-ID: <20090228050707.GB22330@merfinllc.com>
References: <20090223201108.GB3308@merfinllc.com> <20090225023900.GD15475@sgi.com> <20090226001744.GB7613@merfinllc.com> <20090227235434.GH15475@sgi.com> <1235781463.20549.33.camel@heimdal.trondhjem.org> <20090228013457.GF7706@merfinllc.com> <1235785237.20549.51.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Myers <bpm@sgi.com>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org, neilb@suse.de
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:57046 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750735AbZB1FHJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Feb 2009 00:07:09 -0500
In-Reply-To: <1235785237.20549.51.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 27 08:40 PM, Trond Myklebust wrote:
> > > >  static inline int xprt_test_and_set_connected(struct rpc_xprt *xprt)
> > > > Index: linux-2.6.27.15-2/net/sunrpc/xprtsock.c
> > > > ===================================================================
> > > > --- linux-2.6.27.15-2.orig/net/sunrpc/xprtsock.c
> > > > +++ linux-2.6.27.15-2/net/sunrpc/xprtsock.c
> > > > @@ -1512,14 +1512,13 @@ static void xs_udp_finish_connecting(str
> > > >  		sk->sk_no_check = UDP_CSUM_NORCV;
> > > >  		sk->sk_allocation = GFP_ATOMIC;
> > > >  
> > > > -		xprt_set_connected(xprt);
> > > > -
> > > >  		/* Reset to new socket */
> > > >  		transport->sock = sock;
> > > >  		transport->inet = sk;
> > > >  
> > > >  		xs_set_memalloc(xprt);
> > > >  
> > > > +		xprt_set_connected(xprt);
> > > >  		write_unlock_bh(&sk->sk_callback_lock);
> > > >  	}
> > > >  	xs_udp_do_set_buffer_size(xprt);
> > > 
> > 
> > @@ -588,19 +603,20 @@ static int xs_udp_send_request(struct rpc_task *task)
> >  	}
> >  
> >  	switch (status) {
> > +	case -EAGAIN:
> > +		xs_nospace(task);
> > +		break;
> >  	case -ENETUNREACH:
> >  	case -EPIPE:
> >  	case -ECONNREFUSED:
> >  		/* When the server has died, an ICMP port unreachable message
> >  		 * prompts ECONNREFUSED. */
> > -		break;
> > -	case -EAGAIN:
> > -		xs_nospace(task);
> > +		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
> >  		break;
> >  	default:
> > +		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
> >  		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
> >  			-status);
> > -		break;
> >  	}
> >  
> >  	return status;
> > 
> > This went in to 2.6.26 which was the first time we saw the bug
> > (2.6.26.3) on kerneloops.
> > 
> > I don't know if *this* is a bad commit or some other locking changed in
> > 2.6.26 which tickles the bug.
> 
> It should be unrelated. If the client managed to get past the call to
> xs_sendpages(), then the UDP socket must obviously exist already.

PS just to repeat the previous discussion.  

It seems like xs_sendpages does check if sock is NULL and returns
-ENOTCONN in that case.

The problem is that now in xs_udp_send_request falls into the default:
section of that switch statement and tries to do the:

> > +		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);

but sock is NULL, so I think that's the oops.


Anyway, that's why Ben thinks we need to move xprt_set_connected() down
(past the setting of transport->sock) in xs_udp_finish_connecting().  

I was worried without a barrier xprt_set_connected() could just move
back up before the setting of transport->sock again either by compiler
or CPU reordering.

Anyway that's where we are....

thanks!

					=a=




-- 
===================
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org
