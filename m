Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56572 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185Ab3KROKj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Nov 2013 09:10:39 -0500
Date: Mon, 18 Nov 2013 09:10:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: split up nfsd_setattr
Message-ID: <20131118141031.GA3203@fieldses.org>
References: <20131118130730.GA17184@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131118130730.GA17184@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 18, 2013 at 05:07:30AM -0800, Christoph Hellwig wrote:
> Split out two helpers to make the code more readable and easier to verify
> for correctness.

Thanks, both queued up for 2.14.

Might also be worth splitting off that time_set/inode_change_ok logic
into a separate function as its a lot of lines (comments and code)
devoted to a case that we don't care about in the normal (non-v2) case.

--b.

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> ---
>  fs/nfsd/vfs.c |  144 +++++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 84 insertions(+), 60 deletions(-)
> 
> Index: linux/fs/nfsd/vfs.c
> ===================================================================
> --- linux.orig/fs/nfsd/vfs.c	2013-11-17 19:32:05.807321620 +0100
> +++ linux/fs/nfsd/vfs.c	2013-11-18 11:45:09.971804080 +0100
> @@ -298,41 +298,12 @@ commit_metadata(struct svc_fh *fhp)
>  }
>  
>  /*
> - * Set various file attributes.
> - * N.B. After this call fhp needs an fh_put
> + * Go over the attributes and take care of the small differences between
> + * NFS semantics and what Linux expects.
>   */
> -__be32
> -nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> -	     int check_guard, time_t guardtime)
> +static void
> +nfsd_sanitize_attrs(struct inode *inode, struct iattr *iap)
>  {
> -	struct dentry	*dentry;
> -	struct inode	*inode;
> -	int		accmode = NFSD_MAY_SATTR;
> -	umode_t		ftype = 0;
> -	__be32		err;
> -	int		host_err;
> -	int		size_change = 0;
> -
> -	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
> -		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
> -	if (iap->ia_valid & ATTR_SIZE)
> -		ftype = S_IFREG;
> -
> -	/* Get inode */
> -	err = fh_verify(rqstp, fhp, ftype, accmode);
> -	if (err)
> -		goto out;
> -
> -	dentry = fhp->fh_dentry;
> -	inode = dentry->d_inode;
> -
> -	/* Ignore any mode updates on symlinks */
> -	if (S_ISLNK(inode->i_mode))
> -		iap->ia_valid &= ~ATTR_MODE;
> -
> -	if (!iap->ia_valid)
> -		goto out;
> -
>  	/*
>  	 * NFSv2 does not differentiate between "set-[ac]time-to-now"
>  	 * which only requires access, and "set-[ac]time-to-X" which
> @@ -342,8 +313,7 @@ nfsd_setattr(struct svc_rqst *rqstp, str
>  	 * convert to "set to now" instead of "set to explicit time"
>  	 *
>  	 * We only call inode_change_ok as the last test as technically
> -	 * it is not an interface that we should be using.  It is only
> -	 * valid if the filesystem does not define it's own i_op->setattr.
> +	 * it is not an interface that we should be using.
>  	 */
>  #define BOTH_TIME_SET (ATTR_ATIME_SET | ATTR_MTIME_SET)
>  #define	MAX_TOUCH_TIME_ERROR (30*60)
> @@ -369,30 +339,6 @@ nfsd_setattr(struct svc_rqst *rqstp, str
>  			iap->ia_valid &= ~BOTH_TIME_SET;
>  		}
>  	}
> -	    
> -	/*
> -	 * The size case is special.
> -	 * It changes the file as well as the attributes.
> -	 */
> -	if (iap->ia_valid & ATTR_SIZE) {
> -		if (iap->ia_size < inode->i_size) {
> -			err = nfsd_permission(rqstp, fhp->fh_export, dentry,
> -					NFSD_MAY_TRUNC|NFSD_MAY_OWNER_OVERRIDE);
> -			if (err)
> -				goto out;
> -		}
> -
> -		host_err = get_write_access(inode);
> -		if (host_err)
> -			goto out_nfserr;
> -
> -		size_change = 1;
> -		host_err = locks_verify_truncate(inode, NULL, iap->ia_size);
> -		if (host_err) {
> -			put_write_access(inode);
> -			goto out_nfserr;
> -		}
> -	}
>  
>  	/* sanitize the mode change */
>  	if (iap->ia_valid & ATTR_MODE) {
> @@ -415,8 +361,86 @@ nfsd_setattr(struct svc_rqst *rqstp, str
>  			iap->ia_valid |= (ATTR_KILL_SUID | ATTR_KILL_SGID);
>  		}
>  	}
> +}
> +
> +static __be32
> +nfsd_get_write_access(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +		struct iattr *iap)
> +{
> +	struct inode *inode = fhp->fh_dentry->d_inode;
> +	int host_err;
> +
> +	if (iap->ia_size < inode->i_size) {
> +		__be32 err;
> +
> +		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
> +				NFSD_MAY_TRUNC | NFSD_MAY_OWNER_OVERRIDE);
> +		if (err)
> +			return err;
> +	}
> +
> +	host_err = get_write_access(inode);
> +	if (host_err)
> +		goto out_nfserrno;
> +
> +	host_err = locks_verify_truncate(inode, NULL, iap->ia_size);
> +	if (host_err)
> +		goto out_put_write_access;
> +	return 0;
> +
> +out_put_write_access:
> +	put_write_access(inode);
> +out_nfserrno:
> +	return nfserrno(host_err);
> +}
> +
> +/*
> + * Set various file attributes.  After this call fhp needs an fh_put.
> + */
> +__be32
> +nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> +	     int check_guard, time_t guardtime)
> +{
> +	struct dentry	*dentry;
> +	struct inode	*inode;
> +	int		accmode = NFSD_MAY_SATTR;
> +	umode_t		ftype = 0;
> +	__be32		err;
> +	int		host_err;
> +	int		size_change = 0;
> +
> +	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
> +		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
> +	if (iap->ia_valid & ATTR_SIZE)
> +		ftype = S_IFREG;
> +
> +	/* Get inode */
> +	err = fh_verify(rqstp, fhp, ftype, accmode);
> +	if (err)
> +		goto out;
> +
> +	dentry = fhp->fh_dentry;
> +	inode = dentry->d_inode;
> +
> +	/* Ignore any mode updates on symlinks */
> +	if (S_ISLNK(inode->i_mode))
> +		iap->ia_valid &= ~ATTR_MODE;
> +
> +	if (!iap->ia_valid)
> +		goto out;
> +
> +	nfsd_sanitize_attrs(inode, iap);
>  
> -	/* Change the attributes. */
> +	/*
> +	 * The size case is special, it changes the file in addition to the
> +	 * attributes.
> +	 */
> +	if (iap->ia_valid & ATTR_SIZE) {
> +		err = nfsd_get_write_access(rqstp, fhp, iap);
> +		if (err)
> +			goto out;
> +		size_change = 1;
> +	}
>  
>  	iap->ia_valid |= ATTR_CTIME;
>  
