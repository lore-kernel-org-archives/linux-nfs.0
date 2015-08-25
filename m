Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:50978 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbbHYPQR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2015 11:16:17 -0400
Date: Tue, 25 Aug 2015 17:16:14 +0200
From: Guillaume Morin <guillaume@morinfr.org>
To: Chuck Lever <chucklever@gmail.com>,
        Guillaume Morin <guillaume@morinfr.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chris Mason <clm@fb.com>
Subject: Re: [BUG] nfs3 client stops retrying to connect
Message-ID: <20150825151614.GA31127@bender.morinfr.org>
References: <20150521012155.GA19680@bender.morinfr.org>
 <DAF3CB64-5777-4F74-A31E-4F3FE55D14AD@gmail.com>
 <20150604200621.GA10335@bender.morinfr.org>
 <1E6DAEB8-754B-4F88-8301-4A1A9134922A@gmail.com>
 <20150604221404.GA20363@bender.morinfr.org>
 <22109174-5489-46AB-8C0A-62840D63DC97@gmail.com>
 <20150608171006.GA13396@bender.morinfr.org>
 <21A8A567-1EB4-4E3A-8DB8-BD07212044D0@gmail.com>
 <20150608181210.GA18244@bender.morinfr.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150608181210.GA18244@bender.morinfr.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08 Jun 20:12, Guillaume Morin wrote:
>
> On 08 Jun 13:50, Chuck Lever wrote:
> > The linger timer is started by FIN_WAIT1 or LAST_ACK, and
> > xs_tcp_schedule_linger_timeout sets XPRT_CONNECTING and
> > XPRT_CONNECTION_ABORT.
> > 
> > At a guess there could be a race between xs_tcp_cancel_linger_timeout
> > and the connect worker clearing those flags.
> 
> The connect worker is xs_tcp_setup_socket().  It clears the connecting
> bit in all code paths.  So the only kind of race I can see here is
> another function cancelling it before it runs without clearing the bit.
> 
> xs_tcp_cancel_linger_timeout() does the right thing afaict.  It clears
> the bit if cancel_delayed_work() returns a non-zero value.
> 
> The only other place where the worker is cancelled is xs_close() but it
> does not clear the bit. So if it cancels the worker before it had
> started running, the bit will stay up.

FWIW I patched our production kernel a couple months ago to clear the
connecting bit in xs_close(). Since then we've had a few nfs server
downtime and the problem has never reoccured while before the change we
always had a few machines that could not reconnect.  I feel fairly
confident this was the bug.

I am posting the change in case it helps someone running one of the
stable kernels

    sunrpc: call xprt_clear_connecting in xs_close
    
    It closes the race where the CONNECTING bit in the xprt
    is left on while the kernel is not trying to connect

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 41c2f9d..1b71c59 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -891,6 +891,7 @@ static void xs_close(struct rpc_xprt *xprt)
 	dprintk("RPC:       xs_close xprt %p\n", xprt);
 
 	cancel_delayed_work_sync(&transport->connect_worker);
+	xprt_clear_connecting(xprt);
 
 	xs_reset_transport(transport);
 	xprt->reestablish_timeout = 0;


Another option would be is to call clear_bit a few lines later but
clear_bit is never used for CONNECTING so I went with this.

-- 
Guillaume Morin <guillaume@morinfr.org>
