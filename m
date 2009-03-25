From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: reset inode dirty time when adding it back
	to empty s_dirty list
Date: Wed, 25 Mar 2009 22:16:18 +0800
Message-ID: <20090325141618.GA5684@localhost>
References: <20090324104657.6907b19e@tleilax.poochiereds.net> <20090325012829.GA7506@localhost> <20090324221528.2bb7c50b@tleilax.poochiereds.net> <20090325025037.GA17374@localhost> <20090325075110.028f0d1d@tleilax.poochiereds.net> <20090325121742.GA22869@localhost> <20090325091325.17c997fd@tleilax.poochiereds.net> <49CA2F41.8030804@themaw.net> <49CA33E7.6090309@themaw.net> <20090325100049.0cc4de87@tleilax.poochiereds.net>
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090325100049.0cc4de87@tleilax.poochiereds.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2009 at 10:00:49PM +0800, Jeff Layton wrote:
> On Wed, 25 Mar 2009 22:38:47 +0900
> Ian Kent <raven@themaw.net> wrote:
> 
> > Ian Kent wrote:
> > > Jeff Layton wrote:
> > >> On Wed, 25 Mar 2009 20:17:43 +0800
> > >> Wu Fengguang <fengguang.wu@intel.com> wrote:
> > >>
> > >>> On Wed, Mar 25, 2009 at 07:51:10PM +0800, Jeff Layton wrote:
> > >>>> On Wed, 25 Mar 2009 10:50:37 +0800
> > >>>> Wu Fengguang <fengguang.wu@intel.com> wrote:
> > >>>>
> > >>>>>> Given the right situation though (or maybe the right filesystem), it's
> > >>>>>> not too hard to imagine this problem occurring even in current mainline
> > >>>>>> code with an inode that's frequently being redirtied.
> > >>>>> My reasoning with recent kernel is: for kupdate, s_dirty enqueues only
> > >>>>> happen in __mark_inode_dirty() and redirty_tail().  Newly dirtied
> > >>>>> inodes will be parked in s_dirty for 30s. During which time the
> > >>>>> actively being-redirtied inodes, if their dirtied_when is an old stuck
> > >>>>> value, will be retried for writeback and then re-inserted into a
> > >>>>> non-empty s_dirty queue and have their dirtied_when refreshed.
> > >>>>>
> > >>>> Doesn't that assume that there are new inodes that are being dirtied?
> > >>>> If you only have the same inodes being redirtied and never any new
> > >>>> ones, the problem still occurs, right?
> > >>> Yes. But will a production server run months without making one single
> > >>> new dirtied inode? (Just out of curiosity. Not that I'm not willing to
> > >>> fix this possible issue.:)
> > >>>
> > >> Yes. It's not that the box will run that long without creating a
> > >> single new dirtied inode, but rather that it won't necessarily create
> > >> one on all of its mounts. It's often the case that someone has a
> > >> mountpoint for a dedicated purpose.
> > >>
> > >> Consider a host that has a mountpoint that contains logfiles that are
> > >> being heavily written. There's nothing that says that they must rotate
> > >> those logs over a particular period (assuming the fs has enough space,
> > >> etc). If the same ones are constantly being redirtied and no new
> > >> ones are created, then I think this problem can easily happen.
> > >>
> > >>>>>>> ...I see no obvious reasons against unconditionally resetting dirtied_when.
> > >>>>>>>
> > >>>>>>> (a) Delaying an inode's writeback for 30s maybe too long - its blocking
> > >>>>>>> condition may well go away within 1s. (b) And it would be very undesirable
> > >>>>>>> if one big file is repeatedly redirtied hence its writeback being
> > >>>>>>> delayed considerably.
> > >>>>>>>
> > >>>>>>> However, redirty_tail() currently only tries to speedup writeback-after-redirty
> > >>>>>>> in a _best effort_ way. It at best partially hides the above issues,
> > >>>>>>> if there are any. In particular, if (b) is possible, the bug should
> > >>>>>>> already show up at least in some situations.
> > >>>>>>>
> > >>>>>>> For XFS, immediately sync of redirtied inode is actually discouraged:
> > >>>>>>>
> > >>>>>>>         http://lkml.org/lkml/2008/1/16/491
> > >>>>>>>
> > >>>>>>>
> > >>>>>> Ok, those are good points that I need to think about.
> > >>>>>>
> > >>>>>> Thanks for the help so far. I'd welcome any suggestions you have on
> > >>>>>> how best to fix this.
> > >>>>> For NFS, is it desirable to retry a redirtied inode after 30s, or
> > >>>>> after a shorter 5s, or after 0.1~5s? Or the exact timing simply
> > >>>>> doesn't matter?
> > >>>>>
> > >>>> I don't really consider NFS to be a special case here. It just happens
> > >>>> to be where we saw the problem originally. Some of its characteristics
> > >>>> might make it easier to hit this, but I'm not certain of that.
> > >>> Now there are now two possible solutions:
> > >>> - unconditionally update dirtied_when in redirty_tail();
> > >>> - keep dirtied_when and redirty inodes to a new dedicated queue.
> > >>> The first one involves less code, the second one allows more flexible timing.
> > >>>
> > >>> NFS/XFS could be a good starting point for discussing the
> > >>> requirements, so that we can reach a suitable solution.
> > >>>
> > >> It sounds like it, yes. I saw that you posted some patches in January
> > >> (including your s_more_io_wait patch). I'll give those a closer look.
> > >> Adding the new s_more_io_wait queue is interesting and might sidestep
> > >> this problem nicely.
> > >>
> > > 
> > > Yes, I was looking at that bit of code but, so far, I think it won't be
> > > called for the case we are trying to describe.
> > 
> > I take that back.
> > As Jeff pointed out I haven't seen these patches and can't seem to find
> > them in my fsdevel list folder, Wu can you send me a copy please?
> > 
> 
> Actually, I think you were right. We still have this check in
> generic_sync_sb_inodes() even with Wu's January 2008 patches:
> 
> 	/* Was this inode dirtied after sync_sb_inodes was called? */
> 	if (time_after(inode->dirtied_when, start))
> 		break;

