Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846Ab3GINOk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 09:14:40 -0400
Date: Tue, 9 Jul 2013 09:14:38 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 10/12] locks: break delegations on rename
Message-ID: <20130709091438.1be8d3af@tlielax.poochiereds.net>
In-Reply-To: <1372882356-14168-11-git-send-email-bfields@redhat.com>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
	<1372882356-14168-11-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed,  3 Jul 2013 16:12:34 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Cc: David Howells <dhowells@redhat.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/cachefiles/namei.c |    2 +-
>  fs/namei.c            |   26 ++++++++++++++++++++++----
>  fs/nfsd/vfs.c         |    2 +-
>  include/linux/fs.h    |    2 +-
>  4 files changed, 25 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
> index d61d884..678a8af 100644
> --- a/fs/cachefiles/namei.c
> +++ b/fs/cachefiles/namei.c
> @@ -396,7 +396,7 @@ try_again:
>  		cachefiles_io_error(cache, "Rename security error %d", ret);
>  	} else {
>  		ret = vfs_rename(dir->d_inode, rep,
> -				 cache->graveyard->d_inode, grave);
> +				 cache->graveyard->d_inode, grave, NULL);
>  		if (ret != 0 && ret != -ENOMEM)
>  			cachefiles_io_error(cache,
>  					    "Rename failed with error %d", ret);
> diff --git a/fs/namei.c b/fs/namei.c
> index a9d4031..be00d37 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -3763,7 +3763,8 @@ out:
>  }
>  
>  static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
> -			    struct inode *new_dir, struct dentry *new_dentry)
> +			    struct inode *new_dir, struct dentry *new_dentry,
> +			    struct inode **delegated_inode)
>  {
>  	struct inode *target = new_dentry->d_inode;
>  	struct inode *source = old_dentry->d_inode;
> @@ -3783,6 +3784,14 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
>  	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
>  		goto out;
>  
> +	error = try_break_deleg(source, delegated_inode);
> +	if (error)
> +		goto out;
> +	if (target) {
> +		error = try_break_deleg(target, delegated_inode);
> +		if (error)
> +			goto out;
> +	}
>  	error = old_dir->i_op->rename(old_dir, old_dentry, new_dir, new_dentry);
>  	if (error)
>  		goto out;
> @@ -3801,7 +3810,8 @@ out:
>  }
>  
>  int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
> -	       struct inode *new_dir, struct dentry *new_dentry)
> +	       struct inode *new_dir, struct dentry *new_dentry,
> +	       struct inode **delegated_inode)
>  {
>  	int error;
>  	int is_dir = S_ISDIR(old_dentry->d_inode->i_mode);
> @@ -3829,7 +3839,7 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
>  	if (is_dir)
>  		error = vfs_rename_dir(old_dir,old_dentry,new_dir,new_dentry);
>  	else
> -		error = vfs_rename_other(old_dir,old_dentry,new_dir,new_dentry);
> +		error = vfs_rename_other(old_dir,old_dentry,new_dir,new_dentry,delegated_inode);
>  	if (!error)
>  		fsnotify_move(old_dir, new_dir, old_name, is_dir,
>  			      new_dentry->d_inode, old_dentry);
> @@ -3845,6 +3855,7 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
>  	struct dentry *old_dentry, *new_dentry;
>  	struct dentry *trap;
>  	struct nameidata oldnd, newnd;
> +	struct inode *delegated_inode = NULL;
>  	struct filename *from;
>  	struct filename *to;
>  	unsigned int lookup_flags = 0;
> @@ -3884,6 +3895,7 @@ retry:
>  	newnd.flags &= ~LOOKUP_PARENT;
>  	newnd.flags |= LOOKUP_RENAME_TARGET;
>  
> +retry_deleg:
>  	trap = lock_rename(new_dir, old_dir);
>  
>  	old_dentry = lookup_hash(&oldnd);
> @@ -3920,13 +3932,19 @@ retry:
>  	if (error)
>  		goto exit5;
>  	error = vfs_rename(old_dir->d_inode, old_dentry,
> -				   new_dir->d_inode, new_dentry);
> +				   new_dir->d_inode, new_dentry,
> +				   &delegated_inode);
>  exit5:
>  	dput(new_dentry);
>  exit4:
>  	dput(old_dentry);
>  exit3:
>  	unlock_rename(new_dir, old_dir);
> +	if (delegated_inode) {
> +		error = break_deleg_wait(&delegated_inode);
> +		if (!error)
> +			goto retry_deleg;
> +	}
>  	mnt_drop_write(oldnd.path.mnt);
>  exit2:
>  	if (retry_estale(error, lookup_flags))
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6ccaca2..54ac814 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1809,7 +1809,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>  		if (host_err)
>  			goto out_dput_new;
>  	}
> -	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
> +	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL);
>  	if (!host_err) {
>  		host_err = commit_metadata(tfhp);
>  		if (!host_err)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index c37e463..a35dadb 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1464,7 +1464,7 @@ extern int vfs_symlink(struct inode *, struct dentry *, const char *);
>  extern int vfs_link(struct dentry *, struct inode *, struct dentry *);
>  extern int vfs_rmdir(struct inode *, struct dentry *);
>  extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
> -extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
> +extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **);
>  
>  /*
>   * VFS dentry helper functions.

Acked-by: Jeff Layton <jlayton@redhat.com>
