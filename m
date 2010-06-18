From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] pnfs: Fix num_ds bug in nfsd4_set_pnfs_dlm_device()
Date: Fri, 18 Jun 2010 17:23:48 -0400
Message-ID: <4C1BE3E4.2040007@panasas.com>
References: <1276876558.1796.19.camel@Berlin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: eanderle@umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:35542 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989Ab0FRVXm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 17:23:42 -0400
Received: by qyk1 with SMTP id 1so200629qyk.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jun 2010 14:23:41 -0700 (PDT)
In-Reply-To: <1276876558.1796.19.camel@Berlin>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged at pnfs-all-2.6.35-rc3-2010-06-18

On Jun. 18, 2010, 11:55 -0400, Eric Anderle <eanderle@umich.edu> wrote:
>>From cd18db8401e1df4ee031e6a6c53e0f3353080dca Mon Sep 17 00:00:00 2001
> From: Eric Anderle <eanderle@umich.edu>
> Date: Fri, 18 Jun 2010 10:09:46 -0400
> Subject: [PATCH 1/1] pnfs: Fix num_ds bug in nfsd4_set_pnfs_dlm_device()

Oh, and one more nit :)
since this patch is for the server, our convention is to prefix
its subject with "pnfsd:", not "pnfs:"

Thanks!

Benny

> 
> Previously, when updating the DS list of an existing pnfs dlm device,
> the number of ds's was not updated. Fixed.
> 
> Signed-off-by: Eric Anderle <eanderle@umich.edu>
> ---
>  fs/nfsd/nfs4pnfsdlm.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 40f9b84..ffe1c32 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -189,6 +189,7 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
>  			found->disk_name, found->ds_list, new->ds_list);
>  		memset(found->ds_list, 0, DISK_NAME_LEN);
>  		memcpy(found->ds_list, new->ds_list, strlen(new->ds_list));
> +		found->num_ds = new->num_ds;
>  		kfree(new);
>  	} else {
>  		dprintk("%s Adding pnfs_dlm_device %s:%s\n", __func__,

