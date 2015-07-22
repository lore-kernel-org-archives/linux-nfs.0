Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35710 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755276AbbGVNEE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 09:04:04 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, samba-technical@lists.samba.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v5 00/39] Richacls
Date: Wed, 22 Jul 2015 15:02:50 +0200
Message-Id: <1437570209-29832-1-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>

Hello,

here's another update of the richacl patch queue.  Changes since the last
posting (https://lwn.net/Articles/649287/):

* Support for user and group identifiers which don't have a uid/gid
  mapping. Those identifiers are only meaningful for nfs so far; smbfs
  would be a logical next candidate (for Windows SIDs instead of NFSv4
  identifiers in that case). Storing those identifiers on a local file system
  is not allowed.

* New xattr representation for supporting unmapped identifiers: they are stored
  as a list of NUL-terminated strings at the end of the acl, with one string
  for each acl entry that has an unmapped identifier.

* Changes to the nfs patches: acls are now encoded above the sunrpc
  layer. This means we can no longer encode small acls directly into the
  scratch area of an xdr_buf, we always have to allocate extra memory.
  But we also don't need to touch the nfs sunrpc code, which Trond objected
  to.

The complete patch queue is available here:

  git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git \
        richacl-2015-07-22

Open issues in nfs:

* When a user or group name cannot be mapped, nfs's idmapper always
  maps it to nobody. That's good enough for mapping the file owner and
  owning group, but not for identifiers in acls. For now, to get the nfs
  richacl support somewhat working, I'm explicitly checking if mapping
  has resulted in uid/gid 99 in the kernel.

* nfs: When the nfs server replies with NFS4ERR_BADNAME for any
  user or group name lookup, the client will stop sending numeric uids
  and gids to the server even when the lookup wasn't numeric.
  From then on, the client will translate uids and gids that have no
  mapping to the string "nobody", and the server will reject them.
  This problem is not specific to acls.

Other open issues:

 * It would be nice if the MAY_DELETE_SELF flag could override the sticky
   directory check as it did in the previous version of this patch queue.  I
   couldn't come up with a clean way of achieving that.

Thanks,
Andreas

Andreas Gruenbacher (37):
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
  richacl: Add support for unmapped identifiers
  ext4: Don't allow unmapped identifiers in richacls
  sunrpc: Allow to demand-allocate pages to encode into
  sunrpc: Add xdr_init_encode_pages
  nfs: Fix GETATTR bitmap verification
  nfs: Remove unused xdr page offsets in getacl/setacl arguments
  nfs: Add richacl support
  nfs: Add support for the v4.1 dacl attribute

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
 fs/ext4/richacl.c                               | 217 ++++++
 fs/ext4/richacl.h                               |  47 ++
 fs/ext4/super.c                                 |  41 +-
 fs/ext4/xattr.c                                 |   6 +
 fs/ext4/xattr.h                                 |   1 +
 fs/f2fs/acl.c                                   |   4 +-
 fs/inode.c                                      |  15 +-
 fs/namei.c                                      | 108 ++-
 fs/nfs/inode.c                                  |   3 -
 fs/nfs/nfs4proc.c                               | 696 +++++++++++++-----
 fs/nfs/nfs4xdr.c                                | 259 ++++++-
 fs/nfs/super.c                                  |   4 +-
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
 fs/richacl_base.c                               | 669 ++++++++++++++++++
 fs/richacl_compat.c                             | 901 ++++++++++++++++++++++++
 fs/richacl_inode.c                              | 262 +++++++
 fs/richacl_xattr.c                              | 249 +++++++
 fs/xattr.c                                      |  34 +-
 include/linux/fs.h                              |  50 +-
 include/linux/nfs4.h                            |  24 +-
 include/linux/nfs4acl.h                         |   7 +
 include/linux/nfs_fs.h                          |   1 -
 include/linux/nfs_fs_sb.h                       |   2 +
 include/linux/nfs_xdr.h                         |  13 +-
 include/linux/posix_acl.h                       |  12 +-
 include/linux/richacl.h                         | 366 ++++++++++
 include/linux/richacl_compat.h                  |  40 ++
 include/linux/richacl_xattr.h                   |  52 ++
 include/linux/sunrpc/xdr.h                      |   2 +
 include/uapi/linux/fs.h                         |   3 +-
 include/uapi/linux/nfs4.h                       |   3 +-
 include/uapi/linux/xattr.h                      |   2 +
 net/sunrpc/xdr.c                                |  33 +
 55 files changed, 4465 insertions(+), 709 deletions(-)
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
2.4.3

