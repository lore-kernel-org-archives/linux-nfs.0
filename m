From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs41: Free layoutcommit_data when error occurs in setup
Date: Fri, 07 May 2010 00:16:17 +0300
Message-ID: <4BE331A1.9000802@panasas.com>
References: <20100506071656.GA2746@MDS-78.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63666 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819Ab0EFVQX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 17:16:23 -0400
Received: by wyg36 with SMTP id 36so354046wyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 May 2010 14:16:22 -0700 (PDT)
In-Reply-To: <20100506071656.GA2746-nK6E9TRyOkVSq9BJjBFyUp/QNRX+jHPU@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 06, 2010, 10:18 +0300, Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org> wrote:
> When layout driver cannot setup layoutcommit_data, we should free
> layoutcommit_data data structure before we return.
> 
> Signed-off-by: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>

Committed to pnfs-submit and pnfs-all-2.6.33. Thanks!

Benny

> ---
>  fs/nfs/pnfs.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index e17efcc..1018bc6 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2226,10 +2226,8 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>  		return -ENOMEM;
>  
>  	spin_lock(&nfsi->lo_lock);
> -	if (!nfsi->layoutcommit_ctx) {
> -		pnfs_layoutcommit_free(data);
> +	if (!nfsi->layoutcommit_ctx)
>  		goto out_unlock;
> -	}
>  
>  	data->args.inode = inode;
>  	data->cred  = nfsi->layoutcommit_ctx->cred;
> @@ -2256,6 +2254,7 @@ out:
>  	dprintk("%s end (err:%d)\n", __func__, status);
>  	return status;
>  out_unlock:
> +	pnfs_layoutcommit_free(data);
>  	spin_unlock(&nfsi->lo_lock);
>  	goto out;
>  }
