From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 03 May 2006 00:42:51 -0400
Message-ID: <445834CB.4050408@citi.umich.edu>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <44572B33.4070100@RedHat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Steve Dickson wrote:
> Talking with Trond, he would like to do something slightly different
> which I'll outline here to make sure we are all on the same page....
> 
> Basically we would maintain one global hlist (i.e. link list) that
> would contain all of the cached entries; then each nfs_inode would
> have its own LRU hlist that would contain entries that are associated
> with that nfs_inode. So each entry would be on two lists, the
> global hlist and hlist in the nfs_inode.
> 
> We would govern memory consumption by only allowing 30 entries
> on any one hlist in the nfs_inode and by registering the globe
> hlist with the VFS shrinker which will cause the list to be prune
> when memory is needed. So this means, when the 31st entry was added
> to the hlist in the nfs_inode, the least recently used entry would
> be removed.
> 
> Locking might be a bit tricky, but do able... To make this scalable,
> I would think we would need global read/write spin_lock. The read_lock()
> would be taken when the hlist in the inode was searched and the
> write_lock() would taken when the hlist in the inode was changed
> and when the global list was prune.

For the sake of discussion, let me propose some design alternatives.

1.  We already have cache shrinkage built in: when an inode is purged 
due to cache shrinkage, the access cache for that inode is purged as 
well.  In other words, there is already a mechanism for external memory 
pressure to shrink this cache.  I don't see a strong need to complicate 
matters by adding more cache shrinkage than already exists with normal 
inode and dentry cache shrinkage.

Now you won't need to hold a global lock to serialize normal accesses 
with purging and cache garbage collection.  Eliminating global 
serialization is a Good Thing (tm).

2.  Use a radix tree per inode.  The radix tree key is a uid or gid, and 
each node in a tree stores the access mask for that {inode, uid} tuple. 
  This seems a lot simpler to implement than a dual hlist, and will 
scale automatically with a large number of uids accessing the same 
inode.  The nodes are small, and you don't need to allocate a big chunk 
of contiguous memory for a hash table.

3.  Instead of serializing by spinning, you should use a semaphore.  The 
reason for this is that when multiple processes owned by the same uid 
access the same inode concurrently, only the first process should be 
allowed to generate a real ACCESS request; otherwise they will race and 
potentially all of them could generate the same ACCESS request concurrently.

You will need to serialize on-the-wire requests with accesses to the 
cache, and such wire requests will need the waiting processes to sleep, 
not spin.

4.  You will need some mechanism for ensuring that the contents of the 
access cache are "up to date".  You will need some way of deciding when 
to revalidate each {inode, uid} tuple.  Based on what Peter said, I 
think you are going to check the inode's ctime, and purge the whole 
access cache for an inode if its ctime changes.  But you may need 
something like an nfs_revalidate_inode() before you proceed to examine 
an inode's access cache.  It might be more efficient to generate just an 
ACCESS request instead of a GETATTR followed by an ACCESS, but I don't 
see an easy way to do this given the current inode revalidation 
architecture of the client.

5.  You need to handle ESTALE.  Often, ->permission is the first thing 
the VFS will do before a lookup or open, and that is when the NFS client 
first notices that a cached file handle is stale.  Should ESTALE 
returned on an ACCESS request mean always return permission denied, or 
should it mean purge the access cache and grant access, so that the next 
VFS step sees the ESTALE and can recover appropriately?

-- 
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>
