Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:2551 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751263AbbI3DWN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Sep 2015 23:22:13 -0400
From: Zhao Lei <zhaolei@cn.fujitsu.com>
To: "'Anna Schumaker'" <Anna.Schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
References: <1443549913-8091-1-git-send-email-Anna.Schumaker@Netapp.com> <1443549913-8091-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1443549913-8091-4-git-send-email-Anna.Schumaker@Netapp.com>
Subject: RE: [PATCH v4 3/9] btrfs: add .copy_file_range file operation
Date: Wed, 30 Sep 2015 11:20:59 +0800
Message-ID: <00cc01d0fb2f$079ae210$16d0a630$@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Anna Schumaker

> -----Original Message-----
> From: linux-btrfs-owner@vger.kernel.org
> [mailto:linux-btrfs-owner@vger.kernel.org] On Behalf Of Anna Schumaker
> Sent: Wednesday, September 30, 2015 2:05 AM
> To: linux-nfs@vger.kernel.org; linux-btrfs@vger.kernel.org;
> linux-fsdevel@vger.kernel.org; linux-api@vger.kernel.org; zab@zabbo.net;
> viro@zeniv.linux.org.uk; clm@fb.com; darrick.wong@oracle.com;
> mtk.manpages@gmail.com; andros@netapp.com; hch@infradead.org
> Subject: [PATCH v4 3/9] btrfs: add .copy_file_range file operation
> 
> From: Zach Brown <zab@redhat.com>
> 
> This rearranges the existing COPY_RANGE ioctl implementation so that
> the .copy_file_range file operation can call the core loop that copies file data
> extent items.
> 
> The extent copying loop is lifted up into its own function.  It retains the core
> btrfs error checks that should be shared.
> 
> Signed-off-by: Zach Brown <zab@redhat.com>
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> Reviewed-by: Josef Bacik <jbacik@fb.com>
> Reviewed-by: David Sterba <dsterba@suse.com>
> ---
>  fs/btrfs/ctree.h |  3 ++
>  fs/btrfs/file.c  |  1 +
>  fs/btrfs/ioctl.c | 91 ++++++++++++++++++++++++++++++++------------------------
>  3 files changed, 56 insertions(+), 39 deletions(-)
> 
> diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h index 938efe3..5d06a4f 100644
> --- a/fs/btrfs/ctree.h
> +++ b/fs/btrfs/ctree.h
> @@ -3996,6 +3996,9 @@ int btrfs_dirty_pages(struct btrfs_root *root, struct
> inode *inode,
>  		      loff_t pos, size_t write_bytes,
>  		      struct extent_state **cached);
>  int btrfs_fdatawrite_range(struct inode *inode, loff_t start, loff_t end);
> +ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
> +			      struct file *file_out, loff_t pos_out,
> +			      size_t len, int flags);
> 

It is different with declaration:
ssize_t (*copy_file_range)(struct file *, loff_t, struct file *, loff_t, size_t, unsigned int);

(flags changed from unsigned int to int)

