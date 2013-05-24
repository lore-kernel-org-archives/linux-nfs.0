Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10186 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520Ab3EXLYG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 May 2013 07:24:06 -0400
Date: Fri, 24 May 2013 07:24:03 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Scott Mayhew <smayhew@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 1/1] NFS: Allow nfs_updatepage to extend a write to
 cover a full page when we have a lock that covers the entire file
Message-ID: <20130524072403.6b814585@corrin.poochiereds.net>
In-Reply-To: <1369348209.8861.12.camel@leira.trondhjem.org>
References: <1369346021-20041-1-git-send-email-smayhew@redhat.com>
	<1369346021-20041-2-git-send-email-smayhew@redhat.com>
	<20130523182450.18adbcd8@tlielax.poochiereds.net>
	<1369348209.8861.12.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 23 May 2013 22:30:10 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-05-23 at 18:24 -0400, Jeff Layton wrote:
> > On Thu, 23 May 2013 17:53:41 -0400
> > Scott Mayhew <smayhew@redhat.com> wrote:
> > 
> > > Currently nfs_updatepage allows a write to be extended to cover a full
> > > page only if we don't have a byte range lock on the file... but if we've
> > > got the whole file locked, then we should be allowed to extend the
> > > write.
> > > 
> > > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > > ---
> > >  fs/nfs/write.c | 7 +++++--
> > >  1 file changed, 5 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > > index a2c7c28..f35fb4f 100644
> > > --- a/fs/nfs/write.c
> > > +++ b/fs/nfs/write.c
> > > @@ -908,13 +908,16 @@ int nfs_updatepage(struct file *file, struct page *page,
> > >  		file->f_path.dentry->d_name.name, count,
> > >  		(long long)(page_file_offset(page) + offset));
> > >  
> > > -	/* If we're not using byte range locks, and we know the page
> > > +	/* If we're not using byte range locks (or if the range of the
> > > +	 * lock covers the entire file), and we know the page
> > >  	 * is up to date, it may be more efficient to extend the write
> > >  	 * to cover the entire page in order to avoid fragmentation
> > >  	 * inefficiencies.
> > >  	 */
> > >  	if (nfs_write_pageuptodate(page, inode) &&
> > > -			inode->i_flock == NULL &&
> > > +			(inode->i_flock == NULL ||
> > > +			(inode->i_flock->fl_start == 0 &&
> > > +			inode->i_flock->fl_end == OFFSET_MAX)) &&
> > >  			!(file->f_flags & O_DSYNC)) {
> > >  		count = max(count + offset, nfs_page_length(page));
> > >  		offset = 0;
> > 
> > Sounds like a reasonable proposition, but I think you might need to do
> > more vetting of the locks...
> > 
> > For instance, does it make sense to do this if it's a F_RDLCK? Also,
> > you're only looking at the first lock in the i_flock list. Might it
> > make more sense to walk the list and see whether the page might be
> > entirely covered by a lock that doesn't extend over the whole file?
> > 
> 
> I'm guessing that the answer is to both these questions are "no":
> - Anybody who is writing while holding a F_RDLCK is likely doing
> something wrong.

Right, so I think we ought to be conservative here and not extend the
write if this is an F_RDLCK.

> - Walking the lock list on every write can quickly get painful if we
> have lots of small locks.
> 

True, but it's probably still preferable to do that than to do a bunch
of small I/Os to the server. But, that's an optimization that can be
done later. Hardly anyone does real byte-range locking so I'm fine with
this approach for now.

> However it may make a lot of sense to look at whether or not we hold a
> NFSv4 write delegation.
> 

Yes, that would be a good thing too. Having a helper function like you
suggested should make it easier to encapsulate that logic sanely.

-- 
Jeff Layton <jlayton@redhat.com>
