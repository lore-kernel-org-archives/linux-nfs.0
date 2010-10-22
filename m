Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53552 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751233Ab0JVXBN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 19:01:13 -0400
Date: Fri, 22 Oct 2010 19:01:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: "xprt" reference count drops to 0
Message-ID: <20101022230111.GC22837@fieldses.org>
References: <4C7E4469.70807@duchatelet.net>
 <4CAAE046.5060209@bull.net>
 <20101021203801.GA12038@fieldses.org>
 <4CC1A722.4060907@bull.net>
 <20101022212007.GB22837@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101022212007.GB22837@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Oct 22, 2010 at 05:20:07PM -0400, J. Bruce Fields wrote:
> On Fri, Oct 22, 2010 at 05:00:50PM +0200, Menyhart Zoltan wrote:
> > J. Bruce Fields wrote:
> > >On Tue, Oct 05, 2010 at 10:22:30AM +0200, Menyhart Zoltan wrote:
> > >>Due to some race conditions, the reference count can become 0
> > >>while "xprt" is still on a "pool":
> > >
> > >Apologies, your email got buried in my inbox....
> > >
> > >>
> > >>WARNING: at lib/kref.c:43 kref_get+0x23/0x2d()
> > >>  [] kref_get+0x23/0x2d
> > >>  [] svc_xprt_get+0x12/0x14 [sunrpc]
> > >>  [] svc_recv+0x2db/0x78a [sunrpc]
> > >
> > >Which kernel exactly did you see this on?  Is it reproduceable?
> > 
> > I saw it on a 2.6.32.
> > It has not been corrected for the 2.6.36-rc3 yet.
> > The patch is for  the 2.6.36-rc3.
> > 
> > It is a narrow window, you need a high work load and a bit of luck  to
> > delay the current CPU just after"svc_xprt_enqueue()" returns.
> > 
> > >>I think we should increase the reference counter before adding "xprt"
> > >>onto any list.
> > >
> > >I don't see the xprt added to any list after the svc_xprt_get() you've
> > >added below.
> > 
> > "svc_xprt_enqueue()" has got two ways to pass an "xprt":
> > - via "rqstp->rq_xprt" if a worker is available,
> > - on the "pool->sp_sockets" list otherwise
> > 
> >         if (!list_empty(&pool->sp_threads)) {
> >                 rqstp = list_entry(pool->sp_threads.next,  struct svc_rqst,  rq_list);
> >                 svc_thread_dequeue(pool, rqstp);
> >                 rqstp->rq_xprt = xprt;
> >                 svc_xprt_get(xprt);
> >                 rqstp->rq_reserved = serv->sv_max_mesg;
> >                 atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
> >                 pool->sp_stats.threads_woken++;
> >                 wake_up(&rqstp->rq_wait);
> >         } else {
> >                 list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
> >                 pool->sp_stats.sockets_queued++;
> >         }
> > 
> > In the 1st case, there is a "svc_xprt_get(xprt)", in the 2nd one, there is not.
> > Once "svc_xprt_enqueue()" returns, at some places, "svc_xprt_put(xprt)" is
> > invoked. If we has passed the "else" branch, the "kref" can drop down to 0.
> 
> Maybe your fix is right, but I'm not sure: It looks to me like if
> svc_xprt_enqueue() gets to "process:" in a situation where the caller
> holds the only reference, then that's already a bug.  Do you know who
> the caller of svc_xprt_enqueue() was when this happened?

Hm.  Maybe something like this could happen: two threads call
svc_check_conn_limits at about the same time, and both pick the same
victim xprt.


	thread 1			thread 2
	^^^^^^^^			^^^^^^^^
	set CLOSE			set CLOSE
	call svc_xprt_enqueue
	  set BUSY

	thread 3
	^^^^^^^^			call svc_xprt_enqueue
	call svc_recv
	  dequeue our xprt		
					check DEAD, see it unset
	  call svc_delete_xprt
	    remove xprt from any
	  	global lists
	    put xprt
	  clear BUSY
					test_and_set_bit BUSY
					test CLOSE, go to process:
					make xprt globablly visible
						again
					ARGH!


The put in svc_delete_xprt() is meant to happen only when the xprt is
taken off any rqstp's or global lists.  We shouldn't be able to requeue
the xprt after that's done.

So, both the svc_check_conn_limits return, the reference count's
probably gone to zero at that point, and the xprt's freed while there
are still references to it somewhere.

It seems wrong to be clearing BUSY after deleting an xprt; what good
could come of letting someone try to process an xprt that's already
DEAD?

But I need to go back over that.  Maybe I've missed something.

--b.
