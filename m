Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60271 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432AbaE1Tlb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2014 15:41:31 -0400
Date: Wed, 28 May 2014 15:41:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: remove unused function nfsd_read_file
Message-ID: <20140528194130.GE22210@fieldses.org>
References: <1401266792-19086-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401266792-19086-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 28, 2014 at 10:46:32AM +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Oops, thanks.--b.

> ---
>  fs/nfsd/vfs.c |   20 --------------------
>  fs/nfsd/vfs.h |    2 --
>  2 files changed, 22 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index b7d35a4..140c496 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1026,26 +1026,6 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	return err;
>  }
>  
> -/* As above, but use the provided file descriptor. */
> -__be32
> -nfsd_read_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
> -		loff_t offset, struct kvec *vec, int vlen,
> -		unsigned long *count)
> -{
> -	__be32		err;
> -
> -	if (file) {
> -		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
> -				NFSD_MAY_READ|NFSD_MAY_OWNER_OVERRIDE);
> -		if (err)
> -			goto out;
> -		err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
> -	} else /* Note file may still be NULL in NFSv4 special stateid case: */
> -		err = nfsd_read(rqstp, fhp, offset, vec, vlen, count);
> -out:
> -	return err;
> -}
> -
>  /*
>   * Write data to a file.
>   * The stable flag requests synchronous writes.
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index 7441e96..91b6ae3 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -80,8 +80,6 @@ int		nfsd_readv(struct file *, loff_t, struct kvec *, int,
>  				unsigned long *);
>  __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
>  				loff_t, struct kvec *, int, unsigned long *);
> -__be32 		nfsd_read_file(struct svc_rqst *, struct svc_fh *, struct file *,
> -				loff_t, struct kvec *, int, unsigned long *);
>  __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
>  				loff_t, struct kvec *,int, unsigned long *, int *);
>  __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
> -- 
> 1.7.10.4
> 
