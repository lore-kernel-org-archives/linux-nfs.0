Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36400 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754252Ab1BDC7r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 21:59:47 -0500
Subject: Re: [PATCH] Ensure user-supplied string null terminated before
 kstrdup()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Rob Landley <rlandley@parallels.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4D4B287E.70206@parallels.com>
References: <4D4B287E.70206@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Feb 2011 21:59:45 -0500
Message-ID: <1296788385.2957.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-03 at 16:13 -0600, Rob Landley wrote: 
> From: Rob Landley <rlandley@parallels.com>
> 
> Make sure user string is null terminated before copying it.
> 
> Signed-off-by: Rob Landley <rlandley@parallels.com>
> ---
> 
>  fs/nfs/super.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index b68c860..0ad1255 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1881,9 +1881,12 @@ static int nfs_validate_mount_data(void *options,
>  
>  		if (!(data->flags & NFS_MOUNT_TCP))
>  			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
> +		/* Force null termination of data->hostname no matter what
> +		   user passed in. */
> +		args->namlen		= data->namlen;
> +		data->namlen = 0;
>  		/* N.B. caller will free nfs_server.hostname in all cases */
>  		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
> -		args->namlen		= data->namlen;
>  		args->bsize		= data->bsize;
>  
>  		if (data->flags & NFS_MOUNT_SECFLAVOUR)

The "namlen" mount option bears absolutely no relation to the server
hostname AFAIK. I can't see how this patch makes sense...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

