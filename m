Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9149 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759766Ab3EWWaY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 May 2013 18:30:24 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Scott Mayhew <smayhew@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 1/1] NFS: Allow nfs_updatepage to extend a write to
 cover a full page when we have a lock that covers the entire file
Date: Thu, 23 May 2013 22:30:10 +0000
Message-ID: <1369348209.8861.12.camel@leira.trondhjem.org>
References: <1369346021-20041-1-git-send-email-smayhew@redhat.com>
	 <1369346021-20041-2-git-send-email-smayhew@redhat.com>
	 <20130523182450.18adbcd8@tlielax.poochiereds.net>
In-Reply-To: <20130523182450.18adbcd8@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-23 at 18:24 -0400, Jeff Layton wrote:
> On Thu, 23 May 2013 17:53:41 -0400
> Scott Mayhew <smayhew@redhat.com> wrote:
> 
> > Currently nfs_updatepage allows a write to be extended to cover a full
> > page only if we don't have a byte range lock on the file... but if we've
> > got the whole file locked, then we should be allowed to extend the
> > write.
> > 
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  fs/nfs/write.c | 7 +++++--
> >  1 file changed, 5 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index a2c7c28..f35fb4f 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -908,13 +908,16 @@ int nfs_updatepage(struct file *file, struct page *page,
> >  		file->f_path.dentry->d_name.name, count,
> >  		(long long)(page_file_offset(page) + offset));
> >  
> > -	/* If we're not using byte range locks, and we know the page
> > +	/* If we're not using byte range locks (or if the range of the
> > +	 * lock covers the entire file), and we know the page
> >  	 * is up to date, it may be more efficient to extend the write
> >  	 * to cover the entire page in order to avoid fragmentation
> >  	 * inefficiencies.
> >  	 */
> >  	if (nfs_write_pageuptodate(page, inode) &&
> > -			inode->i_flock == NULL &&
> > +			(inode->i_flock == NULL ||
> > +			(inode->i_flock->fl_start == 0 &&
> > +			inode->i_flock->fl_end == OFFSET_MAX)) &&
> >  			!(file->f_flags & O_DSYNC)) {
> >  		count = max(count + offset, nfs_page_length(page));
> >  		offset = 0;
> 
> Sounds like a reasonable proposition, but I think you might need to do
> more vetting of the locks...
> 
> For instance, does it make sense to do this if it's a F_RDLCK? Also,
> you're only looking at the first lock in the i_flock list. Might it
> make more sense to walk the list and see whether the page might be
> entirely covered by a lock that doesn't extend over the whole file?
> 

I'm guessing that the answer is to both these questions are "no":
- Anybody who is writing while holding a F_RDLCK is likely doing
something wrong.
- Walking the lock list on every write can quickly get painful if we
have lots of small locks.

However it may make a lot of sense to look at whether or not we hold a
NFSv4 write delegation.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
