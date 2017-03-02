Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46652 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752495AbdCBQ7N (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Mar 2017 11:59:13 -0500
Date: Thu, 2 Mar 2017 08:58:39 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 1/3] fs: Don't copy beyond the end of the file
Message-ID: <20170302165839.GC5269@birch.djwong.org>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-2-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170302160211.30451-2-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 02, 2017 at 11:02:09AM -0500, Olga Kornievskaia wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  fs/read_write.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 5816d4c..1d9e305 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1526,6 +1526,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	if (unlikely(ret))
>  		return ret;
>  
> +	if (pos_in >= i_size_read(inode_in))
> +		return -EINVAL;
> +

This ought to go in vfs_clone_file_prep_inodes.

(He says, noticing that btrfs never got updated to use that validator...)

--D

>  	if (!(file_in->f_mode & FMODE_READ) ||
>  	    !(file_out->f_mode & FMODE_WRITE) ||
>  	    (file_out->f_flags & O_APPEND))
> -- 
> 1.8.3.1
> 
