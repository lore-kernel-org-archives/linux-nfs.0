Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56739 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910AbbGVTWj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 15:22:39 -0400
Date: Wed, 22 Jul 2015 15:22:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 14/14] nfsd: Remove unused clientid arguments from,
 find_lockowner_str{_locked}
Message-ID: <20150722192238.GC3168@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A38669.6050903@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A38669.6050903@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK, applied the rest of these.--b.

On Mon, Jul 13, 2015 at 05:35:37PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 16 ++++++----------
>  1 file changed, 6 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2704270..b6c134d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5131,8 +5131,7 @@ nevermind:
>  }
>  
>  static struct nfs4_lockowner *
> -find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
> -		struct nfs4_client *clp)
> +find_lockowner_str_locked(struct nfs4_client *clp, struct xdr_netobj *owner)
>  {
>  	unsigned int strhashval = ownerstr_hashval(owner);
>  	struct nfs4_stateowner *so;
> @@ -5150,13 +5149,12 @@ find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
>  }
>  
>  static struct nfs4_lockowner *
> -find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
> -		struct nfs4_client *clp)
> +find_lockowner_str(struct nfs4_client *clp, struct xdr_netobj *owner)
>  {
>  	struct nfs4_lockowner *lo;
>  
>  	spin_lock(&clp->cl_lock);
> -	lo = find_lockowner_str_locked(clid, owner, clp);
> +	lo = find_lockowner_str_locked(clp, owner);
>  	spin_unlock(&clp->cl_lock);
>  	return lo;
>  }
> @@ -5200,8 +5198,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
>  	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
>  	lo->lo_owner.so_ops = &lockowner_ops;
>  	spin_lock(&clp->cl_lock);
> -	ret = find_lockowner_str_locked(&clp->cl_clientid,
> -			&lock->lk_new_owner, clp);
> +	ret = find_lockowner_str_locked(clp, &lock->lk_new_owner);
>  	if (ret == NULL) {
>  		list_add(&lo->lo_owner.so_strhash,
>  			 &clp->cl_ownerstr_hashtbl[strhashval]);
> @@ -5322,7 +5319,7 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
>  	struct nfs4_lockowner *lo;
>  	unsigned int strhashval;
>  
> -	lo = find_lockowner_str(&cl->cl_clientid, &lock->lk_new_owner, cl);
> +	lo = find_lockowner_str(cl, &lock->lk_new_owner);
>  	if (!lo) {
>  		strhashval = ownerstr_hashval(&lock->lk_new_owner);
>  		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
> @@ -5597,8 +5594,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		goto out;
>  	}
>  
> -	lo = find_lockowner_str(&lockt->lt_clientid, &lockt->lt_owner,
> -				cstate->clp);
> +	lo = find_lockowner_str(cstate->clp, &lockt->lt_owner);
>  	if (lo)
>  		file_lock->fl_owner = (fl_owner_t)lo;
>  	file_lock->fl_pid = current->tgid;
> -- 
> 2.4.3
