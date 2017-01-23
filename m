Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33360 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750723AbdAWPwQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 10:52:16 -0500
Received: by mail-qt0-f195.google.com with SMTP id n13so18187219qtc.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2017 07:52:15 -0800 (PST)
Message-ID: <1485186729.2786.11.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: special case truncates some more
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@lst.de>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Mon, 23 Jan 2017 10:52:09 -0500
In-Reply-To: <20170123153615.GA32201@lst.de>
References: <1485104060-15209-1-git-send-email-hch@lst.de>
         <1485104060-15209-2-git-send-email-hch@lst.de>
         <1485174116.2786.7.camel@poochiereds.net> <20170123123348.GA28102@lst.de>
         <20170123153615.GA32201@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-01-23 at 16:36 +0100, Christoph Hellwig wrote:
> On Mon, Jan 23, 2017 at 01:33:48PM +0100, Christoph Hellwig wrote:
> > I'll need to look at the exact NFS semantics in that area, but after
> > a bit of research I can probably come up with something that will work.
> 
> Here is my first attempt.  As vfs_truncate will add the ctime and mtime
> updates when needed it just leaves handling that quirk to vfs_truncate
> and then exits early if no other attributes are set.
> 
> Unfortunately at least the Linux client always seems to also request
> a mtime update with a size update.  We could keep the
> 
> 	if (iap->ia_size != i_size_read(inode))
> 
> check from the old code and remove ATTR_MTIME, but these racy checks
> outside i_rwsem make me feel a bit uneasy.  Jeff, Bruce - any opinion
> if we should add something like this:
> 

Ok, that's more complicated than it looked at first blush. :)

To be clear, the client is requesting to set the mtime to current server
time and not to a specific mtime, right?

> 	/* vfs_truncate will update ctime and mtime if the size changes */
> 	if (iap->ia_size != i_size_read(inode))
> 		iap->ia_valid &= ATTR_MTIME;
> 
> back to nfsd_setattr?  This would avoid the additional setattr call,
> but make me feel dirty :)
> 

I agree that I wouldn't want to go with a potentially racy check.

I don't see where vfs_truncate will handle the times though. do_truncate
will, but you have to pass in a non-zero time_attrs and vfs_truncate
always sets that to 0.

If we did want to do this, it seems like it might be better to just add
a new time_attrs arg to vfs_truncate that gets passed to do_truncate.
Most callers would set it to zero, but nfsd could set it to:

    iap->ia_valid & (ATTR_MTIME|ATTR_CTIME)

Would that work?

> ---
> From 0e06e2fc6157bb97692ed47c21e36120efb9f15c Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Sun, 22 Jan 2017 17:17:48 +0100
> Subject: nfsd: special case truncates some more
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
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
>  fs/nfsd/vfs.c | 92 +++++++++++++++++++----------------------------------------
>  1 file changed, 30 insertions(+), 62 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 26c6fdb..4ca5b92 100644
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
> @@ -405,50 +373,50 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
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
> +	 *
> +	 * Note that vfs_truncate will also update ctime and mtime if
> +	 * the file size changes.
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
> -		/*
> -		 * RFC5661, Section 18.30.4:
> -		 *   Changing the size of a file with SETATTR indirectly
> -		 *   changes the time_modify and change attributes.
> -		 *
> -		 * (and similar for the older RFCs)
> -		 */
> -		if (iap->ia_size != i_size_read(inode))
> -			iap->ia_valid |= ATTR_MTIME;
> +		host_err = vfs_truncate(&path, iap->ia_size);
> +		if (host_err)
> +			goto out_host_err;
> +
> +		iap->ia_valid &= ~ATTR_SIZE;
> +		if (!iap->ia_valid)
> +			goto done;
>  	}
>  
>  	iap->ia_valid |= ATTR_CTIME;
>  
> -	if (check_guard && guardtime != inode->i_ctime.tv_sec) {
> -		err = nfserr_notsync;
> -		goto out_put_write_access;
> -	}
> -
>  	fh_lock(fhp);
>  	host_err = notify_change(dentry, iap, NULL);
>  	fh_unlock(fhp);
> -	err = nfserrno(host_err);
> +	if (host_err)
> +		goto out_host_err;
>  
> -out_put_write_access:
> -	if (size_change)
> -		put_write_access(inode);
> -	if (!err)
> -		err = nfserrno(commit_metadata(fhp));
> -out:
> -	return err;
> +done:
> +	host_err = commit_metadata(fhp);
> +out_host_err:
> +	return nfserrno(host_err);
>  }
>  
>  #if defined(CONFIG_NFSD_V4)

-- 
Jeff Layton <jlayton@poochiereds.net>
