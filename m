Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38983 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756531Ab3CYLoN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 07:44:13 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 00/14] lnfs: 3.9-rc3 release
Date: Mon, 25 Mar 2013 07:42:44 -0400
Message-Id: <1364211778-29172-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

Here is the next release of the Label NFS patches 
forward ported to linux-3.9-rc3.

These are the bits I successfully tested at this year's
Connectathon and has been very stable for a quite while now.

This release does not contain the bit that enable the
-o v4.2 mount options. It turns out adding these bits 
are not as straightforward as once thought. Especially 
tying the labeling functionality to a mount option.

So I'm going to submit those enabling 4.2 bits in a 
different patch set since they functionally different
than the core labeling bits.

So if possible, I would like these core lnfs bits be accepted
as is, keeping the "only for developers and testers" 
config warning in place. Once the 4.2 bits are added, that
warning could be removed.


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
 fs/nfs/nfs4proc.c                   | 561 ++++++++++++++++++++++++++++++++----
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
 33 files changed, 1332 insertions(+), 210 deletions(-)

-- 
1.8.1.4

