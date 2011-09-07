Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36299 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756348Ab1IGUkM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Sep 2011 16:40:12 -0400
Date: Wed, 7 Sep 2011 16:39:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 09/26] vfs: Add delete child and delete self
 permission flags
Message-ID: <20110907203916.GE8074@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1315243548-18664-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1315243548-18664-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 05, 2011 at 10:55:31PM +0530, Aneesh Kumar K.V wrote:
> From: Andreas Gruenbacher <agruen@kernel.org>
> 
> Normally, deleting a file requires write access to the parent directory.
> Some permission models use a different permission on the parent
> directory to indicate delete access.  In addition, a process can have
> per-file delete access even without delete access on the parent
> directory.
> 
> Introduce two new inode_permission() mask flags and use them in
> may_delete()
> 
> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  fs/namei.c         |   41 +++++++++++++++++++++++++++--------------
>  include/linux/fs.h |    2 ++
>  2 files changed, 29 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index d52a4cd..eacb530 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -337,7 +337,7 @@ static inline int do_inode_permission(struct inode *inode, int mask)
>   * are used for other things.
>   *
>   * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
> - * MAY_WRITE must also be set in @mask.
> + * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
>   */
>  int inode_permission(struct inode *inode, int mask)
>  {
> @@ -1862,7 +1862,7 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
>  		return 0;
>  
>  other_userns:
> -	return !ns_capable(inode_userns(inode), CAP_FOWNER);
> +	return 1;
>  }
>  
>  /*
> @@ -1884,30 +1884,43 @@ other_userns:
>   * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
>   *     nfs_async_unlink().
>   */
> -static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
> +static int may_delete(struct inode *dir, struct dentry *victim,
> +		      int isdir, int replace)
>  {
> -	int error;
> +	int mask, error, is_sticky;
> +	struct inode *inode = victim->d_inode;
>  
> -	if (!victim->d_inode)
> +	if (!inode)
>  		return -ENOENT;
>  
>  	BUG_ON(victim->d_parent->d_inode != dir);
>  	audit_inode_child(victim, dir);
>  
> -	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
> +	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
> +	if (replace)
> +		mask |= S_ISDIR(inode->i_mode) ?
> +			MAY_CREATE_DIR : MAY_CREATE_FILE;

I'm having trouble understanding this next bit:

> +	is_sticky = check_sticky(dir, inode);
> +	error = inode_permission(dir, mask);
> +	if ((error || is_sticky) && IS_RICHACL(inode) &&
> +	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
> +	    !inode_permission(inode, MAY_DELETE_SELF))
> +		error = 0;

OK, so we can ignore the lack of write or delete permissions on the
parent if we have delete_self permissions on the child.  I guess that's
right.

Why the "|| is_sticky" above?

Is there some less complicated why to write this?

--b.

> +	else if (!error && is_sticky &&
> +		 !ns_capable(inode_userns(inode), CAP_FOWNER))
> +		error = -EPERM;
>  	if (error)
>  		return error;
>  	if (IS_APPEND(dir))
>  		return -EPERM;
> -	if (check_sticky(dir, victim->d_inode)||IS_APPEND(victim->d_inode)||
> -	    IS_IMMUTABLE(victim->d_inode) || IS_SWAPFILE(victim->d_inode))
> +	if (IS_APPEND(inode) || IS_IMMUTABLE(inode) || IS_SWAPFILE(inode))
>  		return -EPERM;
>  	if (isdir) {
> -		if (!S_ISDIR(victim->d_inode->i_mode))
> +		if (!S_ISDIR(inode->i_mode))
>  			return -ENOTDIR;
>  		if (IS_ROOT(victim))
>  			return -EBUSY;
> -	} else if (S_ISDIR(victim->d_inode->i_mode))
> +	} else if (S_ISDIR(inode->i_mode))
>  		return -EISDIR;
>  	if (IS_DEADDIR(dir))
>  		return -ENOENT;
> @@ -2614,7 +2627,7 @@ void dentry_unhash(struct dentry *dentry)
>  
>  int vfs_rmdir(struct inode *dir, struct dentry *dentry)
>  {
> -	int error = may_delete(dir, dentry, 1);
> +	int error = may_delete(dir, dentry, 1, 0);
>  
>  	if (error)
>  		return error;
> @@ -2707,7 +2720,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
>  
>  int vfs_unlink(struct inode *dir, struct dentry *dentry)
>  {
> -	int error = may_delete(dir, dentry, 0);
> +	int error = may_delete(dir, dentry, 0, 0);
>  
>  	if (error)
>  		return error;
> @@ -3101,14 +3114,14 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
>  	if (old_dentry->d_inode == new_dentry->d_inode)
>   		return 0;
>   
> -	error = may_delete(old_dir, old_dentry, is_dir);
> +	error = may_delete(old_dir, old_dentry, is_dir, 0);
>  	if (error)
>  		return error;
>  
>  	if (!new_dentry->d_inode)
>  		error = may_create(new_dir, new_dentry, is_dir);
>  	else
> -		error = may_delete(new_dir, new_dentry, is_dir);
> +		error = may_delete(new_dir, new_dentry, is_dir, 1);
>  	if (error)
>  		return error;
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 8707f43..c5c98c5 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -69,6 +69,8 @@ struct inodes_stat_t {
>  #define MAY_NOT_BLOCK		0x00000080
>  #define MAY_CREATE_FILE		0x00000100
>  #define MAY_CREATE_DIR		0x00000200
> +#define MAY_DELETE_CHILD	0x00000400
> +#define MAY_DELETE_SELF		0x00000800
>  
>  /*
>   * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
> -- 
> 1.7.4.1
> 
