Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34922 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbbHMNEA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Aug 2015 09:04:00 -0400
Received: by pdrg1 with SMTP id g1so19386223pdr.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2015 06:04:00 -0700 (PDT)
Subject: Re: [PATCH 4/7] VFS: Fall back on splice if no copy function defined
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, kinglongmee@gmail.com
References: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1438979904-8775-5-git-send-email-Anna.Schumaker@Netapp.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55CC95B1.3040502@gmail.com>
Date: Thu, 13 Aug 2015 21:03:45 +0800
MIME-Version: 1.0
In-Reply-To: <1438979904-8775-5-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/8/2015 04:38, Anna Schumaker wrote:
> The NFS server will need a fallback for filesystems that don't have any
> kind of copy acceleration yet.  Let's handle this by having
> vfs_copy_range() fall back to splice, enabling an in-kernel fallback for
> all filesystems.

I'd like do the job in nfsd_copy_range().

If user only want call the underlay filesystem's copy_file_range()?
want get an error if not support. But, this patch lets the syscall
to another logical of calling do_splice_direct().

thanks,
Kinglong Mee

> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  fs/read_write.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 3804547..e564a6b 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1358,7 +1358,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	if (!(file_in->f_mode & FMODE_READ) ||
>  	    !(file_out->f_mode & FMODE_WRITE) ||
>  	    (file_out->f_flags & O_APPEND) ||
> -	    !file_in->f_op || !file_in->f_op->copy_file_range)
> +	    !file_in->f_op)
>  		return -EINVAL;
>  
>  	inode_in = file_inode(file_in);
> @@ -1382,8 +1382,12 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	if (ret)
>  		return ret;
>  
> -	ret = file_in->f_op->copy_file_range(file_in, pos_in, file_out, pos_out,
> -					     len, flags);
> +	ret = -ENOTSUPP;
> +	if (file_in->f_op->copy_file_range)
> +		ret = file_in->f_op->copy_file_range(file_in, pos_in, file_out,
> +						     pos_out, len, flags);
> +	if (ret == -ENOTSUPP)
> +		ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out, len, flags);
>  	if (ret > 0) {
>  		fsnotify_access(file_in);
>  		add_rchar(current, ret);
> 
