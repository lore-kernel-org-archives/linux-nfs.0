Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34646 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835Ab2DJNSd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 09:18:33 -0400
Date: Tue, 10 Apr 2012 09:18:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120410131832.GC18465@fieldses.org>
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
 <20120409231849.GH10508@fieldses.org>
 <20120410071317.0e60bcd5@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120410071317.0e60bcd5@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2012 at 07:13:17AM -0400, Jeff Layton wrote:
> Yes, FS implementers should expect that this could get called
> frequently and ensure that it doesn't generate undue load.
> 
> I'd expect that any that do this via an upcall would ratelimit it in
> some fashion during the grace period. They'd then set a flag or
> something in the superblock afterward so they wouldn't need to upcall
> anymore once it ends.
> 
> I'd rather push those smarts into the filesystems for now though in
> order to allow for more flexibility. There are potential designs where
> a fs could end up back in grace after initially leaving it and we
> should allow for that.

Even then a grace period transition should be rare, so I'd think they'd
want to notify the kernel on the transition rather than polling?

> 
> > > @@ -3183,7 +3183,7 @@ nfs4_laundromat(void)
> > >  	nfs4_lock_state();
> > >  
> > >  	dprintk("NFSD: laundromat service - starting\n");
> > > -	if (locks_in_grace())
> > > +	if (generic_locks_in_grace())
> > >  		nfsd4_end_grace();
> > 
> > Looking at the code.... This is really just checking whether we've ended
> > our own grace period.  The laundromat's scheduled to run a grace period
> > after startup.  So I think we should just make this:
> > 
> > 	static bool grace_ended = false;
> > 
> > 	if (!grace_ended) {
> > 		grace_ended = true;
> > 		nfsd4_end_grace();
> > 	}
> > 
> > or something.  No reason not to do that now.
> > 
> > (Hm, and maybe there's a reason to: locks_in_grace() could in theory
> > still return true on a second run of nfs4_laundromat(), but
> > nfsd4_end_grace() probably shouldn't really be run twice?)
> > 
> 
> Most of the things that nfsd4_end_grace does should be safe to run
> twice. The exception is nfsd4_recdir_purge_old which could be bad news.
> So, doing what you suggest looks reasonable. I'll add that into the next
> respin.

Thanks; that at least I can merge whenever it's ready.

--b.
