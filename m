Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46298 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659Ab1K3Xzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 18:55:43 -0500
Date: Wed, 30 Nov 2011 18:55:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd41: check reclaim for open claim previous at
 nfsd4_open
Message-ID: <20111130235541.GD354@fieldses.org>
References: <4EC470B1.5000505@cn.fujitsu.com>
 <20111122220834.GC23243@fieldses.org>
 <4ECC5F08.4070900@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4ECC5F08.4070900@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 23, 2011 at 10:48:40AM +0800, Mi Jinlong wrote:
> Opening file with filehandle, check reclaim is not needed.
> So, let open reclaim check at nfsd4_open.

Thanks!  Applying for 3.3.--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4proc.c |    7 +++----
>  1 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index fa38336..9415bc4 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -266,10 +266,6 @@ do_open_fhandle(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_
>  {
>  	__be32 status;
>  
> -	/* Only reclaims from previously confirmed clients are valid */
> -	if ((status = nfs4_check_open_reclaim(&open->op_clientid)))
> -		return status;
> -
>  	/* We don't know the target directory, and therefore can not
>  	* set the change info
>  	*/
> @@ -373,6 +369,9 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  			break;
>  		case NFS4_OPEN_CLAIM_PREVIOUS:
>  			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
> +			status = nfs4_check_open_reclaim(&open->op_clientid);
> +			if (status)
> +				goto out;
>  		case NFS4_OPEN_CLAIM_FH:
>  		case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
>  			status = do_open_fhandle(rqstp, &cstate->current_fh,
> -- 
> 1.7.7
> 
> 