>  /* tree-defrag.c */
>  int btrfs_defrag_leaves(struct btrfs_trans_handle *trans, diff --git
> a/fs/btrfs/file.c b/fs/btrfs/file.c index b823fac..b05449c 100644
> --- a/fs/btrfs/file.c
> +++ b/fs/btrfs/file.c
> @@ -2816,6 +2816,7 @@ const struct file_operations btrfs_file_operations =
> {  #ifdef CONFIG_COMPAT
>  	.compat_ioctl	= btrfs_ioctl,
>  #endif
> +	.copy_file_range = btrfs_copy_file_range,

And cause compiler warning at this line:
fs/btrfs/file.c:2819: warning: initialization from incompatible pointer type   

Small problem, but better to fix.

Thanks
Zhaolei

>  };
> 
>  void btrfs_auto_defrag_exit(void)
> diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c index 0adf542..4311554 100644
> --- a/fs/btrfs/ioctl.c
> +++ b/fs/btrfs/ioctl.c
> @@ -3727,17 +3727,16 @@ out:
>  	return ret;
>  }
> 
> -static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
> -				       u64 off, u64 olen, u64 destoff)
> +static noinline int btrfs_clone_files(struct file *file, struct file *file_src,
> +					u64 off, u64 olen, u64 destoff)
>  {
>  	struct inode *inode = file_inode(file);
> +	struct inode *src = file_inode(file_src);
>  	struct btrfs_root *root = BTRFS_I(inode)->root;
> -	struct fd src_file;
> -	struct inode *src;
>  	int ret;
>  	u64 len = olen;
>  	u64 bs = root->fs_info->sb->s_blocksize;
> -	int same_inode = 0;
> +	int same_inode = src == inode;
> 
>  	/*
>  	 * TODO:
> @@ -3750,49 +3749,20 @@ static noinline long btrfs_ioctl_clone(struct file
> *file, unsigned long srcfd,
>  	 *   be either compressed or non-compressed.
>  	 */
> 
> -	/* the destination must be opened for writing */
> -	if (!(file->f_mode & FMODE_WRITE) || (file->f_flags & O_APPEND))
> -		return -EINVAL;
> -
>  	if (btrfs_root_readonly(root))
>  		return -EROFS;
> 
> -	ret = mnt_want_write_file(file);
> -	if (ret)
> -		return ret;
> -
> -	src_file = fdget(srcfd);
> -	if (!src_file.file) {
> -		ret = -EBADF;
> -		goto out_drop_write;
> -	}
> -
> -	ret = -EXDEV;
> -	if (src_file.file->f_path.mnt != file->f_path.mnt)
> -		goto out_fput;
> -
> -	src = file_inode(src_file.file);
> -
> -	ret = -EINVAL;
> -	if (src == inode)
> -		same_inode = 1;
> -
> -	/* the src must be open for reading */
> -	if (!(src_file.file->f_mode & FMODE_READ))
> -		goto out_fput;
> +	if (file_src->f_path.mnt != file->f_path.mnt ||
> +	    src->i_sb != inode->i_sb)
> +		return -EXDEV;
> 
>  	/* don't make the dst file partly checksummed */
>  	if ((BTRFS_I(src)->flags & BTRFS_INODE_NODATASUM) !=
>  	    (BTRFS_I(inode)->flags & BTRFS_INODE_NODATASUM))
> -		goto out_fput;
> +		return -EINVAL;
> 
> -	ret = -EISDIR;
>  	if (S_ISDIR(src->i_mode) || S_ISDIR(inode->i_mode))
> -		goto out_fput;
> -
> -	ret = -EXDEV;
> -	if (src->i_sb != inode->i_sb)
> -		goto out_fput;
> +		return -EISDIR;
> 
>  	if (!same_inode) {
>  		btrfs_double_inode_lock(src, inode);
> @@ -3869,6 +3839,49 @@ out_unlock:
>  		btrfs_double_inode_unlock(src, inode);
>  	else
>  		mutex_unlock(&src->i_mutex);
> +	return ret;
> +}
> +
> +ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
> +			      struct file *file_out, loff_t pos_out,
> +			      size_t len, int flags)
> +{
> +	ssize_t ret;
> +
> +	ret = btrfs_clone_files(file_out, file_in, pos_in, len, pos_out);
> +	if (ret == 0)
> +		ret = len;
> +	return ret;
> +}
> +
> +static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
> +				       u64 off, u64 olen, u64 destoff) {
> +	struct fd src_file;
> +	int ret;
> +
> +	/* the destination must be opened for writing */
> +	if (!(file->f_mode & FMODE_WRITE) || (file->f_flags & O_APPEND))
> +		return -EINVAL;
> +
> +	ret = mnt_want_write_file(file);
> +	if (ret)
> +		return ret;
> +
> +	src_file = fdget(srcfd);
> +	if (!src_file.file) {
> +		ret = -EBADF;
> +		goto out_drop_write;
> +	}
> +
> +	/* the src must be open for reading */
> +	if (!(src_file.file->f_mode & FMODE_READ)) {
> +		ret = -EINVAL;
> +		goto out_fput;
> +	}
> +
> +	ret = btrfs_clone_files(file, src_file.file, off, olen, destoff);
> +
>  out_fput:
>  	fdput(src_file);
>  out_drop_write:
> --
> 2.5.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-btrfs" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

