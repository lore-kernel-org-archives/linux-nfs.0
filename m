Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899Ab3AWTty convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 14:49:54 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: David Quigley <selinux@davequigley.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 14/14] lnfs: Do not sleep holding the inode spin lock.
Date: Wed, 23 Jan 2013 19:49:51 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA918333669@sacexcmbx05-prd.hq.netapp.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
	 <1358862042-27520-15-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-15-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
> The nfs_setsecurity code can sleep while allocating memory
> so the inode spin lock can not be held while during this call.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfs/inode.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 56cd542..e5b030a 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1295,6 +1295,10 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_
>  	status = nfs_refresh_inode_locked(inode, fattr, label);
>  	spin_unlock(&inode->i_lock);
>  
> +	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {

Again, why do we need the capability check when we also check that label
is non-NULL?

> +		if (label && !status)
> +			nfs_setsecurity(inode, fattr, label);
> +	}
>  	return status;
>  }
>  EXPORT_SYMBOL_GPL(nfs_refresh_inode);
> @@ -1334,6 +1338,11 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr, struc
>  	spin_lock(&inode->i_lock);
>  	status = nfs_post_op_update_inode_locked(inode, fattr, label);
>  	spin_unlock(&inode->i_lock);
> +
> +	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {
> +		if (label && !status)
> +			nfs_setsecurity(inode, fattr, label);
> +	}
>  	return status;
>  }
>  EXPORT_SYMBOL_GPL(nfs_post_op_update_inode);
> @@ -1553,9 +1562,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct
>  				| NFS_INO_INVALID_ACL
>  				| NFS_INO_REVAL_FORCED);
>  
> -	if (label && (server->caps & NFS_CAP_SECURITY_LABEL))
> -		nfs_setsecurity(inode, fattr, label);
> -
>  	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
>  		if (inode->i_nlink != fattr->nlink) {
>  			invalid |= NFS_INO_INVALID_ATTR;

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
