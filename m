Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45938 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751602AbaHAToS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Aug 2014 15:44:18 -0400
Date: Fri, 1 Aug 2014 15:44:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v3 30/38] nfsd: Protect adding/removing lock owners using
 client_lock
Message-ID: <20140801194413.GD24461@fieldses.org>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
 <1406684083-19736-31-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406684083-19736-31-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 09:34:35PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Once we remove client mutex protection, we'll need to ensure that
> stateowner lookup and creation are atomic between concurrent compounds.
> Ensure that alloc_init_lock_stateowner checks the hashtable under the
> client_lock before adding a new element.

Not worth respinning any patches for this, but "alloc_init_..." was
never my favorite naming scheme, and isn't so accurate at this point.
"find_or_create_..." is a little cumbersome too, but maybe it'd do.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 69 ++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 61 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c4bb7f2b29d9..7c15918d20f0 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1000,26 +1000,42 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
>  	nfs4_put_stid(&stp->st_stid);
>  }
>  
> -static void unhash_lockowner(struct nfs4_lockowner *lo)
> +static void unhash_lockowner_locked(struct nfs4_lockowner *lo)
>  {
> +	struct nfsd_net *nn = net_generic(lo->lo_owner.so_client->net,
> +						nfsd_net_id);
> +
> +	lockdep_assert_held(&nn->client_lock);
> +
>  	list_del_init(&lo->lo_owner.so_strhash);
>  }
>  
>  static void release_lockowner_stateids(struct nfs4_lockowner *lo)
>  {
> +	struct nfsd_net *nn = net_generic(lo->lo_owner.so_client->net,
> +						nfsd_net_id);
>  	struct nfs4_ol_stateid *stp;
>  
> +	lockdep_assert_held(&nn->client_lock);
> +
>  	while (!list_empty(&lo->lo_owner.so_stateids)) {
>  		stp = list_first_entry(&lo->lo_owner.so_stateids,
>  				struct nfs4_ol_stateid, st_perstateowner);
> +		spin_unlock(&nn->client_lock);
>  		release_lock_stateid(stp);
> +		spin_lock(&nn->client_lock);
>  	}
>  }
>  
>  static void release_lockowner(struct nfs4_lockowner *lo)
>  {
> -	unhash_lockowner(lo);
> +	struct nfsd_net *nn = net_generic(lo->lo_owner.so_client->net,
> +						nfsd_net_id);
> +
> +	spin_lock(&nn->client_lock);
> +	unhash_lockowner_locked(lo);
>  	release_lockowner_stateids(lo);
> +	spin_unlock(&nn->client_lock);
>  	nfs4_put_stateowner(&lo->lo_owner);
>  }
>  
> @@ -4801,7 +4817,7 @@ nevermind:
>  }
>  
>  static struct nfs4_lockowner *
> -find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
> +find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
>  		struct nfsd_net *nn)
>  {
>  	unsigned int strhashval = ownerstr_hashval(clid->cl_id, owner);
> @@ -4818,9 +4834,25 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
>  	return NULL;
>  }
>  
> +static struct nfs4_lockowner *
> +find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
> +		struct nfsd_net *nn)
> +{
> +	struct nfs4_lockowner *lo;
> +
> +	spin_lock(&nn->client_lock);
> +	lo = find_lockowner_str_locked(clid, owner, nn);
> +	spin_unlock(&nn->client_lock);
> +	return lo;
> +}
> +
>  static void nfs4_unhash_lockowner(struct nfs4_stateowner *sop)
>  {
> -	unhash_lockowner(lockowner(sop));
> +	struct nfsd_net *nn = net_generic(sop->so_client->net, nfsd_net_id);
> +
> +	spin_lock(&nn->client_lock);
> +	unhash_lockowner_locked(lockowner(sop));
> +	spin_unlock(&nn->client_lock);
>  }
>  
>  static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
> @@ -4843,9 +4875,12 @@ static const struct nfs4_stateowner_operations lockowner_ops = {
>   * strhashval = ownerstr_hashval
>   */
>  static struct nfs4_lockowner *
> -alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp, struct nfsd4_lock *lock) {
> -	struct nfs4_lockowner *lo;
> +alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
> +			   struct nfs4_ol_stateid *open_stp,
> +			   struct nfsd4_lock *lock)
> +{
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +	struct nfs4_lockowner *lo, *ret;
>  
>  	lo = alloc_stateowner(lockowner_slab, &lock->lk_new_owner, clp);
>  	if (!lo)
> @@ -4854,7 +4889,16 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
>  	lo->lo_owner.so_is_open_owner = 0;
>  	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
>  	lo->lo_owner.so_ops = &lockowner_ops;
> -	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
> +	spin_lock(&nn->client_lock);
> +	ret = find_lockowner_str_locked(&clp->cl_clientid,
> +			&lock->lk_new_owner, nn);
> +	if (ret == NULL) {
> +		list_add(&lo->lo_owner.so_strhash,
> +			 &nn->ownerstr_hashtbl[strhashval]);
> +		ret = lo;
> +	} else
> +		nfs4_free_lockowner(&lo->lo_owner);
> +	spin_unlock(&nn->client_lock);
>  	return lo;
>  }
>  
> @@ -5395,6 +5439,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
>  	__be32 status;
>  	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> +	struct nfs4_client *clp;
>  
>  	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
>  		clid->cl_boot, clid->cl_id);
> @@ -5408,6 +5453,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  	status = nfserr_locks_held;
>  
>  	/* Find the matching lock stateowner */
> +	spin_lock(&nn->client_lock);
>  	list_for_each_entry(tmp, &nn->ownerstr_hashtbl[hashval], so_strhash) {
>  		if (tmp->so_is_open_owner)
>  			continue;
> @@ -5417,6 +5463,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  			break;
>  		}
>  	}
> +	spin_unlock(&nn->client_lock);
>  
>  	/* No matching owner found, maybe a replay? Just declare victory... */
>  	if (!sop) {
> @@ -5426,16 +5473,22 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  
>  	lo = lockowner(sop);
>  	/* see if there are still any locks associated with it */
> +	clp = cstate->clp;
> +	spin_lock(&clp->cl_lock);
>  	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
>  		if (check_for_locks(stp->st_stid.sc_file, lo)) {
> -			nfs4_put_stateowner(sop);
> +			spin_unlock(&clp->cl_lock);
>  			goto out;
>  		}
>  	}
> +	spin_unlock(&clp->cl_lock);
>  
>  	status = nfs_ok;
> +	sop = NULL;
>  	release_lockowner(lo);
>  out:
> +	if (sop)
> +		nfs4_put_stateowner(sop);
>  	nfs4_unlock_state();
>  	return status;
>  }
> -- 
> 1.9.3
> 
