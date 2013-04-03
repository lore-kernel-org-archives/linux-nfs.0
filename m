Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50149 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932132Ab3DCTc6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 15:32:58 -0400
Date: Wed, 3 Apr 2013 15:32:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org
Subject: Re: [PATCH] SUNRPC/cache: add module_put() on error path in
 cache_open()
Message-ID: <20130403193253.GK6044@fieldses.org>
References: <1363984604-17739-1-git-send-email-khoroshilov@ispras.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1363984604-17739-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Sat, Mar 23, 2013 at 12:36:44AM +0400, Alexey Khoroshilov wrote:
> If kmalloc() fails in cache_open(), module cd->owner left locked.
> The patch adds module_put(cd->owner) on this path.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>  net/sunrpc/cache.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 25d58e76..1d3c514 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -986,8 +986,10 @@ static int cache_open(struct inode *inode, struct file *filp,
>  	nonseekable_open(inode, filp);
>  	if (filp->f_mode & FMODE_READ) {
>  		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
> -		if (!rp)
> +		if (!rp) {
> +			module_put(cd->owner);
>  			return -ENOMEM;
> +		}
>  		rp->offset = 0;
>  		rp->q.reader = 1;
>  		atomic_inc(&cd->readers);
> -- 
> 1.7.9.5
> 
