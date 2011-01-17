Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53685 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751479Ab1AQDGr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Jan 2011 22:06:47 -0500
Message-ID: <4D33B30A.8050507@cn.fujitsu.com>
Date: Mon, 17 Jan 2011 11:10:02 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Jesper Juhl <jj@chaosbits.net>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFS4: Avoid potential NULL pointer dereference in decode_and_add_ds().
References: <alpine.LNX.2.00.1101162145290.13377@swampdragon.chaosbits.net>
In-Reply-To: <alpine.LNX.2.00.1101162145290.13377@swampdragon.chaosbits.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Jesper Juhl:
> strrchr() can return NULL if nothing is found. If this happens we'll 
> dereference a NULL pointer in 
> fs/nfs/nfs4filelayoutdev.c::decode_and_add_ds().
> 
> I tried to find some other code that guarantees that this can never 
> happen but I was unsuccessful. So, unless someone else can point to some 
> code that ensures this can never be a problem, I believe this patch is 
> needed.
> 
> While I was changing this code I also noticed that all the dprintk() 
> statements, except one, start with "%s:". The one missing the ":" I added 
> it to.

  Maybe another one also should be changed at decode_and_add_ds() at line 243:

   243  printk("%s Decoded address and port %s\n", __func__, buf);

-- 
----
thanks
Mi Jinlong

> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  nfs4filelayoutdev.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
>   only compile tested.
> 
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 51fe64a..5a85b8f 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -214,7 +214,7 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
>  
>  	/* ipv6 length plus port is legal */
>  	if (rlen > INET6_ADDRSTRLEN + 8) {
> -		dprintk("%s Invalid address, length %d\n", __func__,
> +		dprintk("%s: Invalid address, length %d\n", __func__,
>  			rlen);
>  		goto out_err;
>  	}
> @@ -225,6 +225,11 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
>  	/* replace the port dots with dashes for the in4_pton() delimiter*/
>  	for (i = 0; i < 2; i++) {
>  		char *res = strrchr(buf, '.');
> +		if (!res) {
> +			dprintk("%s: Failed finding expected dots in port\n",
> +				__func__);
> +			goto out_free;
> +		}
>  		*res = '-';
>  	}
>  
> 

