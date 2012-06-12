Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59960 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753749Ab2FLRZW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jun 2012 13:25:22 -0400
Date: Tue, 12 Jun 2012 13:25:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel@suse.cz, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 12/27] nfsd: Push mnt_want_write() outside of i_mutex
Message-ID: <20120612172516.GA24476@fieldses.org>
References: <1339510848-16992-1-git-send-email-jack@suse.cz>
 <1339510848-16992-13-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1339510848-16992-13-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 12, 2012 at 04:20:33PM +0200, Jan Kara wrote:
> When mnt_want_write() starts to handle freezing it will get a full lock
> semantics requiring proper lock ordering. So push mnt_want_write() call
> consistently outside of i_mutex.
> 
> CC: linux-nfs@vger.kernel.org
> CC: "J. Bruce Fields" <bfields@fieldses.org>

Looks good to me.  (If you want:
Acked-by: J. Bruce Fields <bfields@redhat.com>
.)

--b.

> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/nfsd/nfs4recover.c      |    9 +++--
>  fs/nfsd/nfsfh.c            |    1 +
>  fs/nfsd/nfsproc.c          |    9 ++++-
>  fs/nfsd/vfs.c              |   79 ++++++++++++++++++++++---------------------
>  fs/nfsd/vfs.h              |   11 +++++-
>  include/linux/nfsd/nfsfh.h |    1 +
>  6 files changed, 64 insertions(+), 46 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 5ff0b7b..43295d4 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -154,6 +154,10 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
>  	if (status < 0)
>  		return;
>  
> +	status = mnt_want_write_file(rec_file);
> +	if (status)
> +		return;
> +
>  	dir = rec_file->f_path.dentry;
>  	/* lock the parent */
>  	mutex_lock(&dir->d_inode->i_mutex);
> @@ -173,11 +177,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
>  		 * as well be forgiving and just succeed silently.
>  		 */
>  		goto out_put;
> -	status = mnt_want_write_file(rec_file);
> -	if (status)
> -		goto out_put;
>  	status = vfs_mkdir(dir->d_inode, dentry, S_IRWXU);
> -	mnt_drop_write_file(rec_file);
>  out_put:
>  	dput(dentry);
>  out_unlock:
> @@ -189,6 +189,7 @@ out_unlock:
>  				" (err %d); please check that %s exists"
>  				" and is writeable", status,
>  				user_recovery_dirname);
> +	mnt_drop_write_file(rec_file);
>  	nfs4_reset_creds(original_cred);
>  }
>  
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index cc79300..032af38 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -635,6 +635,7 @@ fh_put(struct svc_fh *fhp)
>  		fhp->fh_post_saved = 0;
>  #endif
>  	}
> +	fh_drop_write(fhp);
>  	if (exp) {
>  		exp_put(exp);
>  		fhp->fh_export = NULL;
> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index e15dc45..aad6d45 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -196,6 +196,7 @@ nfsd_proc_create(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
>  	struct dentry	*dchild;
>  	int		type, mode;
>  	__be32		nfserr;
> +	int		hosterr;
>  	dev_t		rdev = 0, wanted = new_decode_dev(attr->ia_size);
>  
>  	dprintk("nfsd: CREATE   %s %.*s\n",
> @@ -214,6 +215,12 @@ nfsd_proc_create(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
>  	nfserr = nfserr_exist;
>  	if (isdotent(argp->name, argp->len))
>  		goto done;
> +	hosterr = fh_want_write(dirfhp);
> +	if (hosterr) {
> +		nfserr = nfserrno(hosterr);
> +		goto done;
> +	}
> +
>  	fh_lock_nested(dirfhp, I_MUTEX_PARENT);
>  	dchild = lookup_one_len(argp->name, dirfhp->fh_dentry, argp->len);
>  	if (IS_ERR(dchild)) {
> @@ -330,7 +337,7 @@ nfsd_proc_create(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
>  out_unlock:
>  	/* We don't really need to unlock, as fh_put does it. */
>  	fh_unlock(dirfhp);
> -
> +	fh_drop_write(dirfhp);
>  done:
>  	fh_put(dirfhp);
>  	return nfsd_return_dirop(nfserr, resp);
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index c8bd9c3..4503995 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1276,6 +1276,10 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	 * If it has, the parent directory should already be locked.
>  	 */
>  	if (!resfhp->fh_dentry) {
> +		host_err = fh_want_write(fhp);
> +		if (host_err)
> +			goto out_nfserr;
> +
>  		/* called from nfsd_proc_mkdir, or possibly nfsd3_proc_create */
>  		fh_lock_nested(fhp, I_MUTEX_PARENT);
>  		dchild = lookup_one_len(fname, dentry, flen);
> @@ -1319,14 +1323,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		goto out;
>  	}
>  
> -	host_err = fh_want_write(fhp);
> -	if (host_err)
> -		goto out_nfserr;
> -
>  	/*
>  	 * Get the dir op function pointer.
>  	 */
>  	err = 0;
> +	host_err = 0;
>  	switch (type) {
>  	case S_IFREG:
>  		host_err = vfs_create(dirp, dchild, iap->ia_mode, NULL);
> @@ -1343,10 +1344,8 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		host_err = vfs_mknod(dirp, dchild, iap->ia_mode, rdev);
>  		break;
>  	}
> -	if (host_err < 0) {
> -		fh_drop_write(fhp);
> +	if (host_err < 0)
>  		goto out_nfserr;
> -	}
>  
>  	err = nfsd_create_setattr(rqstp, resfhp, iap);
>  
> @@ -1358,7 +1357,6 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	err2 = nfserrno(commit_metadata(fhp));
>  	if (err2)
>  		err = err2;
> -	fh_drop_write(fhp);
>  	/*
>  	 * Update the file handle to get the new inode info.
>  	 */
> @@ -1417,6 +1415,11 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	err = nfserr_notdir;
>  	if (!dirp->i_op->lookup)
>  		goto out;
> +
> +	host_err = fh_want_write(fhp);
> +	if (host_err)
> +		goto out_nfserr;
> +
>  	fh_lock_nested(fhp, I_MUTEX_PARENT);
>  
>  	/*
> @@ -1449,9 +1452,6 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		v_atime = verifier[1]&0x7fffffff;
>  	}
>  	
> -	host_err = fh_want_write(fhp);
> -	if (host_err)
> -		goto out_nfserr;
>  	if (dchild->d_inode) {
>  		err = 0;
>  
> @@ -1522,7 +1522,6 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	if (!err)
>  		err = nfserrno(commit_metadata(fhp));
>  
> -	fh_drop_write(fhp);
>  	/*
>  	 * Update the filehandle to get the new inode info.
>  	 */
> @@ -1533,6 +1532,7 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	fh_unlock(fhp);
>  	if (dchild && !IS_ERR(dchild))
>  		dput(dchild);
> +	fh_drop_write(fhp);
>   	return err;
>   
>   out_nfserr:
> @@ -1613,6 +1613,11 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
>  	if (err)
>  		goto out;
> +
> +	host_err = fh_want_write(fhp);
> +	if (host_err)
> +		goto out_nfserr;
> +
>  	fh_lock(fhp);
>  	dentry = fhp->fh_dentry;
>  	dnew = lookup_one_len(fname, dentry, flen);
> @@ -1620,10 +1625,6 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	if (IS_ERR(dnew))
>  		goto out_nfserr;
>  
> -	host_err = fh_want_write(fhp);
> -	if (host_err)
> -		goto out_nfserr;
> -
>  	if (unlikely(path[plen] != 0)) {
>  		char *path_alloced = kmalloc(plen+1, GFP_KERNEL);
>  		if (path_alloced == NULL)
> @@ -1683,6 +1684,12 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
>  	if (isdotent(name, len))
>  		goto out;
>  
> +	host_err = fh_want_write(tfhp);
> +	if (host_err) {
> +		err = nfserrno(host_err);
> +		goto out;
> +	}
> +
>  	fh_lock_nested(ffhp, I_MUTEX_PARENT);
>  	ddir = ffhp->fh_dentry;
>  	dirp = ddir->d_inode;
> @@ -1694,18 +1701,13 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
>  
>  	dold = tfhp->fh_dentry;
>  
> -	host_err = fh_want_write(tfhp);
> -	if (host_err) {
> -		err = nfserrno(host_err);
> -		goto out_dput;
> -	}
>  	err = nfserr_noent;
>  	if (!dold->d_inode)
> -		goto out_drop_write;
> +		goto out_dput;
>  	host_err = nfsd_break_lease(dold->d_inode);
>  	if (host_err) {
>  		err = nfserrno(host_err);
> -		goto out_drop_write;
> +		goto out_dput;
>  	}
>  	host_err = vfs_link(dold, dirp, dnew);
>  	if (!host_err) {
> @@ -1718,12 +1720,11 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
>  		else
>  			err = nfserrno(host_err);
>  	}
> -out_drop_write:
> -	fh_drop_write(tfhp);
>  out_dput:
>  	dput(dnew);
>  out_unlock:
>  	fh_unlock(ffhp);
> +	fh_drop_write(tfhp);
>  out:
>  	return err;
>  
> @@ -1766,6 +1767,12 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>  	if (!flen || isdotent(fname, flen) || !tlen || isdotent(tname, tlen))
>  		goto out;
>  
> +	host_err = fh_want_write(ffhp);
> +	if (host_err) {
> +		err = nfserrno(host_err);
> +		goto out;
> +	}
> +
>  	/* cannot use fh_lock as we need deadlock protective ordering
>  	 * so do it by hand */
>  	trap = lock_rename(tdentry, fdentry);
> @@ -1796,17 +1803,14 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>  	host_err = -EXDEV;
>  	if (ffhp->fh_export->ex_path.mnt != tfhp->fh_export->ex_path.mnt)
>  		goto out_dput_new;
> -	host_err = fh_want_write(ffhp);
> -	if (host_err)
> -		goto out_dput_new;
>  
>  	host_err = nfsd_break_lease(odentry->d_inode);
>  	if (host_err)
> -		goto out_drop_write;
> +		goto out_dput_new;
>  	if (ndentry->d_inode) {
>  		host_err = nfsd_break_lease(ndentry->d_inode);
>  		if (host_err)
> -			goto out_drop_write;
> +			goto out_dput_new;
>  	}
>  	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
>  	if (!host_err) {
> @@ -1814,8 +1818,6 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>  		if (!host_err)
>  			host_err = commit_metadata(ffhp);
>  	}
> -out_drop_write:
> -	fh_drop_write(ffhp);
>   out_dput_new:
>  	dput(ndentry);
>   out_dput_old:
> @@ -1831,6 +1833,7 @@ out_drop_write:
>  	fill_post_wcc(tfhp);
>  	unlock_rename(tdentry, fdentry);
>  	ffhp->fh_locked = tfhp->fh_locked = 0;
> +	fh_drop_write(ffhp);
>  
>  out:
>  	return err;
> @@ -1856,6 +1859,10 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
>  	if (err)
>  		goto out;
>  
> +	host_err = fh_want_write(fhp);
> +	if (host_err)
> +		goto out_nfserr;
> +
>  	fh_lock_nested(fhp, I_MUTEX_PARENT);
>  	dentry = fhp->fh_dentry;
>  	dirp = dentry->d_inode;
> @@ -1874,21 +1881,15 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
>  	if (!type)
>  		type = rdentry->d_inode->i_mode & S_IFMT;
>  
> -	host_err = fh_want_write(fhp);
> -	if (host_err)
> -		goto out_put;
> -
>  	host_err = nfsd_break_lease(rdentry->d_inode);
>  	if (host_err)
> -		goto out_drop_write;
> +		goto out_put;
>  	if (type != S_IFDIR)
>  		host_err = vfs_unlink(dirp, rdentry);
>  	else
>  		host_err = vfs_rmdir(dirp, rdentry);
>  	if (!host_err)
>  		host_err = commit_metadata(fhp);
> -out_drop_write:
> -	fh_drop_write(fhp);
>  out_put:
>  	dput(rdentry);
>  
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index ec0611b..359594c 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -110,12 +110,19 @@ int nfsd_set_posix_acl(struct svc_fh *, int, struct posix_acl *);
>  
>  static inline int fh_want_write(struct svc_fh *fh)
>  {
> -	return mnt_want_write(fh->fh_export->ex_path.mnt);
> +	int ret = mnt_want_write(fh->fh_export->ex_path.mnt);
> +
> +	if (!ret)
> +		fh->fh_want_write = 1;
> +	return ret;
>  }
>  
>  static inline void fh_drop_write(struct svc_fh *fh)
>  {
> -	mnt_drop_write(fh->fh_export->ex_path.mnt);
> +	if (fh->fh_want_write) {
> +		fh->fh_want_write = 0;
> +		mnt_drop_write(fh->fh_export->ex_path.mnt);
> +	}
>  }
>  
>  #endif /* LINUX_NFSD_VFS_H */
> diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
> index ce4743a..fa63048 100644
> --- a/include/linux/nfsd/nfsfh.h
> +++ b/include/linux/nfsd/nfsfh.h
> @@ -143,6 +143,7 @@ typedef struct svc_fh {
>  	int			fh_maxsize;	/* max size for fh_handle */
>  
>  	unsigned char		fh_locked;	/* inode locked by us */
> +	unsigned char		fh_want_write;	/* remount protection taken */
>  
>  #ifdef CONFIG_NFSD_V3
>  	unsigned char		fh_post_saved;	/* post-op attrs saved */
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
