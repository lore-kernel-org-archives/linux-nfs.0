Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25354 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab0DSVoJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 17:44:09 -0400
Message-ID: <4BCCCE84.3050109@oracle.com>
Date: Mon, 19 Apr 2010 17:43:32 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/24] Reduce the stack foot print of the NFS client
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/16/2010 04:30 PM, Trond Myklebust wrote:
> The following patch series aims to significantly reduce the stack foot
> print of the NFS client by dynamically allocating the struct nfs_fattr
> and struct nfs_fh.

Random comments:

1.  There's an open-coded kzalloc of an nfs_fh in nfs_get_sb.  This can 
be replaced with nfs_alloc_fh().

2.  root_nfs_get_handle allocates an nfs_fh on the stack.  This can be 
replaced with nfs_alloc_fh().

3.  There is an unneeded nfs_fattr_init() call in nfs_probe_fsinfo().  I 
didn't look for others that are similarly made obsolete.

4.  Where ever you have "if (fattr == NULL) goto out;" (and similarly 
for filehandles) you could add "unlikely()" to improve branch prediction 
slightly.

5.  The documenting comment before nfs_do_refmount() is out of date.

> Cheers
>    Trond
>
> Trond Myklebust (24):
>    NFS: Add helper functions for allocating filehandles and fattr
>      structs
>    NFSv4: Eliminate nfs4_path_walk()
>    NFS: Reduce the stack footprint of nfs_follow_mountpoint()
>    NFS: Reduce the stack footprint of nfs_create_server
>    NFSv4: Reduce the stack footprint of try_location()
>    NFS: Reduce the stack footprint of nfs_lookup
>    NFS: Reduce the stack footprint of nfs_follow_remote_path()
>    NFSv4: Reduce stack footprint of nfs4_get_root()
>    NFSv4: Reduce the stack footprint of nfs4_remote_referral_get_sb
>    NFSv4: Reduce stack footprint of nfs4_proc_access() and
>      nfs3_proc_access()
>    NFS: Reduce stack footprint of nfs_revalidate_inode()
>    NFS: Reduce stack footprint of nfs3_proc_rename() and
>      nfs4_proc_rename()
>    NFS: Reduce stack footprint of nfs_readdir()
>    NFS: Reduce the stack footprint of nfs_link()
>    NFS: Reduce stack footprint of nfs3_proc_readlink()
>    NFS: Reduce stack footprint of nfs_proc_remove()
>    NFS: Reduce the stack footprint of nfs_rmdir
>    NFS: Reduce the stack footprint of nfs_proc_create
>    NFS: Reduce the stack footprint of nfs_proc_symlink()
>    NFS: Reduce stack footprint of nfs4_proc_create()
>    NFS: Reduce stack footprint of nfs_setattr()
>    NFS: Reduce stack footprint of nfs_statfs()
>    NFS: Reduce stack footprint of nfs3_proc_getacl() and
>      nfs3_proc_setacl()
>    NFS: Prevent the mount code from looping forever on broken exports
>
>   fs/nfs/client.c         |   54 ++++++++++---
>   fs/nfs/dir.c            |   62 +++++++++++----
>   fs/nfs/getroot.c        |  191 +++++++++++++++++------------------------------
>   fs/nfs/inode.c          |   46 ++++++++++--
>   fs/nfs/internal.h       |    4 +-
>   fs/nfs/namespace.c      |   20 ++++--
>   fs/nfs/nfs3acl.c        |   23 ++++--
>   fs/nfs/nfs3proc.c       |  128 +++++++++++++++++++------------
>   fs/nfs/nfs3xdr.c        |    2 +-
>   fs/nfs/nfs4namespace.c  |   10 ++-
>   fs/nfs/nfs4proc.c       |   81 ++++++++++++--------
>   fs/nfs/nfs4xdr.c        |    2 +-
>   fs/nfs/proc.c           |  144 ++++++++++++++++++++---------------
>   fs/nfs/super.c          |  121 ++++++++++++++++++++++++++----
>   fs/nfs/unlink.c         |    4 +-
>   include/linux/nfs_fs.h  |   14 ++++
>   include/linux/nfs_xdr.h |    2 +-
>   17 files changed, 566 insertions(+), 342 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
chuck[dot]lever[at]oracle[dot]com
