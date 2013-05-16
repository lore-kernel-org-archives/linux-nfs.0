Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38783 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844Ab3EPP4x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 May 2013 11:56:53 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Froe e71bf1d708e1294b3bae64d04f03228b3625f2a3 Mon Sep 17 00:00:00 2001
Date: Thu, 16 May 2013 11:56:35 -0400
Message-Id: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an updated to the linux-3-10.rc1 release. The minor 
changes in this release are:

* Added the needed Acked-by:

* Stop labels leaking into the cache_consistency_bitmask

David Quigley (7):
  Security: Add Hook to test if the particular xattr is part of a MAC
    model.
  LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount
    data.
  SELinux: Add new labeling type native labels
  NFSv4: Add label recommended attribute and NFSv4 flags
  NFSv4: Introduce new label structure
  NFSv4: Extend fattr bitmaps to support all 3 words
  NFS: Extend NFS xattr handlers to accept the security namespace

Steve Dickson (6):
  Security: Add hook to calculate context based on a negative dentry.
  NFSv4.2: Added NFS v4.2 support to the NFS client
  NFS:Add labels to client function prototypes
  NFS: Add label lifecycle management
  NFS: Client implementation of Labeled-NFS
  Kconfig: Add Kconfig entry for Labeled NFS V4 client

 fs/nfs/Kconfig                      |  28 ++
 fs/nfs/callback.c                   |   1 +
 fs/nfs/callback_xdr.c               |   6 +-
 fs/nfs/client.c                     |   2 +-
 fs/nfs/dir.c                        |  46 ++-
 fs/nfs/getroot.c                    |   2 +-
 fs/nfs/inode.c                      | 133 +++++++--
 fs/nfs/namespace.c                  |   2 +-
 fs/nfs/nfs3acl.c                    |   4 +-
 fs/nfs/nfs3proc.c                   |  41 +--
 fs/nfs/nfs4_fs.h                    |   8 +-
 fs/nfs/nfs4client.c                 |   5 +
 fs/nfs/nfs4namespace.c              |   2 +-
 fs/nfs/nfs4proc.c                   | 549 ++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4xdr.c                    | 184 +++++++++---
 fs/nfs/proc.c                       |  15 +-
 fs/nfs/super.c                      |  24 +-
 include/linux/nfs4.h                |  11 +
 include/linux/nfs_fs.h              |  30 +-
 include/linux/nfs_fs_sb.h           |   8 +-
 include/linux/nfs_xdr.h             |  30 +-
 include/linux/security.h            |  57 +++-
 include/uapi/linux/nfs4.h           |   2 +-
 security/capability.c               |  19 +-
 security/security.c                 |  24 +-
 security/selinux/hooks.c            |  92 +++++-
 security/selinux/include/security.h |   2 +
 security/selinux/ss/policydb.c      |   5 +-
 security/smack/smack_lsm.c          |  11 +
 29 files changed, 1133 insertions(+), 210 deletions(-)

-- 
1.8.1.4

