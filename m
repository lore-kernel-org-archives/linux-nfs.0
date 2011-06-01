Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25079 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757315Ab1FANw0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 09:52:26 -0400
Message-ID: <4DE64416.2050005@panasas.com>
Date: Wed, 01 Jun 2011 16:52:22 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Michael Groshans <groshans@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfsd: Prevent ipv6 address truncation in /proc/fs/nfsd/pnfs_dlm_device
References: <4DE53146.3030208@umich.edu>
In-Reply-To: <4DE53146.3030208@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-31 21:19, Michael Groshans wrote:
> From: Michael Groshans <groshans@umich.edu>
> 
> ipv6 addresses in /proc/fs/nfsd/pnfs_dlm_device were being truncated because the
> length was determined by looking for the next colon. Changed to use strlen()
> instead.
> 
> Signed-off by: Michael Groshans <groshans@umich.edu>

All 3 patches look good to me.
For easier patch management, next time it would be good
to send all three as replies to an introductory message,

Also, please use "Signed-off-by:" rather than "Signed-off by:".
Besides the fact that checkpatch warns about that I'm not sure
it gets tracked properly...
I'll fix that before committing.

Thanks!

Benny

> ---
>  fs/nfsd/nfs4pnfsdlm.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 006ded5..0068ba0 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -165,7 +165,7 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
>  
>  	/* data server list */
>  	/* FIXME: need to check for comma separated valid ip format */
> -	len = strcspn(bufp, ":");
> +	len = strlen(bufp);
>  	if (len > NFSD_DLM_DS_LIST_MAX)
>  		goto out_free;
>  	memcpy(new->ds_list, bufp, len);

