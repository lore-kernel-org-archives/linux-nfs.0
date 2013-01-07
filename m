Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:52650 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab3AGOxQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2013 09:53:16 -0500
From: Steve Dickson <steved@redhat.com>
To: David Quigley <selinux@davequigley.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/12] lNFS: 3.7 port
Date: Mon,  7 Jan 2013 09:47:21 -0500
Message-Id: <1357570053-28849-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I basically reworked the code in the following areas:

1) Forward ported to Linux 3.7 kernel

2) Separated the server patches from the client patches

3) Eliminated the need for the previous two clean up patches

4) Eliminated a large number of #ifdefs 

Dave Quigley (2):
  NFS:Add labels to client function prototypes
  NFS: Add label lifecycle management

David Quigley (10):
  Security: Add hook to calculate context based on a negative dentry.
  Security: Add Hook to test if the particular xattr is part of a MAC
    model.
  LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount
    data.
  SELinux: Add new labeling type native labels
  KConfig: Add KConfig entries for Labeled NFS
  NFSv4: Add label recommended attribute and NFSv4 flags
  NFSv4: Introduce new label structure
  NFSv4: Extend fattr bitmaps to support all 3 words
  NFS: Client implementation of Labeled-NFS
  NFSD: Server implementation of MAC Labeling

 fs/nfs/Kconfig                      |  16 +
 fs/nfs/client.c                     |   2 +-
 fs/nfs/dir.c                        |  49 ++-
 fs/nfs/getroot.c                    |   2 +-
 fs/nfs/inode.c                      | 140 +++++++--
 fs/nfs/namespace.c                  |   2 +-
 fs/nfs/nfs3acl.c                    |   4 +-
 fs/nfs/nfs3proc.c                   |  41 +--
 fs/nfs/nfs4_fs.h                    |   8 +-
 fs/nfs/nfs4namespace.c              |   2 +-
 fs/nfs/nfs4proc.c                   | 574 ++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4xdr.c                    | 198 ++++++++++---
 fs/nfs/proc.c                       |  15 +-
 fs/nfs/super.c                      |  17 +-
 fs/nfsd/Kconfig                     |  13 +
 fs/nfsd/nfs4proc.c                  |  33 +++
 fs/nfsd/nfs4xdr.c                   | 115 +++++++-
 fs/nfsd/nfsd.h                      |   8 +-
 fs/nfsd/vfs.c                       |  31 ++
 fs/nfsd/vfs.h                       |   2 +
 fs/nfsd/xdr4.h                      |   3 +
 include/linux/nfs4.h                |   9 +
 include/linux/nfs_fs.h              |  28 +-
 include/linux/nfs_fs_sb.h           |  10 +-
 include/linux/nfs_xdr.h             |  30 +-
 include/linux/security.h            |  57 +++-
 include/uapi/linux/nfs4.h           |   1 +
 security/capability.c               |  19 +-
 security/security.c                 |  24 +-
 security/selinux/hooks.c            |  92 +++++-
 security/selinux/include/security.h |   2 +
 security/selinux/ss/policydb.c      |   5 +-
 security/smack/smack_lsm.c          |  11 +
 33 files changed, 1360 insertions(+), 203 deletions(-)

-- 
1.7.11.7

