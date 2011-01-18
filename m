From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH] NFS4: Avoid potential NULL pointer dereference in decode_and_add_ds().
Date: Tue, 18 Jan 2011 09:43:22 -0500
Message-ID: <2C44474C-1803-4B94-8140-6DF64A87418F@netapp.com>
References: <alpine.LNX.2.00.1101162145290.13377@swampdragon.chaosbits.net> <4D33B30A.8050507@cn.fujitsu.com> <alpine.LNX.2.00.1101171940480.27021@swampdragon.chaosbits.net>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5887 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab1AROni convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 09:43:38 -0500
In-Reply-To: <alpine.LNX.2.00.1101171940480.27021-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 17, 2011, at 1:41 PM, Jesper Juhl wrote:

> On Mon, 17 Jan 2011, Mi Jinlong wrote:
> 
>> 
>> 
>> Jesper Juhl:
>>> strrchr() can return NULL if nothing is found. If this happens we'll 
>>> dereference a NULL pointer in 
>>> fs/nfs/nfs4filelayoutdev.c::decode_and_add_ds().



Yes - good catch.

-->Andy

>>> 
>>> I tried to find some other code that guarantees that this can never 
>>> happen but I was unsuccessful. So, unless someone else can point to some 
>>> code that ensures this can never be a problem, I believe this patch is 
>>> needed.
>>> 
>>> While I was changing this code I also noticed that all the dprintk() 
>>> statements, except one, start with "%s:". The one missing the ":" I added 
>>> it to.
>> 
>>  Maybe another one also should be changed at decode_and_add_ds() at line 243:
>> 
>>   243  printk("%s Decoded address and port %s\n", __func__, buf);
>> 
> Missed that one. Thanks. 
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
> nfs4filelayoutdev.c |    9 +++++++--
> 1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 51fe64a..f5c9b12 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -214,7 +214,7 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
> 
> 	/* ipv6 length plus port is legal */
> 	if (rlen > INET6_ADDRSTRLEN + 8) {
> -		dprintk("%s Invalid address, length %d\n", __func__,
> +		dprintk("%s: Invalid address, length %d\n", __func__,
> 			rlen);
> 		goto out_err;
> 	}
> @@ -225,6 +225,11 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
> 	/* replace the port dots with dashes for the in4_pton() delimiter*/
> 	for (i = 0; i < 2; i++) {
> 		char *res = strrchr(buf, '.');
> +		if (!res) {
> +			dprintk("%s: Failed finding expected dots in port\n",
> +				__func__);
> +			goto out_free;
> +		}
> 		*res = '-';
> 	}
> 
> @@ -240,7 +245,7 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
> 	port = htons((tmp[0] << 8) | (tmp[1]));
> 
> 	ds = nfs4_pnfs_ds_add(inode, ip_addr, port);
> -	dprintk("%s Decoded address and port %s\n", __func__, buf);
> +	dprintk("%s: Decoded address and port %s\n", __func__, buf);
> out_free:
> 	kfree(buf);
> out_err:
> 
> 
> -- 
> Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

