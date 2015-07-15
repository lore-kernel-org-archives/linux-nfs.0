Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35111 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753642AbbGOU5T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2015 16:57:19 -0400
Date: Wed, 15 Jul 2015 16:57:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 03/14] nfsd: Fix memory leak of so_owner.data in
 nfs4_stateowner
Message-ID: <20150715205719.GC21669@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A3852D.8080106@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A3852D.8080106@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good catch, but could we make a common nfs4_free_stateowner() helper
called both from here and nfs4_put_stateowner() so we only have to do
the kfree() in that one place?

--b.

On Mon, Jul 13, 2015 at 05:30:21PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b1f84fc..e5e14fa 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3316,8 +3316,10 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
>  	if (ret == NULL) {
>  		hash_openowner(oo, clp, strhashval);
>  		ret = oo;
> -	} else
> +	} else {
> +		kfree(oo->oo_owner.so_owner.data);
>  		nfs4_free_openowner(&oo->oo_owner);
> +	}
>  	spin_unlock(&clp->cl_lock);
>  	return ret;
>  }
> @@ -5217,8 +5219,10 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
>  		list_add(&lo->lo_owner.so_strhash,
>  			 &clp->cl_ownerstr_hashtbl[strhashval]);
>  		ret = lo;
> -	} else
> -		nfs4_free_lockowner(&lo->lo_owner);
> +	} else {
> +		kfree(lo->lo_owner.so_owner.data);
> +		nfs4_free_openowner(&lo->lo_owner);
> +	}
>  	spin_unlock(&clp->cl_lock);
>  	return ret;
>  }
> -- 
> 2.4.3
