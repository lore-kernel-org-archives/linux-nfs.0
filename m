Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46310 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750947AbdBIQC3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Feb 2017 11:02:29 -0500
Date: Thu, 9 Feb 2017 11:01:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: restore owner override for truncate
Message-ID: <20170209160131.GE17622@fieldses.org>
References: <20170209142238.5322-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170209142238.5322-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 09, 2017 at 03:22:38PM +0100, Christoph Hellwig wrote:
> The switch to vfs_truncate in nfsd_setattr dropped the owner override
> used for NFS permissions.  Add a copy of vfs_truncate with it restored
> to the nfsd code for now as it's very late in the cycle, but there
> should be a way to consolidate it back in the future.

This also needs:


diff --git a/fs/open.c b/fs/open.c
index 9921f70bc5ca..5d8126b230d9 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -64,6 +64,7 @@ int do_truncate(struct dentry *dentry, loff_t length, unsigned int time_attrs,
 	inode_unlock(dentry->d_inode);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(do_truncate);
 
 long vfs_truncate(const struct path *path, loff_t length)
 {

--b.

> 
> Fixes: 41f53350 ("nfsd: special case truncates some more")
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reported-by: Chuck Lever <chucklever@gmail.com>
> ---
>  fs/nfsd/vfs.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 80 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index a974368026a1..fd4a32e0b0b4 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -332,6 +332,85 @@ nfsd_sanitize_attrs(struct inode *inode, struct iattr *iap)
>  	}
>  }
>  
> +/* copy of vfs_truncate with NFS owner override hacked in, sigh.. */
> +static long nfsd_truncate(const struct path *path, loff_t length)
> +{
> +	struct inode *inode;
> +	struct dentry *upperdentry;
> +	long error;
> +
> +	inode = path->dentry->d_inode;
> +
> +	/* For directories it's -EISDIR, for other non-regulars - -EINVAL */
> +	if (S_ISDIR(inode->i_mode))
> +		return -EISDIR;
> +	if (!S_ISREG(inode->i_mode))
> +		return -EINVAL;
> +
> +	error = mnt_want_write(path->mnt);
> +	if (error)
> +		goto out;
> +
> +	/*
> +	 * The file owner always gets access permission for accesses that
> +	 * would normally be checked at open time. This is to make
> +	 * file access work even when the client has done a fchmod(fd, 0).
> +	 *
> +	 * However, `cp foo bar' should fail nevertheless when bar is
> +	 * readonly. A sensible way to do this might be to reject all
> +	 * attempts to truncate a read-only file, because a creat() call
> +	 * always implies file truncation.
> +	 * ... but this isn't really fair.  A process may reasonably call
> +	 * ftruncate on an open file descriptor on a file with perm 000.
> +	 * We must trust the client to do permission checking - using "ACCESS"
> +	 * with NFSv3.
> +	 */
> +	if (!uid_eq(inode->i_uid, current_fsuid())) {
> +		error = inode_permission(inode, MAY_WRITE);
> +		if (error)
> +			goto mnt_drop_write_and_out;
> +	}
> +
> +	error = -EPERM;
> +	if (IS_APPEND(inode))
> +		goto mnt_drop_write_and_out;
> +
> +	/*
> +	 * If this is an overlayfs then do as if opening the file so we get
> +	 * write access on the upper inode, not on the overlay inode.  For
> +	 * non-overlay filesystems d_real() is an identity function.
> +	 */
> +	upperdentry = d_real(path->dentry, NULL, O_WRONLY);
> +	error = PTR_ERR(upperdentry);
> +	if (IS_ERR(upperdentry))
> +		goto mnt_drop_write_and_out;
> +
> +	error = get_write_access(upperdentry->d_inode);
> +	if (error)
> +		goto mnt_drop_write_and_out;
> +
> +	/*
> +	 * Make sure that there are no leases.  get_write_access() protects
> +	 * against the truncate racing with a lease-granting setlease().
> +	 */
> +	error = break_lease(inode, O_WRONLY);
> +	if (error)
> +		goto put_write_and_out;
> +
> +	error = locks_verify_truncate(inode, NULL, length);
> +	if (!error)
> +		error = security_path_truncate(path);
> +	if (!error)
> +		error = do_truncate(path->dentry, length, 0, NULL);
> +
> +put_write_and_out:
> +	put_write_access(upperdentry->d_inode);
> +mnt_drop_write_and_out:
> +	mnt_drop_write(path->mnt);
> +out:
> +	return error;
> +}
> +
>  /*
>   * Set various file attributes.  After this call fhp needs an fh_put.
>   */
> @@ -398,7 +477,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  		    ((iap->ia_valid & ~(ATTR_SIZE | ATTR_MTIME)) == 0))
>  			implicit_mtime = true;
>  
> -		host_err = vfs_truncate(&path, iap->ia_size);
> +		host_err = nfsd_truncate(&path, iap->ia_size);
>  		if (host_err)
>  			goto out_host_err;
>  
> -- 
> 2.11.0
