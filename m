Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:34863 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdF0Lrq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jun 2017 07:47:46 -0400
Received: by mail-qk0-f170.google.com with SMTP id 16so22621379qkg.2
        for <linux-nfs@vger.kernel.org>; Tue, 27 Jun 2017 04:47:45 -0700 (PDT)
Message-ID: <1498564063.4539.5.camel@redhat.com>
Subject: Re: [PATCH 1/1] VFS permit cross device vfs_copy_file_range
From: Jeff Layton <jlayton@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 27 Jun 2017 07:47:43 -0400
In-Reply-To: <20170626144943.86070-1-kolga@netapp.com>
References: <CAN-5tyG-2=Y26oG91H-Htymda2K=bGVrMuRR8EvB1vs1KLi3Zw@mail.gmail.com>
         <20170626144943.86070-1-kolga@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-06-26 at 10:49 -0400, Olga Kornievskaia wrote:
> Allow copy_file_range to copy between different superblocks but only
> of the same file system types.
> 
> This feature is needed by NFSv4.2 to perform file copy operation on
> the same server or file copy between different NFSv4.2 servers.
> 
> If a file system's fileoperations copy_file_range operation prohibits
> cross-device copies, fall back to do_splice_direct. This is needed for
> the NFS (destination) server side implementation of the file copy.
> 
> Currently there is only 1 implementor of the copy_file_range FS
> operation -- CIFS. CIFS assumes incoming file descriptors are both
> CIFS but it will check if they are coming from different servers.
> 
> NFS will allow for copies between different NFS servers.
> 
> Adding to the vfs.txt documentation to explicitly warn about allowing
> for different superblocks of the same file type to be passed into the
> copy_file_range for the future users of copy_file_range method.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  Documentation/filesystems/vfs.txt |  7 +++++++
>  fs/read_write.c                   | 12 +++++-------
>  2 files changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> index f42b906..cf22424 100644
> --- a/Documentation/filesystems/vfs.txt
> +++ b/Documentation/filesystems/vfs.txt
> @@ -845,6 +845,8 @@ struct file_operations {
>  #ifndef CONFIG_MMU
>  	unsigned (*mmap_capabilities)(struct file *);
>  #endif
> +	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *,
> +				   loff_t, size_t, unsigned int);
>  };
>  
>  Again, all methods are called without any locks being held, unless
> @@ -913,6 +915,11 @@ otherwise noted.
>  
>    fallocate: called by the VFS to preallocate blocks or punch a hole.
>  
> +  copy_file_range: called by copy_file_range(2) system call. This method
> +		   works on two file descriptors that might reside on
> +		   different superblocks of the same type of file system.
> +		   
> +
>  Note that the file operations are implemented by the specific
>  filesystem in which the inode resides. When opening a device node
>  (character or block special) most filesystems will call special
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 47c1d44..effbfb2 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1589,10 +1589,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	    (file_out->f_flags & O_APPEND))
>  		return -EBADF;
>  
> -	/* this could be relaxed once a method supports cross-fs copies */
> -	if (inode_in->i_sb != inode_out->i_sb)
> -		return -EXDEV;
> -
>  	if (len == 0)
>  		return 0;
>  
> @@ -1602,7 +1598,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	 * Try cloning first, this is supported by more file systems, and
>  	 * more efficient if both clone and copy are supported (e.g. NFS).
>  	 */
> -	if (file_in->f_op->clone_file_range) {
> +	if (inode_in->i_sb == inode_out->i_sb &&
> +			file_in->f_op->clone_file_range) {

I do wonder if we really ought to check for the same superblock here.

ISTM that it might be possible for some fs' (btrfs?) to clone blocks
across superblocks in some situations?

Oh well -- I guess we can cross that bridge when we come to it.

>  		ret = file_in->f_op->clone_file_range(file_in, pos_in,
>  				file_out, pos_out, len);
>  		if (ret == 0) {
> @@ -1611,10 +1608,11 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  		}
>  	}
>  
> -	if (file_out->f_op->copy_file_range) {
> +	if (file_out->f_op->copy_file_range &&
> +			(file_in->f_op == file_out->f_op)) {

It's possible that they might not have the same f_op pointer, but have
the same copy_file_range operation (e.g. cifs.ko has a bunch of
different f_op structures for different cases, so they might not be the
same even though they have the same copy_file_range op).

Maybe this should be:

    file_in->f_op->copy_file_range == file_out->f_op->copy_file_range

?

>  		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
>  						      pos_out, len, flags);
> -		if (ret != -EOPNOTSUPP)
> +		if (ret != -EOPNOTSUPP && ret != -EXDEV)
>  			goto done;
>  	}
>  

-- 
Jeff Layton <jlayton@redhat.com>
