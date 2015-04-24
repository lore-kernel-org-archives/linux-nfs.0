Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36501 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbbDXLEv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:04:51 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-security-module@vger.kernel.org
Subject: [RFC v3 00/45] Richacls
Date: Fri, 24 Apr 2015 13:03:57 +0200
Message-Id: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

here's another update of the richacl patch queue.  The changes since the last
posting (https://lwn.net/Articles/638242/) include:

 * The nfs client now allocates pages for received acls on demand like the
   server does.  It no longer caches the acl size between calls.

 * All possible acls consisting of only owner@, group@, and everyone@ entries
   which are equivalent to the file mode permission bits are now recognized.
   This is needed because by the NFSv4 specification, the nfs server must
   translate the file mode permission bits into an acl if it supports acls at
   all.

 * Support for the dacl attribute over NFSv4.1 for Automatic Inheritance, and
   also for the write_retention and write_retention_hold permissions.

 * The richacl_compute_max_masks() documentation has been improved.

 * Various minor bug fixes.

The git version is available here:

  git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git \
	richacl-2015-04-24

The richacl command-line has been split into getrichacl and setrichacl, in line
with getfacl and setfacl.  Watch out for that when updating the user-space.

Things still to be done, or which I'm not entirely happy with:

 * The nfs server performs some access checking on its own before calling into
   the vfs which is rersponsible for the actual access checking (see where it
   calls inode_permission()).  With the additional MAY_ flags introduced in
   this patch queue, it gets it wrong in some cases; I have yet to figure out
   how to deal with this.

 * We may still need to add back support for the "system.nfs4_acl" attribute on
   nfs mounts for backwards compatibility; it's not clear to me if anyone is
   actually using that.

 * It would be nice if the MAY_DELETE_SELF flag could override the sticky
   directory check as it did in the previous version of this patch queue.  I
   couldn't come up with a clean way of achieving that, though.

 * The base_acl code is still rather ugly.

Thanks,
Andreas


Andreas Gruenbacher (43):
  vfs: Minor documentation fix
  uapi: Remove kernel internal declaration
  nfsd: Checking for acl support does not require fetching any acls
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
  vfs: Cache base_acl objects in inodes
  vfs: Cache richacl in struct inode
  richacl: Create-time inheritance
  richacl: Check if an acl is equivalent to a file mode
  richacl: Also recognize nontrivial mode-equivalent acls
  richacl: Automatic Inheritance
  richacl: xattr mapping functions
  vfs: Add richacl permission checking
  richacl: acl editing helper functions
  richacl: Move everyone@ aces down the acl
  richacl: Propagate everyone@ permissions to other aces
  richacl: Isolate the owner and group classes
  richacl: Apply the file masks to a richacl
  richacl: Create richacl from mode values
  richacl: Create acl with masks applied in richacl_from_mode()
  nfsd: Remove dead declarations
  nfsd: Keep list of acls to dispose of in compoundargs
  nfsd: Use richacls as internal acl representation
  nfsd: Add richacl support
  NFSv4: Fix GETATTR bitmap verification
  nfs/sunrpc: No more encode and decode function pointer casting
  nfs/sunrpc: Return status code from encode functions
  nfs3: Return posix acl encode errors
  nfs: Remove unused xdr page offsets in getacl/setacl arguments
  rpc: Allow to demand-allocate pages to encode into
  nfs: Add richacl support
  uapi/nfs: Add NFSv4.1 ACL definitions
  nfsd: Add support for the v4.1 dacl attribute
  nfs: Add support for the v4.1 dacl attribute

Aneesh Kumar K.V (2):
  ext4: Add richacl support
  ext4: Add richacl feature flag

 Documentation/filesystems/porting               |    8 +-
 Documentation/filesystems/vfs.txt               |    3 +
 drivers/staging/lustre/lustre/llite/llite_lib.c |    2 +-
 fs/Kconfig                                      |    9 +
 fs/Makefile                                     |    3 +
 fs/attr.c                                       |   81 +-
 fs/ext4/Kconfig                                 |   15 +
 fs/ext4/Makefile                                |    1 +
 fs/ext4/acl.c                                   |    7 +-
 fs/ext4/acl.h                                   |   12 +-
 fs/ext4/ext4.h                                  |    6 +-
 fs/ext4/file.c                                  |    6 +-
 fs/ext4/ialloc.c                                |    7 +-
 fs/ext4/inode.c                                 |   10 +-
 fs/ext4/namei.c                                 |   11 +-
 fs/ext4/richacl.c                               |  211 +++++
 fs/ext4/richacl.h                               |   47 ++
 fs/ext4/super.c                                 |   41 +-
 fs/ext4/xattr.c                                 |    6 +
 fs/ext4/xattr.h                                 |    1 +
 fs/f2fs/acl.c                                   |    4 +-
 fs/inode.c                                      |   15 +-
 fs/lockd/clnt4xdr.c                             |   58 +-
 fs/lockd/clntxdr.c                              |   58 +-
 fs/lockd/mon.c                                  |   26 +-
 fs/namei.c                                      |  108 ++-
 fs/nfs/inode.c                                  |    3 -
 fs/nfs/mount_clnt.c                             |   24 +-
 fs/nfs/nfs2xdr.c                                |  115 ++-
 fs/nfs/nfs3xdr.c                                |  225 +++--
 fs/nfs/nfs4proc.c                               |  357 ++++----
 fs/nfs/nfs4xdr.c                                | 1001 +++++++++++++++--------
 fs/nfs/super.c                                  |    4 +-
 fs/nfs_common/Makefile                          |    1 +
 fs/nfs_common/nfs4acl.c                         |   41 +
 fs/nfsd/Kconfig                                 |    1 +
 fs/nfsd/acl.h                                   |   23 +-
 fs/nfsd/nfs4acl.c                               |  499 +++++------
 fs/nfsd/nfs4callback.c                          |   29 +-
 fs/nfsd/nfs4proc.c                              |   17 +-
 fs/nfsd/nfs4xdr.c                               |  280 ++++---
 fs/nfsd/nfsd.h                                  |    6 +-
 fs/nfsd/xdr4.h                                  |   12 +-
 fs/posix_acl.c                                  |   31 +-
 fs/richacl_base.c                               |  587 +++++++++++++
 fs/richacl_compat.c                             |  841 +++++++++++++++++++
 fs/richacl_inode.c                              |  268 ++++++
 fs/richacl_xattr.c                              |  210 +++++
 fs/xattr.c                                      |   34 +-
 include/linux/fs.h                              |   47 +-
 include/linux/nfs4.h                            |   17 +-
 include/linux/nfs4acl.h                         |    7 +
 include/linux/nfs_fs.h                          |    1 -
 include/linux/nfs_fs_sb.h                       |    2 +
 include/linux/nfs_xdr.h                         |   12 +-
 include/linux/posix_acl.h                       |   12 +-
 include/linux/richacl.h                         |  332 ++++++++
 include/linux/richacl_compat.h                  |   40 +
 include/linux/richacl_xattr.h                   |   52 ++
 include/linux/sunrpc/xdr.h                      |    5 +-
 include/uapi/linux/fs.h                         |    3 +-
 include/uapi/linux/nfs4.h                       |   17 +-
 include/uapi/linux/xattr.h                      |    2 +
 net/sunrpc/auth.c                               |    7 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c            |    4 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.c               |   11 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.h               |    8 +-
 net/sunrpc/clnt.c                               |    5 +-
 net/sunrpc/rpcb_clnt.c                          |   57 +-
 net/sunrpc/xdr.c                                |    8 +
 70 files changed, 4720 insertions(+), 1294 deletions(-)
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
2.1.0

