Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55843 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755973Ab3EVQuv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 May 2013 12:50:51 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 00/13] lnfs: 3.10-rc2 release
Date: Wed, 22 May 2013 12:50:33 -0400
Message-Id: <1369241446-7680-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

Here is the next release the label NFS patches ported to 
linux-3-10.rc2 release.

The changes made in this release:

* Add new Ack-by's 

* Fixed typo in v4.2 section of Kconfig

* Removed all the label points that are no longer needed in linux/nfs_xdr.h

* Move NFS4_MAXLABELLEN to linux/nfs4.h

* Move the label processing out of nfs_post_op_update_inode() and
  nfs_refresh_inode(), putting it around them. 

* Removed the state processing from set security label code.

* Added a new decode_getfattr_label() routine which is by 
  ops that process labels. 

* Removed the select from the Kconfig file


David Quigley (9):
  Security: Add Hook to test if the particular xattr is part of a MAC
    model.
  LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount
    data.
  SELinux: Add new labeling type native labels
  NFSv4: Add label recommended attribute and NFSv4 flags
  NFSv4: Extend fattr bitmaps to support all 3 words
  NFS:Add labels to client function prototypes
  NFS: Add label lifecycle management
  NFS: Client implementation of Labeled-NFS
  NFS: Extend NFS xattr handlers to accept the security namespace

Steve Dickson (4):
  Security: Add hook to calculate context based on a negative dentry.
  NFSv4.2: Added NFS v4.2 support to the NFS client
  NFSv4: Introduce new label structure
  Kconfig: Add Kconfig entry for Labeled NFS V4 client

 fs/nfs/Kconfig                      |  28 ++
 fs/nfs/callback.c                   |   1 +
 fs/nfs/callback_xdr.c               |   6 +-
 fs/nfs/client.c                     |   2 +-
 fs/nfs/dir.c                        |  49 +++-
 fs/nfs/getroot.c                    |   2 +-
 fs/nfs/inode.c                      | 109 +++++++-
 fs/nfs/namespace.c                  |   2 +-
 fs/nfs/nfs3proc.c                   |   7 +-
 fs/nfs/nfs4_fs.h                    |   6 +-
 fs/nfs/nfs4client.c                 |   5 +
 fs/nfs/nfs4proc.c                   | 518 ++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4xdr.c                    | 174 +++++++++---
 fs/nfs/proc.c                       |  13 +-
 fs/nfs/super.c                      |  24 +-
 include/linux/nfs4.h                |  13 +
 include/linux/nfs_fs.h              |  26 +-
 include/linux/nfs_fs_sb.h           |   8 +-
 include/linux/nfs_xdr.h             |  20 +-
 include/linux/security.h            |  57 +++-
 security/capability.c               |  19 +-
 security/security.c                 |  24 +-
 security/selinux/hooks.c            |  92 ++++++-
 security/selinux/include/security.h |   2 +
 security/selinux/ss/policydb.c      |   5 +-
 security/smack/smack_lsm.c          |  11 +
 26 files changed, 1066 insertions(+), 157 deletions(-)

-- 
1.8.1.4

