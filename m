Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:63344 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752524Ab3E3Txh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 15:53:37 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/13] lnfs: 3.10-rc2 release
Date: Thu, 30 May 2013 19:53:30 +0000
Message-ID: <1369943609.3111.4.camel@leira.trondhjem.org>
References: <1369241446-7680-1-git-send-email-SteveD@redhat.com>
In-Reply-To: <1369241446-7680-1-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-05-22 at 12:50 -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> Here is the next release the label NFS patches ported to 
> linux-3-10.rc2 release.
> 
> The changes made in this release:
> 
> * Add new Ack-by's 
> 
> * Fixed typo in v4.2 section of Kconfig
> 
> * Removed all the label points that are no longer needed in linux/nfs_xdr.h
> 
> * Move NFS4_MAXLABELLEN to linux/nfs4.h
> 
> * Move the label processing out of nfs_post_op_update_inode() and
>   nfs_refresh_inode(), putting it around them. 
> 
> * Removed the state processing from set security label code.
> 
> * Added a new decode_getfattr_label() routine which is by 
>   ops that process labels. 
> 
> * Removed the select from the Kconfig file
> 
> 
> David Quigley (9):
>   Security: Add Hook to test if the particular xattr is part of a MAC
>     model.
>   LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount
>     data.
>   SELinux: Add new labeling type native labels
>   NFSv4: Add label recommended attribute and NFSv4 flags
>   NFSv4: Extend fattr bitmaps to support all 3 words
>   NFS:Add labels to client function prototypes
>   NFS: Add label lifecycle management
>   NFS: Client implementation of Labeled-NFS
>   NFS: Extend NFS xattr handlers to accept the security namespace
> 
> Steve Dickson (4):
>   Security: Add hook to calculate context based on a negative dentry.
>   NFSv4.2: Added NFS v4.2 support to the NFS client
>   NFSv4: Introduce new label structure
>   Kconfig: Add Kconfig entry for Labeled NFS V4 client
> 
>  fs/nfs/Kconfig                      |  28 ++
>  fs/nfs/callback.c                   |   1 +
>  fs/nfs/callback_xdr.c               |   6 +-
>  fs/nfs/client.c                     |   2 +-
>  fs/nfs/dir.c                        |  49 +++-
>  fs/nfs/getroot.c                    |   2 +-
>  fs/nfs/inode.c                      | 109 +++++++-
>  fs/nfs/namespace.c                  |   2 +-
>  fs/nfs/nfs3proc.c                   |   7 +-
>  fs/nfs/nfs4_fs.h                    |   6 +-
>  fs/nfs/nfs4client.c                 |   5 +
>  fs/nfs/nfs4proc.c                   | 518 ++++++++++++++++++++++++++++++++----
>  fs/nfs/nfs4xdr.c                    | 174 +++++++++---
>  fs/nfs/proc.c                       |  13 +-
>  fs/nfs/super.c                      |  24 +-
>  include/linux/nfs4.h                |  13 +
>  include/linux/nfs_fs.h              |  26 +-
>  include/linux/nfs_fs_sb.h           |   8 +-
>  include/linux/nfs_xdr.h             |  20 +-
>  include/linux/security.h            |  57 +++-
>  security/capability.c               |  19 +-
>  security/security.c                 |  24 +-
>  security/selinux/hooks.c            |  92 ++++++-
>  security/selinux/include/security.h |   2 +
>  security/selinux/ss/policydb.c      |   5 +-
>  security/smack/smack_lsm.c          |  11 +
>  26 files changed, 1066 insertions(+), 157 deletions(-)
> 
Hi Steve,

Bryan found a problem with the NFSv4.2 enabling patch above: the
callback channel needs to recognise minor version 2 CB_COMPOUND. There
are several places in the current callback code where people have hacked
the hard coded value '1' for the minor version field... :-(

Bryan is working on a fix for us that I will just apply on top of the
existing labeled NFS branch.

Cheers,
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
