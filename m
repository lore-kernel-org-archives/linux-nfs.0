Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756759Ab0HCS7i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 14:59:38 -0400
Date: Tue, 3 Aug 2010 14:59:28 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, bfields@fieldses.org
Subject: Re: sunrpc: what prevents an xprt from being freed before
 task_cleanup runs?
Message-ID: <20100803145928.2655b388@tlielax.poochiereds.net>
In-Reply-To: <1280860815.9771.25.camel@heimdal.trondhjem.org>
References: <20100803132453.4fa18444@tlielax.poochiereds.net>
	<1280860815.9771.25.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 03 Aug 2010 14:40:15 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Tue, 2010-08-03 at 13:24 -0400, Jeff Layton wrote:
> > We got a report recently about a panic in RHEL5 (2.6.18 based kernel).
> > The problem appears to be that a task_cleanup workqueue job ran and got
> > passed a pointer to an xprt that had been freed. The bug is here in
> > case anyone is interested in the details:
> > 
> >     https://bugzilla.redhat.com/show_bug.cgi?id=611938
> > 
> > The situation seems to be pretty difficult to reproduce, but I don't
> > see anything that's intended to ensure that this doesn't occur in RHEL5
> > or mainline. The task_cleanup workqueue job doesn't hold a reference to
> > the xprt, and the job isn't canceled when the xprt is torn down.
> > 
> > Bruce had a look and suggested that we may need something like the
> > patch below (pasted in, so it probably won't apply correctly). I've
> > tested a backported version of it on RHEL5 and it seems to work fine.
> > 
> > Is it reasonable to cancel task_cleanup when destroying the xprt? Or,
> > am I missing something that should prevent this situation in mainline
> > (and perhaps isn't in RHEL5's kernel).
> > 
> > Any help is appreciated...
> > 
> > -----------------------------[snip]---------------------------------
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index dcd0132..2a1f664 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -1129,6 +1129,7 @@ static void xprt_destroy(struct kref *kref)
> >   rpc_destroy_wait_queue(&xprt->sending);
> >   rpc_destroy_wait_queue(&xprt->resend);
> >   rpc_destroy_wait_queue(&xprt->backlog);
> > + cancel_work_sync(&xprt->task_cleanup);
> >   /*
> >    * Tear down transport state and free the rpc_xprt
> >    */
> > -----------------------------[snip]---------------------------------
> > 
> > Thanks,
> 
> How about doing a wait_on_bit_lock(&xprt->state, XPRT_LOCKED,...)
> instead?
> 

I haven't quite grokked what XPRT_LOCKED is supposed to signify. What
would be the advantage of doing that over just killing off the
task_cleanup job? It seems like if we're tearing down the xprt then
waiting for task_cleanup to run is sort of pointless -- xs_destroy will
take care of closing the socket anyway.

Also, if we do go that route, do we need a wake_up_bit call in
xprt_clear_locked?

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
