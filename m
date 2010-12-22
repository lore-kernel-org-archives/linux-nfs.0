Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60149 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394Ab0LVW1j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Dec 2010 17:27:39 -0500
Date: Wed, 22 Dec 2010 17:27:38 -0500
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V5 09/11] NFS RPC_AUTH_GSS unsupported on v4.1 back
 channel
Message-ID: <20101222222738.GF13243@fieldses.org>
References: <1292879088-7821-1-git-send-email-andros@netapp.com>
 <1292879088-7821-2-git-send-email-andros@netapp.com>
 <1292879088-7821-3-git-send-email-andros@netapp.com>
 <1292879088-7821-4-git-send-email-andros@netapp.com>
 <1292879088-7821-5-git-send-email-andros@netapp.com>
 <1292879088-7821-6-git-send-email-andros@netapp.com>
 <1292879088-7821-7-git-send-email-andros@netapp.com>
 <1292879088-7821-8-git-send-email-andros@netapp.com>
 <1292879088-7821-9-git-send-email-andros@netapp.com>
 <1292879088-7821-10-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292879088-7821-10-git-send-email-andros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 20, 2010 at 04:04:46PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 541be39..4a9c517 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -368,6 +368,9 @@ static int check_gss_callback_principal(struct nfs_client *clp,
>  	struct rpc_clnt *r = clp->cl_rpcclient;
>  	char *p = svc_gss_principal(rqstp);
>  
> +	/* No RPC_AUTH_GSS on NFSv4.1 back channel yet */
> +	if (clp->cl_minorversion != 0)
> +		return SVC_DENIED;

May as well just drop in this case, actually, right?  You didn't ask for
gss in the create_session, so this would be an outright server bug.

--b.

>  	/*
>  	 * It might just be a normal user principal, in which case
>  	 * userspace won't bother to tell us the name at all.
> -- 
> 1.6.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
