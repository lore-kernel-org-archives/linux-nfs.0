Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751194Ab2DJLNZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 07:13:25 -0400
Date: Tue, 10 Apr 2012 07:13:17 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120410071317.0e60bcd5@tlielax.poochiereds.net>
In-Reply-To: <20120409231849.GH10508@fieldses.org>
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
	<20120409231849.GH10508@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 9 Apr 2012 19:18:49 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Apr 03, 2012 at 08:14:39AM -0400, Jeff Layton wrote:
> > The main reason for the grace period is to prevent the server from
> > allowing an operation that might otherwise be denied once the client has
> > reclaimed all of its stateful objects.
> > 
> > Currently, the grace period handling in the nfsd/lockd server code is
> > very simple. When the lock managers start, they stick an entry on a list
> > and set a timer. When the timers pop, then they remove the entry from
> > the list. The locks_in_grace check just looks to see if the list is
> > empty. If it is, then the grace period is considered to be over.
> > 
> > This is insufficient for a clustered filesystem that is being served
> > from multiple nodes at the same time. In such a configuration, the grace
> > period must be coordinated in some fashion, or else one node might hand
> > out stateful objects that conflict with those that have not yet been
> > reclaimed.
> > 
> > This patch paves the way for fixing this by adding a new export
> > operation called locks_in_grace that takes a superblock argument. The
> > existing locks_in_grace function is renamed to generic_locks_in_grace,
> > and a new locks_in_grace function that takes a superblock arg is added.
> > If a filesystem does not have a locks_in_grace export operation then the
> > generic version will be used.
> 
> Looks more or less OK to me....
> 
> > Care has also been taken to reorder calls such that locks_in_grace is
> > called last in compound conditional statements. Handling this for
> > clustered filesystems may involve upcalls, so we don't want to call it
> > unnecessarily.
> 
> Even if we're careful to do the check last, we potentially still have to
> do it on every otherwise-succesful open and lock operation.
> 
> And really I don't think it's too much to ask that this be fast.
> 

Yes, FS implementers should expect that this could get called
frequently and ensure that it doesn't generate undue load.

I'd expect that any that do this via an upcall would ratelimit it in
some fashion during the grace period. They'd then set a flag or
something in the superblock afterward so they wouldn't need to upcall
anymore once it ends.

I'd rather push those smarts into the filesystems for now though in
order to allow for more flexibility. There are potential designs where
a fs could end up back in grace after initially leaving it and we
should allow for that.

> > @@ -3183,7 +3183,7 @@ nfs4_laundromat(void)
> >  	nfs4_lock_state();
> >  
> >  	dprintk("NFSD: laundromat service - starting\n");
> > -	if (locks_in_grace())
> > +	if (generic_locks_in_grace())
> >  		nfsd4_end_grace();
> 
> Looking at the code.... This is really just checking whether we've ended
> our own grace period.  The laundromat's scheduled to run a grace period
> after startup.  So I think we should just make this:
> 
> 	static bool grace_ended = false;
> 
> 	if (!grace_ended) {
> 		grace_ended = true;
> 		nfsd4_end_grace();
> 	}
> 
> or something.  No reason not to do that now.
> 
> (Hm, and maybe there's a reason to: locks_in_grace() could in theory
> still return true on a second run of nfs4_laundromat(), but
> nfsd4_end_grace() probably shouldn't really be run twice?)
> 

Most of the things that nfsd4_end_grace does should be safe to run
twice. The exception is nfsd4_recdir_purge_old which could be bad news.
So, doing what you suggest looks reasonable. I'll add that into the next
respin.

Thanks for having a look!
-- 
Jeff Layton <jlayton@redhat.com>
