From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks
	(RFC)
Date: Tue, 20 Jan 2009 18:05:48 -0500
Message-ID: <20090120230548.GA28500@fieldses.org>
References: <20081122011555.GA28485@fieldses.org> <20081124103313.0c779324@tleilax.poochiereds.net> <20081124170653.GF17862@fieldses.org> <20081213074042.2e8223c3@tleilax.poochiereds.net> <20081216193806.GC18928@fieldses.org> <20081216195635.GD18928@fieldses.org> <20081216161158.2d173667@tleilax.poochiereds.net> <20081217191453.GA16777@redhat.com> <20081217200156.GO4614@fieldses.org> <20081217212827.GB16777@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: David Teigland <teigland@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40309 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882AbZATXFs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jan 2009 18:05:48 -0500
In-Reply-To: <20081217212827.GB16777@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delay responding!

On Wed, Dec 17, 2008 at 03:28:27PM -0600, David Teigland wrote:
> On Wed, Dec 17, 2008 at 03:01:56PM -0500, J. Bruce Fields wrote:
> > Yep, that looks much better.  Though actually I suspect what was really
> > intended was to use "flc" for the notifies, and "fl" for the
> > posix_lock_file().
> > 
> > Also, since flc is never actually handed to the posix lock system, I
> > think it should be a "shallow" lock copy--so it should be created with
> > __locks_copy_lock().  Something like the below?
> 
> With this I'm back to seeing the same problem, but with the mismatch in
> the reverse direction.
> 
> It seems fl points to lockd's file_lock, and that lockd expects notify()
> will be called with a pointer to a file_lock that matches one of its own.
> Based on that I think we'd always pass fl to notify().

The lockd grant function that's called is nlmsvc_grant_deferred(), and
it uses the passed-in fl only in nlm_compare_locks().

Perhaps the problem is that the posix_lock_file() modifies the original
file lock which lockd is also holding a pointer to, and thus the
coalescing has also changed the lock that *lockd*'s sees?

--b.

> 
> The question then is whether lockd's file_lock should be coalesced or not.
> If so, we'd pass fl to posix_lock_file().  If not, we'd pass flc to
> posix_lock_file().  In both cases, fl would be passed to notify() and
> would match.  In the former case, I don't see much purpose for flc to even
> exist.  The patch I sent was the later case.
> 
> In the original code, we coalesce flc which then fails to match the
> original (fl) in lockd.  In your patch, we coalesce fl which then fails to
> match the copy of the original (flc).
> 
> Dave
> 
> > 
> > diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
> > index eba87ff..e8d9086 100644
> > --- a/fs/dlm/plock.c
> > +++ b/fs/dlm/plock.c
> > @@ -103,7 +103,7 @@ int dlm_posix_lock(dlm_lockspace_t *lockspace, u64 number, struct file *file,
> >  		op->info.owner	= (__u64) fl->fl_pid;
> >  		xop->callback	= fl->fl_lmops->fl_grant;
> >  		locks_init_lock(&xop->flc);
> > -		locks_copy_lock(&xop->flc, fl);
> > +		__locks_copy_lock(&xop->flc, fl);
> >  		xop->fl		= fl;
> >  		xop->file	= file;
> >  	} else {
> > @@ -173,8 +173,8 @@ static int dlm_plock_callback(struct plock_op *op)
> >  	}
> >  
> >  	/* got fs lock; bookkeep locally as well: */
> > -	flc->fl_flags &= ~FL_SLEEP;
> > -	if (posix_lock_file(file, flc, NULL)) {
> > +	fl->fl_flags &= ~FL_SLEEP;
> > +	if (posix_lock_file(file, fl, NULL)) {
> >  		/*
> >  		 * This can only happen in the case of kmalloc() failure.
> >  		 * The filesystem's own lock is the authoritative lock,
