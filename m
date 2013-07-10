Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:3956 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754308Ab3GJDi7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jul 2013 23:38:59 -0400
Date: Wed, 10 Jul 2013 13:38:53 +1000
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: Re: [PATCH 01/12] vfs: pull ext4's double-i_mutex-locking into
 common code
Message-ID: <20130710033853.GP3438@dastard>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-2-git-send-email-bfields@redhat.com>
 <20130709220411.GK3438@dastard>
 <20130710002120.GM32574@pad.fieldses.org>
 <20130710020921.GN3438@dastard>
 <20130710024059.GN32574@pad.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130710024059.GN32574@pad.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 10:40:59PM -0400, J. Bruce Fields wrote:
> On Wed, Jul 10, 2013 at 12:09:21PM +1000, Dave Chinner wrote:
> > On Tue, Jul 09, 2013 at 08:21:20PM -0400, J. Bruce Fields wrote:
> > > On Wed, Jul 10, 2013 at 08:04:11AM +1000, Dave Chinner wrote:
> ...
> > > > Just to throw a spanner in the works - have you considered that
> > > > other filesystems might have different inode lock ordering rules?
> > > > 
> > > > For example, XFS locks multiple inodes in ascending inode number
> > > > order, not ordered by pointer address. Hence we end up different
> > > > inode lock ordering at different layers of the stack and I can't see
> > > > that ending well....
> > > 
> > > What lock(s) is it taking exactly, where?
> > 
> > xfs_lock_two_inodes() locks two XFS inodes and doesn't require
> > i_mutex on the inodes to be held first.
> > 
> > Then there's xfs_lock_inodes() which can lock an arbitrary number of
> > inodes and has some special casing to avoid transaction subsystem
> > deadlocks. That's used by rename so typically is used for 4 inodes
> > maximum, and the ordering is set up via xfs_sort_for_rename(). The
> > VFS typically already holds the i_mutex on these inodes first, so
> > I'm not so concerned about this case.
> > 
> > I'm not sure that there is actually deadlock, but given that XFS can
> > lock multiple inodes independently of the VFS (e.g. through ioctl
> > interfaces) I'm extremely wary of differences in lock ordering on
> > the same structure....
> 
> OK.
> 
> > > If there's a possible
> > > deadlock, can we come up with a compatible ordering?
> > 
> > Sure. I'd prefer ordering by inode number, because then ordering is
> > deterministic rather than being dependent on memory allocation
> > results.  It makes forensic analysis of deadlocks and corruptions
> > easier because you can look at on-disk structures and accurately
> > predict locking behaviour and therefore determine the order of
> > operations that should occur. With lock ordering determined by
> > memory addresses, you can't easily predict the lock ordering two
> > particular inodes might take from one operation to another.
> 
> Hm, OK, not having done this I don't have a good feeling for how
> important that is, but I can take your word for it.
> 
> But the ext4 code actually originally used i_ino order and was changed
> by 03bd8b9b896c8e "ext4: move_extent code cleanup", possibly on Linus's
> suggestion?:
> 
> 	http://mid.gmane.org/<CA+55aFwdh_QWG-R2FQ71kDXiNYZ04qPANBsY_PssVUwEBH4uSw@mail.gmail.com>
> 
> 	"And the only sane order is comparing inode pointers, not inode
> 	numbers like ext4 apparently does."

Interesting. What has worked for the last 20 years must be wrong if
Linus says so ;)

> 
> (Uh, I thought I also remembered some rationale but can't dig up the
> email now.)

Probably duplicate inode numbers on inodes in different filesystems.
But rename doesn't allow that, and I don't we ever want to allow
arbitrary nested inode locking across superblocks. Hence I can't
think of a reason why it's a problem...

FWIW - gfs2 does multiple glock locking similar to XFS inode locking
- it sorts the locks in lock number order and the locks them all one
at a time...

> > > > > +EXPORT_SYMBOL(lock_two_nondirectories);
> > > > 
> > > > What makes this specific to non-directories?
> > > 
> > > See 
> > > 
> > > 	http://mid.gmane.org/<1372882356-14168-5-git-send-email-bfields@redhat.com>
> > > 
> > > The only caller outside ext4 is vfs_rename_other.
> > 
> > Ah, so we now mix two different lock ordering models for directories
> > vs non-directories.  i.e. lock_rename() enforces parent/child
> > relationships on the two directories being locked, but if there is
> > no ancestry, it doesn't order the inode locking at all.
> > 
> > So it seems that we can make up whatever ordering we want here,
> > as long as we use it everywhere for locking multiple inodes. What
> > other code locks multiple inodes?
> 
> The ext4 code is the only code I know of--but only I think because Al
> pointed out.  And obviously I overlooked the xfs case.  I'll try looking
> harder....

A quick grep shows lock_2_inodes() in fs/ubifs/dir.c. I don't see
any other obvious ones.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
