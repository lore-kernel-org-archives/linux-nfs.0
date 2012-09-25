Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37832 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751593Ab2IYTID (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 15:08:03 -0400
Date: Tue, 25 Sep 2012 15:08:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Set alloc_slot for backchannel tcp ops
Message-ID: <20120925190801.GA31363@fieldses.org>
References: <1348508341-19642-1-git-send-email-bjschuma@netapp.com>
 <20120924174246.GA12238@fieldses.org>
 <50609DF3.2060204@netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FE5E31@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FE5E31@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 24, 2012 at 07:31:23PM +0000, Myklebust, Trond wrote:
> On Mon, 2012-09-24 at 13:52 -0400, Bryan Schumaker wrote:
> > On 09/24/2012 01:42 PM, J. Bruce Fields wrote:
> > > On Mon, Sep 24, 2012 at 01:39:01PM -0400, bjschuma@netapp.com wrote:
> > >> From: Bryan Schumaker <bjschuma@netapp.com>
> > >>
> > >> f39c1bfb5a03e2d255451bff05be0d7255298fa4 (SUNRPC: Fix a UDP transport
> > >> regression) introduced the "alloc_slot" function for xprt operations,
> > >> but never created one for the backchannel operations.  This patch fixes
> > >> a null pointer dereference when mounting NFS over v4.1.
> > > 
> > > Thanks, I just rebased some of my work to 3.6 and ran across that!  It
> > > crashes the 4.1 server very quickly....
> > 
> > That sounds like my story.  It got my peer-to-peer server right away, too.
> > 
> > - Bryan
> > 
> > > 
> > > --b.
> > > 
> > >>
> > >> Call Trace:
> > >>  [<ffffffffa0207957>] ? xprt_reserve+0x47/0x50 [sunrpc]
> > >>  [<ffffffffa02023a4>] call_reserve+0x34/0x60 [sunrpc]
> > >>  [<ffffffffa020e280>] __rpc_execute+0x90/0x400 [sunrpc]
> > >>  [<ffffffffa020e61a>] rpc_async_schedule+0x2a/0x40 [sunrpc]
> > >>  [<ffffffff81073589>] process_one_work+0x139/0x500
> > >>  [<ffffffff81070e70>] ? alloc_worker+0x70/0x70
> > >>  [<ffffffffa020e5f0>] ? __rpc_execute+0x400/0x400 [sunrpc]
> > >>  [<ffffffff81073d1e>] worker_thread+0x15e/0x460
> > >>  [<ffffffff8145c839>] ? preempt_schedule+0x49/0x70
> > >>  [<ffffffff81073bc0>] ? rescuer_thread+0x230/0x230
> > >>  [<ffffffff81079603>] kthread+0x93/0xa0
> > >>  [<ffffffff81465d04>] kernel_thread_helper+0x4/0x10
> > >>  [<ffffffff81079570>] ? kthread_freezable_should_stop+0x70/0x70
> > >>  [<ffffffff81465d00>] ? gs_change+0x13/0x13
> > >>
> > >> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> > >> ---
> > >>  net/sunrpc/xprtsock.c | 1 +
> > >>  1 file changed, 1 insertion(+)
> > >>
> > >> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > >> index 86b7777..aaaadfb 100644
> > >> --- a/net/sunrpc/xprtsock.c
> > >> +++ b/net/sunrpc/xprtsock.c
> > >> @@ -2521,6 +2521,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
> > >>  static struct rpc_xprt_ops bc_tcp_ops = {
> > >>  	.reserve_xprt		= xprt_reserve_xprt,
> > >>  	.release_xprt		= xprt_release_xprt,
> > >> +	.alloc_slot		= xprt_alloc_slot,
> > >>  	.rpcbind		= xs_local_rpcbind,
> > >>  	.buf_alloc		= bc_malloc,
> > >>  	.buf_free		= bc_free,
> > >> -- 
> > >> 1.7.12.1
> > >>
> > >> --
> > >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > >> the body of a message to majordomo@vger.kernel.org
> > >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> Argh... Sorry, that was entirely my fault. I traced the client side
> backchannel code, and found it was allocating slots using its own
> mechanism, then thought that applied to bc_tcp_ops.
> 
> I find the NFSv4.1 backchannel code to be even more confusing than
> lockd.

Patches very much welcomed.

> ...and BTW the .rpcbind hack above is a prime example. Bruce, why do you
> need that? The server back channel sets xprt_set_bound() in
> xs_setup_bc_tcp() and should never clear it.

Beats me; you're suggesting the below?  Agreed, looks wrong.

It must be pointless in the AF_LOCAL case too, though I didn't try to
verify.

--b.

commit ad25de5558f702fa2c7ececedf4d61975dababa8
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Sep 24 15:53:29 2012 -0400

    sunrpc: server back channel needs no rpcbind method
    
    XPRT_BOUND is set on server backchannel xprts by xs_setup_bc_tcp()
    (using xprt_set_bound()), and is never cleared, so ->rpcbind() will
    never need to be called.
    
    Reported-by: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index cd59a80..3a8663e6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2529,7 +2529,6 @@ static struct rpc_xprt_ops bc_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xprt_release_xprt,
 	.alloc_slot		= xprt_alloc_slot,
-	.rpcbind		= xs_local_rpcbind,
 	.buf_alloc		= bc_malloc,
 	.buf_free		= bc_free,
 	.send_request		= bc_send_request,
