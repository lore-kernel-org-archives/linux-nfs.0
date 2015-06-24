Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35824 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbbFXV5b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 17:57:31 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-security-module@vger.kernel.org
Subject: [RFC v4 00/31] Richacls
Date: Wed, 24 Jun 2015 23:56:49 +0200
Message-Id: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

here's another update of the richacl patch queue.  The changes since the last
posting (https://lwn.net/Articles/641764/) include:

* The owner and other masks now determine the owner and other
  permissions rather than just limiting them. For example, a
  'chmod u=rw' will always grant the owner read and write access.
  The group mask still behaves as before and only limits the group
  class permissions.  Hence, the owner, group, and other masks
  now behave like the 'user::', 'group::', and 'mask::' entries in
  POSIX ACLs.

* ACL entries for users matching the current owner are treated similar to
  owner@ entries; they match the file owner. This differs from how such
  entries are treated in POSIX ACLs but is more consistent with the
  NFSv4 / Windows ACL model.

* Permissions implicitly granted to the owner ("ACo") are no longer added to
  owner@ entries automatically (they are still granted though). The idea
  behind adding them was to make the acl reflect the actual permissions
  more closely, but that didn't turn out to be helpful.

* Various smaller improvements and bug fixes.

The complete patch queue is available here:

  git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git \
        richacl-2015-06-24

I'm leaving out patches here which have been queued for 4.2 already.  Also,
the nfs patches need some more work before another round of reviews.

Thanks,
Andreas

Andreas Gruenbacher (29):
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
  vfs: Cache base_acl objects in inodes
  vfs: Cache richacl in struct inode
  richacl: Check if an acl is equivalent to a file mode
  richacl: Create-time inheritance
  richacl: Automatic Inheritance
  richacl: xattr mapping functions
  vfs: Add richacl permission checking
  richacl: acl editing helper functions
  richacl: Move everyone@ aces down the acl
  richacl: Propagate everyone@ permissions to other aces
  richacl: Set the owner permissions to the owner mask
  richacl: Set the other permissions to the other mask
  richacl: Isolate the owner and group classes
  richacl: Apply the file masks to a richacl
  richacl: Create richacl from mode values
  nfsd: Keep list of acls to dispose of in compoundargs
  nfsd: Use richacls as internal acl representation
  nfsd: Add richacl support
  nfsd: Add support for the v4.1 dacl attribute

Aneesh Kumar K.V (2):
  ext4: Add richacl support
  ext4: Add richacl feature flag

 drivers/staging/lustre/lustre/llite/llite_lib.c |   2 +-
 fs/Kconfig                                      |   9 +
 fs/Makefile                                     |   3 +
 fs/attr.c                                       |  81 ++-
 fs/ext4/Kconfig                                 |  15 +
 fs/ext4/Makefile                                |   1 +
 fs/ext4/acl.c                                   |   6 +-
 fs/ext4/acl.h                                   |  12 +-
 fs/ext4/ext4.h                                  |   6 +-
 fs/ext4/file.c                                  |   6 +-
 fs/ext4/ialloc.c                                |   7 +-
 fs/ext4/inode.c                                 |  10 +-
 fs/ext4/namei.c                                 |  11 +-
 fs/ext4/richacl.c                               | 211 ++++++
 fs/ext4/richacl.h                               |  47 ++
 fs/ext4/super.c                                 |  41 +-
 fs/ext4/xattr.c                                 |   6 +
 fs/ext4/xattr.h                                 |   1 +
 fs/f2fs/acl.c                                   |   4 +-
 fs/inode.c                                      |  15 +-
 fs/namei.c                                      | 108 ++-
 fs/nfs_common/Makefile                          |   1 +
 fs/nfs_common/nfs4acl.c                         |  41 ++
 fs/nfsd/Kconfig                                 |   1 +
 fs/nfsd/acl.h                                   |  23 +-
 fs/nfsd/nfs4acl.c                               | 483 +++++++------
 fs/nfsd/nfs4proc.c                              |  19 +-
 fs/nfsd/nfs4xdr.c                               | 267 ++++---
 fs/nfsd/nfsd.h                                  |   6 +-
 fs/nfsd/xdr4.h                                  |  12 +-
 fs/posix_acl.c                                  |  26 +-
 fs/richacl_base.c                               | 539 ++++++++++++++
 fs/richacl_compat.c                             | 908 ++++++++++++++++++++++++
 fs/richacl_inode.c                              | 264 +++++++
 fs/richacl_xattr.c                              | 210 ++++++
 fs/xattr.c                                      |  34 +-
 include/linux/fs.h                              |  50 +-
 include/linux/nfs4.h                            |  24 +-
 include/linux/nfs4acl.h                         |   7 +
 include/linux/posix_acl.h                       |  12 +-
 include/linux/richacl.h                         | 342 +++++++++
 include/linux/richacl_compat.h                  |  40 ++
 include/linux/richacl_xattr.h                   |  52 ++
 include/uapi/linux/fs.h                         |   3 +-
 include/uapi/linux/nfs4.h                       |   3 +-
 include/uapi/linux/xattr.h                      |   2 +
 46 files changed, 3498 insertions(+), 473 deletions(-)
 create mode 100644 fs/ext4/richacl.c
 create mode 100644 fs/ext4/richacl.h
 create mode 100644 fs/nfs_common/nfs4acl.c
 create mode 100644 fs/richacl_base.c
 create mode 100644 fs/richacl_compat.c
 create mode 100644 fs/richacl_inode.c
 create mode 100644 fs/richacl_xattr.c
 create mode 100644 include/linux/nfs4acl.h
 create mode 100644 include/linux/richacl.h
 create mode 100644 include/linux/richacl_compat.h
 create mode 100644 include/linux/richacl_xattr.h

-- 
2.4.2

