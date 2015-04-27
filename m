Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42206 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965001AbbD0Ujn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Apr 2015 16:39:43 -0400
Date: Mon, 27 Apr 2015 16:39:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org, Sachin Bhamare <sachin.bhamare@primarydata.com>,
        Jeff Layton <jlayton@primarydata.com>
Subject: Re: [PATCH 2/2] nfsd: fix pNFS return on close semantics
Message-ID: <20150427203943.GI4083@fieldses.org>
References: <1430139014-28013-1-git-send-email-hch@lst.de>
 <1430139014-28013-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1430139014-28013-3-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 27, 2015 at 02:50:14PM +0200, Christoph Hellwig wrote:
> From: Sachin Bhamare <sachin.bhamare@primarydata.com>
> 
> In case of forgetful clients, server should return the layouts to the
> file system on 'last close' of a file (assuming that there are no
> delegations outstanding to that particular client) or on delegreturn
> (assuming that there are no opens on a file from that particular client).
> 
> This patch introduces infrastructure to maintain per-client opens and
> delegation counters on per-file basis.

This could use some explanation of why you can't track this with
existing data structures.  E.g., I assume you thought about it and that
e.g. the existing fi_ref won't work--but, it's not immediately obvious
to me.

(Also: does this need to go to stable?  If we're potentially leaving
layouts around forever, this sounds pretty serious.)

--b.

