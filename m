Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53667 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648Ab0CERkX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Mar 2010 12:40:23 -0500
Date: Fri, 5 Mar 2010 17:40:18 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [git pull] vfs part 3 (write_inode mess)
Message-ID: <20100305174017.GX30031@ZenIV.linux.org.uk>
References: <1267802800.5174.6.camel@localhost.localdomain>
 <20100305154823.GV30031@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100305154823.GV30031@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 05, 2010 at 03:48:23PM +0000, Al Viro wrote:
> I'm going to push the next VFS pile in about half an hour and get to the
> write_inode situation.  I'm not sure what's the best course here.  Note
> that since you've pulled it, you also have conflicts with what's in the
> mainline.  I can do *another* backmerge (already had one due to gfs2 trivial
> conflicts) and push the result.  Which will suck, since XFS conflicts
> are not entirely trivial and we'll get a really ugly merge node, with
> conflict resolution both hidden and not quite obvious.

OK, a backmerge it is.  Linus, could you please pull
git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/ write_inode
or suggest a saner way to do that?

I've done backmerges of two points in mainline (trees that got merged
into mainline, actually) that created conflicts.  So at that point it's
(a) descendent of what's been pulled into NFS tree and (b) merges clean
with mainline.  All for two patches (at commit 716c28c..) ;-/

It's independent from the previous VFS pull; there's more stuff, hopefully
for later today, but the worst of the mess should be gone with that one.

Shortlog:
Al Viro (2):
      Merge commit 'e402746a945ceb9d0486a8e3d5917c9228fa4404' into write_inode
      Merge commit '07fec73625dc0db6f9aed68019918208a2ca53f5' into write_inode

Christoph Hellwig (2):
      make sure data is on disk before calling ->write_inode
      pass writeback_control to ->write_inode

Diffstat:
 fs/adfs/adfs.h               |    2 +-
 fs/adfs/inode.c              |    5 +++--
 fs/affs/affs.h               |    3 ++-
 fs/affs/inode.c              |    2 +-
 fs/afs/internal.h            |    1 -
 fs/afs/super.c               |    1 -
 fs/afs/write.c               |   21 ---------------------
 fs/bfs/inode.c               |    5 +++--
 fs/btrfs/ctree.h             |    2 +-
 fs/btrfs/inode.c             |    4 ++--
 fs/exofs/exofs.h             |    2 +-
 fs/exofs/inode.c             |    4 ++--
 fs/ext2/ext2.h               |    2 +-
 fs/ext2/inode.c              |   11 +++++++++--
 fs/ext3/inode.c              |    4 ++--
 fs/ext4/ext4.h               |    2 +-
 fs/ext4/inode.c              |    6 +++---
 fs/fat/inode.c               |    9 +++++++--
 fs/fs-writeback.c            |   22 +++++++++++++---------
 fs/gfs2/super.c              |    5 +++--
 fs/hfs/hfs_fs.h              |    2 +-
 fs/hfs/inode.c               |    2 +-
 fs/hfsplus/super.c           |    3 ++-
 fs/jfs/inode.c               |    5 ++++-
 fs/jfs/jfs_inode.h           |    2 +-
 fs/minix/inode.c             |    8 +++++---
 fs/nfs/inode.c               |   10 +++-------
 fs/nfs/internal.h            |    2 +-
 fs/ntfs/dir.c                |    2 +-
 fs/ntfs/file.c               |    2 +-
 fs/ntfs/inode.c              |    2 +-
 fs/ntfs/inode.h              |    4 ++--
 fs/ntfs/super.c              |    8 ++++++++
 fs/omfs/inode.c              |   10 ++++++++--
 fs/reiserfs/inode.c          |    4 ++--
 fs/sysv/inode.c              |   10 ++++++++--
 fs/sysv/sysv.h               |    2 +-
 fs/ubifs/dir.c               |    2 +-
 fs/ubifs/file.c              |    8 ++++----
 fs/ubifs/super.c             |    2 +-
 fs/udf/inode.c               |    4 ++--
 fs/udf/udfdecl.h             |    2 +-
 fs/ufs/inode.c               |    5 +++--
 fs/ufs/ufs.h                 |    2 +-
 fs/xfs/linux-2.6/xfs_super.c |    8 ++------
 include/linux/ext3_fs.h      |    2 +-
 include/linux/fs.h           |    2 +-
 include/linux/reiserfs_fs.h  |    2 +-
 48 files changed, 123 insertions(+), 107 deletions(-)
