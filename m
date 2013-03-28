Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756055Ab3C1N5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Mar 2013 09:57:23 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 00/14] nfs: 3.9-rc3 release (v2)
Date: Thu, 28 Mar 2013 09:53:51 -0400
Message-Id: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

A bug was found in the READDIR code with v4.1 and v4.2 mounts
which caused the client to request an attribute it did not
support. Only v4.0 mounts were tested at Connectathon. 

The v4.2 enabling code will be coming in the next few days. It
just needs a little more testing. 

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
  NFSv4: Add label recommended attribute and NFSv4 flags
  NFSv4: Introduce new label structure
  NFSv4: Extend fattr bitmaps to support all 3 words
  NFS: Client implementation of Labeled-NFS
  NFS: Extend NFS xattr handlers to accept the security namespace
  NFSD: Server implementation of MAC Labeling

Steve Dickson (2):
  Kconfig: Add Kconfig entry for Labeled NFS V4 client
  Kconfig: Add Kconfig entry for Labeled NFS V4 server

 fs/nfs/Kconfig                      |  18 ++
 fs/nfs/client.c                     |   2 +-
 fs/nfs/dir.c                        |  46 ++-
 fs/nfs/getroot.c                    |   2 +-
 fs/nfs/inode.c                      | 129 +++++++--
 fs/nfs/namespace.c                  |   2 +-
 fs/nfs/nfs3acl.c                    |   4 +-
 fs/nfs/nfs3proc.c                   |  41 +--
 fs/nfs/nfs4_fs.h                    |   8 +-
 fs/nfs/nfs4namespace.c              |   2 +-
 fs/nfs/nfs4proc.c                   | 563 ++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4xdr.c                    | 188 +++++++++---
 fs/nfs/proc.c                       |  15 +-
 fs/nfs/super.c                      |  17 +-
 fs/nfsd/Kconfig                     |  16 +
 fs/nfsd/nfs4proc.c                  |  41 +++
 fs/nfsd/nfs4xdr.c                   | 116 +++++++-
 fs/nfsd/nfsd.h                      |   6 +-
 fs/nfsd/vfs.c                       |  29 ++
 fs/nfsd/vfs.h                       |   2 +
 fs/nfsd/xdr4.h                      |   3 +
 include/linux/nfs4.h                |   8 +
 include/linux/nfs_fs.h              |  30 +-
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
 33 files changed, 1328 insertions(+), 212 deletions(-)

-- 
1.8.1.4

