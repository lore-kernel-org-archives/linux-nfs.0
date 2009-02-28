From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [PATCH] sunrpc: xprt is not connected until after sock is set
Date: Fri, 27 Feb 2009 17:34:57 -0800
Message-ID: <20090228013457.GF7706@merfinllc.com>
References: <20090223201108.GB3308@merfinllc.com> <20090225023900.GD15475@sgi.com> <20090226001744.GB7613@merfinllc.com> <20090227235434.GH15475@sgi.com> <1235781463.20549.33.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Myers <bpm@sgi.com>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org, neilb@suse.de
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:58520 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750905AbZB1Be7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2009 20:34:59 -0500
In-Reply-To: <1235781463.20549.33.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Feb 27 07:37 PM, Trond Myklebust wrote:
> NACK. If you need a memory barrier, put it in the UDP case only (and
> justify why). The TCP case sets and clears the above in the
> connect/disconnect softirqs and so does not require them.
> 
> I certainly see no reason whatsoever for adding memory barriers to
> xprt_connected() or xprt_clear_connected().
> 
> >  static inline int xprt_test_and_set_connected(struct rpc_xprt *xprt)
> > Index: linux-2.6.27.15-2/net/sunrpc/xprtsock.c
> > ===================================================================
> > --- linux-2.6.27.15-2.orig/net/sunrpc/xprtsock.c
> > +++ linux-2.6.27.15-2/net/sunrpc/xprtsock.c
> > @@ -1512,14 +1512,13 @@ static void xs_udp_finish_connecting(str
> >  		sk->sk_no_check = UDP_CSUM_NORCV;
> >  		sk->sk_allocation = GFP_ATOMIC;
> >  
> > -		xprt_set_connected(xprt);
> > -
> >  		/* Reset to new socket */
> >  		transport->sock = sock;
> >  		transport->inet = sk;
> >  
> >  		xs_set_memalloc(xprt);
> >  
> > +		xprt_set_connected(xprt);
> >  		write_unlock_bh(&sk->sk_callback_lock);
> >  	}
> >  	xs_udp_do_set_buffer_size(xprt);
> 
> Please move that call to xprt_set_connected() outside the if statement.
> We want to set the connected flag unconditionally here.

FYI, I've been digging a bit.  This commit adds the clearing of the
bits:

commit b6ddf64ffe9d59577a9176856bb6fe69a539f573
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Apr 17 18:52:19 2008 -0400

    SUNRPC: Fix up xprt_write_space()
    
<snip>

@@ -588,19 +603,20 @@ static int xs_udp_send_request(struct rpc_task *task)
 	}
 
 	switch (status) {
+	case -EAGAIN:
+		xs_nospace(task);
+		break;
 	case -ENETUNREACH:
 	case -EPIPE:
 	case -ECONNREFUSED:
 		/* When the server has died, an ICMP port unreachable message
 		 * prompts ECONNREFUSED. */
-		break;
-	case -EAGAIN:
-		xs_nospace(task);
+		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 		break;
 	default:
+		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
-		break;
 	}
 
 	return status;


This went in to 2.6.26 which was the first time we saw the bug
(2.6.26.3) on kerneloops.

I don't know if *this* is a bad commit or some other locking changed in
2.6.26 which tickles the bug.

Hope it helps.  Have a good weekend all!

				=a=

-- 
===================
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org
