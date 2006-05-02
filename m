From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Tue, 02 May 2006 05:49:39 -0400
Message-ID: <44572B33.4070100@RedHat.com>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net
In-Reply-To: <17487.62730.16297.979429@cse.unsw.edu.au>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Neil Brown wrote:
>>To rephrase to make sure I understand....
>>1) P1(uid=1) creates an access pointer in the nfs_inode
>>2) P2(uid=2) sees the access pointer is not null so it adds them both
>>    to the table, right?
>>
> 
> 
> Exactly.
> 
> 
>>>We would need to be able to tell from the inode whether anything is
>>>hashed or not.  This could simply be if the nfs_access_entry point is
>>>non-null, and its hashlist it non-empty.  Or we could just use a bit
>>>flag somewhere.
>>
>>So I guess it would be something like:
>>if (nfs_inode->access == null)
>>     set nfs_inode->access
>>if (nfs_inode->access =! NULL && nfs_inode->access_hash == empty)
>>     move both pointer into hast able.
>>if (nfs_inode->access == null && nfs_inode->access_hash != empty)
>>     use hastable.
>>
>>But now the question is how would I know when there is only one
>>entry in the table? Or do we just let the hash table "drain"
>>naturally and when it become empty we start with the nfs_inode->access
>>pointer again... Is this close to what your thinking??
> 
> 
> Yes.  Spot on.  Once some inode has 'spilled' into the hash table
> there isn't a lot to gain by "unspilling" it.
Talking with Trond, he would like to do something slightly different
which I'll outline here to make sure we are all on the same page....

Basically we would maintain one global hlist (i.e. link list) that
would contain all of the cached entries; then each nfs_inode would
have its own LRU hlist that would contain entries that are associated
with that nfs_inode. So each entry would be on two lists, the
global hlist and hlist in the nfs_inode.

We would govern memory consumption by only allowing 30 entries
on any one hlist in the nfs_inode and by registering the globe
hlist with the VFS shrinker which will cause the list to be prune
when memory is needed. So this means, when the 31st entry was added
to the hlist in the nfs_inode, the least recently used entry would
be removed.

Locking might be a bit tricky, but do able... To make this scalable,
I would think we would need global read/write spin_lock. The read_lock()
would be taken when the hlist in the inode was searched and the
write_lock() would taken when the hlist in the inode was changed
and when the global list was prune.

Comments?

steved.
