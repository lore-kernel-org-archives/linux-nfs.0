From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Fwd: Re: Linux 2.6.25-rc2]
Date: Wed, 20 Feb 2008 13:52:53 -0500
Message-ID: <20080220185253.GF30160@fieldses.org>
References: <1203282165.2929.7.camel@heimdal.trondhjem.org> <20080218174509.GC32492@fieldses.org> <1203358682.24272.31.camel@trinity.ogc.int> <47BA8CB3.4030703@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41973 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbYBTSw5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 13:52:57 -0500
In-Reply-To: <47BA8CB3.4030703-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 19, 2008 at 07:00:51PM +1100, Greg Banks wrote:
> Tom Tucker wrote:
> > Bruce:
> >
> > I'll take a look...
> >
> > Tom
> >
> > On Mon, 2008-02-18 at 12:45 -0500, J. Bruce Fields wrote:
> >   
> >> On Sun, Feb 17, 2008 at 04:02:45PM -0500, Trond Myklebust wrote:
> >>     
> >>> Hi Bruce,
> >>>
> >>> Here is a question for you.
> >>>
> >>>         Why does svc_close_all() get away with deleting xprt->xpt_ready
> >>>         without holding the pool->sp_lock?
> >>>       
> >> >From a quick look--I think the intention is that the code that calls it
> >> (in svc_destroy()) is only called after all other server threads have
> >> exited, and that there can't be anyone else monkeying with that service
> >> any more.  But I haven't verified that really carefully.
> >>     
> That's certainly the intention.  The serv->sv_nrthreads fields is used
> as a refcount, which counts 1 for each nfsd thread and sometimes 1 to
> guard some short-term manipulations.  This refcount should not drop to
> zero until the last thread exits.  So by the time svc_close_all() is
> called, no thread can be looking at a pool's sp_sockets list.  Each
> xprt could still be racily added to that list from softirq mode data
> ready handlers calling svc_xprt_enqueue(), but only until the xprt's
> xpo_detach method is called (which removes any data ready callbacks).
> At that point, no code should be modifying the xpt_ready field, and
> it may or may not be used to link the xprt into some pool->sp_sockets
> but we don't care because all the pools are about to be destroyed
> anyway.

OK, thanks very much for the confirmation.  It looks like they've
finally decided the problem was actually with the memory allocator:

	http://bugzilla.kernel.org/show_bug.cgi?id=9973

so I think we're OK.

> That's the way it's been working since 2.6.19, and I don't think any
> of Tom's patches changed that.
> 
> I can think of a couple of things that could be wrong:
> 
>  * serv->sv_nrthreads is used in a few places, and there might
>    be bugs in that which are getting that count wrong (when I left
>    the code, all increments and decrements of that field went through
>    svc_get() and svc_destroy(), but other changes have crept in).
> 
>  * Currently running data ready callbacks might be racing with xpo_detach.
>    Moving that call inside the spin_lock_bh() critical section just
>    after it might help.

But if you were unsure about these two things then I suppose it might be
worth doing a closer audit and seeing if there's any refactoring or
documentation that could be added to make the rules clearer.

--b.
