From: Ian Kent <raven@themaw.net>
Subject: Re: [PATCH] writeback: reset inode dirty time when adding it back
 to empty s_dirty list
Date: Wed, 25 Mar 2009 14:03:25 +0900
Message-ID: <49C9BB1D.8000603@themaw.net>
References: <1237840233-11045-1-git-send-email-jlayton@redhat.com> <20090324135720.GA25314@localhost> <20090324102806.4f38fd26@tleilax.poochiereds.net> <20090324104657.6907b19e@tleilax.poochiereds.net> <20090325012829.GA7506@localhost> <49C99D64.5070800@themaw.net> <20090325032854.GA18741@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hch@infradead.org" <hch@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090325032854.GA18741@localhost>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wu Fengguang wrote:
> On Wed, Mar 25, 2009 at 10:56:36AM +0800, Ian Kent wrote:
>> Wu Fengguang wrote:
>>> Hi Jeff,
>>>
>>> On Tue, Mar 24, 2009 at 10:46:57PM +0800, Jeff Layton wrote:
>>>> On Tue, 24 Mar 2009 10:28:06 -0400
>>>> Jeff Layton <jlayton@redhat.com> wrote:
>>>>
>>>>> On Tue, 24 Mar 2009 21:57:20 +0800
>>>>> Wu Fengguang <fengguang.wu@intel.com> wrote:
>>>>>
>>>>>> Hi Jeff,
>>>>>>
>>>>>> On Mon, Mar 23, 2009 at 04:30:33PM -0400, Jeff Layton wrote:
>>>>>>> This may be a problem on other filesystems too, but the reproducer I
>>>>>>> have involves NFS.
>>>>>>>
>>>>>>> On NFS, the __mark_inode_dirty() call after writing back the inode is
>>>>>>> done in the rpc_release handler for COMMIT calls. This call is done
>>>>>>> asynchronously after the call completes.
>>>>>>>
>>>>>>> Because there's no real coordination between __mark_inode_dirty() and
>>>>>>> __sync_single_inode(), it's often the case that these two calls will
>>>>>>> race and __mark_inode_dirty() will get called while I_SYNC is still set.
>>>>>>> When this happens, __sync_single_inode() should detect that the inode
>>>>>>> was redirtied while we were flushing it and call redirty_tail() to put
>>>>>>> it back on the s_dirty list.
>>>>>>>
>>>>>>> When redirty_tail() puts it back on the list, it only resets the
>>>>>>> dirtied_when value if it's necessary to maintain the list order. Given
>>>>>>> the right situation (the right I/O patterns and a lot of luck), this
>>>>>>> could result in dirtied_when never getting updated on an inode that's
>>>>>>> constantly being redirtied while pdflush is writing it back.
>>>>>>>
>>>>>>> Since dirtied_when is based on jiffies, it's possible for it to persist
>>>>>>> across 2 sign-bit flips of jiffies. When that happens, the time_after()
>>>>>>> check in sync_sb_inodes no longer works correctly and writeouts by
>>>>>>> pdflush of this inode and any inodes after it on the list stop.
>>>>>>>
>>>>>>> This patch fixes this by resetting the dirtied_when value on an inode
>>>>>>> when we're adding it back onto an empty s_dirty list. Since we generally
>>>>>>> write inodes from oldest to newest dirtied_when values, this has the
>>>>>>> effect of making it so that these inodes don't end up with dirtied_when
>>>>>>> values that are frozen.
>>>>>>>
>>>>>>> I've also taken the liberty of fixing up the comments a bit and changed
>>>>>>> the !time_after_eq() check in redirty_tail to be time_before().  That
>>>>>>> should be functionally equivalent but I think it's more readable.
>>>>>>>
>>>>>>> I wish this were just a theoretical problem, but we've had a customer
>>>>>>> hit a variant of it in an older kernel. Newer upstream kernels have a
>>>>>>> number of changes that make this problem less likely. As best I can tell
>>>>>>> though, there is nothing that really prevents it.
>>>>>>>
>>>>>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>>>>>> ---
>>>>>>>  fs/fs-writeback.c |   22 +++++++++++++++++-----
>>>>>>>  1 files changed, 17 insertions(+), 5 deletions(-)
>>>>>>>
>>>>>>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
>>>>>>> index e3fe991..bd2a7ff 100644
>>>>>>> --- a/fs/fs-writeback.c
>>>>>>> +++ b/fs/fs-writeback.c
>>>>>>> @@ -184,19 +184,31 @@ static int write_inode(struct inode *inode, int sync)
>>>>>>>   * furthest end of its superblock's dirty-inode list.
>>>>>>>   *
>>>>>>>   * Before stamping the inode's ->dirtied_when, we check to see whether it is
>>>>>>> - * already the most-recently-dirtied inode on the s_dirty list.  If that is
>>>>>>> - * the case then the inode must have been redirtied while it was being written
>>>>>>> - * out and we don't reset its dirtied_when.
>>>>>>> + * "newer" or equal to that of the most-recently-dirtied inode on the s_dirty
>>>>>>> + * list. If that is the case then we don't need to restamp it to maintain the
>>>>>>> + * order of the list.
>>>>>>> + *
>>>>>>> + * If s_dirty is empty however, then we need to go ahead and update
>>>>>>> + * dirtied_when for the inode. Not doing so will mean that inodes that are
>>>>>>> + * constantly being redirtied can end up with "stuck" dirtied_when values if
>>>>>>> + * they happen to consistently be the first one to go back on the list.
>>>>>>> + *
>>>>>>> + * Since we're using jiffies values in that field, letting dirtied_when grow
>>>>>>> + * too old will be problematic if jiffies wraps. It may also be causing
>>>>>>> + * pdflush to flush the inode too often since it'll always look like it was
>>>>>>> + * dirtied a long time ago.
>>>>>>>   */
>>>>>>>  static void redirty_tail(struct inode *inode)
>>>>>>>  {
>>>>>>>  	struct super_block *sb = inode->i_sb;
>>>>>>>  
>>>>>>> -	if (!list_empty(&sb->s_dirty)) {
>>>>>>> +	if (list_empty(&sb->s_dirty)) {
>>>>>>> +		inode->dirtied_when = jiffies;
>>>>>>> +	} else {
>>>>>>>  		struct inode *tail_inode;
>>>>>>>  
>>>>>>>  		tail_inode = list_entry(sb->s_dirty.next, struct inode, i_list);
>>>>>>> -		if (!time_after_eq(inode->dirtied_when,
>>>>>>> +		if (time_before(inode->dirtied_when,
>>>>>>>  				tail_inode->dirtied_when))
>>>>>>>  			inode->dirtied_when = jiffies;
>>>>>>>  	}
>>>>>> I'm afraid you patch is equivalent to the following one.
>>>>>> Because once the first inode's dirtied_when is set to jiffies,
>>>>>> in order to keep the list in order, the following ones (mostly)
>>>>>> will also be updated. A domino effect.
>>>>>>
>>>>>> Thanks,
>>>>>> Fengguang
>>>>>>
>>>>> Good point. One of our other engineers proposed a similar patch
>>>>> originally. I considered it but wasn't clear whether there could be a
>>>>> situation where unconditionally resetting dirtied_when would be a
>>>>> problem. Now that I think about it though, I think you're right...
>>>>>
>>>>> So maybe something like the patch below is the right thing to do? Or,
>>>>> maybe when we believe that the inode was fully cleaned and then
>>>>> redirtied, we'd just unconditionally stamp dirtied_when. Something like
>>>>> this maybe?
>>>>>
>>>>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
>>>>> index bd2a7ff..596c96e 100644
>>>>> --- a/fs/fs-writeback.c
>>>>> +++ b/fs/fs-writeback.c
>>>>> @@ -364,7 +364,8 @@ __sync_single_inode(struct inode *inode, struct writeback_control *wbc)
>>>>>  			 * Someone redirtied the inode while were writing back
>>>>>  			 * the pages.
>>>>>  			 */
>>>>> -			redirty_tail(inode);
>>>>> +			inode->dirtied_when = jiffies;
>>>>> +			list_move(&inode->i_list, &sb->s_dirty);
>>>>>  		} else if (atomic_read(&inode->i_count)) {
>>>>>  			/*
>>>>>  			 * The inode is clean, inuse
>>>> Hmm...though it is still possible that you could consistently race in
>>>> such a way that after writepages(), I_DIRTY is never set but the
>>>> PAGECACHE_TAG_DIRTY is still set on the mapping. And then we'd be back
>>>> to the same problem of a stuck dirtied_when value.
>>>  
>>> Jeff, did you spot real impacts of stuck dirtied_when?
>>> Or it's simply possible in theory?
>> We've seen it with Web Server logging to an NFS mounted filesystem, and 
>> that is both continuous and frequent.
> 
> What's your kernel version? In old kernels, the s_dirty queue will be
> completely spliced into s_io, being walked on until hit first not-yet-expired
> inode, and have the remaining s_io inodes spliced back to s_dirty.

As you know the problem has been observed in an older kernel.
But I'm looking at the code in the current Linus tree and also the mmtom
tree with what has been observed in mind.

> 
> The new behavior is to move only expired inodes into s_io. So the
> redirtied inodes will now be inserted into a *non-empty* s_dirty if
> there are any newly dirtied inodes, and have their stuck dirtied_when
> refreshed. This makes a huge difference.

Yes, Jeffs work indicates that to be the case but, based on the what
we've seen in older kernels, I'm having trouble seeing that it isn't
still a problem in the current code.

In the current code, if an inode that is constantly marked as dirty gets
to the tail of the s_dirty list how does its dirtied_when get updated?

> 
>>> IMHO it requires extremely strong conditions to happen: It takes
>>> months to wrap around the value, during that period it takes only
>>> one _single_ newly dirtied inode to refresh the stuck dirtied_when. 
>> Sure, but with the above workload we see inodes continuously dirty and, 
>> as they age, find their way to the tail of the queue. They continue to 
>> age and when the time difference between dirtied_when and jiffies (or 
>> start in generic_sync_sb_inodes()) becomes greater than 2^31 the logic 
>> of the time_* macros inverts and dirtied_when appears to be in the 
>> future. Then, in generic_sync_sb_inodes() the check:
>>
>>       /* Was this inode dirtied after sync_sb_inodes was called? */
>>       if (time_after(inode->dirtied_when, start))
>>               break;
>>
>> always breaks out without doing anything and writback for the filesystem 
>> stops.
>>
>> Also, from the investigation, we see that it takes a while before the 
>> inode dirtied_when gets stuck so the problem isn't seen until around 50 
>> days or more of uptime.
>>
>> The other way to work around this without changing dirtied_when is to 
>> use a range for the aove check in generic_sync_sb_inodes(). Like,
>>
>> if (dirtied_when is between start and "right now")
>>       break;
>>
>> But the problem with this is that there are other places these macros 
>> could yield incorrect and possibly undesirable results, such as in 
>> queue_io() (via move_expired_inodes()). Which is what lead us to use the 
>> more aggressive dirtied_when stamping.
>>
>>> However...
>>>
>>>> So maybe someone can explain to me why we take such great pains to
>>>> preserve the dirtied_when value when we're putting the inode back on
>>>> the tail of s_dirty? Why not just unconditionally reset it?
>>> ...I see no obvious reasons against unconditionally resetting dirtied_when.
>>>
>>> (a) Delaying an inode's writeback for 30s maybe too long - its blocking
>>> condition may well go away within 1s. (b) And it would be very undesirable
>>> if one big file is repeatedly redirtied hence its writeback being
>>> delayed considerably.
>>>
>>> However, redirty_tail() currently only tries to speedup writeback-after-redirty
>>> in a _best effort_ way. It at best partially hides the above issues,
>>> if there are any. In particular, if (b) is possible, the bug should
>>> already show up at least in some situations.
>>>
>>> For XFS, immediately sync of redirtied inode is actually discouraged:
>>>
>>>         http://lkml.org/lkml/2008/1/16/491
>> Yes, that's an interesting (and unfortuneate) case.
>>
>> It looks like the potential to re-write an already written inode is also 
>> present because in generic_sync_sb_inodes() the inode could be marked as 
>> dirty either "before" or after the writeback. I can't see any way to 
>> detect and handle this within the current code.
> 
> I'm not sure. Can you elaborate the problem (and why it's a problem)
> with flags, states etc.?

It's only a problem if writing the same inode out twice is considered a
problem. Probably not a big deal.

It looks to me like __mark_inode_dirty() can be called at any time while
 I_SYNC is set in __sync_single_inode() and the inode_lock is not held.
So an inode can be marked dirty at any time between the inode_lock
release and when it is re-aquired so it looks like the inode could be
written out either before or after the inode dirty marking occurs. So if
the inode is written after the dirty marking it will still be seen as
dirty even though it has already been written out.

But this is just my impression from reading the code and I could be
mistaken.

Ian

