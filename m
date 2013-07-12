Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932434Ab3GLWHj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jul 2013 18:07:39 -0400
Date: Fri, 12 Jul 2013 18:07:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>, swhiteho@redhat.com
Subject: Re: [PATCH 01/12] vfs: pull ext4's double-i_mutex-locking into
 common code
Message-ID: <20130712220731.GD20370@pad.fieldses.org>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-2-git-send-email-bfields@redhat.com>
 <20130709220411.GK3438@dastard>
 <20130710002120.GM32574@pad.fieldses.org>
 <20130710020921.GN3438@dastard>
 <20130710024059.GN32574@pad.fieldses.org>
 <20130710033853.GP3438@dastard>
 <20130710212620.GB24548@pad.fieldses.org>
 <20130711100406.21b08420@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130711100406.21b08420@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 11, 2013 at 10:04:06AM -0400, Jeff Layton wrote:
> On Wed, 10 Jul 2013 17:26:21 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > On Wed, Jul 10, 2013 at 01:38:53PM +1000, Dave Chinner wrote:
> > > On Tue, Jul 09, 2013 at 10:40:59PM -0400, J. Bruce Fields wrote:
> > > > On Wed, Jul 10, 2013 at 12:09:21PM +1000, Dave Chinner wrote:
> > > > > Sure. I'd prefer ordering by inode number, because then ordering is
> > > > > deterministic rather than being dependent on memory allocation
> > > > > results.  It makes forensic analysis of deadlocks and corruptions
> > > > > easier because you can look at on-disk structures and accurately
> > > > > predict locking behaviour and therefore determine the order of
> > > > > operations that should occur. With lock ordering determined by
> > > > > memory addresses, you can't easily predict the lock ordering two
> > > > > particular inodes might take from one operation to another.
> > > > 
> > > > Hm, OK, not having done this I don't have a good feeling for how
> > > > important that is, but I can take your word for it.
> > > > 
> > > > But the ext4 code actually originally used i_ino order and was changed
> > > > by 03bd8b9b896c8e "ext4: move_extent code cleanup", possibly on Linus's
> > > > suggestion?:
> > > > 
> > > > 	http://mid.gmane.org/<CA+55aFwdh_QWG-R2FQ71kDXiNYZ04qPANBsY_PssVUwEBH4uSw@mail.gmail.com>
> > > > 
> > > > 	"And the only sane order is comparing inode pointers, not inode
> > > > 	numbers like ext4 apparently does."
> > > 
> > > Interesting. What has worked for the last 20 years must be wrong if
> > > Linus says so ;)
> > > 
> > > > 
> > > > (Uh, I thought I also remembered some rationale but can't dig up the
> > > > email now.)
> > > 
> > > Probably duplicate inode numbers on inodes in different filesystems.
> > > But rename doesn't allow that, and I don't we ever want to allow
> > > arbitrary nested inode locking across superblocks. Hence I can't
> > > think of a reason why it's a problem...
> > 
> > I have some vague memory the argument was rather that inode numbers
> > could fail to be unique within a fs due to bugs, but I may be making
> > that up.  I've got no strong opinion here.
> > 
> 
> There are also legitimate cases where inode numbers can collide,
> particularly on network filesystems. That's one of the main reasons we
> have iget5_locked().
> 
> One possibility might be to order by i_ino first, and then fall back to
> using the inode pointer value if they are equal.

As long as no one ever modifies i_ino.  Which I'd think would be a
shooting offense.  But it sure looks like fuse allows this--see
fuse_do_getattr->fuse_change_attributes->fuse_change_attributes_common.

Maybe I'm misunderstanding....

As long as there's a chance filesystems (even if only due to bugs) could
mess with this sort of guarantee I'm really inclined to stick with the
obviously-well-defined pointer ordering even if it means giving up the
determinism Dave wants.  Argh.

> > > FWIW - gfs2 does multiple glock locking similar to XFS inode locking
> > > - it sorts the locks in lock number order and the locks them all one
> > > at a time...

Taking a look--I don't think I'm going to begin to understand how that's
used in any reasonable amount of time.  Cc'ing Steve in case he can.

> > > A quick grep shows lock_2_inodes() in fs/ubifs/dir.c. I don't see
> > > any other obvious ones.

Which isn't bothering with consistent lock ordering because (says a
comment) its only called after taking the vfs locks.  Which looks
correct--the only callers are in link, unlink, and rmdir methods.  And a
similar lock_3_inodes is called from the rename method.

--b.
