From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 14:55:21 +1000
Message-ID: <17486.64825.942642.594218@cse.unsw.edu.au>
References: <444EC96B.80400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Tuesday April 25
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tuesday April 25, SteveD@redhat.com wrote:
> Currently the NFS client caches ACCESS information on a per uid basis
> which fall apart when different process with different uid consistently
> access the same directory. The end result being a storm of needless
> ACCESS calls...
> 
> The attached patch used a hash table to store the nfs_access_entry
> entires which cause the ACCESS request to only happen when the
> attributes timeout.. The table is indexed by the addition of the
> nfs_inode pointer and the cr_uid in the cred structure which should
> spread things out nicely for some decent scalability (although the
> locking scheme may need to be reworked a bit). The table has 256 entries
> of struct list_head giving it a total size of 2k.
> 
> The patch is based on Trond's GIT tree...
> 
> Comments?

- There is no upper bound imposed on the size of the cache, and no way
  for memory pressure to shrink the cache except indirectly by
  discarding inodes.
  I cannot see this being exploitable as getting access to lots of
  credentials would be hard for any given user.  However I feel that
  some cleaning might be in order.
- The nfs_zap_access_cache call isn't cheap.  If that could be
  amortised somehow it would be good.  Maybe use some version tagging
  so that when an inode is reused the access entry will no longer
  match in some way.  Then just clean the table by periodic scans that
  discard based on timeout information ?

It occurs to me that the large majority of inodes will only be
accessed by a single user and so need not reside in the cache.

So how about having a single "struct nfs_access_entry" pointer in the
inode.
When we do a lookup we look there first.
When we want to add an entry, we try to add it there first.
When we end up with two current access entries for the same inode,
only then do we insert them into the hash.
We would need to be able to tell from the inode whether anything is
hashed or not.  This could simply be if the nfs_access_entry point is
non-null, and its hashlist it non-empty.  Or we could just use a bit
flag somewhere.

I suspect this would keep the cache much smaller, and some of my other
concerns might then become irrelevant.

NeilBrown
