From: Ben Myers <bpm@sgi.com>
Subject: [PATCH] sunrpc: xprt is not connected until after sock is set
Date: Fri, 27 Feb 2009 17:54:34 -0600
Message-ID: <20090227235434.GH15475@sgi.com>
References: <20090223201108.GB3308@merfinllc.com> <20090225023900.GD15475@sgi.com> <20090226001744.GB7613@merfinllc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, neilb@suse.de,
	Trond.Myklebust@netapp.com
To: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:48161 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752514AbZB0Xwk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Feb 2009 18:52:40 -0500
In-Reply-To: <20090226001744.GB7613-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Aaron,

I'm just getting back to this.

On Wed, Feb 25, 2009 at 04:17:45PM -0800, Aaron Straus wrote:
> Quick question, do we need a barrier between setting the transport->sock
> and the xprt_set_connected(xprt)?

Yeah, looks that way.  That was some interesting reading.  Here is the
patch as it stands now.  Hopefully I got that right.  This has
apparently fixed the problem on ia64 even with out the barriers.  rpciod
racing with a write.

> Also, out of curiosity, do you know what changed to introduce the BUG?

I haven't looked into that.

Bruce, can you take this patch?  I understand that you're the
maintainer?

Thanks!
	Ben

xs_sendpages() returned -ENOTCONN to xs_udp_send_request() and we tried to
clear a bit in transport->sock->flags when sock hadn't been set.  With this
change we will instead return earlier in xprt_prepare_transmit() and the rpc
will be retried.
---
 include/linux/sunrpc/xprt.h |    9 ++++++++-
 net/sunrpc/xprtsock.c       |    3 +--
 2 files changed, 9 insertions(+), 3 deletions(-)

Index: linux-2.6.27.15-2/include/linux/sunrpc/xprt.h
===================================================================
--- linux-2.6.27.15-2.orig/include/linux/sunrpc/xprt.h
+++ linux-2.6.27.15-2/include/linux/sunrpc/xprt.h
@@ -266,17 +266,24 @@ int			xs_swapper(struct rpc_xprt *xprt,
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
+	smp_wmb();
 	set_bit(XPRT_CONNECTED, &xprt->state);
 }
 
 static inline void xprt_clear_connected(struct rpc_xprt *xprt)
 {
 	clear_bit(XPRT_CONNECTED, &xprt->state);
+	smp_wmb();
 }
 
 static inline int xprt_connected(struct rpc_xprt *xprt)
 {
-	return test_bit(XPRT_CONNECTED, &xprt->state);
+	int	connected;
+
+	connected = test_bit(XPRT_CONNECTED, &xprt->state);
+	smp_rmb();
+
+	return connected;
 }
 
 static inline int xprt_test_and_set_connected(struct rpc_xprt *xprt)
Index: linux-2.6.27.15-2/net/sunrpc/xprtsock.c
===================================================================
--- linux-2.6.27.15-2.orig/net/sunrpc/xprtsock.c
+++ linux-2.6.27.15-2/net/sunrpc/xprtsock.c
@@ -1512,14 +1512,13 @@ static void xs_udp_finish_connecting(str
 		sk->sk_no_check = UDP_CSUM_NORCV;
 		sk->sk_allocation = GFP_ATOMIC;
 
-		xprt_set_connected(xprt);
-
 		/* Reset to new socket */
 		transport->sock = sock;
 		transport->inet = sk;
 
 		xs_set_memalloc(xprt);
 
+		xprt_set_connected(xprt);
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);


