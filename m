From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 24/51] nfsd41: print exchange flags when purging
 client
Date: Mon, 17 Nov 2008 16:08:22 +0200
Message-ID: <49217AD6.5070705@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350133-11000-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:17135 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753088AbYKQOIZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:08:25 -0500
In-Reply-To: <1226350133-11000-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:48 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Dean Hildebrand <seattleplus@gmail.com>
> 
> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-13: get rid of this patch.

> ---
>  fs/nfsd/nfs4state.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 76b2870..cbbb733 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2114,8 +2114,14 @@ nfs4_laundromat(void)
>  				clientid_val = t;
>  			break;
>  		}
> -		dprintk("NFSD: purging unused client (clientid %08x)\n",
> +#if defined(CONFIG_NFSD_V4_1)
> +		dprintk("NFSD: purging unused client"
> +			"(clientid %08x cl_exchange_flags %x)\n",
> +			clp->cl_clientid.cl_id, clp->cl_exchange_flags);
> +#else
> +		dprintk("NFSD: purging unused client(clientid %08x)\n",
>  			clp->cl_clientid.cl_id);
> +#endif /* CONFIG_NFSD_V4_1 */
>  		nfsd4_remove_clid_dir(clp);
>  		expire_client(clp);
>  	}
