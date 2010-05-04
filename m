From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [RFC 3/3] nfsd4: do not expire nfs41 clients while in use
Date: Tue, 04 May 2010 08:39:56 +0300
Message-ID: <4BDFB32C.7080107@panasas.com>
References: <4BDEF641.4020507@panasas.com> <1272904313-27145-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:35419 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038Ab0EDFkA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 May 2010 01:40:00 -0400
Received: by bwz9 with SMTP id 9so1873076bwz.29
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 22:39:58 -0700 (PDT)
In-Reply-To: <1272904313-27145-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny Halevy wrote:
> Add a cl_use_count atomic counter to struct nfs4_client.
> Hold a use count while the client is in use by a compound that begins
> with SEQUENCE.
> Renew the client when the comound completes.
> The laundromat skips clients that have a positive use count.
> Otherwise, the laundromat marks the client as expired by setting
> cl_use_count to -1.
> 
> Note that we don't want to use the state lock to synchronize with nfsd4_sequence
> as we want to diminish the state lock scope.
> An alternative to using atomic_cmpxchg is to grab the sessionid_lock spin lock
> while accessing cl_use_count, but that would cause some contention in the
> laundromat if it needs to lock and unlock it for every client.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |   40 ++++++++++++++++++++++++++++++++++------
>  fs/nfsd/nfs4xdr.c   |    2 ++
>  fs/nfsd/state.h     |    9 +++++++++
>  3 files changed, 45 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 50b75af..c95ddca 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -647,6 +647,14 @@ renew_client(struct nfs4_client *clp)
>  	clp->cl_time = get_seconds();
>  }
>  
> +void
> +renew_nfs4_client(struct nfs4_client *clp)
> +{
> +	nfs4_lock_state();
> +	renew_client(clp);
> +	nfs4_unlock_state();
> +}
> +
>  /* SETCLIENTID and SETCLIENTID_CONFIRM Helper functions */
>  static int
>  STALE_CLIENTID(clientid_t *clid)
> @@ -715,6 +723,24 @@ put_nfs4_client(struct nfs4_client *clp)
>  		free_client(clp);
>  }
>  
> +/*
> + * atomically mark client as used, as long as it's not already expired.
> + * return 0 on success, or a negative value if client already expired.
> + */
> +int
> +use_nfs4_client(struct nfs4_client *clp)
> +{
> +	int orig;
> +
> +	do {
> +		orig = atomic_read(&clp->cl_use_count);
> +		if (orig < 0)
> +			return orig;
> +	} while (atomic_cmpxchg(&clp->cl_use_count, orig, orig + 1) != orig);
> +
> +	return 0;
> +}
> +
>  static void
>  expire_client(struct nfs4_client *clp)
>  {
> @@ -840,6 +866,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
>  
>  	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
>  	atomic_set(&clp->cl_count, 1);
> +	atomic_set(&clp->cl_use_count, 0);
>  	atomic_set(&clp->cl_cb_conn.cb_set, 0);
>  	INIT_LIST_HEAD(&clp->cl_idhash);
>  	INIT_LIST_HEAD(&clp->cl_strhash);
> @@ -1423,6 +1450,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	if (!session)
>  		goto out;
>  
> +	/* keep the client from expiring */
> +	if (use_nfs4_client(cstate->session->se_client) < 0)
> +		goto out;
> +
>  	status = nfserr_badslot;
>  	if (seq->slotid >= session->se_fchannel.maxreqs)
>  		goto out;
> @@ -1463,12 +1494,6 @@ out:
>  		get_nfs4_client(cstate->session->se_client);
>  	}
>  	spin_unlock(&sessionid_lock);
> -	/* Renew the clientid on success and on replay */
> -	if (cstate->session) {
> -		nfs4_lock_state();
> -		renew_client(session->se_client);
> -		nfs4_unlock_state();
> -	}
>  	dprintk("%s: return %d\n", __func__, ntohl(status));
>  	return status;
>  }
> @@ -2575,6 +2600,9 @@ nfs4_laundromat(void)
>  		nfsd4_end_grace();
>  	list_for_each_safe(pos, next, &client_lru) {
>  		clp = list_entry(pos, struct nfs4_client, cl_lru);
> +		/* skip client if in use (cl_use_count is greater than zero) */
> +		if (atomic_cmpxchg(&clp->cl_use_count, 0, -1) > 0)
> +			continue;

I'll move that check after the time comparison
since there's no need for the atomic instruction if the client's
time out hasn't expired yet.

Benny

>  		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
>  			t = clp->cl_time - cutoff;
>  			if (clientid_val > t)
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index aed733c..0f0b857 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3313,6 +3313,8 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
>  			cs->slot->sl_inuse = false;
>  		}
> +		renew_nfs4_client(cs->session->se_client);
> +		unuse_nfs4_client(cs->session->se_client);
>  		put_nfs4_client(cs->session->se_client);
>  		nfsd4_put_session(cs->session);
>  	}
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index e3c002e..806d9b8 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -214,6 +214,7 @@ struct nfs4_client {
>  	nfs4_verifier		cl_confirm;	/* generated by server */
>  	struct nfs4_cb_conn	cl_cb_conn;     /* callback info */
>  	atomic_t		cl_count;	/* ref count */
> +	atomic_t		cl_use_count;	/* session use count */
>  	u32			cl_firststate;	/* recovery dir creation */
>  
>  	/* for nfs41 */
> @@ -237,6 +238,12 @@ get_nfs4_client(struct nfs4_client *clp)
>  	atomic_inc(&clp->cl_count);
>  }
>  
> +static inline void
> +unuse_nfs4_client(struct nfs4_client *clp)
> +{
> +	atomic_dec(&clp->cl_use_count);
> +}
> +
>  /* struct nfs4_client_reset
>   * one per old client. Populates reset_str_hashtbl. Filled from conf_id_hashtbl
>   * upon lease reset, or from upcall to state_daemon (to read in state
> @@ -384,6 +391,8 @@ extern void nfs4_unlock_state(void);
>  extern int nfs4_in_grace(void);
>  extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
>  extern void put_nfs4_client(struct nfs4_client *clp);
> +extern int use_nfs4_client(struct nfs4_client *clp);
> +extern void renew_nfs4_client(struct nfs4_client *clp);
>  extern void nfs4_free_stateowner(struct kref *kref);
>  extern int set_callback_cred(void);
>  extern void nfsd4_probe_callback(struct nfs4_client *clp);

