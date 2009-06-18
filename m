From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 33/44] nfsd41: Remove ip address collision detection
	case per review comment
Date: Thu, 18 Jun 2009 19:36:44 -0400
Message-ID: <20090618233644.GA15962@fieldses.org>
References: <1245115247-7890-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:41385 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbZFRXgq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 19:36:46 -0400
In-Reply-To: <1245115247-7890-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:20:47AM +0300, Benny Halevy wrote:
> From: Mike Sager <sager@netapp.com>
> 
> Verified that cthon and pynfs exchange id tests pass (except for the
> two expected fails: EID8 and EID50)

Thanks, applied.  Though exchange_id still isn't right: for example,
we're expiring the client in the conf && !same_verf case without
checking the principal.

If someone could take an hour or two, go through the 18.35.4 *very*
carefully, and check all of this, it would be appreciated.

--b.

> 
> Signed-off-by: Mike Sager <sager@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |   18 ++++++------------
>  1 files changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c91b333..8ac5630 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1158,12 +1158,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  			expire_client(conf);
>  			goto out_new;
>  		}
> -		if (ip_addr != conf->cl_addr &&
> -		    !(exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A)) {
> -			/* Client collision. 18.35.4 case 3 */
> -			status = nfserr_clid_inuse;
> -			goto out;
> -		}
>  		/*
>  		 * Set bit when the owner id and verifier map to an already
>  		 * confirmed client id (18.35.3).
> @@ -1177,12 +1171,12 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  		copy_verf(conf, &verf);
>  		new = conf;
>  		goto out_copy;
> -	} else {
> -		/* 18.35.4 case 7 */
> -		if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
> -			status = nfserr_noent;
> -			goto out;
> -		}
> +	}
> +
> +	/* 18.35.4 case 7 */
> +	if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
> +		status = nfserr_noent;
> +		goto out;
>  	}
>  
>  	unconf  = find_unconfirmed_client_by_str(dname, strhashval, true);
> -- 
> 1.6.3
> 
