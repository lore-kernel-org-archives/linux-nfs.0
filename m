Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874Ab1JKNtq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Oct 2011 09:49:46 -0400
Date: Tue, 11 Oct 2011 09:49:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, mikem@redhat.com
Subject: Re: [PATCH][RFC] nfs: don't redirty inode when ncommit == 0 in
 nfs_commit_unstable_pages
Message-ID: <20111011094921.72f78153@tlielax.poochiereds.net>
In-Reply-To: <1318281342.14423.63.camel@lade.trondhjem.org>
References: <1318278838-26653-1-git-send-email-jlayton@redhat.com>
	<1318281342.14423.63.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Oct 2011 17:15:42 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2011-10-10 at 16:33 -0400, Jeff Layton wrote: 
> > The current test in nfs_commit_unstable_pages does not handle the edge
> > condition properly. When ncommit == 0, then that likely means that the
> > kernel doesn't need to do anything more for the inode. The current test
> > though will return true in that case, and the inode will end up being
> > marked dirty.
> > 
> > Fix this by not re-marking the inode dirty when ncommit == 0.
> > 
> > Mike noticed this problem initially in RHEL5 (2.6.18-based kernel) which
> > has a backported version of 420e3646. The inode cache there was
> > growing very large, but calling sync() would essentially "fix" the
> > problem.
> > 
> > What I'm not clear on is how big a problem this is in mainline kernels
> > as the writeback code there is very different. I think this basically
> > means that the inode will remain dirty until there's a WB_SYNC_ALL
> > flush. Either way, it seems incorrect to mark the inode dirty in this
> > case.
> > 
> > Also, another question I have here -- shouldn't we be holding the i_lock
> > when doing this check?
> > 
> > Reported-by: Mike McLean <mikem@redhat.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/write.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index 17e20e4..6395e98 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -1557,7 +1557,7 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
> >  		/* Don't commit yet if this is a non-blocking flush and there
> >  		 * are a lot of outstanding writes for this mapping.
> >  		 */
> > -		if (nfsi->ncommit <= (nfsi->npages >> 1))
> > +		if (nfsi->ncommit && nfsi->ncommit <= (nfsi->npages >> 1))
> >  			goto out_mark_dirty;
> >  
> >  		/* don't wait for the COMMIT response */
> 
> Umm... The above implementation will actually cause you to call
> nfs_commit_inode() when nfsi->ncommit is zero, which again causes you to
> go through all the hoopla with nfs_commit_set_lock() etc., for a case
> when you know you could just exit...
> 

Ok, I think I've convinced myself that there is no possibility of a
race here. We always mark the inode dirty after incrementing ncommit,
and the dirty bits are always cleared before write_inode is called.
There's also no need to take the i_lock, I think -- worst case we'll end
up with the inode marked dirty again after exiting. The next pass should
clean it, so no harm done...

I think therefore that this patch should also be safe. This extends the
optimization for ncommit == 0 to the WB_SYNC_ALL case too.

I wonder too whether this is the root cause of some of the problems
that people have reported like this one:

    http://www.spinics.net/lists/linux-nfs/msg24378.html

Thoughts?

-----------------------[snip]----------------------

nfs: don't redirty inode when ncommit == 0 in  nfs_commit_unstable_pages (RFC)

commit 420e3646 allowed the kernel to reduce the number of unnecessary
commit calls by skipping the commit when there are a large number of
outstanding pages.

However, the current test in nfs_commit_unstable_pages does not handle
the edge condition properly. When ncommit == 0, then that means that the
kernel doesn't need to do anything more for the inode. The current test
though in the WB_SYNC_NONE case will return true, and the inode will end
up being marked dirty. Once that happens the inode will never be clean
until there's a WB_SYNC_ALL flush.

Fix this by immediately returning from nfs_commit_unstable_pages when
ncommit == 0.

Mike noticed this problem initially in RHEL5 (2.6.18-based kernel) which
has a backported version of 420e3646. The inode cache there was growing
very large. The inode cache was unable to be shrunk since the inodes
were all marked dirty. Calling sync() would essentially "fix" the
problem -- the WB_SYNC_ALL flush would result in the inodes all being
marked clean.

What I'm not clear on is how big a problem this is in mainline kernels
as the writeback code there is very different. Either way, it seems
incorrect to re-mark the inode dirty in this case.

Reported-by: Mike McLean <mikem@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/write.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 17e20e4..62e6b01 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1553,6 +1553,10 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 	int flags = FLUSH_SYNC;
 	int ret = 0;
 
+	/* no commits means nothing needs to be done */
+	if (!nfsi->ncommit)
+		return ret;
+
 	if (wbc->sync_mode == WB_SYNC_NONE) {
 		/* Don't commit yet if this is a non-blocking flush and there
 		 * are a lot of outstanding writes for this mapping.
-- 
1.7.6.4

