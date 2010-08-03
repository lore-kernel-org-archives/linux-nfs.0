Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39754 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757608Ab0HCSuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 14:50:21 -0400
Date: Tue, 3 Aug 2010 14:48:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: Re: sunrpc: what prevents an xprt from being freed before
 task_cleanup runs?
Message-ID: <20100803184856.GA31579@fieldses.org>
References: <20100803132453.4fa18444@tlielax.poochiereds.net>
 <1280860815.9771.25.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1280860815.9771.25.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 03, 2010 at 02:40:15PM -0400, Trond Myklebust wrote:
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

I'll believe you, but I don't get it: what guarantees that XPRT_LOCKED
isn't cleared while xprt_autoclose autoclose is still running?

--b.
