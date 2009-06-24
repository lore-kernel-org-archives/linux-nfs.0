From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 0/5] NFS private namespace patchset
Date: Wed, 24 Jun 2009 13:58:12 +0100
Message-ID: <20090624125812.GQ8633@ZenIV.linux.org.uk>
References: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org> <alpine.LFD.2.01.0906221238370.3240@localhost.localdomain> <20090623213309.GK8633@ZenIV.linux.org.uk> <alpine.LFD.2.01.0906231438390.3240@localhost.localdomain> <20090623232258.GL8633@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090623232258.GL8633@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 24, 2009 at 12:22:58AM +0100, Al Viro wrote:

> OK, I've finally crawled through the pile of mail.  Will have the trees
> (VFS and audit) out later tonight...

OK, here's the tame stuff; there's still more left, but that'll have to
wait.  My apologies for disappearing in the middle of merge window ;-/
Please pull from

  git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/ for-linus

Shortlog:

Al Viro (16):
      Make allocation of anon devices cheaper
      ... and the same for vfsmount id/mount group id
      add caching of ACLs in struct inode
      switch ext2 to inode->i_acl
      switch ext3 to inode->i_acl
      switch ext4 to inode->i_acl
      switch jfs to inode->i_acl
      switch jffs2 to inode->i_acl
      switch btrfs to inode->i_acl
      switch nilfs2 to inode->i_acl
      reiserfs: minimal fix for ACL caching
      switch reiserfs to usual conventions for caching ACLs
      switch reiserfs to inode->i_acl
      switch shmem to inode->i_acl
      helpers for acl caching + switch to those
      switch xfs to generic acl caching helpers

Ankit Jain (1):
      fs: Add new pre-allocation ioctls to vfs for compatibility with legacy xfs ioctls

Christoph Hellwig (3):
      reiserfs: remove stray unlock_super in reiserfs_resize
      update Documentation/filesystems/Locking
      cleanup __writeback_single_inode

H. Peter Anvin (1):
      devpts: remove module-related code

J. R. Okajima (1):
      vfs: fix nd->root leak in do_filp_open()

Trond Myklebust (1):
      VFS: Switch init_mount_tree() to use the new create_mnt_ns() helper

Diffstat:

 Documentation/filesystems/Locking |   41 ++++++++-------
 fs/btrfs/acl.c                    |   44 +++-------------
 fs/btrfs/btrfs_inode.h            |    4 --
 fs/btrfs/ctree.h                  |    2 -
 fs/btrfs/inode.c                  |   16 +-----
 fs/compat_ioctl.c                 |   48 ++++++++++++++++++
 fs/devpts/inode.c                 |   10 ----
 fs/ext2/acl.c                     |   81 ++++++-----------------------
 fs/ext2/acl.h                     |    4 --
 fs/ext2/ext2.h                    |    4 --
 fs/ext2/inode.c                   |    4 --
 fs/ext2/super.c                   |   16 ------
 fs/ext3/acl.c                     |   85 +++++++------------------------
 fs/ext3/acl.h                     |    4 --
 fs/ext3/inode.c                   |    4 --
 fs/ext3/super.c                   |   16 ------
 fs/ext4/acl.c                     |   67 +++---------------------
 fs/ext4/acl.h                     |    4 --
 fs/ext4/ext4.h                    |    4 --
 fs/ext4/inode.c                   |    4 --
 fs/ext4/super.c                   |   16 ------
 fs/fs-writeback.c                 |  100 ++++++++++++++++++------------------
 fs/inode.c                        |   10 ++++
 fs/ioctl.c                        |   35 +++++++++++++
 fs/jffs2/acl.c                    |   88 ++++++--------------------------
 fs/jffs2/acl.h                    |    4 --
 fs/jffs2/jffs2_fs_i.h             |    4 --
 fs/jffs2/os-linux.h               |    4 --
 fs/jffs2/readinode.c              |    1 -
 fs/jfs/acl.c                      |   42 ++++++----------
 fs/jfs/jfs_incore.h               |    6 --
 fs/jfs/super.c                    |   16 ------
 fs/jfs/xattr.c                    |   10 +---
 fs/namei.c                        |   11 ++++-
 fs/namespace.c                    |   37 +++++++++-----
 fs/nilfs2/inode.c                 |    8 ---
 fs/nilfs2/nilfs.h                 |    4 --
 fs/nilfs2/super.c                 |   10 ----
 fs/open.c                         |   58 +++++++++++-----------
 fs/reiserfs/inode.c               |    4 --
 fs/reiserfs/resize.c              |    1 -
 fs/reiserfs/super.c               |   24 ---------
 fs/reiserfs/xattr_acl.c           |   58 ++++-----------------
 fs/super.c                        |    9 +++-
 fs/ubifs/xattr.c                  |    2 +-
 fs/xfs/linux-2.6/xfs_acl.c        |   73 +++-----------------------
 fs/xfs/xfs_acl.h                  |    4 --
 fs/xfs/xfs_iget.c                 |    2 -
 fs/xfs/xfs_inode.h                |    5 --
 include/linux/ext3_fs_i.h         |    4 --
 include/linux/falloc.h            |   21 ++++++++
 include/linux/fs.h                |   13 +++++
 include/linux/posix_acl.h         |   64 +++++++++++++++++++++++
 include/linux/reiserfs_acl.h      |   17 ------
 include/linux/reiserfs_fs_i.h     |    4 --
 include/linux/shmem_fs.h          |    8 ---
 mm/shmem.c                        |    9 ++--
 mm/shmem_acl.c                    |   29 ++---------
 58 files changed, 455 insertions(+), 822 deletions(-)
