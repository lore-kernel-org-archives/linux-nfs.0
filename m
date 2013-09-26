Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65388 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754345Ab3IZVzo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:55:44 -0400
Date: Thu, 26 Sep 2013 17:55:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 03/49] pnfsd: return pnfs flags on exchange_id
Message-ID: <20130926215534.GB24894@pad.fieldses.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220802-12810-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220802-12810-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 02:40:02PM -0400, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@panasas.com>
> 
> Set the cl_exchange_flags to be non_pnfs if we do not set
> either pnfs or ds (in the plain old nfs41 case).
> 
> Note that we always set both MDS and DS exchangeid capability flags
> when CONFIG_PNFSD is enabled.
> The client needs to remember what the session is used for
> if it cares to distiguish between DSs and MDSs.
> 
> EXCHGID4_FLAG_USE_NON_PNFS should be set when the server does not support
> operations (e.g. LAYOUTGET) or attributes that pertain to pNFS.

Minor nit: since we don't actually support those operations yet, this
patch should probably come later in the series.

--b.

> 
> [extraced from pnfsd: Initial pNFS server implementation.]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [pnfsd: Fixup nfsd4_set_ex_flags.]
> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> [pnfsd: set EXCHGID4_FLAG_USE_NON_PNFS when !CONFIG_PNFSD]
> [pnfsd: fix compiler warning in nfsd4_set_ex_flags when CONFIG_PNFSD is not defined]
> [pnfsd: always set both MDS and DS exchangeid capability flags]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 57a0340..21c15fc 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1614,8 +1614,12 @@ static bool clp_used_exchangeid(struct nfs4_client *clp)
>  static void
>  nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
>  {
> -	/* pNFS is not supported */
> +#if defined(CONFIG_PNFSD)
> +	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_PNFS_MDS |
> +				  EXCHGID4_FLAG_USE_PNFS_DS;
> +#else  /* CONFIG_PNFSD */
>  	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_NON_PNFS;
> +#endif /* CONFIG_PNFSD */
>  
>  	/* Referrals are supported, Migration is not. */
>  	new->cl_exchange_flags |= EXCHGID4_FLAG_SUPP_MOVED_REFER;
> -- 
> 1.8.3.1
> 
