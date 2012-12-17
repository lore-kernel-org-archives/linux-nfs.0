Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753144Ab2LQPnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 10:43:14 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/13] NFSv4: Label NFS Patches
Date: Mon, 17 Dec 2012 10:42:58 -0500
Message-Id: <1355758991-30049-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are the current version of Dave Quigley's Label NFS patches
which have been ported to the 3.7-rc2 kernel. Both client and 
patches are included in this posting.

I'm posting these patches to help the reviewing process proceed.

The Dave's Git tree is at:
    git://www.selinuxproject.org/~dpquigl/lnfs/

The label NFS wiki is at:
    http://www.selinuxproject.org/page/Labeled_NFS

Dave Quigley (2):
  NFS:Add labels to client function prototypes
  NFS: Add label lifecycle management

David Quigley (11):
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
  NFS: Extend NFS xattr handlers to accept the security namespace
  NFSD: Server implementation of MAC Labeling

 fs/nfs/Kconfig                      |  16 +
 fs/nfs/client.c                     |   2 +-
 fs/nfs/dir.c                        |  53 +++-
 fs/nfs/getroot.c                    |   2 +-
 fs/nfs/inode.c                      | 138 ++++++--
 fs/nfs/namespace.c                  |   2 +-
 fs/nfs/nfs3acl.c                    |   4 +-
 fs/nfs/nfs3proc.c                   |  41 +--
 fs/nfs/nfs4_fs.h                    |   8 +-
 fs/nfs/nfs4namespace.c              |   2 +-
 fs/nfs/nfs4proc.c                   | 612 ++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4xdr.c                    | 202 +++++++++---
 fs/nfs/proc.c                       |  15 +-
 fs/nfs/super.c                      |  19 +-
 fs/nfsd/Kconfig                     |  13 +
 fs/nfsd/export.c                    |   3 +
 fs/nfsd/nfs4proc.c                  |  33 ++
 fs/nfsd/nfs4xdr.c                   | 121 ++++++-
 fs/nfsd/nfsd.h                      |   8 +-
 fs/nfsd/vfs.c                       |  31 ++
 fs/nfsd/vfs.h                       |   2 +
 fs/nfsd/xdr4.h                      |   3 +
 include/linux/nfs4.h                |   9 +
 include/linux/nfs_fs.h              |  26 +-
 include/linux/nfs_fs_sb.h           |  10 +-
 include/linux/nfs_xdr.h             |  30 +-
 include/linux/security.h            |  57 +++-
 include/uapi/linux/nfs4.h           |   1 +
 include/uapi/linux/nfsd/export.h    |   5 +-
 security/capability.c               |  19 +-
 security/security.c                 |  24 +-
 security/selinux/hooks.c            |  92 +++++-
 security/selinux/include/security.h |   2 +
 security/selinux/ss/policydb.c      |   5 +-
 security/smack/smack_lsm.c          |  11 +
 35 files changed, 1416 insertions(+), 205 deletions(-)

-- 
1.7.11.7

