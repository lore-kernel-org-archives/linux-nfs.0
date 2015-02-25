Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:45251 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038AbbBYXmD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 18:42:03 -0500
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 00/21] Richacls
Date: Thu, 26 Feb 2015 00:41:21 +0100
Message-Id: <cover.1424907511.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

here is an updated richacl patch queue, also available in git [1].  For those
who might not know, richacls are an implementation of NFSv4 ACLs that cleanly
integrates into the POSIX file permission model.  The goal is to improve
interoperability between Linux and other systems, mainly across the NFSv4 and
CIFS/SMB protocols.  A file system can either contain posix acls or richacls,
but not both.

This patch queue includes the vfs and ext4 changes needed for local richacl
support.  A previous version of this patch queue was last posted about a year
ago [2]; I have updated the patches to v4.0-rc1 and tried to incorporate the
feedback from the previous discussion.  The changes include:

 * Introduction of a base_acl object type so that an inode can either cache
   a posix acl or a richacl largely without caring which of the two kinds
   it is dealing with.

 * RCU support as for posix acls.

 * Various cleanups and more documentation.

Things I'm not entirely happy with:

 * A new get_richacl inode operation is introduced.  This is needed because
   we need to perform permission checks in contexts where the dentry of the
   inode to check is not available and we cannot use the getxattr inode
   operation.  It would be nice if we could either convert the getxattr inode
   operation to take an inode instead, or pass the dentries down to where
   the get_richacl inode operation is currently used.

 * The base_acl code is rather ugly; maybe the previous version which was
   criticized wasn't so bad after all.

 * It would be nice if the MAY_DELETE_SELF flag could override the sticky
   directory check as it did in the previous version of this patch queue.  I
   couldn't come up with a clean way of achieving that, though.

Because the code has changed quite a bit since the last posting, I have removed
the previous sign-offs.

At this point, I would like to ask for your feedback as to what should be
changed before these patches can be merged, even if merging these patches alone
doesn't make a while lot of sense.  I will follow up with additional pieces to
the puzzle like the nfsv4 support as I get them into shape again.

--

Which kind of acls an ext4 file system supports is determined by the "richacl"
ext4 feature (mkfs.ext4 -O richacl or tune2fs -O richacl).  The file system
also needs to be mounted with the "acl" mount option, which is the default
nowadays.

A version of e2fsprogs with support for the "richacl" feature can be found on
github [3], but the feature can also be enabled "hard" in debugfs.  Note that
unpatched versions of e2fsck will not check file systems with the feature
enabled though.

The acls themselves can be manipulated with the richacl command-line utility
[4].  Some details on the permission model and examples of its use can be found
at the richacl page, http://acl.bestbits.at/richacl/.

 [1] git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git richacl
 [2] http://lwn.net/Articles/596517/
 [3] https://github.com/andreas-gruenbacher/e2fsprogs
 [4] https://github.com/andreas-gruenbacher/richacl

Thanks,
Andreas

--

Andreas Gruenbacher (19):
  vfs: Minor documentation fix
  vfs: Shrink struct posix_acl
  vfs: Add IS_ACL() and IS_RICHACL() tests
  vfs: Add MAY_CREATE_FILE and MAY_CREATE_DIR permission flags
  vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD permission flags
  vfs: Make the inode passed to inode_change_ok non-const
  vfs: Add permission flags for setting file attributes
  richacl: In-memory representation and helper functions
  richacl: Permission mapping functions
  richacl: Compute maximum file masks from an acl
  richacl: Update the file masks in chmod()
  richacl: Permission check algorithm
  richacl: Create-time inheritance
  richacl: Check if an acl is equivalent to a file mode
  richacl: Automatic Inheritance
  richacl: xattr mapping functions
  vfs: Cache base_acl objects in inodes
  vfs: Cache richacl in struct inode
  vfs: Add richacl permission checking

Aneesh Kumar K.V (2):
  ext4: Implement rich acl for ext4
  ext4: Add richacl feature flag

 Documentation/filesystems/porting               |   8 +-
 Documentation/filesystems/vfs.txt               |   3 +
 drivers/staging/lustre/lustre/llite/llite_lib.c |   2 +-
 fs/Kconfig                                      |   3 +
 fs/Makefile                                     |   2 +
 fs/attr.c                                       |  81 ++-
 fs/ext4/Kconfig                                 |  15 +
 fs/ext4/Makefile                                |   1 +
 fs/ext4/acl.c                                   |   7 +-
 fs/ext4/acl.h                                   |  12 +-
 fs/ext4/ext4.h                                  |   6 +-
 fs/ext4/file.c                                  |   6 +-
 fs/ext4/ialloc.c                                |   7 +-
 fs/ext4/inode.c                                 |  10 +-
 fs/ext4/namei.c                                 |  11 +-
 fs/ext4/richacl.c                               | 229 ++++++++
 fs/ext4/richacl.h                               |  47 ++
 fs/ext4/super.c                                 |  41 +-
 fs/ext4/xattr.c                                 |   6 +
 fs/ext4/xattr.h                                 |   1 +
 fs/f2fs/acl.c                                   |   4 +-
 fs/inode.c                                      |  15 +-
 fs/namei.c                                      | 108 +++-
 fs/posix_acl.c                                  |  31 +-
 fs/richacl_base.c                               | 660 ++++++++++++++++++++++++
 fs/richacl_inode.c                              |  67 +++
 fs/richacl_xattr.c                              | 131 +++++
 include/linux/fs.h                              |  47 +-
 include/linux/posix_acl.h                       |  12 +-
 include/linux/richacl.h                         | 329 ++++++++++++
 include/linux/richacl_xattr.h                   |  47 ++
 include/uapi/linux/fs.h                         |   3 +-
 32 files changed, 1844 insertions(+), 108 deletions(-)
 create mode 100644 fs/ext4/richacl.c
 create mode 100644 fs/ext4/richacl.h
 create mode 100644 fs/richacl_base.c
 create mode 100644 fs/richacl_inode.c
 create mode 100644 fs/richacl_xattr.c
 create mode 100644 include/linux/richacl.h
 create mode 100644 include/linux/richacl_xattr.h

-- 
2.1.0

