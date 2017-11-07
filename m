Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48818 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934101AbdKGVhT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 16:37:19 -0500
Date: Tue, 7 Nov 2017 16:37:19 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 5/7] nfsd: Fix race in lock stateid creation
Message-ID: <20171107213719.GG24262@fieldses.org>
References: <20171103120016.6200-1-trond.myklebust@primarydata.com>
 <20171103120016.6200-2-trond.myklebust@primarydata.com>
 <20171103120016.6200-3-trond.myklebust@primarydata.com>
 <20171103120016.6200-4-trond.myklebust@primarydata.com>
 <20171103120016.6200-5-trond.myklebust@primarydata.com>
 <20171103120016.6200-6-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171103120016.6200-6-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 03, 2017 at 08:00:14AM -0400, Trond Myklebust wrote:
> If we're looking up a new lock state, and the creation fails, then
> we want to unhash it, just like we do for OPEN. However in order
> to do so, we need to that no other LOCK requests can grab the
> mutex until we have unhashed it (and marked it as closed).

I split the move of find_lock_stateid() into a separate patch just to
make it easier for me to read the result....  Looks fine otherwise.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 104 +++++++++++++++++++++++++++++-----------------------
>  1 file changed, 59 insertions(+), 45 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f93ca0682aaa..f13fba4f51ec 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5630,14 +5630,41 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
>  	return ret;
>  }
>  
> -static void
> +static struct nfs4_ol_stateid *
> +find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
> +{
> +	struct nfs4_ol_stateid *lst;
> +	struct nfs4_client *clp = lo->lo_owner.so_client;
> +
> +	lockdep_assert_held(&clp->cl_lock);
> +
> +	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
> +		if (lst->st_stid.sc_type != NFS4_LOCK_STID)
> +			continue;
> +		if (lst->st_stid.sc_file == fp) {
> +			atomic_inc(&lst->st_stid.sc_count);
> +			return lst;
> +		}
> +	}
> +	return NULL;
> +}
> +
> +static struct nfs4_ol_stateid *
>  init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
>  		  struct nfs4_file *fp, struct inode *inode,
>  		  struct nfs4_ol_stateid *open_stp)
>  {
>  	struct nfs4_client *clp = lo->lo_owner.so_client;
> +	struct nfs4_ol_stateid *retstp;
>  
> -	lockdep_assert_held(&clp->cl_lock);
> +	mutex_init(&stp->st_mutex);
> +	mutex_lock(&stp->st_mutex);
> +retry:
> +	spin_lock(&clp->cl_lock);
> +	spin_lock(&fp->fi_lock);
> +	retstp = find_lock_stateid(lo, fp);
> +	if (retstp)
> +		goto out_unlock;
>  
>  	atomic_inc(&stp->st_stid.sc_count);
>  	stp->st_stid.sc_type = NFS4_LOCK_STID;
> @@ -5647,31 +5674,22 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = open_stp->st_deny_bmap;
>  	stp->st_openstp = open_stp;
> -	mutex_init(&stp->st_mutex);
>  	list_add(&stp->st_locks, &open_stp->st_locks);
>  	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
> -	spin_lock(&fp->fi_lock);
>  	list_add(&stp->st_perfile, &fp->fi_stateids);
> +out_unlock:
>  	spin_unlock(&fp->fi_lock);
> -}
> -
> -static struct nfs4_ol_stateid *
> -find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
> -{
> -	struct nfs4_ol_stateid *lst;
> -	struct nfs4_client *clp = lo->lo_owner.so_client;
> -
> -	lockdep_assert_held(&clp->cl_lock);
> -
> -	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
> -		if (lst->st_stid.sc_type != NFS4_LOCK_STID)
> -			continue;
> -		if (lst->st_stid.sc_file == fp) {
> -			atomic_inc(&lst->st_stid.sc_count);
> -			return lst;
> +	spin_unlock(&clp->cl_lock);
> +	if (retstp) {
> +		if (nfsd4_lock_ol_stateid(retstp) != nfs_ok) {
> +			nfs4_put_stid(&retstp->st_stid);
> +			goto retry;
>  		}
> +		/* To keep mutex tracking happy */
> +		mutex_unlock(&stp->st_mutex);
> +		stp = retstp;
>  	}
> -	return NULL;
> +	return stp;
>  }
>  
>  static struct nfs4_ol_stateid *
> @@ -5684,26 +5702,25 @@ find_or_create_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fi,
>  	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
>  	struct nfs4_client *clp = oo->oo_owner.so_client;
>  
> +	*new = false;
>  	spin_lock(&clp->cl_lock);
>  	lst = find_lock_stateid(lo, fi);
> -	if (lst == NULL) {
> -		spin_unlock(&clp->cl_lock);
> -		ns = nfs4_alloc_stid(clp, stateid_slab, nfs4_free_lock_stateid);
> -		if (ns == NULL)
> -			return NULL;
> -
> -		spin_lock(&clp->cl_lock);
> -		lst = find_lock_stateid(lo, fi);
> -		if (likely(!lst)) {
> -			lst = openlockstateid(ns);
> -			init_lock_stateid(lst, lo, fi, inode, ost);
> -			ns = NULL;
> -			*new = true;
> -		}
> -	}
>  	spin_unlock(&clp->cl_lock);
> -	if (ns)
> +	if (lst != NULL) {
> +		if (nfsd4_lock_ol_stateid(lst) == nfs_ok)
> +			goto out;
> +		nfs4_put_stid(&lst->st_stid);
> +	}
> +	ns = nfs4_alloc_stid(clp, stateid_slab, nfs4_free_lock_stateid);
> +	if (ns == NULL)
> +		return NULL;
> +
> +	lst = init_lock_stateid(openlockstateid(ns), lo, fi, inode, ost);
> +	if (lst == openlockstateid(ns))
> +		*new = true;
> +	else
>  		nfs4_put_stid(ns);
> +out:
>  	return lst;
>  }
>  
> @@ -5755,17 +5772,12 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
>  			goto out;
>  	}
>  
> -retry:
>  	lst = find_or_create_lock_stateid(lo, fi, inode, ost, new);
>  	if (lst == NULL) {
>  		status = nfserr_jukebox;
>  		goto out;
>  	}
>  
> -	if (nfsd4_lock_ol_stateid(lst) != nfs_ok) {
> -		nfs4_put_stid(&lst->st_stid);
> -		goto retry;
> -	}
>  	status = nfs_ok;
>  	*plst = lst;
>  out:
> @@ -5971,14 +5983,16 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		    seqid_mutating_err(ntohl(status)))
>  			lock_sop->lo_owner.so_seqid++;
>  
> -		mutex_unlock(&lock_stp->st_mutex);
> -
>  		/*
>  		 * If this is a new, never-before-used stateid, and we are
>  		 * returning an error, then just go ahead and release it.
>  		 */
> -		if (status && new)
> +		if (status && new) {
> +			lock_stp->st_stid.sc_type = NFS4_CLOSED_STID;
>  			release_lock_stateid(lock_stp);
> +		}
> +
> +		mutex_unlock(&lock_stp->st_mutex);
>  
>  		nfs4_put_stid(&lock_stp->st_stid);
>  	}
> -- 
> 2.13.6
