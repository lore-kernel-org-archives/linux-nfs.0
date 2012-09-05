Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45179 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215Ab2IEVCI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 17:02:08 -0400
Date: Wed, 5 Sep 2012 17:02:06 -0400
To: jlayton@redhat.com
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: Re: [RFC PATCH 12/13] locks: break delegations on link
Message-ID: <20120905210206.GB10724@fieldses.org>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
 <1346878524-10585-13-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1346878524-10585-13-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oops, I meant to cc this to Jeff:

On Wed, Sep 05, 2012 at 04:55:22PM -0400, J. Bruce Fields wrote:
> @@ -3556,6 +3560,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
>  	if (error)
>  		return error;
>  
> +retry_deleg:
>  	new_dentry = user_path_create(newdfd, newname, &new_path, 0);
>  	error = PTR_ERR(new_dentry);
>  	if (IS_ERR(new_dentry))
> @@ -3570,9 +3575,14 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
>  	error = security_path_link(old_path.dentry, &new_path, new_dentry);
>  	if (error)
>  		goto out_dput;
> -	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry);
> +	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry, &delegated_inode);
>  out_dput:
>  	done_path_create(&new_path, new_dentry);
> +	if (delegated_inode) {
> +		error = break_deleg_wait(&delegated_inode);
> +		if (!error)
> +			goto retry_deleg;
> +	}
>  out:
>  	path_put(&old_path);
>  

I think this will get me into trouble with the audit code, right?

(On a quick skim I think I'm retrying from a point after the getname()
in rename and unlink, so I think those are OK, but I may be missing
something....)

--b.

> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index c8f5e74..2a77b28 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1717,7 +1717,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
>  		err = nfserrno(host_err);
>  		goto out_dput;
>  	}
> -	host_err = vfs_link(dold, dirp, dnew);
> +	host_err = vfs_link(dold, dirp, dnew, NULL);
>  	if (!host_err) {
>  		err = nfserrno(commit_metadata(ffhp));
>  		if (!err)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index ad9df65e..52b8c67 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1721,7 +1721,7 @@ extern int vfs_create(struct inode *, struct dentry *, umode_t, bool);
>  extern int vfs_mkdir(struct inode *, struct dentry *, umode_t);
>  extern int vfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
>  extern int vfs_symlink(struct inode *, struct dentry *, const char *);
> -extern int vfs_link(struct dentry *, struct inode *, struct dentry *);
> +extern int vfs_link(struct dentry *, struct inode *, struct dentry *, struct inode **);
>  extern int vfs_rmdir(struct inode *, struct dentry *);
>  extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
>  extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **);
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
