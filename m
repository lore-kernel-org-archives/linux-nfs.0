Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:54568 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397Ab3AVNku (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 08:40:50 -0500
From: Steve Dickson <steved@redhat.com>
To: David Quigley <selinux@davequigley.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/14] lNFS: 3.8-rc3 release
Date: Tue, 22 Jan 2013 08:40:28 -0500
Message-Id: <1358862042-27520-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the latest version of the label NFS code that has
been forward ported to 3.8-rc3. 

This release also contains the fix of not sleep while holding
the inode spin lock. 

The Fedora kernel rpms that have the patches are under
    http://steved.fedorapeople.org/lnfs/kernels/

A wireshark rpm that can dissect the labels is under
   http://steved.fedorapeople.org/lnfs/wireshark/

The actual patches from the release are under
   http://steved.fedorapeople.org/lnfs/patches/v3.8-rc3-lnfs/

I did all my testing on Fedora 18, but I'm assuming these 
rpms will work in on Fedora 17 as well. If that is not the
case please let me know.

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

Steve Dickson (1):
  lnfs: Do not sleep holding the inode spin lock.

 fs/nfs/Kconfig                      |  16 +
 fs/nfs/client.c                     |   2 +-
 fs/nfs/dir.c                        |  49 ++-
 fs/nfs/getroot.c                    |   2 +-
 fs/nfs/inode.c                      | 146 +++++++--
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
 33 files changed, 1366 insertions(+), 203 deletions(-)

-- 
1.8.1

