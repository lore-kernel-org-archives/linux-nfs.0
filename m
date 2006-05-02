From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Tue, 02 May 2006 10:38:28 -0400
Message-ID: <44576EE4.4010704@RedHat.com>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com> <445763CF.5040506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <445763CF.5040506@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Peter Staubach wrote:
>> Basically we would maintain one global hlist (i.e. link list) that
>> would contain all of the cached entries; then each nfs_inode would
>> have its own LRU hlist that would contain entries that are associated
>> with that nfs_inode. So each entry would be on two lists, the
>> global hlist and hlist in the nfs_inode.
>>
> 
> How are these lists used?
The inode hlist will be used to search and purge...

> 
> I would suggest that a global set of hash queues would work better than
> a linked list and that these hash queues by used to find the cache entry
> for any particular user.  Finding the entry for a particular (user,inode)
> needs to be fast and linearly searching a linked list is slow.  Linear
> searching needs to be avoided.  Comparing the fewest number of entries
> possible will result in the best performance because the comparisons
> need to take into account the entire user identification, including
> the groups list.
I guess we could have the VFS  shrinker to purge a hash table just
as well as a link list... although a hash table will have an
small memory cost...

> The list in the inode seems useful, but only for purges.  Searching via
> this list will be very slow once the list grows beyond a few entries.
> Purging needs to be fast because purging the access cache entries for a
> particular file will need to happen whenever the ctime on the file changes.
> This list can be used to make it easy to find the correct entries in the
> global access cache.
Seems reasonable assuming we use a hash table...

> 
>> We would govern memory consumption by only allowing 30 entries
>> on any one hlist in the nfs_inode and by registering the globe
>> hlist with the VFS shrinker which will cause the list to be prune
>> when memory is needed. So this means, when the 31st entry was added
>> to the hlist in the nfs_inode, the least recently used entry would
>> be removed.
>>
> 
> Why is there a limit at all and why is 30 the right number?  This
> seems small and rather arbitrary.  If there is some way to trigger
> memory reclaiming, then letting the list grow as appropriate seems
> like a good thing to do.
Well the vfs mechanism will be the trigger... so your saying we
should just let the purge hlist lists in the nfs_inode grow
untethered? How about read-only filesystems where the ctime
will not change... I would think we might want some type of
high water mark for that case, true?

> 
> Making sure that you are one of the original 30 users accessing the
> file in order to get reasonable performance seems tricky to me.  :-)
> 
>> Locking might be a bit tricky, but do able... To make this scalable,
>> I would think we would need global read/write spin_lock. The read_lock()
>> would be taken when the hlist in the inode was searched and the
>> write_lock() would taken when the hlist in the inode was changed
>> and when the global list was prune.
>>
> 
> Sorry, read/write spin lock?  I thought that spin locks were exclusive,
> either the lock was held or the process spins waiting to acquire it.
See the rwlock_t lock type in asm/spinlock.h.. That's the one
I was planning on using...


steved.
