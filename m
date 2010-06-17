From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] pnfsd: Add ability to clear pnfs dlm device ds list
Date: Thu, 17 Jun 2010 16:55:40 -0400
Message-ID: <4C1A8BCC.1000909@panasas.com>
References: <1276804400.1796.8.camel@Berlin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: eanderle@umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53232 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757100Ab0FQUze (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 16:55:34 -0400
In-Reply-To: <1276804400.1796.8.camel@Berlin>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 17, 2010, 15:53 -0400, Eric Anderle <eanderle@umich.edu> wrote:
> Added the ability to clear the pnfs dlm device ds list. Before, we
> checked to make sure the list wasn't empty; this is accomplished by
> examining the character after the ':' in the passed-in string. By
> modifying this check, an empty list is considered valid, and everything
> just works.
> 
> ---
>  fs/nfsd/nfs4pnfsdlm.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 40f9b84..befec4f 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -160,17 +160,15 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device,
> int len)
>  
>         err = -EINVAL;
>         bufp += len + 1;
> -       if (bufp >= endp)
> +       if (bufp > endp)
>                 goto out_free;
>  
>         /* data server list */ and 
> -       /* FIXME: need to check for comma separated valid ip format */
>         len = strcspn(bufp, ":");
>         if (len > NFSD_DLM_DS_LIST_MAX)
>                 goto out_free;
>         memcpy(new->ds_list, bufp, len);

BTW, what about null termination in case len == NFSD_DLM_DS_LIST_MAX?
and same for new->disk_name and DISK_NAME_LEN

Benny

>  
> -
>         /*  validate the ips */
>         if (!nfsd4_validate_pnfs_dlm_device(new->ds_list,
> &(new->num_ds)))
>                 goto out_free;
