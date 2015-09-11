Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48540 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841AbbIKUaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2015 16:30:19 -0400
Date: Fri, 11 Sep 2015 16:30:16 -0400
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [PATCH] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD permission
 flags
Message-ID: <20150911203016.GD11677@fieldses.org>
References: <1441448856-13478-4-git-send-email-agruenba@redhat.com>
 <1441527246-18189-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441527246-18189-1-git-send-email-agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 06, 2015 at 10:14:06AM +0200, Andreas Gruenbacher wrote:
> [This replaces v7 of this patch; MAY_DELETE_SELF now properly overrides the
> sticky check.]
> 
> Normally, deleting a file requires MAY_WRITE access to the parent
> directory.  With richacls, a file may be deleted with MAY_DELETE_CHILD access
> to the parent directory or with MAY_DELETE_SELF access to the file.
> 
> To support that, pass the MAY_DELETE_CHILD mask flag to inode_permission()
> when checking for delete access inside a directory, and MAY_DELETE_SELF
> when checking for delete access to a file itelf.
> 
> The MAY_DELETE_SELF permission overrides the sticky directory check.
> 

Reviewed-by: J. Bruce Fields <bfields@redhat.com>

> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/namei.c         | 21 ++++++++++++---------
>  include/linux/fs.h |  2 ++
>  2 files changed, 14 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 428b4a6..1a3f0d8 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -453,9 +453,9 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
>   * this, letting us set arbitrary permissions for filesystem access without
>   * changing the "normal" UIDs which are used for other things.
>   *
> - * MAY_WRITE must be set in @mask whenever MAY_APPEND, MAY_CREATE_FILE, or
> - * MAY_CREATE_DIR are set.  That way, file systems that don't support these
> - * permissions will check for MAY_WRITE instead.
> + * MAY_WRITE must be set in @mask whenever MAY_APPEND, MAY_CREATE_FILE,
> + * MAY_CREATE_DIR, or MAY_DELETE_CHILD are set.  That way, file systems that
> + * don't support these permissions will check for MAY_WRITE instead.
>   */
>  int inode_permission(struct inode *inode, int mask)
>  {
> @@ -2528,7 +2528,7 @@ static int may_delete(struct inode *dir, struct dentry *victim,
>  		      bool isdir, bool replace)
>  {
>  	struct inode *inode = d_backing_inode(victim);
> -	int error, mask = MAY_WRITE | MAY_EXEC;
> +	int error, mask = MAY_EXEC;
>  
>  	if (d_is_negative(victim))
>  		return -ENOENT;
> @@ -2538,15 +2538,18 @@ static int may_delete(struct inode *dir, struct dentry *victim,
>  	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
>  
>  	if (replace)
> -		mask |= isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE;
> -	error = inode_permission(dir, mask);
> +		mask |= MAY_WRITE | (isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE);
> +	error = inode_permission(dir, mask | MAY_WRITE | MAY_DELETE_CHILD);
> +	if (!error && check_sticky(dir, inode))
> +		error = -EPERM;
> +	if (error && IS_RICHACL(inode) &&
> +	    inode_permission(inode, MAY_DELETE_SELF) == 0)
> +		error = 0;
>  	if (error)
>  		return error;
>  	if (IS_APPEND(dir))
>  		return -EPERM;
> -
> -	if (check_sticky(dir, inode) || IS_APPEND(inode) ||
> -	    IS_IMMUTABLE(inode) || IS_SWAPFILE(inode))
> +	if (IS_APPEND(inode) || IS_IMMUTABLE(inode) || IS_SWAPFILE(inode))
>  		return -EPERM;
>  	if (isdir) {
>  		if (!d_is_dir(victim))
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index b2f1b1b..99c95d1 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -84,6 +84,8 @@ typedef void (dax_iodone_t)(struct buffer_head *bh_map, int uptodate);
>  #define MAY_NOT_BLOCK		0x00000080
>  #define MAY_CREATE_FILE		0x00000100
>  #define MAY_CREATE_DIR		0x00000200
> +#define MAY_DELETE_CHILD	0x00000400
> +#define MAY_DELETE_SELF		0x00000800
>  
>  /*
>   * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
