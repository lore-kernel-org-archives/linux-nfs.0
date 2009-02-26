From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: BUG NULL pointer dereference in SUNRPC xs_udp_send_request
Date: Wed, 25 Feb 2009 16:17:45 -0800
Message-ID: <20090226001744.GB7613@merfinllc.com>
References: <20090223201108.GB3308@merfinllc.com> <20090225023900.GD15475@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Trond.Myklebust@netapp.com
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:60795 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751066AbZBZARr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2009 19:17:47 -0500
In-Reply-To: <20090225023900.GD15475@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

Thanks for the response.

On Feb 24 08:39 PM, Ben Myers wrote:
> >   If I'm reading the trace correctly, it looks like this line of
> > xs_udp_send_request:
> > 
> >    clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
> 
> That's a coincidence.  I looked at a similar bug today that crashed on
> the same line but a different stack.  My suggestion is:
> 
> Index: linux/net/sunrpc/xprtsock.c
> ===================================================================
> --- linux.orig/net/sunrpc/xprtsock.c
> +++ linux/net/sunrpc/xprtsock.c
> @@ -1512,14 +1512,13 @@ static void xs_udp_finish_connecting(str
>                 sk->sk_no_check = UDP_CSUM_NORCV;
>                 sk->sk_allocation = GFP_ATOMIC;
> 
> -               xprt_set_connected(xprt);
> -
>                 /* Reset to new socket */
>                 transport->sock = sock;
>                 transport->inet = sk;
> 
>                 xs_set_memalloc(xprt);
> 
> +               xprt_set_connected(xprt);
>                 write_unlock_bh(&sk->sk_callback_lock);
>         }
>         xs_udp_do_set_buffer_size(xprt);
> 
> Looks like xs_sendpages() returned -ENOTCONN.  The above should sort
> that out by returning earlier in xprt_prepare_transmit() and the rpc
> would be retried by __rpc_execute().

I'll start running with it tonight to see if I can trigger the BUG
again (it was hard to hit).

Quick question, do we need a barrier between setting the transport->sock
and the xprt_set_connected(xprt)?  I don't really understand the locking
on the reader side, so I cannot say...

Also, out of curiosity, do you know what changed to introduce the BUG?

Kerneloops doesn't seem to know about it before 2.6.26.3:

  http://www.kerneloops.org/search.php?search=xs_udp_send_request&btnG=Function+Search

Anyway, thanks!

					=a=



-- 
===================
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org
