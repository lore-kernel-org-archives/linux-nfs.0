Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19582 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756499AbbI1Sc6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 14:32:58 -0400
Date: Mon, 28 Sep 2015 11:31:52 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        mtk.manpages@gmail.com, andros@netapp.com, hch@infradead.org
Subject: Re: [PATCH v3 8/9] vfs: copy_file_range() can do a pagecache copy
 with splice
Message-ID: <20150928183152.GB850@birch.djwong.org>
References: <1443214096-12769-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443214096-12769-9-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443214096-12769-9-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 25, 2015 at 04:48:14PM -0400, Anna Schumaker wrote:
> The NFS server will need some kind offallback for filesystems that don't

"some kind of fallback"

> have any kind of copy acceleration, and it should be generally useful to
> have an in-kernel copy to avoid lots of switches between kernel and user
> space.
> 
> I make this configurable by adding two new flags.  Users who only want a
> reflink can pass COPY_FR_REFLINK, and users who want a full data copy can
> pass COPY_FR_COPY.  The default (flags=0) means to first attempt a
> reflink, but use the pagecache if that fails.

"The COPY_FR_DEDUPE flag makes a reflink, but only if the contents of both
file ranges are identical."

> I moved the rw_verify_area() calls into the fallback code since some
> filesystems can handle reflinking a large range.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
> v3:
> - Check that both filesystems have the same filesystem type
> - Add COPY_FR_DEDUPE flag for Darrick
> - Check that at most one flag is set at a time
> ---
>  fs/read_write.c           | 61 +++++++++++++++++++++++++++++++----------------
>  include/linux/copy.h      |  6 +++++
>  include/uapi/linux/Kbuild |  1 +
>  include/uapi/linux/copy.h |  8 +++++++
>  4 files changed, 56 insertions(+), 20 deletions(-)
>  create mode 100644 include/linux/copy.h
>  create mode 100644 include/uapi/linux/copy.h
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index ee9fa37..a0fd9dc 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -7,6 +7,7 @@
>  #include <linux/slab.h> 
>  #include <linux/stat.h>
>  #include <linux/fcntl.h>
> +#include <linux/copy.h>
>  #include <linux/file.h>
>  #include <linux/uio.h>
>  #include <linux/fsnotify.h>
> @@ -1329,6 +1330,29 @@ COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
>  }
>  #endif
>  
> +static ssize_t vfs_copy_file_pagecache(struct file *file_in, loff_t pos_in,
> +				       struct file *file_out, loff_t pos_out,
> +				       size_t len)
> +{
> +	ssize_t ret;
> +
> +	ret = rw_verify_area(READ, file_in, &pos_in, len);
> +	if (ret >= 0) {
> +		len = ret;
> +		ret = rw_verify_area(WRITE, file_out, &pos_out, len);
> +		if (ret >= 0)
> +			len = ret;
> +	}
> +	if (ret < 0)
> +		return ret;
> +
> +	file_start_write(file_out);
> +	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out, len, 0);
> +	file_end_write(file_out);
> +
> +	return ret;
> +}
> +
>  /*
>   * copy_file_range() differs from regular file read and write in that it
>   * specifically allows return partial success.  When it does so is up to
> @@ -1338,34 +1362,26 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  			    struct file *file_out, loff_t pos_out,
>  			    size_t len, unsigned int flags)
>  {
> -	struct inode *inode_in;
> -	struct inode *inode_out;
>  	ssize_t ret;
>  
> -	if (flags)
> +	/* Flags should only be used exclusively. */
> +	if ((flags & COPY_FR_COPY) && (flags & ~COPY_FR_COPY))
>  		return -EINVAL;
> +	if ((flags & COPY_FR_REFLINK) && (flags & ~COPY_FR_REFLINK))
> +		return -EINVAL;
> +	if (flags & COPY_FR_DEDUPE)
> +		return -EOPNOTSUPP;

Since dedupe can't be combined with copy or reflink either, we might as well
say:

if ((flags & COPY_FR_DEDUPE) && (flags & ~COPY_FR_DEDUPE))
	return -EINVAL;

and let the per-fs copy_file_range()s dispatch appropriately.

Otherwise, you can add:
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

>  
> -	/* copy_file_range allows full ssize_t len, ignoring MAX_RW_COUNT  */
> -	ret = rw_verify_area(READ, file_in, &pos_in, len);
> -	if (ret >= 0)
> -		ret = rw_verify_area(WRITE, file_out, &pos_out, len);
> -	if (ret < 0)
> -		return ret;
> +	/* Default behavior is to try both. */
> +	if (flags == 0)
> +		flags = COPY_FR_COPY | COPY_FR_REFLINK;
>  
>  	if (!(file_in->f_mode & FMODE_READ) ||
>  	    !(file_out->f_mode & FMODE_WRITE) ||
>  	    (file_out->f_flags & O_APPEND) ||
> -	    !file_out->f_op || !file_out->f_op->copy_file_range)
> +	    !file_out->f_op)
>  		return -EBADF;
>  
> -	inode_in = file_inode(file_in);
> -	inode_out = file_inode(file_out);
> -
> -	/* make sure offsets don't wrap and the input is inside i_size */
> -	if (pos_in + len < pos_in || pos_out + len < pos_out ||
> -	    pos_in + len > i_size_read(inode_in))
> -		return -EINVAL;
> -
>  	if (len == 0)
>  		return 0;
>  
> @@ -1373,8 +1389,13 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	if (ret)
>  		return ret;
>  
> -	ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out, pos_out,
> -					      len, flags);
> +	ret = -EOPNOTSUPP;
> +	if (file_out->f_op->copy_file_range && (file_in->f_op == file_out->f_op))
> +		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
> +						      pos_out, len, flags);
> +	if ((ret < 0) && (flags & COPY_FR_COPY))
> +		ret = vfs_copy_file_pagecache(file_in, pos_in, file_out,
> +					      pos_out, len);
>  	if (ret > 0) {
>  		fsnotify_access(file_in);
>  		add_rchar(current, ret);
> diff --git a/include/linux/copy.h b/include/linux/copy.h
> new file mode 100644
> index 0000000..fd54543
> --- /dev/null
> +++ b/include/linux/copy.h
> @@ -0,0 +1,6 @@
> +#ifndef _LINUX_COPY_H
> +#define _LINUX_COPY_H
> +
> +#include <uapi/linux/copy.h>
> +
> +#endif /* _LINUX_COPY_H */
> diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
> index f7b2db4..faafd67 100644
> --- a/include/uapi/linux/Kbuild
> +++ b/include/uapi/linux/Kbuild
> @@ -90,6 +90,7 @@ header-y += coda_psdev.h
>  header-y += coff.h
>  header-y += connector.h
>  header-y += const.h
> +header-y += copy.h
>  header-y += cramfs_fs.h
>  header-y += cuda.h
>  header-y += cyclades.h
> diff --git a/include/uapi/linux/copy.h b/include/uapi/linux/copy.h
> new file mode 100644
> index 0000000..6225838
> --- /dev/null
> +++ b/include/uapi/linux/copy.h
> @@ -0,0 +1,8 @@
> +#ifndef _UAPI_LINUX_COPY_H
> +#define _UAPI_LINUX_COPY_H
> +
> +#define COPY_FR_COPY		(1 << 0)  /* Only do a pagecache copy.  */
> +#define COPY_FR_REFLINK		(1 << 1)  /* Only make a reflink.       */
> +#define COPY_FR_DEDUPE		(1 << 2)  /* Deduplicate file data.     */
> +
> +#endif /* _UAPI_LINUX_COPY_H */
> -- 
> 2.5.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
