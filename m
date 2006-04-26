From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 10:51:27 -0400
Message-ID: <444F88EF.5090105@RedHat.com>
References: <444EC96B.80400@RedHat.com> <17486.64825.942642.594218@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17486.64825.942642.594218@cse.unsw.edu.au>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>



Neil Brown wrote:
> - There is no upper bound imposed on the size of the cache, and no way
>   for memory pressure to shrink the cache except indirectly by
>   discarding inodes.
>   I cannot see this being exploitable as getting access to lots of
>   credentials would be hard for any given user.  However I feel that
>   some cleaning might be in order.
I guess there is no upper bound checking because I didn't see any type
of boundary checking the server hashing code I stoled 8-) Or maybe
I just missed it... Is there an example and what would trigger
this cleanup?

> - The nfs_zap_access_cache call isn't cheap.  If that could be
>   amortised somehow it would be good.  Maybe use some version tagging
>   so that when an inode is reused the access entry will no longer
>   match in some way.  Then just clean the table by periodic scans that
>   discard based on timeout information ?
yes.. I did realize that ifs_zap_access_cache would be expensive...
and I think there might be an issue with holding the access_hash lock
spin lock while calling put_rpccred() since it can also take out
another spin lock... Maybe I just spin through the table marking
entries for deletion and then let somebody else clean them up??
Is there already a clean up process that I would us? I don't
recall one...

> 
> It occurs to me that the large majority of inodes will only be
> accessed by a single user and so need not reside in the cache.
> 
> So how about having a single "struct nfs_access_entry" pointer in the
> inode.
> When we do a lookup we look there first.
> When we want to add an entry, we try to add it there first.
> When we end up with two current access entries for the same inode,
> only then do we insert them into the hash.
To rephrase to make sure I understand....
1) P1(uid=1) creates an access pointer in the nfs_inode
2) P2(uid=2) sees the access pointer is not null so it adds them both
    to the table, right?

> We would need to be able to tell from the inode whether anything is
> hashed or not.  This could simply be if the nfs_access_entry point is
> non-null, and its hashlist it non-empty.  Or we could just use a bit
> flag somewhere.
So I guess it would be something like:
if (nfs_inode->access == null)
     set nfs_inode->access
if (nfs_inode->access =! NULL && nfs_inode->access_hash == empty)
     move both pointer into hast able.
if (nfs_inode->access == null && nfs_inode->access_hash != empty)
     use hastable.

But now the question is how would I know when there is only one
entry in the table? Or do we just let the hash table "drain"
naturally and when it become empty we start with the nfs_inode->access
pointer again... Is this close to what your thinking??

steved.

