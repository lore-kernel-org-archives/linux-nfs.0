Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36188 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbbGQP7p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jul 2015 11:59:45 -0400
Date: Fri, 17 Jul 2015 11:59:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd: Fix memory leak of so_owner.data in
 nfs4_stateowner
Message-ID: <20150717155945.GD6263@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A3852D.8080106@gmail.com>
 <20150715205719.GC21669@fieldses.org>
 <55A72D73.4040609@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A72D73.4040609@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 16, 2015 at 12:05:07PM +0800, Kinglong Mee wrote:
> v2, new helper nfs4_free_stateowner for freeing so_owner.data and sop

Got it, thanks.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 00a0f8f..3c24c72 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -990,6 +990,12 @@ release_all_access(struct nfs4_ol_stateid *stp)
>  	}
>  }
>  
> +static inline void nfs4_free_stateowner(struct nfs4_stateowner *sop)
> +{
> +	kfree(sop->so_owner.data);
> +	sop->so_ops->so_free(sop);
> +}
> +
>  static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
>  {
>  	struct nfs4_client *clp = sop->so_client;
> @@ -1000,8 +1006,7 @@ static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
>  		return;
>  	sop->so_ops->so_unhash(sop);
>  	spin_unlock(&clp->cl_lock);
> -	kfree(sop->so_owner.data);
> -	sop->so_ops->so_free(sop);
> +	nfs4_free_stateowner(sop);
>  }
>  
>  static void unhash_ol_stateid(struct nfs4_ol_stateid *stp)
> @@ -3316,7 +3321,8 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
>  		hash_openowner(oo, clp, strhashval);
>  		ret = oo;
>  	} else
> -		nfs4_free_openowner(&oo->oo_owner);
> +		nfs4_free_stateowner(&oo->oo_owner);
> +
>  	spin_unlock(&clp->cl_lock);
>  	return ret;
>  }
> @@ -5216,7 +5222,8 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
>  			 &clp->cl_ownerstr_hashtbl[strhashval]);
>  		ret = lo;
>  	} else
> -		nfs4_free_lockowner(&lo->lo_owner);
> +		nfs4_free_stateowner(&lo->lo_owner);
> +
>  	spin_unlock(&clp->cl_lock);
>  	return ret;
>  }
> -- 
> 2.4.3
