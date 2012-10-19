Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24472 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755031Ab2JSUXI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2012 16:23:08 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: RE: [PATCH] SUNRPC: Set alloc_slot for backchannel tcp ops
Date: Fri, 19 Oct 2012 20:23:05 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9092851AD@SACEXCMBX04-PRD.hq.netapp.com>
References: <1348508341-19642-1-git-send-email-bjschuma@netapp.com>
 <20121019193951.GA30593@fieldses.org>
In-Reply-To: <20121019193951.GA30593@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Et tu Bruce?

Not yet, because if you check, neither has commit f39c1bfb5a (SUNRPC: Fix a UDP transport regression). I figured it is better to send them both together as a single patch.

Trond

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Friday, October 19, 2012 3:40 PM
> To: Schumaker, Bryan
> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; stable@vger.kernel.org
> Subject: Re: [PATCH] SUNRPC: Set alloc_slot for backchannel tcp ops
> 
> Did this not get sent to stable?  (Now upstream as
> 84e28a307e376f271505af65a7b7e212dd6f61f4.)
> 
> --b.
> 
> On Mon, Sep 24, 2012 at 01:39:01PM -0400, bjschuma@netapp.com wrote:
> > From: Bryan Schumaker <bjschuma@netapp.com>
> >
> > f39c1bfb5a03e2d255451bff05be0d7255298fa4 (SUNRPC: Fix a UDP
> transport
> > regression) introduced the "alloc_slot" function for xprt operations,
> > but never created one for the backchannel operations.  This patch
> > fixes a null pointer dereference when mounting NFS over v4.1.
> >
> > Call Trace:
> >  [<ffffffffa0207957>] ? xprt_reserve+0x47/0x50 [sunrpc]
> > [<ffffffffa02023a4>] call_reserve+0x34/0x60 [sunrpc]
> > [<ffffffffa020e280>] __rpc_execute+0x90/0x400 [sunrpc]
> > [<ffffffffa020e61a>] rpc_async_schedule+0x2a/0x40 [sunrpc]
> > [<ffffffff81073589>] process_one_work+0x139/0x500
> > [<ffffffff81070e70>] ? alloc_worker+0x70/0x70  [<ffffffffa020e5f0>] ?
> > __rpc_execute+0x400/0x400 [sunrpc]  [<ffffffff81073d1e>]
> > worker_thread+0x15e/0x460  [<ffffffff8145c839>] ?
> > preempt_schedule+0x49/0x70  [<ffffffff81073bc0>] ?
> > rescuer_thread+0x230/0x230  [<ffffffff81079603>] kthread+0x93/0xa0
> > [<ffffffff81465d04>] kernel_thread_helper+0x4/0x10
> > [<ffffffff81079570>] ? kthread_freezable_should_stop+0x70/0x70
> >  [<ffffffff81465d00>] ? gs_change+0x13/0x13
> >
> > Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> > ---
> >  net/sunrpc/xprtsock.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c index
> > 86b7777..aaaadfb 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -2521,6 +2521,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
> > static struct rpc_xprt_ops bc_tcp_ops = {
> >  	.reserve_xprt		= xprt_reserve_xprt,
> >  	.release_xprt		= xprt_release_xprt,
> > +	.alloc_slot		= xprt_alloc_slot,
> >  	.rpcbind		= xs_local_rpcbind,
> >  	.buf_alloc		= bc_malloc,
> >  	.buf_free		= bc_free,
> > --
> > 1.7.12.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > in the body of a message to majordomo@vger.kernel.org More
> majordomo
> > info at  http://vger.kernel.org/majordomo-info.html
