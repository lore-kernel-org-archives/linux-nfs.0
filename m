Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50054 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856AbaEHRFA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2014 13:05:00 -0400
Date: Thu, 8 May 2014 13:05:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Use simple_read_from_buffer for coping data to
 userspace
Message-ID: <20140508170500.GG20976@fieldses.org>
References: <53438341.5090705@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53438341.5090705@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Tue, Apr 08, 2014 at 01:04:01PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/fault_inject.c | 15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> index d620e7f..2ed05c3 100644
> --- a/fs/nfsd/fault_inject.c
> +++ b/fs/nfsd/fault_inject.c
> @@ -97,25 +97,14 @@ static ssize_t fault_inject_read(struct file *file,
> char __user *buf,
>  {
>  	static u64 val;
>  	char read_buf[25];
> -	size_t size, ret;
> +	size_t size;
>  	loff_t pos = *ppos;
> 
>  	if (!pos)
>  		nfsd_inject_get(file_inode(file)->i_private, &val);
>  	size = scnprintf(read_buf, sizeof(read_buf), "%llu\n", val);
> 
> -	if (pos < 0)
> -		return -EINVAL;
> -	if (pos >= size || !len)
> -		return 0;
> -	if (len > size - pos)
> -		len = size - pos;
> -	ret = copy_to_user(buf, read_buf + pos, len);
> -	if (ret == len)
> -		return -EFAULT;
> -	len -= ret;
> -	*ppos = pos + len;
> -	return len;
> +	return simple_read_from_buffer(buf, len, ppos, read_buf, size);
>  }
> 
>  static ssize_t fault_inject_write(struct file *file, const char __user
> *buf,
> -- 
> 1.9.0
> 
