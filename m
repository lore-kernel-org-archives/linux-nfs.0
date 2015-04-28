Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43004 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030915AbbD1TMT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 15:12:19 -0400
Date: Tue, 28 Apr 2015 15:12:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 1/6] nfsd: fix the check for confirmed openowner in
 nfs4_preprocess_stateid_op
Message-ID: <20150428191216.GB16090@fieldses.org>
References: <1430228480-7656-1-git-send-email-hch@lst.de>
 <1430228480-7656-2-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1430228480-7656-2-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2015 at 03:41:15PM +0200, Christoph Hellwig wrote:
> If we find a non-confirmed openowner we jump to exit the function, but do
> not set an error value.  Fix this by factoring out a helper to do the
> check and properly set the error from nfsd4_validate_stateid.

Thanks.  I can't tell if the bug has any practical consequences--a
correct client should never hit this case as far as I can tell.

--b.

> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4state.c | 21 +++++++++++----------
>  1 file changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 9072964..66067a2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4498,10 +4498,17 @@ static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_s
>  	return nfserr_old_stateid;
>  }
>  
> +static __be32 nfsd4_check_openowner_confirmed(struct nfs4_ol_stateid *ols)
> +{
> +	if (ols->st_stateowner->so_is_open_owner &&
> +	    !(openowner(ols->st_stateowner)->oo_flags & NFS4_OO_CONFIRMED))
> +		return nfserr_bad_stateid;
> +	return nfs_ok;
> +}
> +
>  static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
>  {
>  	struct nfs4_stid *s;
> -	struct nfs4_ol_stateid *ols;
>  	__be32 status = nfserr_bad_stateid;
>  
>  	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
> @@ -4531,13 +4538,7 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
>  		break;
>  	case NFS4_OPEN_STID:
>  	case NFS4_LOCK_STID:
> -		ols = openlockstateid(s);
> -		if (ols->st_stateowner->so_is_open_owner
> -	    			&& !(openowner(ols->st_stateowner)->oo_flags
> -						& NFS4_OO_CONFIRMED))
> -			status = nfserr_bad_stateid;
> -		else
> -			status = nfs_ok;
> +		status = nfsd4_check_openowner_confirmed(openlockstateid(s));
>  		break;
>  	default:
>  		printk("unknown stateid type %x\n", s->sc_type);
> @@ -4629,8 +4630,8 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
>  		status = nfs4_check_fh(current_fh, stp);
>  		if (status)
>  			goto out;
> -		if (stp->st_stateowner->so_is_open_owner
> -		    && !(openowner(stp->st_stateowner)->oo_flags & NFS4_OO_CONFIRMED))
> +		status = nfsd4_check_openowner_confirmed(stp);
> +		if (status)
>  			goto out;
>  		status = nfs4_check_openmode(stp, flags);
>  		if (status)
> -- 
> 1.9.1
