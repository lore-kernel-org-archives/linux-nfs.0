Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37946 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932795Ab3DJPJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 11:09:45 -0400
Date: Wed, 10 Apr 2013 11:09:40 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/19] lnfs: 3.9-rc5 release
Message-ID: <20130410150940.GB24404@pad.fieldses.org>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 02, 2013 at 05:45:41PM -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> Here is the next release of the Label NFS patches 
> forward ported to linux-3.9-rc3.
> 
> I decided to include the the v4.2 enabling patches since 
> I'm doing all my testing with both sets so at this point 
> I don't think it makes sense to separate them. Plus I'm
> hoping they will take care of the SETATTR problem Bruce was 
> seeing since label attributes were leaking into the bitmask
> when they were not suppose to. 

Still getting a failure.  All you need to do is something like:

	git clone git://linux-nfs.org/~bfields/pynfs.git
	cd pynfs
	./setup.py build
	./setup.py build_ext --inplace
	./nfs4.0/testserver.py pip1:/path/to/export/tmpdir ---maketree --rundeps SATT13

--b.

> 
> I also believe I've address all the review comments of the previous
> release. Thank you very much for those cycles, it definitely 
> appreciated!
> 
> The patches are on a public git tree at
>     git://fedorapeople.org/~steved/linux-steved lnfs-v3.9-rc5
> 
> Fedora rpms on request. I didn't think anybody was using them so I 
> stopped building them. If that is not the case, please let me know.
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
> Steve Dickson (7):
>   Kconfig: Add Kconfig entry for Labeled NFS V4 client
>   Kconfig: Add Kconfig entry for Labeled NFS V4 server
>   NFSv4.2: Added NFS v4.2 support to the NFS client
>   NFSv4.2: Only allocate labels on v4.2 mounts
>   NFSv4.2: Only set the label attribute on v4.2 mounts
>   NFSv4.2: Added v4.2 error codes
>   NFSDv4.2: Added NFS v4.2 support to the NFS server
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
>  fs/nfs/nfs4proc.c                   | 614 ++++++++++++++++++++++++++++++++----
>  fs/nfs/nfs4xdr.c                    | 188 ++++++++---
>  fs/nfs/pnfs.c                       |   2 +-
>  fs/nfs/proc.c                       |  15 +-
>  fs/nfs/super.c                      |  24 +-
>  fs/nfsd/Kconfig                     |  16 +
>  fs/nfsd/nfs4proc.c                  |  41 +++
>  fs/nfsd/nfs4xdr.c                   | 117 ++++++-
>  fs/nfsd/nfsd.h                      |  14 +-
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
>  37 files changed, 1432 insertions(+), 219 deletions(-)
> 
> -- 
> 1.8.1.4
> 
