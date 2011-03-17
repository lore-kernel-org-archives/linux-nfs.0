Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4223 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755023Ab1CQSZS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 14:25:18 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p2HIPHZj018889
	for <linux-nfs@vger.kernel.org>; Thu, 17 Mar 2011 11:25:17 -0700 (PDT)
Subject: Re: [PATCH v5 4/5] NFS: use secinfo when crossing mountpoints
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4D812377.8030908@netapp.com>
References: <4D812377.8030908@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Mar 2011 14:25:17 -0400
Message-ID: <1300386317.28305.41.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-16 at 16:54 -0400, Bryan Schumaker wrote:
> A submount may use different security than the parent
> mount does.  We should figure out what sec flavor the
> submount uses at mount time.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/inode.c                        |    8 ++-
>  fs/nfs/internal.h                     |    7 ++
>  fs/nfs/namespace.c                    |  102 ++++++++++++++++++++++++++++++++-
>  fs/nfs/nfs4proc.c                     |   14 +++++
>  fs/nfs/nfs4xdr.c                      |   11 ++--
>  include/linux/nfs_xdr.h               |    1 +
>  net/sunrpc/auth_gss/gss_mech_switch.c |   22 +++++++
>  7 files changed, 154 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 01768e5..058d7d6 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -254,7 +254,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
>  	struct inode *inode = ERR_PTR(-ENOENT);
>  	unsigned long hash;
>  
> -	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0)
> +	nfs_attr_check_mountpoint(sb, fattr);
> +
> +	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0 && (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT) == 0)

This is equivalent to

if (fattr->valid & (NFS_ATTR_FATTR_FILEID|NFS_ATTR_FATTR_MOUNTPOINT) == 0)


>  		goto out_no_inode;
>  	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) == 0)
>  		goto out_no_inode;
> @@ -298,8 +300,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
>  			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
>  				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
>  			/* Deal with crossing mountpoints */
> -			if ((fattr->valid & NFS_ATTR_FATTR_FSID)
> -					&& !nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
> +			if (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT ||
> +					fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {

This is equivalent to

if (fattr->valid & (NFS_ATTR_FATTR_MOUNTPOINT|NFS_ATTR_FATTR_V4_REFERRAL))

>  				if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
>  					inode->i_op = &nfs_referral_inode_operations;
>  				else
<snip>
> @@ -116,6 +202,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
>  	struct nfs_fh *fh = NULL;
>  	struct nfs_fattr *fattr = NULL;
>  	int err;
> +	rpc_authflavor_t flavor = 1;

Please use the flavour name (i.e. RPC_AUTH_UNIX) in situations like
this. It is hard to remember that 1 == auth unix.
 
>  	dprintk("--> nfs_d_automount()\n");
>  


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

