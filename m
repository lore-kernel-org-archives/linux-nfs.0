From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 1/1] pnfsd: fix ex_pnfs check_export bug
Date: Thu, 10 Dec 2009 00:32:24 +0200
Message-ID: <4B202578.80701@panasas.com>
References: <1260392673-4971-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59010 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758041AbZLIWcR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 17:32:17 -0500
In-Reply-To: <1260392673-4971-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged.  Thanks!

Benny

On Dec. 09, 2009, 23:04 +0200, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Export option strings are not guaranteed to be present in every call to
> svc_export_parse. For example, nfs-utils-1.1.2 exportfs validates the export
> with a test call that does not include the 'pnfs' export option even though
> it is set in /etc/exports.
> 
> nfsd4_layout_verify() checks if ex_pnfs is set so the ex_pnfs check in
> check_export is not needed.
> 
> Furthermore,the pnfs_export_operations super block pointer should not be
> changed because a) it is a const and b) the exports options can be changed
> while the file system is mounted.
> 
> Remove the ex_pnfs check from check_export to prevent the pnfs_export_operations
> superblock pointer from being set to NULL.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/export.c |   15 +++------------
>  1 files changed, 3 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index ddd12d8..8243f2d 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -382,8 +382,7 @@ static struct svc_export *svc_export_update(struct svc_export *new,
>  					    struct svc_export *old);
>  static struct svc_export *svc_export_lookup(struct svc_export *);
>  
> -static int check_export(struct inode *inode, int flags, unsigned char *uuid,
> -			bool ex_pnfs)
> +static int check_export(struct inode *inode, int flags, unsigned char *uuid)
>  {
>  
>  	/* We currently export only dirs and regular files.
> @@ -413,14 +412,6 @@ static int check_export(struct inode *inode, int flags, unsigned char *uuid,
>  		return -EINVAL;
>  	}
>  
> -	dprintk("%s: s_pnfs_op %p ex_pnfs %d\n", __func__,
> -		inode->i_sb->s_pnfs_op, ex_pnfs);
> -
> -	if (!ex_pnfs) {
> -		inode->i_sb->s_pnfs_op = NULL;
> -		return 0;
> -	}
> -
>  	if (inode->i_sb->s_pnfs_op &&
>  	    (!inode->i_sb->s_pnfs_op->layout_type ||
>  	     !inode->i_sb->s_pnfs_op->get_device_info ||
> @@ -635,7 +626,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
>  		}
>  
>  		err = check_export(exp.ex_path.dentry->d_inode, exp.ex_flags,
> -				   exp.ex_uuid, exp.ex_pnfs);
> +				   exp.ex_uuid);
>  		if (err)
>  			goto out4;
>  	}
> @@ -1077,7 +1068,7 @@ exp_export(struct nfsctl_export *nxp)
>  		goto finish;
>  	}
>  
> -	err = check_export(path.dentry->d_inode, nxp->ex_flags, NULL, false);
> +	err = check_export(path.dentry->d_inode, nxp->ex_flags, NULL);
>  	if (err) goto finish;
>  
>  	err = -ENOMEM;
