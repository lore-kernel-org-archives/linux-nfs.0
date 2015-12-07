Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31610 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbbLGAxq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Dec 2015 19:53:46 -0500
Date: Sun, 6 Dec 2015 16:53:31 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Christoph Hellwig <hch@lst.de>
Cc: viro@zeniv.linux.org.uk, tao.peng@primarydata.com,
        jeff.layton@primarydata.com, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 2/4] vfs: pull btrfs clone API to vfs layer
Message-ID: <20151207005331.GA10582@birch.djwong.org>
References: <1449143992-7415-1-git-send-email-hch@lst.de>
 <1449143992-7415-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449143992-7415-3-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 03, 2015 at 12:59:50PM +0100, Christoph Hellwig wrote:
> The btrfs clone ioctls are now adopted by other file systems, with NFS
> and CIFS already having support for them, and XFS being under active
> development.  To avoid growth of various slightly incompatible
> implementations, add one to the VFS.  Note that clones are different from
> file copies in several ways:
> 
>  - they are atomic vs other writers
>  - they support whole file clones
>  - they support 64-bit legth clones
>  - they do not allow partial success (aka short writes)
>  - clones are expected to be a fast metadata operation
> 
> Because of that it would be rather cumbersome to try to piggyback them on
> top of the recent clone_file_range infrastructure.  The converse isn't
> true and the clone_file_range system call could try clone file range as
> a first attempt to copy, something that further patches will enable.
> 
> Based on earlier work from Peng Tao.

<snip>

> diff --git a/fs/read_write.c b/fs/read_write.c
> index 6c1aa73..9e3dd8f 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1451,3 +1451,75 @@ out1:
>  out2:
>  	return ret;
>  }
> +
> +static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
> +{
> +	struct inode *inode = file_inode(file);
> +
> +	if (unlikely(pos < 0))
> +		return -EINVAL;
> +
> +	 if (unlikely((loff_t) (pos + len) < 0))
> +		return -EINVAL;
> +
> +	if (unlikely(inode->i_flctx && mandatory_lock(inode))) {
> +		loff_t end = len ? pos + len - 1 : OFFSET_MAX;
> +		int retval;
> +
> +		retval = locks_mandatory_area(file, pos, end,
> +				write ? F_WRLCK : F_RDLCK);
> +		if (retval < 0)
> +			return retval;
> +	}
> +
> +	return security_file_permission(file, write ? MAY_WRITE : MAY_READ);
> +}
> +
> +int vfs_clone_file_range(struct file *file_in, loff_t pos_in,
> +		struct file *file_out, loff_t pos_out, u64 len)
> +{
> +	struct inode *inode_in = file_inode(file_in);
> +	struct inode *inode_out = file_inode(file_out);
> +	int ret;
> +
> +	if (inode_in->i_sb != inode_out->i_sb ||
> +	    file_in->f_path.mnt != file_out->f_path.mnt)
> +		return -EXDEV;
> +
> +	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
> +		return -EISDIR;
> +	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
> +		return -EOPNOTSUPP;

I thought we were moving to -EINVAL for wrong file types?

Though, perhaps "I've also prepared a btrfs patch for this and clone" from the
earlier thread about generic/157 wasn't referring to /this/ patch. :)

In any case, I'm ok with EINVAL, and I haven't heard any objections to
changing -EOPNOTSUPP -> -EINVAL when trying to reflink/dedupe/whatever
non-file non-dir fds.

<shrug> Anyone object?

--D

> +
> +	if (!(file_in->f_mode & FMODE_READ) ||
> +	    !(file_out->f_mode & FMODE_WRITE) ||
> +	    (file_out->f_flags & O_APPEND) ||
> +	    !file_in->f_op->clone_file_range)
> +		return -EBADF;
> +
> +	ret = clone_verify_area(file_in, pos_in, len, false);
> +	if (ret)
> +		return ret;
> +
> +	ret = clone_verify_area(file_out, pos_out, len, true);
> +	if (ret)
> +		return ret;
> +
> +	if (pos_in + len > i_size_read(inode_in))
> +		return -EINVAL;
> +
> +	ret = mnt_want_write_file(file_out);
> +	if (ret)
> +		return ret;
> +
> +	ret = file_in->f_op->clone_file_range(file_in, pos_in,
> +			file_out, pos_out, len);
> +	if (!ret) {
> +		fsnotify_access(file_in);
> +		fsnotify_modify(file_out);
> +	}
> +
> +	mnt_drop_write_file(file_out);
> +	return ret;
> +}
> +EXPORT_SYMBOL(vfs_clone_file_range);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index af559ac..59bf96d 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1629,7 +1629,10 @@ struct file_operations {
>  #ifndef CONFIG_MMU
>  	unsigned (*mmap_capabilities)(struct file *);
>  #endif
> -	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *, loff_t, size_t, unsigned int);
> +	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *,
> +			loff_t, size_t, unsigned int);
> +	int (*clone_file_range)(struct file *, loff_t, struct file *, loff_t,
> +			u64);
>  };
>  
>  struct inode_operations {
> @@ -1683,6 +1686,8 @@ extern ssize_t vfs_writev(struct file *, const struct iovec __user *,
>  		unsigned long, loff_t *);
>  extern ssize_t vfs_copy_file_range(struct file *, loff_t , struct file *,
>  				   loff_t, size_t, unsigned int);
> +extern int vfs_clone_file_range(struct file *file_in, loff_t pos_in,
> +		struct file *file_out, loff_t pos_out, u64 len);
>  
>  struct super_operations {
>     	struct inode *(*alloc_inode)(struct super_block *sb);
> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
> index f15d980..cd5db7f 100644
> --- a/include/uapi/linux/fs.h
> +++ b/include/uapi/linux/fs.h
> @@ -39,6 +39,13 @@
>  #define RENAME_EXCHANGE		(1 << 1)	/* Exchange source and dest */
>  #define RENAME_WHITEOUT		(1 << 2)	/* Whiteout source */
>  
> +struct file_clone_range {
> +	__s64 src_fd;
> +	__u64 src_offset;
> +	__u64 src_length;
> +	__u64 dest_offset;
> +};
> +
>  struct fstrim_range {
>  	__u64 start;
>  	__u64 len;
> @@ -159,6 +166,8 @@ struct inodes_stat_t {
>  #define FIFREEZE	_IOWR('X', 119, int)	/* Freeze */
>  #define FITHAW		_IOWR('X', 120, int)	/* Thaw */
>  #define FITRIM		_IOWR('X', 121, struct fstrim_range)	/* Trim */
> +#define FICLONE		_IOW(0x94, 9, int)
> +#define FICLONERANGE	_IOW(0x94, 13, struct file_clone_range)
>  
>  #define	FS_IOC_GETFLAGS			_IOR('f', 1, long)
>  #define	FS_IOC_SETFLAGS			_IOW('f', 2, long)
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
