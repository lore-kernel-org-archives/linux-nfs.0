Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754271Ab3BRSsK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 13:48:10 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 00/14] lnfs: 3.8-rc7 release
Date: Mon, 18 Feb 2013 13:47:42 -0500
Message-Id: <1361213276-17962-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

Here is the next release of the Label NFS patches, forward 
ported to linux-3.8-rc7

I believe I've  incorporated all code review that were made
from the last release, including reworking how the labels are 
allocated and freed on both client and server. Thank you 
for those cycles!

I have every intention on bring these bits to next week's Connectathon
so hopefully we can resolve any outstanding issues before then,
if there are any... ;-) 

The Fedora kernel rpms that have the patches are under
    http://steved.fedorapeople.org/lnfs/kernels/

A wireshark rpm that can dissect the labels is under
   http://steved.fedorapeople.org/lnfs/wireshark/

The actual patches from this release are under
   http://steved.fedorapeople.org/lnfs/patches/lnfs-v3.8-rc7

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
 fs/nfs/nfs4xdr.c                    | 192 +++++++++---
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
 33 files changed, 1333 insertions(+), 211 deletions(-)

-- 
1.8.1.2

