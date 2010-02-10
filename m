From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 1/2] commit_metadata export operation and nfsd_sync2
Date: Wed, 10 Feb 2010 03:56:14 -0500
Message-ID: <20100210085614.GA21875@infradead.org>
References: <20100210003220.6021.74943.stgit@case> <20100210003331.6021.55867.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51312 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011Ab0BJI4P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2010 03:56:15 -0500
In-Reply-To: <20100210003331.6021.55867.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Thanks, this looks very good!  A few comments below:

>  	status = nfsd_setattr(rqstp, &cstate->current_fh, &setattr->sa_iattr,
> -				0, (time_t)0);
> +				0, (time_t)0, 0);

While you're at it you might want to remove all those superflous time_t
cases - the C propagation rules take care of it when just passing a "0".

> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 5a754f7..4c8e1d8 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -120,7 +120,7 @@ static void
>  nfsd4_sync_rec_dir(void)
>  {
>  	mutex_lock(&rec_dir.dentry->d_inode->i_mutex);
> -	nfsd_sync_dir(rec_dir.dentry);
> +	nfsd_sync2(rec_dir.dentry, NULL);
>  	mutex_unlock(&rec_dir.dentry->d_inode->i_mutex);

This call should be changed to just use vfs_fsync as it doesn't
need the special semantics with the i_mutex already held - we take
it just for nfsd_sync_dir here.  That also has the advantage that
nfsd_sync_dir or its replacement can be private to vfs.c now.

>  /*
> + * Commit parent and child to stable storage.  You may pass NULL for parent or
> + * child.  This expects i_mutex to be held on the parent and not to be held on
> + * the child.
>   */
>  int
> +nfsd_sync2(struct dentry *parent, struct dentry *child)

I think both the local routine and the method should be the the same.
The commit_metadata seems a quite a bit better than sync2 for that.


I also think the EX_ISSYNC check should be taken into it instead
of beeing duplicated, which would require it to take a file handle argument.

> +	const struct export_operations *export_ops = NULL;
> +	struct inode *p_inode = NULL, *c_inode = NULL;

Normally we'd just use parent and child for this, or posisbly
just inode and child.

> +	if (parent) {
> +		p_inode = parent->d_inode;
> +		WARN_ON(!mutex_is_locked(&p_inode->i_mutex));
> +		export_ops = parent->d_sb->s_export_op;
> +	}
> +	if (child) {
> +		c_inode = child->d_inode;
> +		WARN_ON(mutex_is_locked(&c_inode->i_mutex));
> +		export_ops = child->d_sb->s_export_op;
> +	}

A better calling convention would be for the first paramter to
always be non-zero (and we could take the file handle for that one),
with only the second argument beeing optional.  That would require
using the same method for the fallback sync, which we should do anyway.

Currently the only caller passing a NULL first argument is
nfsd_setattr.  If we use ->write_inode as fallback we could just
pass it as first, if using ->fsync we'd need to take i_mutex before,
but we might just stick to using ->write_inode to keep things
simple (and get rid of the NULL file pointer in ->fsync).

> +	if (export_ops->commit_metadata) {
> +		if (parent) 
> +			error = filemap_write_and_wait(p_inode->i_mapping);
> +		if (child) 
> +		       	error2 = filemap_write_and_wait(c_inode->i_mapping);

I think Trond explained that we do not want force data to disk here.

> +		if (!error) {
> +			if (child)
> +				mutex_lock(&c_inode->i_mutex);
> +			error = export_ops->commit_metadata(parent, child);
> +			if (child)
> +				mutex_unlock(&c_inode->i_mutex);

Note that at least xfs doesn't care about the i_mutex here.

> +		if (parent) {
> +			error = filemap_write_and_wait(p_inode->i_mapping);
> +			if (!error && p_inode->i_fop->fsync) 
> +				error = p_inode->i_fop->fsync(NULL, parent, 0);
> +		}
> +		if (child)
> +			write_inode_now(c_inode, 1);
> +	}

Btw, as we don't need to write data to disk this should be a
sync_inode calls with the following second argument:

struct writeback_control wbc = {
	.sync_mode = WB_SYNC_ALL,
	.nr_to_write = 0, /* metadata-only */
};

>  
> @@ -1321,14 +1355,14 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		goto out_nfserr;
>  	}
>  
> +	err = nfsd_create_setattr(rqstp, resfhp, iap);
>  	if (EX_ISSYNC(fhp->fh_export)) {
> -		err = nfserrno(nfsd_sync_dir(dentry));
> -		write_inode_now(dchild->d_inode, 1);
> +		err2 = nfserrno(nfsd_sync2(dentry,
> +					IS_ERR(dchild) ? NULL : dchild));

I can't see how you could ever get a dchild that is an error pointer
here.

> @@ -1484,6 +1510,14 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		err = fh_update(resfhp);
>  
>   out:
> +	if (!err) {
> +		if (EX_ISSYNC(fhp->fh_export)) {
> +			host_err = nfsd_sync2(created ? dentry : NULL,
> +				       	!IS_ERR(dchild) ? dchild : NULL);
> +			err = nfserrno(host_err);
> +		}
> +	}
> +

The placement of this call looks incorrect to me.  We don't want
this after the out label which is used for errors, but directly after
the nfsd_create_setattr call, and most importantly before the
mnt_drop_write after which we're not allowed to the filesystem anymore.
That also makes sure we'll never get dchild or dentry as an error
pointer.

