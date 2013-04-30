Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39100 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753731Ab3D3P5o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 11:57:44 -0400
Date: Tue, 30 Apr 2013 11:57:40 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/17] lnfs: 3.9-rc8 release (take 2)
Message-ID: <20130430155740.GX17268@fieldses.org>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 29, 2013 at 08:57:02AM -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> Here is an updated 3.9-rc8 release of
> the label NFS patches. 

The nfsd patches look mergeable to me (with a few one-line fixes).

I'm missing ACKs from Trond and security folks.

The merge window is already open, which is late to be queueing up a
significant new feature.

It might be reasonable if we could get the needed ACKs now, but more
likely it looks like 3.11 to me.

(Argh.)

--b.

> The following changes were made from the previous 
> release.
> 
> * Chunks code were moved out of the v4.2 patches
>   and into the server patch.
> 
> * Fixed the server xdr encoding code to reserve
>   and set the size of the third bitmask on
>   setattrs.
> 
> * Correctly initialize the label pointer when
>   decoding fattrs on the server.
> 
> * Found a problem in the client open code where 
>   stack memory was being used when it should not 
>   have been. 
> 
> David Quigley (12):
>   Security: Add hook to calculate context based on a negative dentry.
>   Security: Add Hook to test if the particular xattr is part of a MAC
>     model.
>   LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount
>     data.
>   SELinux: Add new labeling type native labels
>   NFSv4: Add label recommended attribute and NFSv4 flags
>   NFSv4: Introduce new label structure
>   NFSv4: Extend fattr bitmaps to support all 3 words
>   NFS:Add labels to client function prototypes
>   NFS: Add label lifecycle management
>   NFS: Client implementation of Labeled-NFS
>   NFS: Extend NFS xattr handlers to accept the security namespace
>   NFSD: Server implementation of MAC Labeling
> 
> Steve Dickson (5):
>   NFSv4.2: Added v4.2 error codes
>   NFSv4.2: Added NFS v4.2 support to the NFS client
>   NFSDv4.2: Added NFS v4.2 support to the NFS server
>   Kconfig: Add Kconfig entry for Labeled NFS V4 client
>   Kconfig: Add Kconfig entry for Labeled NFS V4 server
> 
>  fs/nfs/Kconfig                      |  28 ++
>  fs/nfs/callback.c                   |   1 +
>  fs/nfs/client.c                     |   2 +-
>  fs/nfs/dir.c                        |  46 ++-
>  fs/nfs/getroot.c                    |   2 +-
>  fs/nfs/inode.c                      | 133 ++++++--
>  fs/nfs/namespace.c                  |   2 +-
>  fs/nfs/nfs3acl.c                    |   4 +-
>  fs/nfs/nfs3proc.c                   |  41 +--
>  fs/nfs/nfs4_fs.h                    |   8 +-
>  fs/nfs/nfs4client.c                 |   5 +
>  fs/nfs/nfs4namespace.c              |   2 +-
>  fs/nfs/nfs4proc.c                   | 596 ++++++++++++++++++++++++++++++++----
>  fs/nfs/nfs4xdr.c                    | 188 +++++++++---
>  fs/nfs/pnfs.c                       |   2 +-
>  fs/nfs/proc.c                       |  15 +-
>  fs/nfs/super.c                      |  24 +-
>  fs/nfsd/Kconfig                     |  16 +
>  fs/nfsd/nfs4proc.c                  |  41 +++
>  fs/nfsd/nfs4xdr.c                   | 128 +++++++-
>  fs/nfsd/nfsd.h                      |  23 +-
>  fs/nfsd/nfsproc.c                   |   1 +
>  fs/nfsd/vfs.c                       |  28 ++
>  fs/nfsd/vfs.h                       |   2 +
>  fs/nfsd/xdr4.h                      |   3 +
>  include/linux/nfs4.h                |  20 ++
>  include/linux/nfs_fs.h              |  40 ++-
>  include/linux/nfs_fs_sb.h           |  10 +-
>  include/linux/nfs_xdr.h             |  30 +-
>  include/linux/security.h            |  57 +++-
>  include/uapi/linux/nfs4.h           |   2 +-
>  security/capability.c               |  19 +-
>  security/security.c                 |  24 +-
>  security/selinux/hooks.c            |  92 +++++-
>  security/selinux/include/security.h |   2 +
>  security/selinux/ss/policydb.c      |   5 +-
>  security/smack/smack_lsm.c          |  11 +
>  37 files changed, 1433 insertions(+), 220 deletions(-)
> 
> -- 
> 1.8.1.4
> 
