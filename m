From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Thu, 27 Apr 2006 08:32:42 +1000
Message-ID: <17487.62730.16297.979429@cse.unsw.edu.au>
References: <444EC96B.80400@RedHat.com>
	<17486.64825.942642.594218@cse.unsw.edu.au>
	<444F88EF.5090105@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Wednesday April 26
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wednesday April 26, SteveD@redhat.com wrote:
> 
> 
> Neil Brown wrote:
> > - There is no upper bound imposed on the size of the cache, and no way
> >   for memory pressure to shrink the cache except indirectly by
> >   discarding inodes.
> >   I cannot see this being exploitable as getting access to lots of
> >   credentials would be hard for any given user.  However I feel that
> >   some cleaning might be in order.
> I guess there is no upper bound checking because I didn't see any type
> of boundary checking the server hashing code I stoled 8-) Or maybe
> I just missed it... Is there an example and what would trigger
> this cleanup?

You can register a 'shrinker' which gets called then the vm wants to
reclaim memory.  See mm/vmscan.c
It gets passed the number of items you should try to discard, and
returned the number of items that are left.

And if you arrange to do all the freeing in batches using the
shrinker, you could use RCU to make all the searches and additions
lockless (Well, you still need rcu_read_lock, but that is super light
weight).  That would be fun :-)

> > 
> > It occurs to me that the large majority of inodes will only be
> > accessed by a single user and so need not reside in the cache.
> > 
> > So how about having a single "struct nfs_access_entry" pointer in the
> > inode.
> > When we do a lookup we look there first.
> > When we want to add an entry, we try to add it there first.
> > When we end up with two current access entries for the same inode,
> > only then do we insert them into the hash.
> To rephrase to make sure I understand....
> 1) P1(uid=1) creates an access pointer in the nfs_inode
> 2) P2(uid=2) sees the access pointer is not null so it adds them both
>     to the table, right?
> 

Exactly.

> > We would need to be able to tell from the inode whether anything is
> > hashed or not.  This could simply be if the nfs_access_entry point is
> > non-null, and its hashlist it non-empty.  Or we could just use a bit
> > flag somewhere.
> So I guess it would be something like:
> if (nfs_inode->access == null)
>      set nfs_inode->access
> if (nfs_inode->access =! NULL && nfs_inode->access_hash == empty)
>      move both pointer into hast able.
> if (nfs_inode->access == null && nfs_inode->access_hash != empty)
>      use hastable.
> 
> But now the question is how would I know when there is only one
> entry in the table? Or do we just let the hash table "drain"
> naturally and when it become empty we start with the nfs_inode->access
> pointer again... Is this close to what your thinking??

Yes.  Spot on.  Once some inode has 'spilled' into the hash table
there isn't a lot to gain by "unspilling" it.

NeilBrown
