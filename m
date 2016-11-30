Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754672AbcK3TJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Nov 2016 14:09:17 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFS: Be more targeted about readdirplus use when
 doing lookup/revalidation
Date: Wed, 30 Nov 2016 14:09:06 -0500
Message-ID: <28E39796-E929-4D65-A6F6-D0AF803AB390@redhat.com>
In-Reply-To: <1479574497-38268-3-git-send-email-trond.myklebust@primarydata.com>
References: <1479574497-38268-1-git-send-email-trond.myklebust@primarydata.com>
 <1479574497-38268-2-git-send-email-trond.myklebust@primarydata.com>
 <1479574497-38268-3-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

.. this one breaks things again:

On 19 Nov 2016, at 11:54, Trond Myklebust wrote:

> There is little point in setting NFS_INO_ADVISE_RDPLUS in nfs_lookup 
> and
> nfs_lookup_revalidate() unless a process is actually doing readdir on 
> the
> parent directory.
> Furthermore, there is little point in using readdirplus if we're 
> trying
> to revalidate a negative dentry.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/dir.c | 28 +++++++++++++++++-----------
>  1 file changed, 17 insertions(+), 11 deletions(-)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 53e02b8bd9bd..5befd382be7d 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -455,14 +455,23 @@ bool nfs_use_readdirplus(struct inode *dir, 
> struct dir_context *ctx)
>  }
>
>  /*
> - * This function is called by the lookup code to request the use of
> - * readdirplus to accelerate any future lookups in the same
> + * This function is called by the lookup and getattr code to request 
> the
> + * use of readdirplus to accelerate any future lookups in the same
>   * directory.
> + * Do this by checking if there is an active file descriptor
> + * and calling nfs_advise_use_readdirplus, then forcing a
> + * cache flush.
>   */
>  static
>  void nfs_advise_use_readdirplus(struct inode *dir)
>  {
> -	set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(dir)->flags);
> +	struct nfs_inode *nfsi = NFS_I(dir);
> +
> +	if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS) &&
> +	    !list_empty(&nfsi->open_files)) {
> +		set_bit(NFS_INO_ADVISE_RDPLUS, &nfsi->flags);
> +		invalidate_mapping_pages(dir->i_mapping, 0, -1);
> +	}
>  }

So every time advise_use_readdirplus it drops the mapping.. but what 
about
subsequent calls into nfs_readdir() to get the next batch of entries?  
For
the ls -l case, we want to keep setting NFS_INO_ADVISE_RDPLUS, but we
shouldn't start over filling the mapping from the beginning again.

>
>  /*
> @@ -475,10 +484,7 @@ void nfs_advise_use_readdirplus(struct inode 
> *dir)
>   */
>  void nfs_force_use_readdirplus(struct inode *dir)
>  {
> -	if (!list_empty(&NFS_I(dir)->open_files)) {
> -		nfs_advise_use_readdirplus(dir);
> -		invalidate_mapping_pages(dir->i_mapping, 0, -1);
> -	}
> +	nfs_advise_use_readdirplus(dir);
>  }
>
>  static
> @@ -1150,7 +1156,7 @@ static int nfs_lookup_revalidate(struct dentry 
> *dentry, unsigned int flags)
>  				return -ECHILD;
>  			goto out_bad;
>  		}
> -		goto out_valid_noent;
> +		goto out_valid;
>  	}
>
>  	if (is_bad_inode(inode)) {
> @@ -1192,6 +1198,9 @@ static int nfs_lookup_revalidate(struct dentry 
> *dentry, unsigned int flags)
>  	if (IS_ERR(label))
>  		goto out_error;
>
> +	/* We need to force a revalidation: set a readdirplus hint */
> +	nfs_advise_use_readdirplus(dir);
> +
>  	trace_nfs_lookup_revalidate_enter(dir, dentry, flags);
>  	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, 
> label);
>  	trace_nfs_lookup_revalidate_exit(dir, dentry, flags, error);
> @@ -1211,9 +1220,6 @@ static int nfs_lookup_revalidate(struct dentry 
> *dentry, unsigned int flags)
>  out_set_verifier:
>  	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
>   out_valid:
> -	/* Success: notify readdir to use READDIRPLUS */
> -	nfs_advise_use_readdirplus(dir);
> - out_valid_noent:
>  	if (flags & LOOKUP_RCU) {
>  		if (parent != ACCESS_ONCE(dentry->d_parent))
>  			return -ECHILD;


Now when listing with `ls -l`:  the second call into nfs_readdir() to 
get
the next batch of entries will not have NFS_INO_ADVISE_RDPLUS.

I think this removes nfs_advise_use_readdirplus(dir) from the common 
"goto
out_valid" path through nfs_lookup_revalidate() (the block with the 
'iff'
typo).

Ben
