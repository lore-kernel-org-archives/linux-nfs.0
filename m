Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43871 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181Ab3EDESy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 May 2013 00:18:54 -0400
Message-ID: <51848BE0.2080901@redhat.com>
Date: Sat, 04 May 2013 07:17:36 +0300
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>
CC: Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>, Jack Rieden <jrieden@redhat.com>
Subject: Re: [PATCH 00/17] lnfs: linux-3.9 release
References: <1367515151-31015-1-git-send-email-SteveD@redhat.com>
In-Reply-To: <1367515151-31015-1-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/02/2013 08:18 PM, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
>
> Here is an the next rlease of the label NFS patches
> ported to the linux-3.9 release
>
> The following changes were made from the previous release.
> (Note, only the server patch changed in this release)
>
> * Remove the buffer overflow in the allocation of labels.
>
> * Removed needless char * casting
>
> * Removed the -EMSGSIZE to nfs4err_badlabel errno mapping
>    by changing the return value of nfsd4_label_alloc() to
>    be a _be32 value.

It would be great to see this patch series land in time for 3.10 - seems like a 
major feature that has had been held in development for years and it does have a 
very interested user base waiting for this to land.

Are there any existing roadblocks to having this make it this merge window?

Thanks!

Ric



>
>
> David Quigley (12):
>    Security: Add hook to calculate context based on a negative dentry.
>    Security: Add Hook to test if the particular xattr is part of a MAC
>      model.
>    LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount
>      data.
>    SELinux: Add new labeling type native labels
>    NFSv4: Add label recommended attribute and NFSv4 flags
>    NFSv4: Introduce new label structure
>    NFSv4: Extend fattr bitmaps to support all 3 words
>    NFS:Add labels to client function prototypes
>    NFS: Add label lifecycle management
>    NFS: Client implementation of Labeled-NFS
>    NFS: Extend NFS xattr handlers to accept the security namespace
>    NFSD: Server implementation of MAC Labeling
>
> Steve Dickson (5):
>    NFSv4.2: Added v4.2 error codes
>    NFSv4.2: Added NFS v4.2 support to the NFS client
>    NFSDv4.2: Added NFS v4.2 support to the NFS server
>    Kconfig: Add Kconfig entry for Labeled NFS V4 client
>    Kconfig: Add Kconfig entry for Labeled NFS V4 server
>
>   fs/nfs/Kconfig                      |  28 ++
>   fs/nfs/callback.c                   |   1 +
>   fs/nfs/client.c                     |   2 +-
>   fs/nfs/dir.c                        |  46 ++-
>   fs/nfs/getroot.c                    |   2 +-
>   fs/nfs/inode.c                      | 133 ++++++--
>   fs/nfs/namespace.c                  |   2 +-
>   fs/nfs/nfs3acl.c                    |   4 +-
>   fs/nfs/nfs3proc.c                   |  41 +--
>   fs/nfs/nfs4_fs.h                    |   8 +-
>   fs/nfs/nfs4client.c                 |   5 +
>   fs/nfs/nfs4namespace.c              |   2 +-
>   fs/nfs/nfs4proc.c                   | 596 ++++++++++++++++++++++++++++++++----
>   fs/nfs/nfs4xdr.c                    | 188 +++++++++---
>   fs/nfs/pnfs.c                       |   2 +-
>   fs/nfs/proc.c                       |  15 +-
>   fs/nfs/super.c                      |  24 +-
>   fs/nfsd/Kconfig                     |  16 +
>   fs/nfsd/nfs4proc.c                  |  41 +++
>   fs/nfsd/nfs4xdr.c                   | 124 +++++++-
>   fs/nfsd/nfsd.h                      |  22 +-
>   fs/nfsd/vfs.c                       |  28 ++
>   fs/nfsd/vfs.h                       |   2 +
>   fs/nfsd/xdr4.h                      |   3 +
>   include/linux/nfs4.h                |  20 ++
>   include/linux/nfs_fs.h              |  40 ++-
>   include/linux/nfs_fs_sb.h           |  10 +-
>   include/linux/nfs_xdr.h             |  30 +-
>   include/linux/security.h            |  57 +++-
>   include/uapi/linux/nfs4.h           |   2 +-
>   security/capability.c               |  19 +-
>   security/security.c                 |  24 +-
>   security/selinux/hooks.c            |  92 +++++-
>   security/selinux/include/security.h |   2 +
>   security/selinux/ss/policydb.c      |   5 +-
>   security/smack/smack_lsm.c          |  11 +
>   36 files changed, 1427 insertions(+), 220 deletions(-)
>

