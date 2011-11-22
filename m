Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53320 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311Ab1KVWIf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 17:08:35 -0500
Date: Tue, 22 Nov 2011 17:08:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd41: donot check reclaim for open with filehandle
Message-ID: <20111122220834.GC23243@fieldses.org>
References: <4EC470B1.5000505@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EC470B1.5000505@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 17, 2011 at 10:25:53AM +0800, Mi Jinlong wrote:
> Opening file with filehandle, check reclaim is not needed.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4proc.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index fa38336..681dff3 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -266,8 +266,9 @@ do_open_fhandle(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_
>  {
>  	__be32 status;
>  
> -	/* Only reclaims from previously confirmed clients are valid */
> -	if ((status = nfs4_check_open_reclaim(&open->op_clientid)))
> +	if (open->op_claim_type != NFS4_OPEN_CLAIM_FH
> +	    && open->op_claim_type != NFS4_OPEN_CLAIM_DELEG_CUR_FH

Thanks for catching that.

I think it would be simpler to pull this check out into nfsd4_open(),
something like:

	case NFS4_OPEN_CLAIM_PREVIOUS:
		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
		status = nfs4_check_open_reclaim(&open->op_clientid);
		if (status)
			goto out;
	case NFS4_OPEN_CLAIM_FH:
	...

--b.

> +	    && (status = nfs4_check_open_reclaim(&open->op_clientid)))
>  		return status;
>  
>  	/* We don't know the target directory, and therefore can not
> -- 
> 1.7.7
> 
> 
