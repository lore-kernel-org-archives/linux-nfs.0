Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21201 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757814Ab3DXUXC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 16:23:02 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 00/17] lnfs: 3.9-rc8 release
Date: Wed, 24 Apr 2013 16:17:46 -0400
Message-Id: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

Here is the next release of the Label NFS patches 
forward ported to linux-3.9-rc9.

The changes on this release are:

* Move the enabling of V4.2 patches to the front 
  of the series. 

* Changed nfsd_suppattrs2() to only give out minor version
  2 attrs on minor version 2 mounts.

* Fixed the return value of nfsd4_set_nfs4_label()
  when labels are not enabled.

* Made sure the sa_label point was initialized to NULL
  when labels are not enabled. 

* Added the encoding of the third bit mask in
  nfsd4_encode_setattr

The patches are on a git tree at
    git://fedorapeople.org/~steved/linux-steved lnfs-v3.9-rc8

David Quigley (12):
  Security: Add hook to calculate context based on a negative dentry.
  Security: Add Hook to test if the particular xattr is part of a MAC
    model.
  LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount
    data.
  SELinux: Add new labeling type native labels
  NFSv4: Add label recommended attribute and NFSv4 flags
  NFSv4: Introduce new label structure
  NFSv4: Extend fattr bitmaps to support all 3 words
  NFS:Add labels to client function prototypes
  NFS: Add label lifecycle management
  NFS: Client implementation of Labeled-NFS
  NFS: Extend NFS xattr handlers to accept the security namespace
  NFSD: Server implementation of MAC Labeling

Steve Dickson (5):
  NFSv4.2: Added v4.2 error codes
  NFSv4.2: Added NFS v4.2 support to the NFS client
  NFSDv4.2: Added NFS v4.2 support to the NFS server
  Kconfig: Add Kconfig entry for Labeled NFS V4 client
  Kconfig: Add Kconfig entry for Labeled NFS V4 server

 fs/nfs/Kconfig                      |  28 ++
 fs/nfs/callback.c                   |   1 +
 fs/nfs/client.c                     |   2 +-
 fs/nfs/dir.c                        |  46 ++-
 fs/nfs/getroot.c                    |   2 +-
 fs/nfs/inode.c                      | 133 ++++++--
 fs/nfs/namespace.c                  |   2 +-
 fs/nfs/nfs3acl.c                    |   4 +-
 fs/nfs/nfs3proc.c                   |  41 +--
 fs/nfs/nfs4_fs.h                    |   8 +-
 fs/nfs/nfs4client.c                 |   5 +
 fs/nfs/nfs4namespace.c              |   2 +-
 fs/nfs/nfs4proc.c                   | 614 ++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4xdr.c                    | 188 ++++++++---
 fs/nfs/pnfs.c                       |   2 +-
 fs/nfs/proc.c                       |  15 +-
 fs/nfs/super.c                      |  24 +-
 fs/nfsd/Kconfig                     |  16 +
 fs/nfsd/nfs4proc.c                  |  41 +++
 fs/nfsd/nfs4xdr.c                   | 122 ++++++-
 fs/nfsd/nfsd.h                      |  23 +-
 fs/nfsd/nfsproc.c                   |   1 +
 fs/nfsd/vfs.c                       |  28 ++
 fs/nfsd/vfs.h                       |   2 +
 fs/nfsd/xdr4.h                      |   3 +
 include/linux/nfs4.h                |  20 ++
 include/linux/nfs_fs.h              |  40 ++-
 include/linux/nfs_fs_sb.h           |  10 +-
 include/linux/nfs_xdr.h             |  30 +-
 include/linux/security.h            |  57 +++-
 include/uapi/linux/nfs4.h           |   2 +-
 security/capability.c               |  19 +-
 security/security.c                 |  24 +-
 security/selinux/hooks.c            |  92 +++++-
 security/selinux/include/security.h |   2 +
 security/selinux/ss/policydb.c      |   5 +-
 security/smack/smack_lsm.c          |  11 +
 37 files changed, 1447 insertions(+), 218 deletions(-)

-- 
1.8.1.4

