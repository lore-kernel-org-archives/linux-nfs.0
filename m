From: Ben Myers <bpm@sgi.com>
Subject: Re: BUG NULL pointer dereference in SUNRPC xs_udp_send_request
Date: Tue, 24 Feb 2009 20:39:00 -0600
Message-ID: <20090225023900.GD15475@sgi.com>
References: <20090223201108.GB3308@merfinllc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Trond.Myklebust@netapp.com
To: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:49334 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754321AbZBYChI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Feb 2009 21:37:08 -0500
In-Reply-To: <20090223201108.GB3308-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Aaron,

On Mon, Feb 23, 2009 at 12:11:09PM -0800, Aaron Straus wrote:
>   We received the trace below on one of our machines this weekend.   The
> machine is running vanilla 2.6.27.14.
> 
>   If I'm reading the trace correctly, it looks like this line of
> xs_udp_send_request:
> 
>    clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
> 
>   The machine is x86 (32-bit).  
> 
>   Please let me know if you need anything else e.g .config or full
> dmesg.  

That's a coincidence.  I looked at a similar bug today that crashed on
the same line but a different stack.  My suggestion is:

Index: linux/net/sunrpc/xprtsock.c
===================================================================
--- linux.orig/net/sunrpc/xprtsock.c
+++ linux/net/sunrpc/xprtsock.c
@@ -1512,14 +1512,13 @@ static void xs_udp_finish_connecting(str
                sk->sk_no_check = UDP_CSUM_NORCV;
                sk->sk_allocation = GFP_ATOMIC;

-               xprt_set_connected(xprt);
-
                /* Reset to new socket */
                transport->sock = sock;
                transport->inet = sk;

                xs_set_memalloc(xprt);

+               xprt_set_connected(xprt);
                write_unlock_bh(&sk->sk_callback_lock);
        }
        xs_udp_do_set_buffer_size(xprt);

Looks like xs_sendpages() returned -ENOTCONN.  The above should sort
that out by returning earlier in xprt_prepare_transmit() and the rpc
would be retried by __rpc_execute().

-ben
