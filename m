Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:34807 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964795Ab2EONsi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 09:48:38 -0400
Message-ID: <4FB25EA7.9050702@panasas.com>
Date: Tue, 15 May 2012 16:48:23 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
Subject: Re: [patch] NFS: kmalloc() doesn't return an ERR_PTR()
References: <20120514194528.GA19613@elgon.mountain>
In-Reply-To: <20120514194528.GA19613@elgon.mountain>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/14/2012 10:45 PM, Dan Carpenter wrote:

> Obviously we should check for NULL here instead of IS_ERR().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index ba3019f..233beea 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -644,14 +644,14 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
>  
>  	/* msg and im are freed in idmap_pipe_destroy_msg */
>  	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
> -	if (IS_ERR(msg)) {
> -		ret = PTR_ERR(msg);
> +	if (!msg) {


While at it please put an unlikely()

Thanks
Boaz

> +		ret = -ENOMEM;
>  		goto out0;
>  	}
>  
>  	im = kmalloc(sizeof(*im), GFP_KERNEL);
> -	if (IS_ERR(im)) {
> -		ret = PTR_ERR(im);
> +	if (!im) {
> +		ret = -ENOMEM;
>  		goto out1;
>  	}
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


