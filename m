Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og110.obsmtp.com ([64.18.0.20]:54796 "HELO
	exprod5og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755146Ab0KKNWQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Nov 2010 08:22:16 -0500
Message-ID: <4CDBEE06.1050309@panasas.com>
Date: Thu, 11 Nov 2010 15:22:14 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
CC: iisaman@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] pnfs-submit: callbacks cannot use an nfs_client that
 is being freed
References: <1289484640-4100-1-git-send-email-andros@netapp.com> <1289484640-4100-2-git-send-email-andros@netapp.com> <1289484640-4100-3-git-send-email-andros@netapp.com> <1289484640-4100-4-git-send-email-andros@netapp.com>
In-Reply-To: <1289484640-4100-4-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-11 16:10, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Guarantee that the nfs_client exists when referenced to by callback processing
> by not procssing callbacks on an nfs_client in the process of being freed.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/client.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index dbf43e7..86657ee 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -392,7 +392,9 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
>  		if (!nfs_sockaddr_match_ipaddr(addr, clap))
>  			continue;
>  
> -		atomic_inc(&clp->cl_count);
> +		/* Don't return an nfs_client that is being freed */
> +		if (!atomic_inc_not_zero(&clp->cl_count))
> +			continue;
>  		spin_unlock(&nfs_client_lock);
>  		return clp;
>  	}
> @@ -425,7 +427,9 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
>  		if (!nfs_sockaddr_match_ipaddr(sap, clap))
>  			continue;
>  
> -		atomic_inc(&clp->cl_count);
> +		/* Don't return an nfs_client that is being freed */
> +		if (!atomic_inc_not_zero(&clp->cl_count))
> +			continue;
>  		spin_unlock(&nfs_client_lock);
>  		return clp;
>  	}

Hmm, nfs_put_client deletes the client when cl_count reaches zero
so how can cl_count be zero while clp is listed?

Benny

In put_nfs_client 
