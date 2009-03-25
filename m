From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: reset inode dirty time when adding it back
	to empty s_dirty list
Date: Wed, 25 Mar 2009 10:50:37 +0800
Message-ID: <20090325025037.GA17374@localhost>
References: <1237840233-11045-1-git-send-email-jlayton@redhat.com> <20090324135720.GA25314@localhost> <20090324102806.4f38fd26@tleilax.poochiereds.net> <20090324104657.6907b19e@tleilax.poochiereds.net> <20090325012829.GA7506@localhost> <20090324221528.2bb7c50b@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Kent <raven@themaw.net>, Dave Chinner <david@fromorbit.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hch@infradead.org" <hch@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28077 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753120AbZCYCxk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Mar 2009 22:53:40 -0400
In-Reply-To: <20090324221528.2bb7c50b-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2009 at 10:15:28AM +0800, Jeff Layton wrote:
> On Wed, 25 Mar 2009 09:28:29 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Hi Jeff,
> > 
> > On Tue, Mar 24, 2009 at 10:46:57PM +0800, Jeff Layton wrote:
> > > On Tue, 24 Mar 2009 10:28:06 -0400
> > > Jeff Layton <jlayton@redhat.com> wrote:
> > > 
> > > > On Tue, 24 Mar 2009 21:57:20 +0800
> > > > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > > 
> > > > > Hi Jeff,
> > > > > 
> > > > > On Mon, Mar 23, 2009 at 04:30:33PM -0400, Jeff Layton wrote:
> > > > > > This may be a problem on other filesystems too, but the reproducer I
> > > > > > have involves NFS.
> > > > > > 
> > > > > > On NFS, the __mark_inode_dirty() call after writing back the inode is
> > > > > > done in the rpc_release handler for COMMIT calls. This call is done
> > > > > > asynchronously after the call completes.
> > > > > > 
> > > > > > Because there's no real coordination between __mark_inode_dirty() and
> > > > > > __sync_single_inode(), it's often the case that these two calls will
> > > > > > race and __mark_inode_dirty() will get called while I_SYNC is still set.
> > > > > > When this happens, __sync_single_inode() should detect that the inode
> > > > > > was redirtied while we were flushing it and call redirty_tail() to put
> > > > > > it back on the s_dirty list.
> > > > > > 
> > > > > > When redirty_tail() puts it back on the list, it only resets the
> > > > > > dirtied_when value if it's necessary to maintain the list order. Given
> > > > > > the right situation (the right I/O patterns and a lot of luck), this
> > > > > > could result in dirtied_when never getting updated on an inode that's
> > > > > > constantly being redirtied while pdflush is writing it back.
> > > > > > 
> > > > > > Since dirtied_when is based on jiffies, it's possible for it to persist
> > > > > > across 2 sign-bit flips of jiffies. When that happens, the time_after()
> > > > > > check in sync_sb_inodes no longer works correctly and writeouts by
> > > > > > pdflush of this inode and any inodes after it on the list stop.
> > > > > > 
> > > > > > This patch fixes this by resetting the dirtied_when value on an inode
> > > > > > when we're adding it back onto an empty s_dirty list. Since we generally
> > > > > > write inodes from oldest to newest dirtied_when values, this has the
> > > > > > effect of making it so that these inodes don't end up with dirtied_when
> > > > > > values that are frozen.
> > > > > > 
> > > > > > I've also taken the liberty of fixing up the comments a bit and changed
> > > > > > the !time_after_eq() check in redirty_tail to be time_before().  That
> > > > > > should be functionally equivalent but I think it's more readable.
> > > > > > 
> > > > > > I wish this were just a theoretical problem, but we've had a customer
> > > > > > hit a variant of it in an older kernel. Newer upstream kernels have a
> > > > > > number of changes that make this problem less likely. As best I can tell
> > > > > > though, there is nothing that really prevents it.
> > > > > > 
> > > > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > > > ---
> > > > > >  fs/fs-writeback.c |   22 +++++++++++++++++-----
> > > > > >  1 files changed, 17 insertions(+), 5 deletions(-)
> > > > > > 
> > > > > > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > > > > > index e3fe991..bd2a7ff 100644
> > > > > > --- a/fs/fs-writeback.c
> > > > > > +++ b/fs/fs-writeback.c
> > > > > > @@ -184,19 +184,31 @@ static int write_inode(struct inode *inode, int sync)
> > > > > >   * furthest end of its superblock's dirty-inode list.
> > > > > >   *
> > > > > >   * Before stamping the inode's ->dirtied_when, we check to see whether it is
> > > > > > - * already the most-recently-dirtied inode on the s_dirty list.  If that is
> > > > > > - * the case then the inode must have been redirtied while it was being written
> > > > > > - * out and we don't reset its dirtied_when.
> > > > > > + * "newer" or equal to that of the most-recently-dirtied inode on the s_dirty
> > > > > > + * list. If that is the case then we don't need to restamp it to maintain the
> > > > > > + * order of the list.
> > > > > > + *
> > > > > > + * If s_dirty is empty however, then we need to go ahead and update
> > > > > > + * dirtied_when for the inode. Not doing so will mean that inodes that are
> > > > > > + * constantly being redirtied can end up with "stuck" dirtied_when values if
> > > > > > + * they happen to consistently be the first one to go back on the list.
> > > > > > + *
> > > > > > + * Since we're using jiffies values in that field, letting dirtied_when grow
> > > > > > + * too old will be problematic if jiffies wraps. It may also be causing
> > > > > > + * pdflush to flush the inode too often since it'll always look like it was
> > > > > > + * dirtied a long time ago.
> > > > > >   */
> > > > > >  static void redirty_tail(struct inode *inode)
> > > > > >  {
> > > > > >  	struct super_block *sb = inode->i_sb;
> > > > > >  
> > > > > > -	if (!list_empty(&sb->s_dirty)) {
> > > > > > +	if (list_empty(&sb->s_dirty)) {
> > > > > > +		inode->dirtied_when = jiffies;
> > > > > > +	} else {
> > > > > >  		struct inode *tail_inode;
> > > > > >  
> > > > > >  		tail_inode = list_entry(sb->s_dirty.next, struct inode, i_list);
> > > > > > -		if (!time_after_eq(inode->dirtied_when,
> > > > > > +		if (time_before(inode->dirtied_when,
> > > > > >  				tail_inode->dirtied_when))
> > > > > >  			inode->dirtied_when = jiffies;
> > > > > >  	}
> > > > > 
> > > > > I'm afraid you patch is equivalent to the following one.
> > > > > Because once the first inode's dirtied_when is set to jiffies,
> > > > > in order to keep the list in order, the following ones (mostly)
> > > > > will also be updated. A domino effect.
> > > > > 
> > > > > Thanks,
> > > > > Fengguang
> > > > > 
> > > > 
> > > > Good point. One of our other engineers proposed a similar patch
> > > > originally. I considered it but wasn't clear whether there could be a
> > > > situation where unconditionally resetting dirtied_when would be a
> > > > problem. Now that I think about it though, I think you're right...
> > > > 
> > > > So maybe something like the patch below is the right thing to do? Or,
> > > > maybe when we believe that the inode was fully cleaned and then
> > > > redirtied, we'd just unconditionally stamp dirtied_when. Something like
> > > > this maybe?
> > > > 
> > > > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > > > index bd2a7ff..596c96e 100644
> > > > --- a/fs/fs-writeback.c
> > > > +++ b/fs/fs-writeback.c
> > > > @@ -364,7 +364,8 @@ __sync_single_inode(struct inode *inode, struct writeback_control *wbc)
> > > >  			 * Someone redirtied the inode while were writing back
> > > >  			 * the pages.
> > > >  			 */
> > > > -			redirty_tail(inode);
> > > > +			inode->dirtied_when = jiffies;
> > > > +			list_move(&inode->i_list, &sb->s_dirty);
> > > >  		} else if (atomic_read(&inode->i_count)) {
> > > >  			/*
> > > >  			 * The inode is clean, inuse
> > > 
> > > Hmm...though it is still possible that you could consistently race in
> > > such a way that after writepages(), I_DIRTY is never set but the
> > > PAGECACHE_TAG_DIRTY is still set on the mapping. And then we'd be back
> > > to the same problem of a stuck dirtied_when value.
> >  
> > Jeff, did you spot real impacts of stuck dirtied_when?
> > Or it's simply possible in theory?
> > 
> > IMHO it requires extremely strong conditions to happen: It takes
> > months to wrap around the value, during that period it takes only
> > one _single_ newly dirtied inode to refresh the stuck dirtied_when. 
> > 
> 
> Yes, we did see this with inodes on NFS...
> 
> We saw it in an older kernel on several machines from one customer
> (RHEL4 2.6.9-based 32-bit kernel). Our support engineering group got a
> vmcore from one of the boxes and it had a dirtied_when value on an
> s_dirty inode that appeared to be in the future. The uptime on the box
> indicated that jiffies had wrapped once.
> 
> I'm also pretty sure I could reproduce this on a 2.6.18-based kernel
> given enough time (based on some debug patches + a reproducer program
> I have). I ran the program overnight and dirtied_when never changed.
>
> With these earlier kernels, the __mark_inode_dirty call after writeback
> is done in a function that's called from nfs_writepages(). I_LOCK is
> set there (these kernels predate the introduction of I_SYNC), so
> I_DIRTY gets set but that codepath can never update dirtied_when.
> 
> Current mainline kernels aren't as susceptible to this problem on NFS.
> The __mark_inode_dirty call there is done asynchronously as a side
> effect of some other changes that went in to fix deadlocking problems.
> So there, dirtied_when can get updated after writeback, but only if
> the rpc_release callback wins the race with __sync_single_inode.
 
There have been lots of writeback-queue updates after 2.6.18...
So my assumptions are sure not valid.

> Given the right situation though (or maybe the right filesystem), it's
> not too hard to imagine this problem occurring even in current mainline
> code with an inode that's frequently being redirtied.

My reasoning with recent kernel is: for kupdate, s_dirty enqueues only
happen in __mark_inode_dirty() and redirty_tail().  Newly dirtied
inodes will be parked in s_dirty for 30s. During which time the
actively being-redirtied inodes, if their dirtied_when is an old stuck
value, will be retried for writeback and then re-inserted into a
non-empty s_dirty queue and have their dirtied_when refreshed.

> > However...
> > 
> > > So maybe someone can explain to me why we take such great pains to
> > > preserve the dirtied_when value when we're putting the inode back on
> > > the tail of s_dirty? Why not just unconditionally reset it?
> > 
> > ...I see no obvious reasons against unconditionally resetting dirtied_when.
> > 
> > (a) Delaying an inode's writeback for 30s maybe too long - its blocking
> > condition may well go away within 1s. (b) And it would be very undesirable
> > if one big file is repeatedly redirtied hence its writeback being
> > delayed considerably.
> > 
> > However, redirty_tail() currently only tries to speedup writeback-after-redirty
> > in a _best effort_ way. It at best partially hides the above issues,
> > if there are any. In particular, if (b) is possible, the bug should
> > already show up at least in some situations.
> > 
> > For XFS, immediately sync of redirtied inode is actually discouraged:
> > 
> >         http://lkml.org/lkml/2008/1/16/491
> > 
> > 
> 
> Ok, those are good points that I need to think about.
> 
> Thanks for the help so far. I'd welcome any suggestions you have on
> how best to fix this.

For NFS, is it desirable to retry a redirtied inode after 30s, or
after a shorter 5s, or after 0.1~5s? Or the exact timing simply
doesn't matter?

Thanks,
Fengguang
