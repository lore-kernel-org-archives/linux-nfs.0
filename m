Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:61261 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753627Ab3GJCJ2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jul 2013 22:09:28 -0400
Date: Wed, 10 Jul 2013 12:09:21 +1000
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: Re: [PATCH 01/12] vfs: pull ext4's double-i_mutex-locking into
 common code
Message-ID: <20130710020921.GN3438@dastard>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-2-git-send-email-bfields@redhat.com>
 <20130709220411.GK3438@dastard>
 <20130710002120.GM32574@pad.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130710002120.GM32574@pad.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 08:21:20PM -0400, J. Bruce Fields wrote:
> On Wed, Jul 10, 2013 at 08:04:11AM +1000, Dave Chinner wrote:
> > On Wed, Jul 03, 2013 at 04:12:25PM -0400, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > We want to do this elsewhere as well.
> > > 
> > > Cc: "Theodore Ts'o" <tytso@mit.edu>
> > > Cc: Andreas Dilger <adilger.kernel@dilger.ca>
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  fs/ext4/ext4.h        |    2 --
> > >  fs/ext4/ioctl.c       |    4 ++--
> > >  fs/ext4/move_extent.c |   40 ++--------------------------------------
> > >  fs/inode.c            |   29 +++++++++++++++++++++++++++++
> > >  include/linux/fs.h    |    3 +++
> > >  5 files changed, 36 insertions(+), 42 deletions(-)
> > > 
> > > diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> > > index 5aae3d1..3590abe 100644
> 
> Thanks for the comment:
> 
> > Just to throw a spanner in the works - have you considered that
> > other filesystems might have different inode lock ordering rules?
> > 
> > For example, XFS locks multiple inodes in ascending inode number
> > order, not ordered by pointer address. Hence we end up different
> > inode lock ordering at different layers of the stack and I can't see
> > that ending well....
> 
> What lock(s) is it taking exactly, where?

xfs_lock_two_inodes() locks two XFS inodes and doesn't require
i_mutex on the inodes to be held first.

Then there's xfs_lock_inodes() which can lock an arbitrary number of
inodes and has some special casing to avoid transaction subsystem
deadlocks. That's used by rename so typically is used for 4 inodes
maximum, and the ordering is set up via xfs_sort_for_rename(). The
VFS typically already holds the i_mutex on these inodes first, so
I'm not so concerned about this case.

I'm not sure that there is actually deadlock, but given that XFS can
lock multiple inodes independently of the VFS (e.g. through ioctl
interfaces) I'm extremely wary of differences in lock ordering on
the same structure....

> If there's a possible
> deadlock, can we come up with a compatible ordering?

Sure. I'd prefer ordering by inode number, because then ordering is
deterministic rather than being dependent on memory allocation
results. It makes forensic analysis of deadlocks and corruptions
easier because you can look at on-disk structures and accurately
predict locking behaviour and therefore determine the order of
operations that should occur. With lock ordering determined by
memory addresses, you can't easily predict the lock ordering two
particular inodes might take from one operation to another.

> > > +EXPORT_SYMBOL(lock_two_nondirectories);
> > 
> > What makes this specific to non-directories?
> 
> See 
> 
> 	http://mid.gmane.org/<1372882356-14168-5-git-send-email-bfields@redhat.com>
> 
> The only caller outside ext4 is vfs_rename_other.

Ah, so we now mix two different lock ordering models for directories
vs non-directories.  i.e. lock_rename() enforces parent/child
relationships on the two directories being locked, but if there is
no ancestry, it doesn't order the inode locking at all.

So it seems that we can make up whatever ordering we want here,
as long as we use it everywhere for locking multiple inodes. What
other code locks multiple inodes?

> I think we could make it work for directories two if necessary though
> the ordering would be more complicated.  Currently there's no reason.

lock_rename() already does it ;)

> > If it's not to be used for directory inodes, then there should be
> > WARN_ON_ONCE() guards in the code...
> 
> Sure.  So something like the following.
> 
> Hm.  I also overlooked that ext4 had a BUG() for the case they're equal.
> Maybe we should keep that too if it's not overkill.

Just do like lock_rename() does - detect it an only lock the single
inode. That way you can also pass in a null inode2 and have it
behave appropriately - it will get rid of the if (target) ... else
code out of vfs_rename_other....

>  /**
> + * lock_two_nondirectories - take two i_mutexes on non-directory objects
> + * @inode1: first inode to lock
> + * @inode2: second inode to lock
> + */
> +void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
> +{
> +	WARN_ON_ONCE(S_ISDIR(inode1->i_mode) || S_ISDIR(inode2->i_mode));
> +	WARN_ON_ONCE(inode1 == inode2);

Sure, but I'd split the first warn on - that way we know which inode
is triggering the warning....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
