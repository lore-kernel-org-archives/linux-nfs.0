Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:48843 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751515AbaD2AIY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 20:08:24 -0400
Date: Tue, 29 Apr 2014 10:07:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 06/22] vfs: Add delete child and delete self
 permission flags
Message-ID: <20140429000758.GP15995@dastard>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1398615293-22931-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1398615293-22931-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 27, 2014 at 09:44:37PM +0530, Aneesh Kumar K.V wrote:
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
>  fs/namei.c         | 45 ++++++++++++++++++++++++++++++++++-----------
>  include/linux/fs.h |  2 ++
>  2 files changed, 36 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 028bc8bcf77c..56ac7613fbca 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -446,7 +446,7 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
>   * changing the "normal" UIDs which are used for other things.
>   *
>   * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
> - * MAY_WRITE must also be set in @mask.
> + * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
>   */
>  int inode_permission(struct inode *inode, int mask)
>  {
> @@ -2366,11 +2366,25 @@ kern_path_mountpoint(int dfd, const char *name, struct path *path,
>  }
>  EXPORT_SYMBOL(kern_path_mountpoint);
>  
> +
> +/*
> + * We should have exec permission on directory and MAY_DELETE_SELF
> + * on the object being deleted.
> + */
> +static int richacl_may_selfdelete(struct inode *dir,
> +				  struct inode *inode, int replace_mask)
> +{
> +	return (IS_RICHACL(inode) &&
> +		(inode_permission(dir, MAY_EXEC | replace_mask) == 0) &&
> +		(inode_permission(inode, MAY_DELETE_SELF) == 0));
> +}

Can't say I like these "richacl" prefixes. Why not just "may_*"
like all the other permission checks?


> @@ -2414,13 +2431,19 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
>  	BUG_ON(victim->d_parent->d_inode != dir);
>  	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
>  
> -	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
> +	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
> +	if (replace)
> +		replace_mask = S_ISDIR(inode->i_mode) ?
> +				MAY_CREATE_DIR : MAY_CREATE_FILE;
> +	error = inode_permission(dir, mask | replace_mask);
> +	if (error && richacl_may_selfdelete(dir, inode, replace_mask))
> +		error = 0;
>  	if (error)
>  		return error;
>  	if (IS_APPEND(dir))
>  		return -EPERM;
>  
> -	if (check_sticky(dir, inode) || IS_APPEND(inode) ||
> +	if (check_sticky(dir, inode, replace_mask) || IS_APPEND(inode) ||
>  	    IS_IMMUTABLE(inode) || IS_SWAPFILE(inode))
>  		return -EPERM;
>  	if (isdir) {
> @@ -3539,7 +3562,7 @@ EXPORT_SYMBOL(dentry_unhash);
>  
>  int vfs_rmdir(struct inode *dir, struct dentry *dentry)
>  {
> -	int error = may_delete(dir, dentry, 1);
> +	int error = may_delete(dir, dentry, 1, 0);
>  
>  	if (error)
>  		return error;
> @@ -3658,7 +3681,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
>  int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegated_inode)
>  {
>  	struct inode *target = dentry->d_inode;
> -	int error = may_delete(dir, dentry, 0);
> +	int error = may_delete(dir, dentry, 0, 0);
>  
>  	if (error)
>  		return error;
> @@ -4060,7 +4083,7 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
>  	if (source == target)
>  		return 0;
>  
> -	error = may_delete(old_dir, old_dentry, is_dir);
> +	error = may_delete(old_dir, old_dentry, is_dir, 0);
>  	if (error)
>  		return error;
>  
> @@ -4070,9 +4093,9 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
>  		new_is_dir = d_is_dir(new_dentry);
>  
>  		if (!(flags & RENAME_EXCHANGE))
> -			error = may_delete(new_dir, new_dentry, is_dir);
> +			error = may_delete(new_dir, new_dentry, is_dir, 1);
>  		else
> -			error = may_delete(new_dir, new_dentry, new_is_dir);
> +			error = may_delete(new_dir, new_dentry, new_is_dir, 1);

Another boolean parameter that means nothing at the call site.  This
should really be passing a flags field, not a bunch of booleans that
are simply evaluated into flags...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
