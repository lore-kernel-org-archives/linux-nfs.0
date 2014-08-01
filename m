Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52029 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460AbaHAT30 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Aug 2014 15:29:26 -0400
Date: Fri, 1 Aug 2014 15:29:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v3 27/38] nfsd: make openstateids hold references to
 their openowners
Message-ID: <20140801192918.GC24461@fieldses.org>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
 <1406684083-19736-28-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406684083-19736-28-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 09:34:32PM -0400, Jeff Layton wrote:
> Change it so that only openstateids hold persistent references to
> openowners. References can still be held by compounds in progress.
> 
> With this, we can get rid of NFS4_OO_NEW.

Yay--that stuff was horrible, my apologies for it.  This looks better.

--b.

> It's possible that we
> will create a new openowner in the process of doing the open, but
> something later fails. In the meantime, another task could find
> that openowner and start using it on a successful open. If that
> occurs we don't necessarily want to tear it down, just put the
> reference that the failing compound holds.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 73 +++++++++++++++++++++++------------------------------
>  fs/nfsd/state.h     |  1 -
>  2 files changed, 32 insertions(+), 42 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c86fe66254b0..b61319401826 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -916,6 +916,8 @@ static void nfs4_free_ol_stateid(struct nfs4_stid *stid)
>  	struct nfs4_ol_stateid *stp = openlockstateid(stid);
>  
>  	release_all_access(stp);
> +	if (stp->st_stateowner)
> +		nfs4_put_stateowner(stp->st_stateowner);
>  	kmem_cache_free(stateid_slab, stid);
>  }
>  
> @@ -928,8 +930,6 @@ static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
>  	file = find_any_file(stp->st_stid.sc_file);
>  	if (file)
>  		filp_close(file, (fl_owner_t)lo);
> -	if (stp->st_stateowner)
> -		nfs4_put_stateowner(stp->st_stateowner);
>  	nfs4_free_ol_stateid(stid);
>  }
>  
> @@ -1008,8 +1008,9 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
>  	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
>  
>  	if (s) {
> -		nfs4_put_stid(&s->st_stid);
> +		list_del_init(&oo->oo_close_lru);
>  		oo->oo_last_closed_stid = NULL;
> +		nfs4_put_stid(&s->st_stid);
>  	}
>  }
>  
> @@ -1028,7 +1029,6 @@ static void release_openowner(struct nfs4_openowner *oo)
>  {
>  	unhash_openowner(oo);
>  	release_openowner_stateids(oo);
> -	list_del(&oo->oo_close_lru);
>  	release_last_closed_stateid(oo);
>  	nfs4_put_stateowner(&oo->oo_owner);
>  }
> @@ -1497,6 +1497,7 @@ destroy_client(struct nfs4_client *clp)
>  	}
>  	while (!list_empty(&clp->cl_openowners)) {
>  		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
> +		atomic_inc(&oo->oo_owner.so_count);
>  		release_openowner(oo);
>  	}
>  	nfsd4_shutdown_callback(clp);
> @@ -3024,7 +3025,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
>  	oo->oo_owner.so_ops = &openowner_ops;
>  	oo->oo_owner.so_is_open_owner = 1;
>  	oo->oo_owner.so_seqid = open->op_seqid;
> -	oo->oo_flags = NFS4_OO_NEW;
> +	oo->oo_flags = 0;
>  	if (nfsd4_has_session(cstate))
>  		oo->oo_flags |= NFS4_OO_CONFIRMED;
>  	oo->oo_time = 0;
> @@ -3041,6 +3042,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
>  	stp->st_stid.sc_type = NFS4_OPEN_STID;
>  	INIT_LIST_HEAD(&stp->st_locks);
>  	stp->st_stateowner = &oo->oo_owner;
> +	atomic_inc(&stp->st_stateowner->so_count);
>  	get_nfs4_file(fp);
>  	stp->st_stid.sc_file = fp;
>  	stp->st_access_bmap = 0;
> @@ -3054,13 +3056,27 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
>  	spin_unlock(&oo->oo_owner.so_client->cl_lock);
>  }
>  
> +/*
> + * In the 4.0 case we need to keep the owners around a little while to handle
> + * CLOSE replay. We still do need to release any file access that is held by
> + * them before returning however.
> + */
>  static void
> -move_to_close_lru(struct nfs4_openowner *oo, struct net *net)
> +move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
>  {
> -	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> +	struct nfs4_openowner *oo = openowner(s->st_stateowner);
> +	struct nfsd_net *nn = net_generic(s->st_stid.sc_client->net,
> +						nfsd_net_id);
>  
>  	dprintk("NFSD: move_to_close_lru nfs4_openowner %p\n", oo);
>  
> +	release_all_access(s);
> +	if (s->st_stid.sc_file) {
> +		put_nfs4_file(s->st_stid.sc_file);
> +		s->st_stid.sc_file = NULL;
> +	}
> +	release_last_closed_stateid(oo);
> +	oo->oo_last_closed_stid = s;
>  	list_move_tail(&oo->oo_close_lru, &nn->close_lru);
>  	oo->oo_time = get_seconds();
>  }
> @@ -3091,6 +3107,7 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
>  			if ((bool)clp->cl_minorversion != sessions)
>  				return NULL;
>  			renew_client(oo->oo_owner.so_client);
> +			atomic_inc(&oo->oo_owner.so_count);
>  			return oo;
>  		}
>  	}
> @@ -3887,19 +3904,10 @@ void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
>  			      struct nfsd4_open *open, __be32 status)
>  {
>  	if (open->op_openowner) {
> -		struct nfs4_openowner *oo = open->op_openowner;
> -
> -		if (!list_empty(&oo->oo_owner.so_stateids))
> -			list_del_init(&oo->oo_close_lru);
> -		if (oo->oo_flags & NFS4_OO_NEW) {
> -			if (status) {
> -				release_openowner(oo);
> -				open->op_openowner = NULL;
> -			} else
> -				oo->oo_flags &= ~NFS4_OO_NEW;
> -		}
> -		if (open->op_openowner)
> -			nfsd4_cstate_assign_replay(cstate, &oo->oo_owner);
> +		struct nfs4_stateowner *so = &open->op_openowner->oo_owner;
> +
> +		nfsd4_cstate_assign_replay(cstate, so);
> +		nfs4_put_stateowner(so);
>  	}
>  	if (open->op_file)
>  		nfsd4_free_file(open->op_file);
> @@ -4015,7 +4023,7 @@ nfs4_laundromat(struct nfsd_net *nn)
>  			new_timeo = min(new_timeo, t);
>  			break;
>  		}
> -		release_openowner(oo);
> +		release_last_closed_stateid(oo);
>  	}
>  	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
>  	nfs4_unlock_state();
> @@ -4580,31 +4588,14 @@ out:
>  static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
>  {
>  	struct nfs4_client *clp = s->st_stid.sc_client;
> -	struct nfs4_openowner *oo = openowner(s->st_stateowner);
>  
>  	s->st_stid.sc_type = NFS4_CLOSED_STID;
>  	unhash_open_stateid(s);
>  
> -	if (clp->cl_minorversion) {
> -		if (list_empty(&oo->oo_owner.so_stateids))
> -			release_openowner(oo);
> +	if (clp->cl_minorversion)
>  		nfs4_put_stid(&s->st_stid);
> -	} else {
> -		/*
> -		 * In the 4.0 case we need to keep the owners around a
> -		 * little while to handle CLOSE replay. We still do need
> -		 * to release any file access that is held by them
> -		 * before returning however.
> -		 */
> -		release_all_access(s);
> -		if (s->st_stid.sc_file) {
> -			put_nfs4_file(s->st_stid.sc_file);
> -			s->st_stid.sc_file = NULL;
> -		}
> -		oo->oo_last_closed_stid = s;
> -		if (list_empty(&oo->oo_owner.so_stateids))
> -			move_to_close_lru(oo, clp->net);
> -	}
> +	else
> +		move_to_close_lru(s, clp->net);
>  }
>  
>  /*
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 232246039db0..e073c86f389c 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -367,7 +367,6 @@ struct nfs4_openowner {
>  	struct nfs4_ol_stateid *oo_last_closed_stid;
>  	time_t			oo_time; /* time of placement on so_close_lru */
>  #define NFS4_OO_CONFIRMED   1
> -#define NFS4_OO_NEW         4
>  	unsigned char		oo_flags;
>  };
>  
> -- 
> 1.9.3
> 
