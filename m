Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39518 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755924AbaAFVbJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 16:31:09 -0500
Date: Mon, 6 Jan 2014 16:31:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rui Xiang <rui.xiang@huawei.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RESEND] nfsd: return err directly while allocing failing
Message-ID: <20140106213108.GH31764@fieldses.org>
References: <52A52B08.9040305@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52A52B08.9040305@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 09, 2013 at 10:29:28AM +0800, Rui Xiang wrote:
> while nthreads alloc fails, return err value directly
> without kfree.

This doesn't fix any problem that I can see, since kfree(NULL) is
defined to be a no-op.

--b.

> 
> Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
> ---
>  fs/nfsd/nfsctl.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 7f55517..1fa6b00 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -491,9 +491,10 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
>  	}
>  
>  	nthreads = kcalloc(npools, sizeof(int), GFP_KERNEL);
> -	rv = -ENOMEM;
> -	if (nthreads == NULL)
> -		goto out_free;
> +	if (nthreads == NULL) {
> +		mutex_unlock(&nfsd_mutex);
> +		return -ENOMEM;
> +	}
>  
>  	if (size > 0) {
>  		for (i = 0; i < npools; i++) {
> -- 
> 1.8.2.2
> 
> 
