Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:36548 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdAWMV7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 07:21:59 -0500
Received: by mail-yw0-f196.google.com with SMTP id q71so11861445ywg.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2017 04:21:59 -0800 (PST)
Message-ID: <1485174116.2786.7.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: special case truncates some more
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@lst.de>, bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date: Mon, 23 Jan 2017 07:21:56 -0500
In-Reply-To: <1485104060-15209-2-git-send-email-hch@lst.de>
References: <1485104060-15209-1-git-send-email-hch@lst.de>
         <1485104060-15209-2-git-send-email-hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2017-01-22 at 17:54 +0100, Christoph Hellwig wrote:
> Both the NFS protocols and the Linux VFS use a setattr operation with a
> bitmap of attributs to set to set various file attributes including the
> file size and the uid/gid.
> 
> The Linux syscalls never mixe size updates with unrelated updates like
> the uid/gid, and some file systems like XFS and GFS2 rely on the fact
> that truncates might not update random other attributes, and many
> other file systems handle the case but do not update the different
> attributes in the same transaction.  NFSD on the other hand passes
> the attributes it gets on the wire more or less directly through to
> the VFS, leading to updates the file systems don't expect.  XFS at
> least has an assert on the allowed attributes, which cought an NFS
> client sets the size and group ІD at the same time.
> 
> To handles this issue properly this switches nfsd to call vfs_truncate
> for size changes, and then handling all other attributes through
> notify_change.  As a side effect this also means less boilerplace
> code around the size change as we can now reuse the VFS code.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/vfs.c | 77 +++++++++++++++++++----------------------------------------
>  1 file changed, 24 insertions(+), 53 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 26c6fdb..fafff37 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -332,37 +332,6 @@ nfsd_sanitize_attrs(struct inode *inode, struct iattr *iap)
>  	}
>  }
>  
> -static __be32
> -nfsd_get_write_access(struct svc_rqst *rqstp, struct svc_fh *fhp,
> -		struct iattr *iap)
> -{
> -	struct inode *inode = d_inode(fhp->fh_dentry);
> -	int host_err;
> -
> -	if (iap->ia_size < inode->i_size) {
> -		__be32 err;
> -
> -		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
> -				NFSD_MAY_TRUNC | NFSD_MAY_OWNER_OVERRIDE);
> -		if (err)
> -			return err;
> -	}
> -
> -	host_err = get_write_access(inode);
> -	if (host_err)
> -		goto out_nfserrno;
> -
> -	host_err = locks_verify_truncate(inode, NULL, iap->ia_size);
> -	if (host_err)
> -		goto out_put_write_access;
> -	return 0;
> -
> -out_put_write_access:
> -	put_write_access(inode);
> -out_nfserrno:
> -	return nfserrno(host_err);
> -}
> -
>  /*
>   * Set various file attributes.  After this call fhp needs an fh_put.
>   */
> @@ -377,7 +346,6 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  	__be32		err;
>  	int		host_err;
>  	bool		get_write_count;
> -	int		size_change = 0;
>  
>  	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
>  		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
> @@ -390,11 +358,11 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  	/* Get inode */
>  	err = fh_verify(rqstp, fhp, ftype, accmode);
>  	if (err)
> -		goto out;
> +		return err;
>  	if (get_write_count) {
>  		host_err = fh_want_write(fhp);
>  		if (host_err)
> -			return nfserrno(host_err);
> +			goto out_host_err;
>  	}
>  
>  	dentry = fhp->fh_dentry;
> @@ -405,19 +373,25 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  		iap->ia_valid &= ~ATTR_MODE;
>  
>  	if (!iap->ia_valid)
> -		goto out;
> +		return 0;
>  
>  	nfsd_sanitize_attrs(inode, iap);
>  
> +	if (check_guard && guardtime != inode->i_ctime.tv_sec)
> +		return nfserr_notsync;
> +
>  	/*
>  	 * The size case is special, it changes the file in addition to the
> -	 * attributes.
> +	 * attributes, and file systems don't expect it to be mixed with
> +	 * "random" attribute changes.  We thus split out the size change
> +	 * into a separate calo for vfs_truncate, and do the rest as a
> +	 * a separate setattr call.
>  	 */
>  	if (iap->ia_valid & ATTR_SIZE) {
> -		err = nfsd_get_write_access(rqstp, fhp, iap);
> -		if (err)
> -			goto out;
> -		size_change = 1;
> +		struct path path = {
> +			.mnt	= fhp->fh_export->ex_path.mnt,
> +			.dentry	= dentry,
> +		};
>  
>  		/*
>  		 * RFC5661, Section 18.30.4:
> @@ -428,27 +402,24 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  		 */
>  		if (iap->ia_size != i_size_read(inode))
>  			iap->ia_valid |= ATTR_MTIME;
> -	}
>  
> -	iap->ia_valid |= ATTR_CTIME;
> +		host_err = vfs_truncate(&path, iap->ia_size);
> +		if (host_err)
> +			goto out_host_err;
>  
> -	if (check_guard && guardtime != inode->i_ctime.tv_sec) {
> -		err = nfserr_notsync;
> -		goto out_put_write_access;
> +		iap->ia_valid &= ~ATTR_SIZE;
>  	}
>  
> +	iap->ia_valid |= ATTR_CTIME;
> +

So if you only have ATTR_SIZE then you're going to end up having to do
another notify_change to update the ctime? Can we get away with just
calling vfs_truncate when only ATTR_SIZE is set and skipping the
notify_change to update the ctime?

>  	fh_lock(fhp);
>  	host_err = notify_change(dentry, iap, NULL);
>  	fh_unlock(fhp);
> -	err = nfserrno(host_err);
>  
> -out_put_write_access:
> -	if (size_change)
> -		put_write_access(inode);
> -	if (!err)
> -		err = nfserrno(commit_metadata(fhp));
> -out:
> -	return err;
> +	if (!host_err)
> +		host_err = commit_metadata(fhp);
> +out_host_err:
> +	return nfserrno(host_err);
>  }
>  
>  #if defined(CONFIG_NFSD_V4)

Overall though, this is a reasonable change I think. Size changes are
more of a special case. I also like the idea of breaking out truncates
to a separate operation, but that's a much bigger project.

-- 
Jeff Layton <jlayton@poochiereds.net>
