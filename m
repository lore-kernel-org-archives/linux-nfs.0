Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32801 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932754AbdGKSjc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jul 2017 14:39:32 -0400
Received: by mail-io0-f193.google.com with SMTP id z62so61095ioi.0
        for <linux-nfs@vger.kernel.org>; Tue, 11 Jul 2017 11:39:31 -0700 (PDT)
Subject: Re: [RFC v3 01/42] fs: Don't copy beyond the end of the file
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-2-kolga@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <e32f9ac3-afa3-d96f-eb80-6a18266f143f@gmail.com>
Date: Tue, 11 Jul 2017 14:39:29 -0400
MIME-Version: 1.0
In-Reply-To: <20170711164416.1982-2-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Would it make sense to submit this patch to the VFS in the same series as the cross mountpoint patch, that way they both go in at once?  This one should really be able to go in now, rather than waiting for the rest of the series.

Thanks,
Anna

> ---
>  fs/read_write.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 19d4d88..cc2618b 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1584,6 +1584,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	if (unlikely(ret))
>  		return ret;
>  
> +	if (pos_in >= i_size_read(inode_in))
> +		return -EINVAL;
> +
>  	if (!(file_in->f_mode & FMODE_READ) ||
>  	    !(file_out->f_mode & FMODE_WRITE) ||
>  	    (file_out->f_flags & O_APPEND))
> 