> 
> [hch: ported to the mainline pNFS support, merged various fixes from Jeff]
> Signed-off-by: Sachin Bhamare <sachin.bhamare@primarydata.com>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4state.c | 117 ++++++++++++++++++++++++++++++++++++++++++++++++----
>  fs/nfsd/state.h     |  14 +++++++
>  fs/nfsd/xdr4.h      |   1 +
>  3 files changed, 125 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 38f2d7a..09c7056 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -281,6 +281,7 @@ put_nfs4_file(struct nfs4_file *fi)
>  	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
>  		hlist_del_rcu(&fi->fi_hash);
>  		spin_unlock(&state_lock);
> +		WARN_ON_ONCE(!list_empty(&fi->fi_clnt_odstate));
>  		WARN_ON_ONCE(!list_empty(&fi->fi_delegations));
>  		call_rcu(&fi->fi_rcu, nfsd4_free_file_rcu);
>  	}
> @@ -471,6 +472,87 @@ static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
>  		__nfs4_file_put_access(fp, O_RDONLY);
>  }
>  
> +/*
> + * Allocate a new open/delegation state counter. This is needed for
> + * pNFS for proper return on close semantics. For v4.0 however, it's
> + * not needed.
> + */
> +static struct nfs4_clnt_odstate *
> +alloc_clnt_odstate(struct nfs4_client *clp)
> +{
> +	struct nfs4_clnt_odstate *co;
> +
> +	co = kzalloc(sizeof(struct nfs4_clnt_odstate), GFP_KERNEL);
> +	if (co) {
> +		co->co_client = clp;
> +		atomic_set(&co->co_odcount, 1);
> +	}
> +	return co;
> +}
> +
> +static void
> +hash_clnt_odstate_locked(struct nfs4_clnt_odstate *co)
> +{
> +	struct nfs4_file *fp = co->co_file;
> +
> +	lockdep_assert_held(&fp->fi_lock);
> +	list_add(&co->co_perfile, &fp->fi_clnt_odstate);
> +}
> +
> +static inline void
> +get_clnt_odstate(struct nfs4_clnt_odstate *co)
> +{
> +	/* This is always NULL in v4.0 */
> +	if (co)
> +		atomic_inc(&co->co_odcount);
> +}
> +
> +static void
> +put_clnt_odstate(struct nfs4_clnt_odstate *co)
> +{
> +	struct nfs4_file *fp;
> +
> +	/* This is always NULL in v4.0 */
> +	if (!co)
> +		return;
> +
> +	fp = co->co_file;
> +	if (atomic_dec_and_lock(&co->co_odcount, &fp->fi_lock)) {
> +		list_del(&co->co_perfile);
> +		spin_unlock(&fp->fi_lock);
> +
> +		nfsd4_return_all_file_layouts(co->co_client, fp);
> +		kfree(co);
> +	}
> +}
> +
> +static struct nfs4_clnt_odstate *
> +find_or_hash_clnt_odstate(struct nfs4_file *fp, struct nfs4_clnt_odstate *new)
> +{
> +	struct nfs4_clnt_odstate *co;
> +	struct nfs4_client *cl;
> +
> +	/* This is always NULL in v4.0 */
> +	if (!new)
> +		return NULL;
> +
> +	cl = new->co_client;
> +
> +	spin_lock(&fp->fi_lock);
> +	list_for_each_entry(co, &fp->fi_clnt_odstate, co_perfile) {
> +		if (co->co_client == cl) {
> +			get_clnt_odstate(co);
> +			goto out;
> +		}
> +	}
> +	co = new;
> +	co->co_file = fp;
> +	hash_clnt_odstate_locked(new);
> +out:
> +	spin_unlock(&fp->fi_lock);
> +	return co;
> +}
> +
>  struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
>  					 struct kmem_cache *slab)
>  {
> @@ -606,7 +688,8 @@ static void block_delegations(struct knfsd_fh *fh)
>  }
>  
>  static struct nfs4_delegation *
> -alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
> +alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh,
> +		 struct nfs4_clnt_odstate *odstate)
>  {
>  	struct nfs4_delegation *dp;
>  	long n;
> @@ -631,6 +714,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
>  	INIT_LIST_HEAD(&dp->dl_perfile);
>  	INIT_LIST_HEAD(&dp->dl_perclnt);
>  	INIT_LIST_HEAD(&dp->dl_recall_lru);
> +	dp->dl_clnt_odstate = odstate;
> +	get_clnt_odstate(odstate);
>  	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
>  	dp->dl_retries = 1;
>  	nfsd4_init_cb(&dp->dl_recall, dp->dl_stid.sc_client,
> @@ -714,6 +799,7 @@ static void destroy_delegation(struct nfs4_delegation *dp)
>  	spin_lock(&state_lock);
>  	unhash_delegation_locked(dp);
>  	spin_unlock(&state_lock);
> +	put_clnt_odstate(dp->dl_clnt_odstate);
>  	nfs4_put_deleg_lease(dp->dl_stid.sc_file);
>  	nfs4_put_stid(&dp->dl_stid);
>  }
> @@ -724,6 +810,7 @@ static void revoke_delegation(struct nfs4_delegation *dp)
>  
>  	WARN_ON(!list_empty(&dp->dl_recall_lru));
>  
> +	put_clnt_odstate(dp->dl_clnt_odstate);
>  	nfs4_put_deleg_lease(dp->dl_stid.sc_file);
>  
>  	if (clp->cl_minorversion == 0)
> @@ -933,6 +1020,7 @@ static void nfs4_free_ol_stateid(struct nfs4_stid *stid)
>  {
>  	struct nfs4_ol_stateid *stp = openlockstateid(stid);
>  
> +	put_clnt_odstate(stp->st_clnt_odstate);
>  	release_all_access(stp);
>  	if (stp->st_stateowner)
>  		nfs4_put_stateowner(stp->st_stateowner);
> @@ -1634,6 +1722,7 @@ __destroy_client(struct nfs4_client *clp)
>  	while (!list_empty(&reaplist)) {
>  		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
>  		list_del_init(&dp->dl_recall_lru);
> +		put_clnt_odstate(dp->dl_clnt_odstate);
>  		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
>  		nfs4_put_stid(&dp->dl_stid);
>  	}
> @@ -3057,6 +3146,7 @@ static void nfsd4_init_file(struct knfsd_fh *fh, unsigned int hashval,
>  	spin_lock_init(&fp->fi_lock);
>  	INIT_LIST_HEAD(&fp->fi_stateids);
>  	INIT_LIST_HEAD(&fp->fi_delegations);
> +	INIT_LIST_HEAD(&fp->fi_clnt_odstate);
>  	fh_copy_shallow(&fp->fi_fhandle, fh);
>  	fp->fi_deleg_file = NULL;
>  	fp->fi_had_conflict = false;
> @@ -3581,6 +3671,13 @@ alloc_stateid:
>  	open->op_stp = nfs4_alloc_open_stateid(clp);
>  	if (!open->op_stp)
>  		return nfserr_jukebox;
> +
> +	if (nfsd4_has_session(cstate)) {
> +		open->op_odstate = alloc_clnt_odstate(clp);
> +		if (!open->op_odstate)
> +			return nfserr_jukebox;
> +	}
> +
>  	return nfs_ok;
>  }
>  
> @@ -3869,7 +3966,7 @@ out_fput:
>  
>  static struct nfs4_delegation *
>  nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
> -		    struct nfs4_file *fp)
> +		    struct nfs4_file *fp, struct nfs4_clnt_odstate *odstate)
>  {
>  	int status;
>  	struct nfs4_delegation *dp;
> @@ -3877,7 +3974,7 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
>  	if (fp->fi_had_conflict)
>  		return ERR_PTR(-EAGAIN);
>  
> -	dp = alloc_init_deleg(clp, fh);
> +	dp = alloc_init_deleg(clp, fh, odstate);
>  	if (!dp)
>  		return ERR_PTR(-ENOMEM);
>  
> @@ -3903,6 +4000,7 @@ out_unlock:
>  	spin_unlock(&state_lock);
>  out:
>  	if (status) {
> +		put_clnt_odstate(dp->dl_clnt_odstate);
>  		nfs4_put_stid(&dp->dl_stid);
>  		return ERR_PTR(status);
>  	}
> @@ -3980,7 +4078,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
>  		default:
>  			goto out_no_deleg;
>  	}
> -	dp = nfs4_set_delegation(clp, fh, stp->st_stid.sc_file);
> +	dp = nfs4_set_delegation(clp, fh, stp->st_stid.sc_file, stp->st_clnt_odstate);
>  	if (IS_ERR(dp))
>  		goto out_no_deleg;
>  
> @@ -4069,6 +4167,11 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  			release_open_stateid(stp);
>  			goto out;
>  		}
> +
> +		stp->st_clnt_odstate = find_or_hash_clnt_odstate(fp,
> +							open->op_odstate);
> +		if (stp->st_clnt_odstate == open->op_odstate)
> +			open->op_odstate = NULL;
>  	}
>  	update_stateid(&stp->st_stid.sc_stateid);
>  	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
> @@ -4129,6 +4232,8 @@ void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
>  		kmem_cache_free(file_slab, open->op_file);
>  	if (open->op_stp)
>  		nfs4_put_stid(&open->op_stp->st_stid);
> +	if (open->op_odstate)
> +		kfree(open->op_odstate);
>  }
>  
>  __be32
> @@ -4852,9 +4957,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	update_stateid(&stp->st_stid.sc_stateid);
>  	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
>  
> -	nfsd4_return_all_file_layouts(stp->st_stateowner->so_client,
> -				      stp->st_stid.sc_file);
> -
>  	nfsd4_close_open_stateid(stp);
>  
>  	/* put reference from nfs4_preprocess_seqid_op */
> @@ -6488,6 +6590,7 @@ nfs4_state_shutdown_net(struct net *net)
>  	list_for_each_safe(pos, next, &reaplist) {
>  		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
>  		list_del_init(&dp->dl_recall_lru);
> +		put_clnt_odstate(dp->dl_clnt_odstate);
>  		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
>  		nfs4_put_stid(&dp->dl_stid);
>  	}
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 4f3bfeb..bde45d9 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -126,6 +126,7 @@ struct nfs4_delegation {
>  	struct list_head	dl_perfile;
>  	struct list_head	dl_perclnt;
>  	struct list_head	dl_recall_lru;  /* delegation recalled */
> +	struct nfs4_clnt_odstate *dl_clnt_odstate;
>  	u32			dl_type;
>  	time_t			dl_time;
>  /* For recall: */
> @@ -465,6 +466,17 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
>  }
>  
>  /*
> + * Per-client state indicating no. of opens and outstanding delegations
> + * on a file from a particular client.'od' stands for 'open & delegation'
> + */
> +struct nfs4_clnt_odstate {
> +	struct nfs4_client	*co_client;
> +	struct nfs4_file	*co_file;
> +	struct list_head	co_perfile;
> +	atomic_t		co_odcount;
> +};
> +
> +/*
>   * nfs4_file: a file opened by some number of (open) nfs4_stateowners.
>   *
>   * These objects are global. nfsd keeps one instance of a nfs4_file per
> @@ -485,6 +497,7 @@ struct nfs4_file {
>  		struct list_head	fi_delegations;
>  		struct rcu_head		fi_rcu;
>  	};
> +	struct list_head	fi_clnt_odstate;
>  	/* One each for O_RDONLY, O_WRONLY, O_RDWR: */
>  	struct file *		fi_fds[3];
>  	/*
> @@ -526,6 +539,7 @@ struct nfs4_ol_stateid {
>  	struct list_head              st_perstateowner;
>  	struct list_head              st_locks;
>  	struct nfs4_stateowner      * st_stateowner;
> +	struct nfs4_clnt_odstate    * st_clnt_odstate;
>  	unsigned char                 st_access_bmap;
>  	unsigned char                 st_deny_bmap;
>  	struct nfs4_ol_stateid         * st_openstp;
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index f982ae8..2f8c092 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -247,6 +247,7 @@ struct nfsd4_open {
>  	struct nfs4_openowner *op_openowner; /* used during processing */
>  	struct nfs4_file *op_file;          /* used during processing */
>  	struct nfs4_ol_stateid *op_stp;	    /* used during processing */
> +	struct nfs4_clnt_odstate *op_odstate; /* used during processing */
>  	struct nfs4_acl *op_acl;
>  	struct xdr_netobj op_label;
>  };
> -- 
> 1.9.1
