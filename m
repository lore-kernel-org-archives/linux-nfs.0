From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: reset inode dirty time when adding it back
	to empty s_dirty list
Date: Wed, 25 Mar 2009 10:25:39 +0800
Message-ID: <20090325022539.GB17502@localhost>
References: <1237840233-11045-1-git-send-email-jlayton@redhat.com> <20090324135720.GA25314@localhost> <20090324102806.4f38fd26@tleilax.poochiereds.net> <20090324104657.6907b19e@tleilax.poochiereds.net> <49C8F66B.3060401@themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hch@infradead.org" <hch@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Ian Kent <raven@themaw.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <49C8F66B.3060401@themaw.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ian,

On Tue, Mar 24, 2009 at 11:04:11PM +0800, Ian Kent wrote:
> Jeff Layton wrote:
> > On Tue, 24 Mar 2009 10:28:06 -0400
> > Jeff Layton <jlayton@redhat.com> wrote:
> > 
> >> On Tue, 24 Mar 2009 21:57:20 +0800
> >> Wu Fengguang <fengguang.wu@intel.com> wrote:
> >>
> >>> Hi Jeff,
> >>>
> >>> On Mon, Mar 23, 2009 at 04:30:33PM -0400, Jeff Layton wrote:
> >>>> This may be a problem on other filesystems too, but the reproducer I
> >>>> have involves NFS.
> >>>>
> >>>> On NFS, the __mark_inode_dirty() call after writing back the inode is
> >>>> done in the rpc_release handler for COMMIT calls. This call is done
> >>>> asynchronously after the call completes.
> >>>>
> >>>> Because there's no real coordination between __mark_inode_dirty() and
> >>>> __sync_single_inode(), it's often the case that these two calls will
> >>>> race and __mark_inode_dirty() will get called while I_SYNC is still set.
> >>>> When this happens, __sync_single_inode() should detect that the inode
> >>>> was redirtied while we were flushing it and call redirty_tail() to put
> >>>> it back on the s_dirty list.
> >>>>
> >>>> When redirty_tail() puts it back on the list, it only resets the
> >>>> dirtied_when value if it's necessary to maintain the list order. Given
> >>>> the right situation (the right I/O patterns and a lot of luck), this
> >>>> could result in dirtied_when never getting updated on an inode that's
> >>>> constantly being redirtied while pdflush is writing it back.
> >>>>
> >>>> Since dirtied_when is based on jiffies, it's possible for it to persist
> >>>> across 2 sign-bit flips of jiffies. When that happens, the time_after()
> >>>> check in sync_sb_inodes no longer works correctly and writeouts by
> >>>> pdflush of this inode and any inodes after it on the list stop.
> >>>>
> >>>> This patch fixes this by resetting the dirtied_when value on an inode
> >>>> when we're adding it back onto an empty s_dirty list. Since we generally
> >>>> write inodes from oldest to newest dirtied_when values, this has the
> >>>> effect of making it so that these inodes don't end up with dirtied_when
> >>>> values that are frozen.
> >>>>
> >>>> I've also taken the liberty of fixing up the comments a bit and changed
> >>>> the !time_after_eq() check in redirty_tail to be time_before().  That
> >>>> should be functionally equivalent but I think it's more readable.
> >>>>
> >>>> I wish this were just a theoretical problem, but we've had a customer
> >>>> hit a variant of it in an older kernel. Newer upstream kernels have a
> >>>> number of changes that make this problem less likely. As best I can tell
> >>>> though, there is nothing that really prevents it.
> >>>>
> >>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> >>>> ---
> >>>>  fs/fs-writeback.c |   22 +++++++++++++++++-----
> >>>>  1 files changed, 17 insertions(+), 5 deletions(-)
> >>>>
> >>>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> >>>> index e3fe991..bd2a7ff 100644
> >>>> --- a/fs/fs-writeback.c
> >>>> +++ b/fs/fs-writeback.c
> >>>> @@ -184,19 +184,31 @@ static int write_inode(struct inode *inode, int sync)
> >>>>   * furthest end of its superblock's dirty-inode list.
> >>>>   *
> >>>>   * Before stamping the inode's ->dirtied_when, we check to see whether it is
> >>>> - * already the most-recently-dirtied inode on the s_dirty list.  If that is
> >>>> - * the case then the inode must have been redirtied while it was being written
> >>>> - * out and we don't reset its dirtied_when.
> >>>> + * "newer" or equal to that of the most-recently-dirtied inode on the s_dirty
> >>>> + * list. If that is the case then we don't need to restamp it to maintain the
> >>>> + * order of the list.
> >>>> + *
> >>>> + * If s_dirty is empty however, then we need to go ahead and update
> >>>> + * dirtied_when for the inode. Not doing so will mean that inodes that are
> >>>> + * constantly being redirtied can end up with "stuck" dirtied_when values if
> >>>> + * they happen to consistently be the first one to go back on the list.
> >>>> + *
> >>>> + * Since we're using jiffies values in that field, letting dirtied_when grow
> >>>> + * too old will be problematic if jiffies wraps. It may also be causing
> >>>> + * pdflush to flush the inode too often since it'll always look like it was
> >>>> + * dirtied a long time ago.
> >>>>   */
> >>>>  static void redirty_tail(struct inode *inode)
> >>>>  {
> >>>>  	struct super_block *sb = inode->i_sb;
> >>>>  
> >>>> -	if (!list_empty(&sb->s_dirty)) {
> >>>> +	if (list_empty(&sb->s_dirty)) {
> >>>> +		inode->dirtied_when = jiffies;
> >>>> +	} else {
> >>>>  		struct inode *tail_inode;
> >>>>  
> >>>>  		tail_inode = list_entry(sb->s_dirty.next, struct inode, i_list);
> >>>> -		if (!time_after_eq(inode->dirtied_when,
> >>>> +		if (time_before(inode->dirtied_when,
> >>>>  				tail_inode->dirtied_when))
> >>>>  			inode->dirtied_when = jiffies;
> >>>>  	}
> >>> I'm afraid you patch is equivalent to the following one.
> >>> Because once the first inode's dirtied_when is set to jiffies,
> >>> in order to keep the list in order, the following ones (mostly)
> >>> will also be updated. A domino effect.
> >>>
> >>> Thanks,
> >>> Fengguang
> >>>
> >> Good point. One of our other engineers proposed a similar patch
> >> originally. I considered it but wasn't clear whether there could be a
> >> situation where unconditionally resetting dirtied_when would be a
> >> problem. Now that I think about it though, I think you're right...
> >>
> >> So maybe something like the patch below is the right thing to do? Or,
> >> maybe when we believe that the inode was fully cleaned and then
> >> redirtied, we'd just unconditionally stamp dirtied_when. Something like
> >> this maybe?
> >>
> >> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> >> index bd2a7ff..596c96e 100644
> >> --- a/fs/fs-writeback.c
> >> +++ b/fs/fs-writeback.c
> >> @@ -364,7 +364,8 @@ __sync_single_inode(struct inode *inode, struct writeback_control *wbc)
> >>  			 * Someone redirtied the inode while were writing back
> >>  			 * the pages.
> >>  			 */
> >> -			redirty_tail(inode);
> >> +			inode->dirtied_when = jiffies;
> >> +			list_move(&inode->i_list, &sb->s_dirty);
> >>  		} else if (atomic_read(&inode->i_count)) {
> >>  			/*
> >>  			 * The inode is clean, inuse
> > 
> > Hmm...though it is still possible that you could consistently race in
> > such a way that after writepages(), I_DIRTY is never set but the
> > PAGECACHE_TAG_DIRTY is still set on the mapping. And then we'd be back
> > to the same problem of a stuck dirtied_when value.
> > 
> > So maybe someone can explain to me why we take such great pains to
> > preserve the dirtied_when value when we're putting the inode back on
> > the tail of s_dirty? Why not just unconditionally reset it?
> 
> I think that redirty_tail() is the best place for this as it is a 
> central location where dirtied_when can be updated. Then all we have to 
> worry about is making sure it is called from all the locations needed.
> 
> I'm not sure that removing the comment is a good idea (the Wu Fengguang 
> patch) but it probably needs to be revised to explain why dirtied_when 
> is forcing a rewrite of the list entry times.

The comment basically says "we do not want to reset dirtied_when for
inodes redirtied while being written out". I guess there are two intentions:

- to retry its writeback as soon as possible and avoid long 30s delays;
- to keep a faithful dirtied_when.

The first one is best effort anyway, changing it should not create new
bugs. The second one shall not, either. Due to the very limited use of
dirtied_when. 

However, we do have another cheap solution that can retain both of the
two original intentions. The main idea is to introduce a new s_more_io_wait
queue, and convert the current redirty_tail() calls to either
requeue_io_wait() or some completely_dirty_inode().

Thanks,
Fengguang
---
(a not-up-to-date patch)
writeback: introduce super_block.s_more_io_wait

Introduce super_block.s_more_io_wait to park inodes that for some reason cannot
be synced immediately. They will be revisited in the next s_io enqueue time(<=5s).

The new data flow after this patchset:

s_dirty --> s_io --> s_more_io/s_more_io_wait --+
             ^                                  |
	     |                                  |
	     +----------------------------------+

- to fill s_io:
		s_more_io +
		s_dirty(expired) +
		s_more_io_wait
				---> s_io
- to drain s_io:
		s_io -+--> clean inodes goto inode_in_use/inode_unused
		      |
		      +--> s_more_io
		      |
		      +--> s_more_io_wait

Obviously there're no ordering or starvation problems in the queues:
- s_dirty is now a strict FIFO queue
- inode.dirtied_when is only set when made dirty
- once exipired, the dirty inode will stay in s_*io* queues until made clean
- the dirty inodes in s_*io* will be revisted in order, hence small files won't
  be starved by big dirty files.

Cc: David Chinner <dgc@sgi.com>
Cc: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Fengguang Wu <wfg@mail.ustc.edu.cn>
---
 fs/fs-writeback.c  |   19 +++++++++++++++----
 fs/super.c         |    1 +
 include/linux/fs.h |    1 +
 3 files changed, 17 insertions(+), 4 deletions(-)

--- linux-mm.orig/fs/fs-writeback.c
+++ linux-mm/fs/fs-writeback.c
@@ -172,6 +172,14 @@ static void requeue_io(struct inode *ino
 	list_move(&inode->i_list, &inode->i_sb->s_more_io);
 }
 
+/*
+ * The inode should be retried after _sleeping_ for a while.
+ */
+static void requeue_io_wait(struct inode *inode)
+{
+	list_move(&inode->i_list, &inode->i_sb->s_more_io_wait);
+}
+
 static void inode_sync_complete(struct inode *inode)
 {
 	/*
@@ -200,7 +208,8 @@ static void move_expired_inodes(struct l
 
 /*
  * Queue all expired dirty inodes for io, eldest first:
- * (entrance) => s_dirty inodes
+ * (entrance) => s_more_io_wait inodes
+ *            => s_dirty inodes
  *            => s_more_io inodes
  *            => remaining inodes in s_io => (dequeue for sync)
  */
@@ -209,13 +218,15 @@ static void queue_io(struct super_block 
 {
 	list_splice_init(&sb->s_more_io, &sb->s_io);
 	move_expired_inodes(&sb->s_dirty, &sb->s_io, older_than_this);
+	list_splice_init(&sb->s_more_io_wait, &sb->s_io);
 }
 
 int sb_has_dirty_inodes(struct super_block *sb)
 {
-	return !list_empty(&sb->s_dirty) ||
-	       !list_empty(&sb->s_io) ||
-	       !list_empty(&sb->s_more_io);
+	return !list_empty(&sb->s_dirty)   ||
+	       !list_empty(&sb->s_io)      ||
+	       !list_empty(&sb->s_more_io) ||
+	       !list_empty(&sb->s_more_io_wait);
 }
 EXPORT_SYMBOL(sb_has_dirty_inodes);
 
--- linux-mm.orig/fs/super.c
+++ linux-mm/fs/super.c
@@ -64,6 +64,7 @@ static struct super_block *alloc_super(s
 		INIT_LIST_HEAD(&s->s_dirty);
 		INIT_LIST_HEAD(&s->s_io);
 		INIT_LIST_HEAD(&s->s_more_io);
+		INIT_LIST_HEAD(&s->s_more_io_wait);
 		INIT_LIST_HEAD(&s->s_files);
 		INIT_LIST_HEAD(&s->s_instances);
 		INIT_HLIST_HEAD(&s->s_anon);
--- linux-mm.orig/include/linux/fs.h
+++ linux-mm/include/linux/fs.h
@@ -1012,6 +1012,7 @@ struct super_block {
 	struct list_head	s_dirty;	/* dirty inodes */
 	struct list_head	s_io;		/* parked for writeback */
 	struct list_head	s_more_io;	/* parked for more writeback */
+	struct list_head	s_more_io_wait;	/* parked for sleep-then-retry */
 	struct hlist_head	s_anon;		/* anonymous dentries for (nfs) exporting */
 	struct list_head	s_files;
 
