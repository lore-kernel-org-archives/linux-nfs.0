Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30444 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbdBUPIE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Feb 2017 10:08:04 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] nfsd: special case truncates some more
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170220062133.26607-2-hch@lst.de>
Date: Tue, 21 Feb 2017 10:07:51 -0500
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, stable@kernel.org
Message-Id: <5B8D7C50-70C3-43F8-B8D6-0B845B84D5F2@oracle.com>
References: <20170220062133.26607-1-hch@lst.de> <20170220062133.26607-2-hch@lst.de>
To: Christoph Hellwig <hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 20, 2017, at 1:21 AM, Christoph Hellwig <hch@lst.de> wrote:
> 
> Both the NFS protocols and the Linux VFS use a setattr operation with a
> bitmap of attributs to set to set various file attributes including the
> file size and the uid/gid.
> 
> The Linux syscalls never mixes size updates with unrelated updates like
> the uid/gid, and some file systems like XFS and GFS2 rely on the fact
> that truncates might not update random other attributes, and many other
> file systems handle the case but do not update the different attributes
> in the same transaction.  NFSD on the other hand passes the attributes
> it gets on the wire more or less directly through to the VFS, leading to
> updates the file systems don't expect.  XFS at least has an assert on
> the allowed attributes, which caught an unusual NFS client setting the
> size and group at the same time.
> 
> To handle this issue properly this splits the notify_change call in
> nfsd_setattr into two separate ones.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Cc: stable@kernel.org

Tested-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> fs/nfsd/vfs.c | 59 +++++++++++++++++++++++++++++++++++++----------------------
> 1 file changed, 37 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 26c6fdb4bf67..3c36ed5a1f07 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -377,7 +377,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> 	__be32		err;
> 	int		host_err;
> 	bool		get_write_count;
> -	int		size_change = 0;
> +	bool		size_change = (iap->ia_valid & ATTR_SIZE);
> 
> 	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
> 		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
> @@ -390,11 +390,11 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> 	/* Get inode */
> 	err = fh_verify(rqstp, fhp, ftype, accmode);
> 	if (err)
> -		goto out;
> +		return err;
> 	if (get_write_count) {
> 		host_err = fh_want_write(fhp);
> 		if (host_err)
> -			return nfserrno(host_err);
> +			goto out;
> 	}
> 
> 	dentry = fhp->fh_dentry;
> @@ -405,20 +405,28 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> 		iap->ia_valid &= ~ATTR_MODE;
> 
> 	if (!iap->ia_valid)
> -		goto out;
> +		return 0;
> 
> 	nfsd_sanitize_attrs(inode, iap);
> 
> +	if (check_guard && guardtime != inode->i_ctime.tv_sec)
> +		return nfserr_notsync;
> +
> 	/*
> 	 * The size case is special, it changes the file in addition to the
> -	 * attributes.
> +	 * attributes, and file systems don't expect it to be mixed with
> +	 * "random" attribute changes.  We thus split out the size change
> +	 * into a separate call to ->setattr, and do the rest as a separate
> +	 * setattr call.
> 	 */
> -	if (iap->ia_valid & ATTR_SIZE) {
> +	if (size_change) {
> 		err = nfsd_get_write_access(rqstp, fhp, iap);
> 		if (err)
> -			goto out;
> -		size_change = 1;
> +			return err;
> +	}
> 
> +	fh_lock(fhp);
> +	if (size_change) {
> 		/*
> 		 * RFC5661, Section 18.30.4:
> 		 *   Changing the size of a file with SETATTR indirectly
> @@ -426,29 +434,36 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> 		 *
> 		 * (and similar for the older RFCs)
> 		 */
> -		if (iap->ia_size != i_size_read(inode))
> -			iap->ia_valid |= ATTR_MTIME;
> -	}
> +		struct iattr size_attr = {
> +			.ia_valid	= ATTR_SIZE | ATTR_CTIME | ATTR_MTIME,
> +			.ia_size	= iap->ia_size,
> +		};
> 
> -	iap->ia_valid |= ATTR_CTIME;
> +		host_err = notify_change(dentry, &size_attr, NULL);
> +		if (host_err)
> +			goto out_unlock;
> +		iap->ia_valid &= ~ATTR_SIZE;
> 
> -	if (check_guard && guardtime != inode->i_ctime.tv_sec) {
> -		err = nfserr_notsync;
> -		goto out_put_write_access;
> +		/*
> +		 * Avoid the additional setattr call below if the only other
> +		 * attribute that the client sends is the mtime, as we update
> +		 * it as part of the size change above.
> +		 */
> +		if ((iap->ia_valid & ~ATTR_MTIME) == 0)
> +			goto out_unlock;
> 	}
> 
> -	fh_lock(fhp);
> +	iap->ia_valid |= ATTR_CTIME;
> 	host_err = notify_change(dentry, iap, NULL);
> -	fh_unlock(fhp);
> -	err = nfserrno(host_err);
> 
> -out_put_write_access:
> +out_unlock:
> +	fh_unlock(fhp);
> 	if (size_change)
> 		put_write_access(inode);
> -	if (!err)
> -		err = nfserrno(commit_metadata(fhp));
> out:
> -	return err;
> +	if (!host_err)
> +		host_err = commit_metadata(fhp);
> +	return nfserrno(host_err);
> }
> 
> #if defined(CONFIG_NFSD_V4)
> -- 
> 2.11.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



