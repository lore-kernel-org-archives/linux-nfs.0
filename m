Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898AbbI0WJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Sep 2015 18:09:46 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Subject: [PATCH v8 00/41] Richacls
Date: Mon, 28 Sep 2015 00:08:51 +0200
Message-Id: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

here's another update of the richacl patch queue.  At this stage, I would
like to ask for final feedback so that the core and ext4 code (patches
1-19) can be merged in the 4.4 merge window.  The nfsd and nfs code should
then go through the respective maintainer trees.

Changes since the last posting (https://lwn.net/Articles/656704/):

* The MAY_DELETE_SELF permission now also overrides the sticky
   directory checks.

* Fix the permission check algorithm to apply the owner mask instead
  of the group mask to user entries matching the current owner. That way,
  the owner will retain the permissions in those entries when creating
  objects with create mode 0700 and similar. (A chmod to mode 0700 already
  creates an owner@:rwpx::allow ace, which was hiding this bug.)

* Fix richacl_apply_masks to properly insert deny aces when raising the
  permissions of the other class. The bug could be triggered by
  chmod'ing a group@:r::allow acl to mode 0077, for example.

* Various cleanups and improvements to comments.


The complete patch queue is available here:

  git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git \
          richacl-2015-09-28


The richacl user-space utilitites and test suite are available here:

  https://github.com/andreas-gruenbacher/richacl/


Open issues in nfs:

* When a user or group name cannot be mapped, nfs's idmapper always maps it
  to nobody. That's good enough for mapping the file owner and owning
  group, but not for identifiers in acls. For now, to get the nfs richacl
  support somewhat working, I'm explicitly checking if mapping has resulted
  in uid/gid 99 in the kernel.

* When the nfs server replies with NFS4ERR_BADNAME for any user or group
  name lookup, the client will stop sending numeric uids and gids to the
  server even when the lookup wasn't numeric.  From then on, the client
  will translate uids and gids that have no mapping to the string "nobody",
  and the server will reject them.  This problem is not specific to acls.

Thanks,
Andreas

Andreas Gruenbacher (39):
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
  nfsd: Add support for the MAY_CREATE_{FILE,DIR} permissions
  richacl: Add support for unmapped identifiers
  ext4: Don't allow unmapped identifiers in richacls
  sunrpc: Allow to demand-allocate pages to encode into
  sunrpc: Add xdr_init_encode_pages
  nfs: Fix GETATTR bitmap verification
  nfs: Remove unused xdr page offsets in getacl/setacl arguments
  nfs: Add richacl support
  nfs: Add support for the v4.1 dacl attribute
  richacl: uapi header split

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
 fs/ext4/richacl.c                               | 218 ++++++
 fs/ext4/richacl.h                               |  47 ++
 fs/ext4/super.c                                 |  42 +-
 fs/ext4/xattr.c                                 |   6 +
 fs/ext4/xattr.h                                 |   1 +
 fs/f2fs/acl.c                                   |   4 +-
 fs/inode.c                                      |  15 +-
 fs/jffs2/acl.c                                  |   6 +-
 fs/namei.c                                      | 111 ++-
 fs/nfs/inode.c                                  |   3 -
 fs/nfs/nfs4proc.c                               | 701 +++++++++++++-----
 fs/nfs/nfs4xdr.c                                | 257 ++++++-
 fs/nfs/super.c                                  |   4 +-
 fs/nfs_common/Makefile                          |   1 +
 fs/nfs_common/nfs4acl.c                         |  44 ++
 fs/nfsd/Kconfig                                 |   1 +
 fs/nfsd/acl.h                                   |  23 +-
 fs/nfsd/nfs4acl.c                               | 482 +++++++------
 fs/nfsd/nfs4proc.c                              |  25 +-
 fs/nfsd/nfs4xdr.c                               | 268 ++++---
 fs/nfsd/nfsd.h                                  |   6 +-
 fs/nfsd/nfsfh.c                                 |   8 +-
 fs/nfsd/vfs.c                                   |  28 +-
 fs/nfsd/vfs.h                                   |  17 +-
 fs/nfsd/xdr4.h                                  |  12 +-
 fs/posix_acl.c                                  |  26 +-
 fs/richacl_base.c                               | 682 ++++++++++++++++++
 fs/richacl_compat.c                             | 915 ++++++++++++++++++++++++
 fs/richacl_inode.c                              | 297 ++++++++
 fs/richacl_xattr.c                              | 267 +++++++
 fs/xattr.c                                      |  34 +-
 include/linux/fs.h                              |  50 +-
 include/linux/nfs4.h                            |  24 +-
 include/linux/nfs4acl.h                         |   7 +
 include/linux/nfs_fs.h                          |   1 -
 include/linux/nfs_fs_sb.h                       |   2 +
 include/linux/nfs_xdr.h                         |  13 +-
 include/linux/posix_acl.h                       |  12 +-
 include/linux/richacl.h                         | 275 +++++++
 include/linux/richacl_compat.h                  |  40 ++
 include/linux/richacl_xattr.h                   |  47 ++
 include/linux/sunrpc/xdr.h                      |   2 +
 include/uapi/linux/Kbuild                       |   2 +
 include/uapi/linux/fs.h                         |   3 +-
 include/uapi/linux/nfs4.h                       |   3 +-
 include/uapi/linux/richacl.h                    | 111 +++
 include/uapi/linux/richacl_xattr.h              |  43 ++
 include/uapi/linux/xattr.h                      |   2 +
 net/sunrpc/xdr.c                                |  34 +
 62 files changed, 4659 insertions(+), 732 deletions(-)
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
 create mode 100644 include/uapi/linux/richacl.h
 create mode 100644 include/uapi/linux/richacl_xattr.h

-- 
2.4.3


Andreas Gruenbacher (39):
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
  nfsd: Add support for the MAY_CREATE_{FILE,DIR} permissions
  richacl: Add support for unmapped identifiers
  ext4: Don't allow unmapped identifiers in richacls
  sunrpc: Allow to demand-allocate pages to encode into
  sunrpc: Add xdr_init_encode_pages
  nfs: Fix GETATTR bitmap verification
  nfs: Remove unused xdr page offsets in getacl/setacl arguments
  nfs: Add richacl support
  nfs: Add support for the v4.1 dacl attribute
  richacl: uapi header split

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
 fs/ext4/richacl.c                               | 218 ++++++
 fs/ext4/richacl.h                               |  47 ++
 fs/ext4/super.c                                 |  42 +-
 fs/ext4/xattr.c                                 |   6 +
 fs/ext4/xattr.h                                 |   1 +
 fs/f2fs/acl.c                                   |   4 +-
 fs/inode.c                                      |  15 +-
 fs/jffs2/acl.c                                  |   6 +-
 fs/namei.c                                      | 111 ++-
 fs/nfs/inode.c                                  |   3 -
 fs/nfs/nfs4proc.c                               | 701 +++++++++++++-----
 fs/nfs/nfs4xdr.c                                | 257 ++++++-
 fs/nfs/super.c                                  |   4 +-
 fs/nfs_common/Makefile                          |   1 +
 fs/nfs_common/nfs4acl.c                         |  44 ++
 fs/nfsd/Kconfig                                 |   1 +
 fs/nfsd/acl.h                                   |  23 +-
 fs/nfsd/nfs4acl.c                               | 482 +++++++------
 fs/nfsd/nfs4proc.c                              |  25 +-
 fs/nfsd/nfs4xdr.c                               | 268 ++++---
 fs/nfsd/nfsd.h                                  |   6 +-
 fs/nfsd/nfsfh.c                                 |   8 +-
 fs/nfsd/vfs.c                                   |  28 +-
 fs/nfsd/vfs.h                                   |  17 +-
 fs/nfsd/xdr4.h                                  |  12 +-
 fs/posix_acl.c                                  |  26 +-
 fs/richacl_base.c                               | 682 ++++++++++++++++++
 fs/richacl_compat.c                             | 915 ++++++++++++++++++++++++
 fs/richacl_inode.c                              | 297 ++++++++
 fs/richacl_xattr.c                              | 267 +++++++
 fs/xattr.c                                      |  34 +-
 include/linux/fs.h                              |  50 +-
 include/linux/nfs4.h                            |  24 +-
 include/linux/nfs4acl.h                         |   7 +
 include/linux/nfs_fs.h                          |   1 -
 include/linux/nfs_fs_sb.h                       |   2 +
 include/linux/nfs_xdr.h                         |  13 +-
 include/linux/posix_acl.h                       |  12 +-
 include/linux/richacl.h                         | 275 +++++++
 include/linux/richacl_compat.h                  |  40 ++
 include/linux/richacl_xattr.h                   |  47 ++
 include/linux/sunrpc/xdr.h                      |   2 +
 include/uapi/linux/Kbuild                       |   2 +
 include/uapi/linux/fs.h                         |   3 +-
 include/uapi/linux/nfs4.h                       |   3 +-
 include/uapi/linux/richacl.h                    | 111 +++
 include/uapi/linux/richacl_xattr.h              |  43 ++
 include/uapi/linux/xattr.h                      |   2 +
 net/sunrpc/xdr.c                                |  34 +
 62 files changed, 4659 insertions(+), 732 deletions(-)
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
 create mode 100644 include/uapi/linux/richacl.h
 create mode 100644 include/uapi/linux/richacl_xattr.h

-- 
2.4.3

