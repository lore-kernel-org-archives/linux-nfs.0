Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064Ab3FDLJn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 07:09:43 -0400
Date: Tue, 4 Jun 2013 07:09:02 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v1 03/11] locks: comment cleanups and clarifications
Message-ID: <20130604070902.07f0caee@tlielax.poochiereds.net>
In-Reply-To: <20130603220024.GF2109@fieldses.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
	<1370056054-25449-4-git-send-email-jlayton@redhat.com>
	<20130603220024.GF2109@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 3 Jun 2013 18:00:24 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 31, 2013 at 11:07:26PM -0400, Jeff Layton wrote:
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/locks.c         |   24 +++++++++++++++++++-----
> >  include/linux/fs.h |    6 ++++++
> >  2 files changed, 25 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/locks.c b/fs/locks.c
> > index e3140b8..a7d2253 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -150,6 +150,16 @@ static int target_leasetype(struct file_lock *fl)
> >  int leases_enable = 1;
> >  int lease_break_time = 45;
> >  
> > +/*
> > + * The i_flock list is ordered by:
> > + *
> > + * 1) lock type -- FL_LEASEs first, then FL_FLOCK, and finally FL_POSIX
> > + * 2) lock owner
> > + * 3) lock range start
> > + * 4) lock range end
> > + *
> > + * Obviously, the last two criteria only matter for POSIX locks.
> > + */
> 
> Thanks, yes, that needs documenting!  Though I wonder if this is the
> place people will look for it.
> 

Agreed. If you can think of a better spot to put this, I'd be happy to
move it in the next iteration of this series.

> >  #define for_each_lock(inode, lockp) \
> >  	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
> >  
> > @@ -806,6 +816,11 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  	}
> >  
> >  	lock_flocks();
> > +	/*
> > +	 * New lock request. Walk all POSIX locks and look for conflicts. If
> > +	 * there are any, either return -EAGAIN or put the request on the
> > +	 * blocker's list of waiters.
> > +	 */
> 
> This though, seems a) not 100% accurate (it could also return EDEADLCK,
> for example), b) mostly redundant with respect to the following code.
> 

Good point -- I'll fix that up. That one was mostly for my own benefit
while trying to figure out how this code works. It's still probably worth
some more verbose comments here since this certainly wasn't 100%
obvious to me when I first dove into this code.

> >  	if (request->fl_type != F_UNLCK) {
> >  		for_each_lock(inode, before) {
> >  			fl = *before;
> > @@ -844,7 +859,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  		before = &fl->fl_next;
> >  	}
> >  
> > -	/* Process locks with this owner.  */
> > +	/* Process locks with this owner. */
> >  	while ((fl = *before) && posix_same_owner(request, fl)) {
> >  		/* Detect adjacent or overlapping regions (if same lock type)
> >  		 */
> > @@ -930,10 +945,9 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  	}
> >  
> >  	/*
> > -	 * The above code only modifies existing locks in case of
> > -	 * merging or replacing.  If new lock(s) need to be inserted
> > -	 * all modifications are done bellow this, so it's safe yet to
> > -	 * bail out.
> > +	 * The above code only modifies existing locks in case of merging or
> > +	 * replacing. If new lock(s) need to be inserted all modifications are
> > +	 * done below this, so it's safe yet to bail out.
> >  	 */
> >  	error = -ENOLCK; /* "no luck" */
> >  	if (right && left == right && !new_fl2)
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index b9d7816..ae377e9 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -926,6 +926,12 @@ int locks_in_grace(struct net *);
> >  /* that will die - we need it for nfs_lock_info */
> >  #include <linux/nfs_fs_i.h>
> >  
> > +/*
> > + * struct file_lock represents a generic "file lock". It's used to represent
> > + * POSIX byte range locks, BSD (flock) locks, and leases. It's important to
> > + * note that the same struct is used to represent both a request for a lock and
> > + * the lock itself, but the same object is never used for both.
> 
> Yes, and I do find that confusing.  I wonder if there's a sensible way
> to use separate structs for the different uses.
> 
> --b.
> 

Yeah. I think that latter point accounts for a lot of the difficulty for
the uninitiated to understand this code.

I considered creating a "struct lock_request" too. If I were designing
this code from scratch I certainly would do so, but it's harder to
justify such a change to the existing code.

It would mean a lot of churn in fs-specific lock routines, and we'd
have to completely revamp things like locks_copy_lock. I just don't see
that giving us a lot of benefit in the near term and I really want this
set to focus on concrete benefits.

We might consider it in the future though. I'll add a FIXME comment
here so we can record the idea for posterity.

Thanks for the comments!

> > + */
> >  struct file_lock {
> >  	struct file_lock *fl_next;	/* singly linked list for this inode  */
> >  	struct list_head fl_link;	/* doubly linked list of all locks */
> > -- 
> > 1.7.1
> > 


-- 
Jeff Layton <jlayton@redhat.com>
