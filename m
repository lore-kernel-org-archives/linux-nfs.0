Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667Ab3GIMuW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 08:50:22 -0400
Date: Tue, 9 Jul 2013 08:50:11 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 07/12] namei: minor vfs_unlink cleanup
Message-ID: <20130709085011.59cf1fad@tlielax.poochiereds.net>
In-Reply-To: <1372882356-14168-8-git-send-email-bfields@redhat.com>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
	<1372882356-14168-8-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed,  3 Jul 2013 16:12:31 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We'll be using dentry->d_inode in one more place.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/namei.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 61f6076..7e76fe1 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -3386,6 +3386,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
>  
>  int vfs_unlink(struct inode *dir, struct dentry *dentry)
>  {
> +	struct inode *target = dentry->d_inode;
>  	int error = may_delete(dir, dentry, 0);
>  
>  	if (error)
> @@ -3394,7 +3395,7 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
>  	if (!dir->i_op->unlink)
>  		return -EPERM;
>  
> -	mutex_lock(&dentry->d_inode->i_mutex);
> +	mutex_lock(&target->i_mutex);
>  	if (d_mountpoint(dentry))
>  		error = -EBUSY;
>  	else {
> @@ -3405,11 +3406,11 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
>  				dont_mount(dentry);
>  		}
>  	}
> -	mutex_unlock(&dentry->d_inode->i_mutex);
> +	mutex_unlock(&target->i_mutex);
>  
>  	/* We don't d_delete() NFS sillyrenamed files--they still exist. */
>  	if (!error && !(dentry->d_flags & DCACHE_NFSFS_RENAMED)) {
> -		fsnotify_link_count(dentry->d_inode);
> +		fsnotify_link_count(target);
>  		d_delete(dentry);
>  	}
>  

Acked-by: Jeff Layton <jlayton@redhat.com>
