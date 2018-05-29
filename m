Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:39316 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754646AbeE2Sdy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 14:33:54 -0400
Received: by mail-io0-f194.google.com with SMTP id 200-v6so17754806ioz.6
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 11:33:54 -0700 (PDT)
Subject: Re: [PATCH] NFSv4: Fix sillyrename to return the delegation when
 appropriate
To: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
References: <20180529154814.12843-1-trond.myklebust@hammerspace.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <816a261e-c94c-4d69-36b9-3f308e8787a9@gmail.com>
Date: Tue, 29 May 2018 14:33:52 -0400
MIME-Version: 1.0
In-Reply-To: <20180529154814.12843-1-trond.myklebust@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 05/29/2018 11:48 AM, Trond Myklebust wrote:
> If the file being sillyrenamed is being completely deleted, or
> we are using NFSv4.0, then we need to return the delegation before
> sending off the sillydelete.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/dir.c | 23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index b315f53b3aec..ed20ff51f865 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1399,11 +1399,32 @@ EXPORT_SYMBOL_GPL(nfs_lookup);
>  #if IS_ENABLED(CONFIG_NFS_V4)
>  static int nfs4_lookup_revalidate(struct dentry *, unsigned int);
>  
> +/*
> + * Called when the dentry loses inode.
> + * We use it to clean up silly-renamed files.
> + */
> +static void nfs4_dentry_iput(struct dentry *dentry, struct inode *inode)
> +{
> +	if (S_ISDIR(inode->i_mode))
> +		/* drop any readdir cache as it could easily be old */
> +		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
> +
> +	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
> +		if (inode->i_nlink == 1)
> +			nfs4_inode_return_delegation(inode);
> +		else
> +			nfs4_inode_make_writeable(inode);

I think these functions need to be exported in delegation.c to avoid undefined symbol warnings from the compiler.

Thanks,
Anna

> +		nfs_complete_unlink(dentry, inode);
> +		nfs_drop_nlink(inode);
> +	}
> +	iput(inode);
> +}
> +
>  const struct dentry_operations nfs4_dentry_operations = {
>  	.d_revalidate	= nfs4_lookup_revalidate,
>  	.d_weak_revalidate	= nfs_weak_revalidate,
>  	.d_delete	= nfs_dentry_delete,
> -	.d_iput		= nfs_dentry_iput,
> +	.d_iput		= nfs4_dentry_iput,
>  	.d_automount	= nfs_d_automount,
>  	.d_release	= nfs_d_release,
>  };
> 
