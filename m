Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45978 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753519AbaHETPA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2014 15:15:00 -0400
Date: Tue, 5 Aug 2014 15:14:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/locks.c: Copy fl_lmops to conflock for nfsd using
Message-ID: <20140805191458.GV23341@fieldses.org>
References: <53BAAAC5.9000106@gmail.com>
 <53DCF97D.3000605@gmail.com>
 <20140802190505.442f07b8@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140802190505.442f07b8@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 02, 2014 at 07:05:05PM -0400, Jeff Layton wrote:
> On Sat, 02 Aug 2014 22:45:17 +0800
> Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
> > Commit d5b9026a67 ([PATCH] knfsd: locks: flag NFSv4-owned locks)
> > using fl_lmops field in file_lock for checking nfsd4 lockowner.
> > 
> > But, commit 1a747ee0cc (locks: don't call ->copy_lock methods
> > on return of conflicting locks) causes the fl_lmops of conflock
> > for nfsd4_lock always be NULL.
> > 
> > Also, commit 0996905f93 (lockd: posix_test_lock() should not call
> > locks_copy_lock()) caused the fl_lmops of conflock for nfsd4_lockt
> > always be NULL too.
> > 
> > So that, nfsd4 lockowner for it always be NULL too.
> > 
> > This patch re-coping the fl_lmops to conflock.
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > ---
> >  fs/locks.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/fs/locks.c b/fs/locks.c
> > index 717fbc4..cc1219a 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -279,7 +279,7 @@ void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
> >  	new->fl_start = fl->fl_start;
> >  	new->fl_end = fl->fl_end;
> >  	new->fl_ops = NULL;
> > -	new->fl_lmops = NULL;
> > +	new->fl_lmops = fl->fl_lmops;
> >  }
> >  EXPORT_SYMBOL(__locks_copy_lock);
> >  
> > @@ -290,7 +290,6 @@ void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
> >  	__locks_copy_lock(new, fl);
> >  	new->fl_file = fl->fl_file;
> >  	new->fl_ops = fl->fl_ops;
> > -	new->fl_lmops = fl->fl_lmops;
> >  
> >  	locks_copy_private(new, fl);
> >  }
> 
> This looks sane to me AFAICT.
> 
> I'll run a few tests with it, and put it into I'll plan to pick this up
> since I have some other fs/locks.c related patches slated for 3.17.

Looks like your mail and Trond's crossed?  I'd need to go remind myself
of the __locks_copy_lock callers, but I'm pretty sure Trond's right....

--b.
