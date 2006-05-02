From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Tue, 02 May 2006 09:51:11 -0400
Message-ID: <445763CF.5040506@redhat.com>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <44572B33.4070100@RedHat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Steve Dickson wrote:

> Neil Brown wrote:
>
>>> To rephrase to make sure I understand....
>>> 1) P1(uid=1) creates an access pointer in the nfs_inode
>>> 2) P2(uid=2) sees the access pointer is not null so it adds them both
>>>    to the table, right?
>>>
>>
>>
>> Exactly.
>>
>>
>>>> We would need to be able to tell from the inode whether anything is
>>>> hashed or not.  This could simply be if the nfs_access_entry point is
>>>> non-null, and its hashlist it non-empty.  Or we could just use a bit
>>>> flag somewhere.
>>>
>>>
>>> So I guess it would be something like:
>>> if (nfs_inode->access == null)
>>>     set nfs_inode->access
>>> if (nfs_inode->access =! NULL && nfs_inode->access_hash == empty)
>>>     move both pointer into hast able.
>>> if (nfs_inode->access == null && nfs_inode->access_hash != empty)
>>>     use hastable.
>>>
>>> But now the question is how would I know when there is only one
>>> entry in the table? Or do we just let the hash table "drain"
>>> naturally and when it become empty we start with the nfs_inode->access
>>> pointer again... Is this close to what your thinking??
>>
>>
>>
>> Yes.  Spot on.  Once some inode has 'spilled' into the hash table
>> there isn't a lot to gain by "unspilling" it.
>
> Talking with Trond, he would like to do something slightly different
> which I'll outline here to make sure we are all on the same page....
>
> Basically we would maintain one global hlist (i.e. link list) that
> would contain all of the cached entries; then each nfs_inode would
> have its own LRU hlist that would contain entries that are associated
> with that nfs_inode. So each entry would be on two lists, the
> global hlist and hlist in the nfs_inode.
>

How are these lists used?

I would suggest that a global set of hash queues would work better than
a linked list and that these hash queues by used to find the cache entry
for any particular user.  Finding the entry for a particular (user,inode)
needs to be fast and linearly searching a linked list is slow.  Linear
searching needs to be avoided.  Comparing the fewest number of entries
possible will result in the best performance because the comparisons
need to take into account the entire user identification, including
the groups list.

The list in the inode seems useful, but only for purges.  Searching via
this list will be very slow once the list grows beyond a few entries.
Purging needs to be fast because purging the access cache entries for a
particular file will need to happen whenever the ctime on the file changes.
This list can be used to make it easy to find the correct entries in the
global access cache.

> We would govern memory consumption by only allowing 30 entries
> on any one hlist in the nfs_inode and by registering the globe
> hlist with the VFS shrinker which will cause the list to be prune
> when memory is needed. So this means, when the 31st entry was added
> to the hlist in the nfs_inode, the least recently used entry would
> be removed.
>

Why is there a limit at all and why is 30 the right number?  This
seems small and rather arbitrary.  If there is some way to trigger
memory reclaiming, then letting the list grow as appropriate seems
like a good thing to do.

Making sure that you are one of the original 30 users accessing the
file in order to get reasonable performance seems tricky to me.  :-)

> Locking might be a bit tricky, but do able... To make this scalable,
> I would think we would need global read/write spin_lock. The read_lock()
> would be taken when the hlist in the inode was searched and the
> write_lock() would taken when the hlist in the inode was changed
> and when the global list was prune.
>

Sorry, read/write spin lock?  I thought that spin locks were exclusive,
either the lock was held or the process spins waiting to acquire it.

A global reader/writer lock can make a lot of sense though.  The reader
lock can allow concurrent lookups in the cache and the writer lock can
serialize updates to the cache.

A global spin lock on the cache can work well.  As long as the spin lock
is not held for very long, ie. short search times, then the lack of
concurrency should not be noticeable.  One global spin lock can also
make the implementation much simpler by simplifying the locking
tremendously.  Grab the lock, search for an entry, release it.  Grab
the lock, insert a new entry, release it.  Simple and fast, not prone
to deadlock or starvation issues.

    Thanx...

       ps
