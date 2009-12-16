From: " J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [RFC 04/11] nfsd: mark client for renew
Date: Wed, 16 Dec 2009 15:48:39 -0500
Message-ID: <20091216204839.GA28822@fieldses.org>
References: <4B291B4C.3060603@panasas.com> <1260985272-21481-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50647 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbZLPUse (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2009 15:48:34 -0500
In-Reply-To: <1260985272-21481-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 16, 2009 at 07:41:12PM +0200, Benny Halevy wrote:
> Mark the nfs4_client for renew on operations holding a stateid (or nfs41
> OP_SEQUENCE).
> Do the actual lru list update when the compound processing is complete.
> This will prevents the client from being expired by the laundromat while
> the compound is in progress.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4proc.c  |    5 +++++
>  fs/nfsd/nfs4state.c |   39 +++++++++++++++++++++++++++++++++++----
>  fs/nfsd/state.h     |    1 +
>  fs/nfsd/xdr4.h      |    1 +
>  4 files changed, 42 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 37514c4..a8e9731 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1010,6 +1010,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  	resp->opcnt = 0;
>  	resp->rqstp = rqstp;
>  	resp->cstate.minorversion = args->minorversion;
> +	resp->cstate.renew_client = NULL;
>  	resp->cstate.replay_owner = NULL;
>  	fh_init(&resp->cstate.current_fh, NFS4_FHSIZE);
>  	fh_init(&resp->cstate.save_fh, NFS4_FHSIZE);
> @@ -1114,6 +1115,10 @@ encode_op:
>  	fh_put(&resp->cstate.current_fh);
>  	fh_put(&resp->cstate.save_fh);
>  	BUG_ON(resp->cstate.replay_owner);
> +	if (resp->cstate.renew_client) {
> +		renew_client(resp->cstate.renew_client);
> +		put_nfs4_client(resp->cstate.renew_client);
> +	}
>  out:
>  	nfsd4_release_compoundargs(args);
>  	/* Reset deferral mechanism for RPC deferrals */
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c456551..16ccab3 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -634,8 +634,39 @@ free_session(struct kref *kref)
>  }
>  
>  static inline void
> +mark_client_for_renew(struct nfsd4_compound_state *cstate,
> +		      struct nfs4_client *clp)
> +{
> +	int old_state = atomic_cmpxchg(&clp->cl_state, CL_STATE_NORMAL,
> +				       CL_STATE_RENEW);
> +
> +	if (old_state != CL_STATE_EXPIRED) {
> +		cstate->renew_client = clp;
> +		get_nfs4_client(clp);

If cstate->renew_client is already set, then we may leak a reference
count here, right?

Also: at least in the v4 case, I don't think there's anything preventing
cstate->renew_client being already set to a different client.  (With
sessions hopefully that's not possible.)

This patch doesn't appear to stand alone as it removes the client
renewals without yet replacing them by anything.

--b.

> +	}
> +
> +	dprintk("%s: client (clientid %08x/%08x) %s\n",
> +		__func__,
> +		clp->cl_clientid.cl_boot,
> +		clp->cl_clientid.cl_id,
> +		old_state == CL_STATE_EXPIRED ? "already expired" :
> +						"marked for renew");
> +}
> +
> +void
>  renew_client(struct nfs4_client *clp)
>  {
> +	int old_state = atomic_cmpxchg(&clp->cl_state, CL_STATE_RENEW,
> +				       CL_STATE_NORMAL);
> +
> +	if (old_state == CL_STATE_EXPIRED) {
> +		dprintk("%s: client (clientid %08x/%08x) already expired\n",
> +			__func__,
> +			clp->cl_clientid.cl_boot,
> +			clp->cl_clientid.cl_id);
> +		return;
> +	}
> +
>  	/*
>  	* Move client to the end to the LRU list.
>  	*/
> @@ -1471,7 +1502,7 @@ out:
>  	/* Renew the clientid on success and on replay */
>  	if (cstate->session) {
>  		nfs4_lock_state();
> -		renew_client(session->se_client);
> +		mark_client_for_renew(cstate, session->se_client);
>  		nfs4_unlock_state();
>  	}
>  	dprintk("%s: return %d\n", __func__, ntohl(status));
> @@ -2830,7 +2861,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
>  		status = nfs4_check_delegmode(dp, flags);
>  		if (status)
>  			goto out;
> -		renew_client(dp->dl_client);
> +		mark_client_for_renew(cstate, dp->dl_client);
>  		if (filpp)
>  			*filpp = dp->dl_vfs_file;
>  	} else { /* open or lock stateid */
> @@ -2850,7 +2881,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
>  		status = nfs4_check_openmode(stp, flags);
>  		if (status)
>  			goto out;
> -		renew_client(stp->st_stateowner->so_client);
> +		mark_client_for_renew(cstate, stp->st_stateowner->so_client);
>  		if (filpp)
>  			*filpp = stp->st_vfs_file;
>  	}
> @@ -2970,7 +3001,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
>  	status = check_stateid_generation(stateid, &stp->st_stateid, flags);
>  	if (status)
>  		return status;
> -	renew_client(sop->so_client);
> +	mark_client_for_renew(cstate, sop->so_client);
>  	return nfs_ok;
>  
>  check_replay:
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 21109d4..b684c84 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -385,6 +385,7 @@ extern void nfs4_lock_state(void);
>  extern void nfs4_unlock_state(void);
>  extern int nfs4_in_grace(void);
>  extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
> +extern void renew_client(struct nfs4_client *);
>  extern void get_nfs4_client(struct nfs4_client *);
>  extern void put_nfs4_client(struct nfs4_client *clp);
>  extern void nfs4_free_stateowner(struct kref *kref);
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index efa3377..e48d5c7 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -46,6 +46,7 @@
>  struct nfsd4_compound_state {
>  	struct svc_fh		current_fh;
>  	struct svc_fh		save_fh;
> +	struct nfs4_client	*renew_client;
>  	struct nfs4_stateowner	*replay_owner;
>  	/* For sessions DRC */
>  	struct nfsd4_session	*session;
> -- 
> 1.6.5.1
> 
