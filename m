Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946405Ab3BHMj3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2013 07:39:29 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 00/15] lnfs: 3.8-rc6 release
Date: Fri,  8 Feb 2013 07:39:08 -0500
Message-Id: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

Here is the next release of the Label NFS code, forward ported to linux-3.8-rc6. 
I've incorporated all of the code review comments (thank you for that time) with the exception of the following:

> Why not use the more common construct of defining
>
> struct nfs4_label {
> 	....
> 	char label[NFS4_MAXLABELLEN];
> };
It makes things easier to keep label a pointer verses an array when it comes to initializing the structure (see _nfs4_get_security_label()), although I did 
decrease NFS4_MAXLABELLEN to (4095 - offsetof(struct nfs4_label , label))


> +	u32			attr_bitmask_nl[3];
> +						/* V4 bitmask representing the
> +						   set of attributes supported
> +						   on this filesystem excluding
> +						   the label support bit. */
>
> Can't we just have attr_bitmask_nl point to attr_bitmask when not #ifdef
> CONFIG_NFS_V4_SECURITY_LABEL?
I'm thinking having both bitmasks makes it more obvious as to what is or is not 
being used. I'm referring to the code in _nfs4_proc_getattr() and _nfs4_proc_lookup().
If the label is not set, use the non label bit mask verses hiding things behind
a pointer and not really knowing what bit mask is being used.

I also found and fixed a couple memory leaks... 

The Fedora kernel rpms that have the patches are under
    http://steved.fedorapeople.org/lnfs/kernels/

A wireshark rpm that can dissect the labels is under
   http://steved.fedorapeople.org/lnfs/wireshark/

The actual patches from this release are under
   http://steved.fedorapeople.org/lnfs/patches/lnfs-v3.8-rc6


Dave Quigley (3):
  NFS:Add labels to client function prototypes
  NFS: Add label lifecycle management
  lnfs: Do not sleep holding the inode spin lock

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
 fs/nfs/inode.c                      | 140 +++++++--
 fs/nfs/namespace.c                  |   2 +-
 fs/nfs/nfs3acl.c                    |   4 +-
 fs/nfs/nfs3proc.c                   |  41 +--
 fs/nfs/nfs4_fs.h                    |   8 +-
 fs/nfs/nfs4namespace.c              |   2 +-
 fs/nfs/nfs4proc.c                   | 565 ++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4xdr.c                    | 199 ++++++++++---
 fs/nfs/proc.c                       |  15 +-
 fs/nfs/super.c                      |  17 +-
 fs/nfsd/Kconfig                     |  16 +
 fs/nfsd/nfs4proc.c                  |  41 +++
 fs/nfsd/nfs4xdr.c                   | 116 +++++++-
 fs/nfsd/nfsd.h                      |   8 +-
 fs/nfsd/vfs.c                       |  30 ++
 fs/nfsd/vfs.h                       |   2 +
 fs/nfsd/xdr4.h                      |   3 +
 include/linux/nfs4.h                |   8 +
 include/linux/nfs_fs.h              |  29 +-
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
 33 files changed, 1352 insertions(+), 214 deletions(-)

-- 
1.7.11.7

