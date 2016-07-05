Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:34480 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775AbcGELAS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jul 2016 07:00:18 -0400
Received: by mail-qk0-f170.google.com with SMTP id t127so284684153qkf.1
        for <linux-nfs@vger.kernel.org>; Tue, 05 Jul 2016 04:00:17 -0700 (PDT)
Message-ID: <1467716413.3800.1.camel@redhat.com>
Subject: Re: [PATCH v23 01/22] vfs: Add IS_ACL() and IS_RICHACL() tests
From: Jeff Layton <jlayton@redhat.com>
To: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Date: Tue, 05 Jul 2016 07:00:13 -0400
In-Reply-To: <1467294433-3222-2-git-send-email-agruenba@redhat.com>
References: <1467294433-3222-1-git-send-email-agruenba@redhat.com>
	 <1467294433-3222-2-git-send-email-agruenba@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-06-30 at 15:46 +0200, Andreas Gruenbacher wrote:
> The vfs does not apply the umask for file systems that support acls.
> The test used for this used to be called IS_POSIXACL().  Switch to a new
> IS_ACL() test to check for either posix acls or richacls instead.  Add a
> new MS_RICHACL flag and IS_RICHACL() test for richacls alone.  The
> IS_POSIXACL() test is still needed in some places like nfsd.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> Reviewed-by: J. Bruce Fields <bfields@redhat.com>
> Reviewed-by: Andreas Dilger <adilger@dilger.ca>
> Reviewed-by: Steve French <steve.french@primarydata.com>
> ---
>  fs/Kconfig              |  3 +++
>  fs/namei.c              |  6 +++---
>  include/linux/fs.h      | 12 ++++++++++++
>  include/uapi/linux/fs.h |  3 ++-
>  4 files changed, 20 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index b8fcb41..de6de55 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -64,6 +64,9 @@ endif # BLOCK
>  config FS_POSIX_ACL
>  	def_bool n
>  
> +config FS_RICHACL
> +	def_bool n
> +
>  config EXPORTFS
>  	tristate
>  
> diff --git a/fs/namei.c b/fs/namei.c
> index 70580ab..7cc5487 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -3115,7 +3115,7 @@ static int lookup_open(struct nameidata *nd, struct path *path,
>  	 * O_EXCL open we want to return EEXIST not EROFS).
>  	 */
>  	if (open_flag & O_CREAT) {
> -		if (!IS_POSIXACL(dir->d_inode))
> +		if (!IS_ACL(dir->d_inode))
>  			mode &= ~current_umask();
>  		if (unlikely(!got_write)) {
>  			create_error = -EROFS;
> @@ -3709,7 +3709,7 @@ retry:
>  	if (IS_ERR(dentry))
>  		return PTR_ERR(dentry);
>  
> -	if (!IS_POSIXACL(path.dentry->d_inode))
> +	if (!IS_ACL(path.dentry->d_inode))
>  		mode &= ~current_umask();
>  	error = security_path_mknod(&path, dentry, mode, dev);
>  	if (error)
> @@ -3780,7 +3780,7 @@ retry:
>  	if (IS_ERR(dentry))
>  		return PTR_ERR(dentry);
>  
> -	if (!IS_POSIXACL(path.dentry->d_inode))
> +	if (!IS_ACL(path.dentry->d_inode))
>  		mode &= ~current_umask();
>  	error = security_path_mkdir(&path, dentry, mode);
>  	if (!error)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index dd28814..4ad130c 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1850,6 +1850,12 @@ struct super_operations {
>  #define IS_IMMUTABLE(inode)	((inode)->i_flags & S_IMMUTABLE)
>  #define IS_POSIXACL(inode)	__IS_FLG(inode, MS_POSIXACL)
>  
> +#ifdef CONFIG_FS_RICHACL
> +#define IS_RICHACL(inode)	__IS_FLG(inode, MS_RICHACL)
> +#else
> +#define IS_RICHACL(inode)	0
> +#endif
> +
>  #define IS_DEADDIR(inode)	((inode)->i_flags & S_DEAD)
>  #define IS_NOCMTIME(inode)	((inode)->i_flags & S_NOCMTIME)
>  #define IS_SWAPFILE(inode)	((inode)->i_flags & S_SWAPFILE)
> @@ -1863,6 +1869,12 @@ struct super_operations {
>  				 (inode)->i_rdev == WHITEOUT_DEV)
>  
>  /*
> + * IS_ACL() tells the VFS to not apply the umask
> + * and use check_acl for acl permission checks when defined.
> + */
> +#define IS_ACL(inode)		__IS_FLG(inode, MS_POSIXACL | MS_RICHACL)
> +
> +/*
>   * Inode state bits.  Protected by inode->i_lock
>   *
>   * Three bits determine the dirty state of the inode, I_DIRTY_SYNC,
> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
> index 3b00f7c..f9c41ef 100644
> --- a/include/uapi/linux/fs.h
> +++ b/include/uapi/linux/fs.h
> @@ -120,7 +120,7 @@ struct inodes_stat_t {
>  #define MS_VERBOSE	32768	/* War is peace. Verbosity is silence.
>  				   MS_VERBOSE is deprecated. */
>  #define MS_SILENT	32768
> -#define MS_POSIXACL	(1<<16)	/* VFS does not apply the umask */
> +#define MS_POSIXACL	(1<<16)	/* Supports POSIX ACLs */
>  #define MS_UNBINDABLE	(1<<17)	/* change to unbindable */
>  #define MS_PRIVATE	(1<<18)	/* change to private */
>  #define MS_SLAVE	(1<<19)	/* change to slave */
> @@ -130,6 +130,7 @@ struct inodes_stat_t {
>  #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
>  #define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
>  #define MS_LAZYTIME	(1<<25) /* Update the on-disk [acm]times lazily */
> +#define MS_RICHACL	(1<<26) /* Supports richacls */
>  
>  /* These sb flags are internal to the kernel */
>  #define MS_NOSEC	(1<<28)

Reviewed-by: Jeff Layton <jlayton@redhat.com>
