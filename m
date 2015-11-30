Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46885 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752648AbbK3Wic (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2015 17:38:32 -0500
Date: Mon, 30 Nov 2015 17:38:30 -0500
To: Christoph Hellwig <hch@lst.de>
Cc: viro@zeniv.linux.org.uk, tao.peng@primarydata.com,
        jeff.layton@primarydata.com, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 2/5] locks: new locks_mandatory_area calling convention
Message-ID: <20151130223830.GB31564@fieldses.org>
References: <1448563859-21922-1-git-send-email-hch@lst.de>
 <1448563859-21922-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1448563859-21922-3-git-send-email-hch@lst.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 26, 2015 at 07:50:56PM +0100, Christoph Hellwig wrote:
> Pass a loff_t end for the last byte instead of the 32-bit count
> parameter to allow full file clones even on 32-bit architectures.
> While we're at it also drop the pointless inode argument and simplify
> the read/write selection.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/locks.c         | 22 +++++++++-------------
>  fs/read_write.c    |  5 ++---
>  include/linux/fs.h | 28 +++++++++++++---------------
>  3 files changed, 24 insertions(+), 31 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 0d2b326..d503669 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1227,21 +1227,17 @@ int locks_mandatory_locked(struct file *file)
>  
>  /**
>   * locks_mandatory_area - Check for a conflicting lock
> - * @read_write: %FLOCK_VERIFY_WRITE for exclusive access, %FLOCK_VERIFY_READ
> - *		for shared
> - * @inode:      the file to check
>   * @filp:       how the file was opened (if it was)
> - * @offset:     start of area to check
> - * @count:      length of area to check
> + * @start:	first byte in the file to check
> + * @end:	lastbyte in the file to check
> + * @write:	%true if checking for write access
>   *
>   * Searches the inode's list of locks to find any POSIX locks which conflict.
> - * This function is called from rw_verify_area() and
> - * locks_verify_truncate().
>   */
> -int locks_mandatory_area(int read_write, struct inode *inode,
> -			 struct file *filp, loff_t offset,
> -			 size_t count)
> +int locks_mandatory_area(struct file *filp, loff_t start, loff_t end,
> +		bool write)
>  {
> +	struct inode *inode = file_inode(filp);
>  	struct file_lock fl;
>  	int error;
>  	bool sleep = false;
> @@ -1252,9 +1248,9 @@ int locks_mandatory_area(int read_write, struct inode *inode,
>  	fl.fl_flags = FL_POSIX | FL_ACCESS;
>  	if (filp && !(filp->f_flags & O_NONBLOCK))
>  		sleep = true;
> -	fl.fl_type = (read_write == FLOCK_VERIFY_WRITE) ? F_WRLCK : F_RDLCK;
> -	fl.fl_start = offset;
> -	fl.fl_end = offset + count - 1;
> +	fl.fl_type = write ? F_WRLCK : F_RDLCK;
> +	fl.fl_start = start;
> +	fl.fl_end = end;
>  
>  	for (;;) {
>  		if (filp) {
> diff --git a/fs/read_write.c b/fs/read_write.c
> index c81ef39..48157dd 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -396,9 +396,8 @@ int rw_verify_area(int read_write, struct file *file, const loff_t *ppos, size_t
>  	}
>  
>  	if (unlikely(inode->i_flctx && mandatory_lock(inode))) {
> -		retval = locks_mandatory_area(
> -			read_write == READ ? FLOCK_VERIFY_READ : FLOCK_VERIFY_WRITE,
> -			inode, file, pos, count);
> +		retval = locks_mandatory_area(file, pos, pos + count - 1,
> +				read_write == READ ? false : true);
>  		if (retval < 0)
>  			return retval;
>  	}
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 870a76e..e640f791 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2030,12 +2030,9 @@ extern struct kobject *fs_kobj;
>  
>  #define MAX_RW_COUNT (INT_MAX & PAGE_CACHE_MASK)
>  
> -#define FLOCK_VERIFY_READ  1
> -#define FLOCK_VERIFY_WRITE 2
> -
>  #ifdef CONFIG_FILE_LOCKING
>  extern int locks_mandatory_locked(struct file *);
> -extern int locks_mandatory_area(int, struct inode *, struct file *, loff_t, size_t);
> +extern int locks_mandatory_area(struct file *, loff_t, loff_t, bool);
>  
>  /*
>   * Candidates for mandatory locking have the setgid bit set
> @@ -2068,14 +2065,16 @@ static inline int locks_verify_truncate(struct inode *inode,
>  				    struct file *filp,
>  				    loff_t size)
>  {
> -	if (inode->i_flctx && mandatory_lock(inode))
> -		return locks_mandatory_area(
> -			FLOCK_VERIFY_WRITE, inode, filp,
> -			size < inode->i_size ? size : inode->i_size,
> -			(size < inode->i_size ? inode->i_size - size
> -			 : size - inode->i_size)
> -		);
> -	return 0;
> +	if (!inode->i_flctx || !mandatory_lock(inode))
> +		return 0;
> +
> +	if (size < inode->i_size) {
> +		return locks_mandatory_area(filp, size, inode->i_size - 1,
> +				true);
> +	} else {
> +		return locks_mandatory_area(filp, inode->i_size, size - 1,
> +				true);

I feel like these callers would be just slightly more self-documenting
if that last parameter was F_WRLCK instead of true.

But I could live with it either way, patch looks like an
improvement--ACK.

--b.

> +	}
>  }
>  
>  static inline int break_lease(struct inode *inode, unsigned int mode)
> @@ -2144,9 +2143,8 @@ static inline int locks_mandatory_locked(struct file *file)
>  	return 0;
>  }
>  
> -static inline int locks_mandatory_area(int rw, struct inode *inode,
> -				       struct file *filp, loff_t offset,
> -				       size_t count)
> +static inline int locks_mandatory_area(struct file *filp, loff_t start,
> +		loff_t end, bool write)
>  {
>  	return 0;
>  }
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