Yeah, ugly code. Jens' per-bdi flush daemons should eliminate it...

> ...this check is the crux of the problem. We're assuming that the
> dirtied_when value will never appear to be in the future. If we change
> this check so that it's checking that dirtied_when is between "start"
> and "now", then this problem basically goes away.

Yeah that turns the problem into a temporary and tolerable one.

> We'll probably also need to change the test in move_expired_inodes
> too, unless Wu's changes go in.

So the most simple (and complete) solution is still this one ;-)

Thanks,
Fengguang

---
 fs/fs-writeback.c |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

--- mm.orig/fs/fs-writeback.c
+++ mm/fs/fs-writeback.c
@@ -182,24 +182,12 @@ static int write_inode(struct inode *ino
 /*
  * Redirty an inode: set its when-it-was dirtied timestamp and move it to the
  * furthest end of its superblock's dirty-inode list.
- *
- * Before stamping the inode's ->dirtied_when, we check to see whether it is
- * already the most-recently-dirtied inode on the s_dirty list.  If that is
- * the case then the inode must have been redirtied while it was being written
- * out and we don't reset its dirtied_when.
  */
 static void redirty_tail(struct inode *inode)
 {
 	struct super_block *sb = inode->i_sb;
 
-	if (!list_empty(&sb->s_dirty)) {
-		struct inode *tail_inode;
-
-		tail_inode = list_entry(sb->s_dirty.next, struct inode, i_list);
-		if (!time_after_eq(inode->dirtied_when,
-				tail_inode->dirtied_when))
-			inode->dirtied_when = jiffies;
-	}
+	inode->dirtied_when = jiffies;
 	list_move(&inode->i_list, &sb->s_dirty);
 }
 
