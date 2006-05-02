From: Peter Staubach <staubach@redhat.com>
Subject: Re: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Tue, 02 May 2006 10:51:48 -0400
Message-ID: <44577204.5070000@redhat.com>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com> <445763CF.5040506@redhat.com> <44576EE4.4010704@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FawEH-0001Ew-IX
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 07:51:57 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FawEG-0002KN-Av
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 07:51:57 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <44576EE4.4010704@RedHat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Steve Dickson wrote:

> Peter Staubach wrote:
>
>>> Basically we would maintain one global hlist (i.e. link list) that
>>> would contain all of the cached entries; then each nfs_inode would
>>> have its own LRU hlist that would contain entries that are associated
>>> with that nfs_inode. So each entry would be on two lists, the
>>> global hlist and hlist in the nfs_inode.
>>>
>>
>> How are these lists used?
>
> The inode hlist will be used to search and purge...
>

Eeee!  A linear search?  That gets expensive as the list grows.  A hashed
list would keep the search times down.


>>
>> I would suggest that a global set of hash queues would work better than
>> a linked list and that these hash queues by used to find the cache entry
>> for any particular user.  Finding the entry for a particular 
>> (user,inode)
>> needs to be fast and linearly searching a linked list is slow.  Linear
>> searching needs to be avoided.  Comparing the fewest number of entries
>> possible will result in the best performance because the comparisons
>> need to take into account the entire user identification, including
>> the groups list.
>
> I guess we could have the VFS  shrinker to purge a hash table just
> as well as a link list... although a hash table will have an
> small memory cost...
>

Yes, but small.  There are always space/time tradeoffs.

>> The list in the inode seems useful, but only for purges.  Searching via
>> this list will be very slow once the list grows beyond a few entries.
>> Purging needs to be fast because purging the access cache entries for a
>> particular file will need to happen whenever the ctime on the file 
>> changes.
>> This list can be used to make it easy to find the correct entries in the
>> global access cache.
>
> Seems reasonable assuming we use a hash table...
>
>>
>>> We would govern memory consumption by only allowing 30 entries
>>> on any one hlist in the nfs_inode and by registering the globe
>>> hlist with the VFS shrinker which will cause the list to be prune
>>> when memory is needed. So this means, when the 31st entry was added
>>> to the hlist in the nfs_inode, the least recently used entry would
>>> be removed.
>>>
>>
>> Why is there a limit at all and why is 30 the right number?  This
>> seems small and rather arbitrary.  If there is some way to trigger
>> memory reclaiming, then letting the list grow as appropriate seems
>> like a good thing to do.
>
> Well the vfs mechanism will be the trigger... so your saying we
> should just let the purge hlist lists in the nfs_inode grow
> untethered? How about read-only filesystems where the ctime
> will not change... I would think we might want some type of
> high water mark for that case, true?
>

Not true.  Why have a limit at all?  As long as there is memory to store
the information, why place arbitrary limits on the amount of information
stored?

As long as the memory can be reclaimed when the system needs it, then
I don't see any reason to place limits.  Whatever number that is chosen
is always the wrong number and requiring users to guess at the sizes or
take steps to tune the system, when the system could have just done the
right thing in the first place, is just wrong.

>>
>> Making sure that you are one of the original 30 users accessing the
>> file in order to get reasonable performance seems tricky to me.  :-)
>>
>>> Locking might be a bit tricky, but do able... To make this scalable,
>>> I would think we would need global read/write spin_lock. The 
>>> read_lock()
>>> would be taken when the hlist in the inode was searched and the
>>> write_lock() would taken when the hlist in the inode was changed
>>> and when the global list was prune.
>>>
>>
>> Sorry, read/write spin lock?  I thought that spin locks were exclusive,
>> either the lock was held or the process spins waiting to acquire it.
>
> See the rwlock_t lock type in asm/spinlock.h.. That's the one
> I was planning on using...


Hmmm.  A reader/writer lock which is busy waited for.  Is there any idea
of the costs of such locks?  This does seem like it would fit the bill
though.  It would be interesting to see what the access patterns for the
cache end up looking like, whether it is useful to separate readers from
writers in this fashion.

    Thanx...

       ps


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
