From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 25/47] nfsd41: non-page DRC for solo sequence
	responses
Date: Wed, 1 Apr 2009 00:12:12 -0400
Message-ID: <20090401041212.GC28096@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229191-11047-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34394 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbZDAEMV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 00:12:21 -0400
In-Reply-To: <1238229191-11047-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2009 at 11:33:11AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> A session inactivity time compound (lease renewal) or a compound where the
> sequence operation has sa_cachethis set to FALSE do not require any pages
> to be held in the v4.1 DRC. This is because struct nfsd4_slot is already
> caching the session information.
> 
> Add logic to the nfs41 server to not cache response pages for solo sequence
> responses.
> 
> Return nfserr_replay_uncached_rep on the operation following the sequence
> operation when sa_cachethis is FALSE.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4proc.c         |   34 +++++++++++++++++++++++++++++-
>  fs/nfsd/nfs4state.c        |   47 ++++++++++++++++++++++++++++++++++++++-----
>  fs/nfsd/nfs4xdr.c          |    5 ++-
>  include/linux/nfsd/state.h |    1 +
>  include/linux/nfsd/xdr4.h  |   15 +++++++++++++-
>  5 files changed, 91 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index bdbeb87..a273023 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -828,6 +828,34 @@ static struct nfsd4_operation nfsd4_ops[];
>  static const char *nfsd4_op_name(unsigned opnum);
>  
>  /*
> + * This is a replay of a compound for which no cache entry pages
> + * were used. Encode the sequence operation, and if cachethis is FALSE
> + * encode the uncache rep error on the next operation.
> + */
> +static __be32
> +nfsd4_enc_no_page_replay(struct nfsd4_compoundargs *args,
> +			 struct nfsd4_compoundres *resp)
> +{
> +	struct nfsd4_op *op;
> +
> +	dprintk("--> %s resp->opcnt %d ce_cachethis %u \n", __func__,
> +		resp->opcnt, resp->cstate.slot->sl_cache_entry.ce_cachethis);
> +
> +	/* Encode the replayed sequence operation */
> +	BUG_ON(resp->opcnt != 1);
> +	op = &args->ops[resp->opcnt - 1];
> +	nfsd4_encode_operation(resp, op);
> +
> +	/*return nfserr_retry_uncached_rep in next operation. */
> +	if (resp->cstate.slot->sl_cache_entry.ce_cachethis == 0) {
> +		op = &args->ops[resp->opcnt++];
> +		op->status = nfserr_retry_uncached_rep;
> +		nfsd4_encode_operation(resp, op);

Encoding both operations here makes me very nervous, but I haven't
thought it through.

> +	}
> +	return op->status;
> +}
> +
> +/*
>   * COMPOUND call.
>   */
>  static __be32
> @@ -879,7 +907,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  		dprintk("nfsv4 compound op #%d/%d: %d (%s)\n",
>  			resp->opcnt, args->opcnt, op->opnum,
>  			nfsd4_op_name(op->opnum));
> -
>  		/*
>  		 * The XDR decode routines may have pre-set op->status;
>  		 * for example, if there is a miscellaneous XDR error
> @@ -923,7 +950,10 @@ encode_op:
>  		/* Only from SEQUENCE or CREATE_SESSION */
>  		if (resp->cstate.status == nfserr_replay_cache) {
>  			dprintk("%s NFS4.1 replay from cache\n", __func__);
> -			status = op->status;
> +			if (nfsd4_no_page_in_cache(resp))

Why not just call that nfsd4_not_cached()?

> +				status = nfsd4_enc_no_page_replay(args, resp);

and nfsd4_enc_uncached_replay()?  (The "no_page" this is a technical
detail of the current caching implementation.)

> +			else
> +				status = op->status;
>  			goto out;
>  		}
>  		if (op->status == nfserr_replay_me) {
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 61af434..f42cda9 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1068,17 +1068,31 @@ nfsd4_set_cache_entry(struct nfsd4_compoundres *resp)
>  	/* Don't cache a failed OP_SEQUENCE. */
>  	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
>  		return;
> +
>  	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
> +	entry->ce_opcnt = resp->opcnt;
> +	entry->ce_status = resp->cstate.status;
> +
> +	/*
> +	 * Don't need a page to cache just the sequence operation - the slot
> +	 * does this for us!
> +	 */
> +
> +	if (nfsd4_no_page_in_cache(resp)) {
> +		entry->ce_resused = 0;
> +		entry->ce_rpchdrlen = 0;
> +		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
> +			resp->cstate.slot->sl_cache_entry.ce_cachethis);
> +		return;
> +	}

Do we *ever* actually need to cache the initial sequence op?  Should we
only be storing subsequent ops in the reply cache?

>  	entry->ce_resused = rqstp->rq_resused;
>  	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
>  		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
>  	nfsd4_move_pages(entry->ce_respages, rqstp->rq_respages,
>  			 entry->ce_resused);
> -	entry->ce_status = resp->cstate.status;
>  	entry->ce_datav.iov_base = resp->cstate.statp;
>  	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->cstate.statp -
>  				(char *)page_address(rqstp->rq_respages[0]));
> -	entry->ce_opcnt = resp->opcnt;
>  	/* Current request rpc header length*/
>  	entry->ce_rpchdrlen = (char *)resp->cstate.statp -
>  				(char *)page_address(rqstp->rq_respages[0]);
> @@ -1117,13 +1131,28 @@ nfsd41_copy_replay_data(struct nfsd4_compoundres *resp,
>   * cached page.  Replace any futher replay pages from the cache.
>   */
>  __be32
> -nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp)
> +nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
> +			 struct nfsd4_sequence *seq)
>  {
>  	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
>  	__be32 status;
>  
>  	dprintk("--> %s entry %p\n", __func__, entry);
>  
> +	/*
> +	 * If this is just the sequence operation, we did not keep
> +	 * a page in the cache entry because we can just use the
> +	 * slot info stored in struct nfsd4_sequence that was checked
> +	 * against the slot in nfsd4_sequence().
> +	 *
> +	 * This occurs when seq->cachethis is FALSE, or when the client
> +	 * session inactivity timer fires and a solo sequence operation
> +	 * is sent (lease renewal).
> +	 */
> +	if (seq && nfsd4_no_page_in_cache(resp)) {
> +		seq->maxslots = resp->cstate.slot->sl_session->se_fnumslots;
> +		return nfs_ok;
> +	}
>  
>  	if (!nfsd41_copy_replay_data(resp, entry)) {
>  		/*
> @@ -1347,7 +1376,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  			cstate->slot = slot;
>  			cstate->status = status;
>  			/* Return the cached reply status */
> -			status = nfsd4_replay_cache_entry(resp);
> +			status = nfsd4_replay_cache_entry(resp, NULL);
>  			goto out;
>  		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
>  			status = nfserr_seq_misordered;
> @@ -1397,6 +1426,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  
>  	slot->sl_inuse = true;
>  	cstate->slot = slot;
> +	/* Ensure a page is used for the cache */
> +	slot->sl_cache_entry.ce_cachethis = 1;
>  out:
>  	nfs4_unlock_state();
>  	dprintk("%s returns %d\n", __func__, ntohl(status));
> @@ -1441,8 +1472,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	if (status == nfserr_replay_cache) {
>  		cstate->slot = slot;
>  		/* Return the cached reply status and set cstate->status
> -		 * for nfsd4_svc_encode_compoundres processing*/
> -		status = nfsd4_replay_cache_entry(resp);
> +		 * for nfsd4_svc_encode_compoundres processing */

The comment typo-fix doesn't belong in this patch.

> +		status = nfsd4_replay_cache_entry(resp, seq);
>  		cstate->status = nfserr_replay_cache;
>  		goto replay_cache;
>  	}
> @@ -1452,6 +1483,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	/* Success! bump slot seqid */
>  	slot->sl_inuse = true;
>  	slot->sl_seqid = seq->seqid;
> +	slot->sl_cache_entry.ce_cachethis = seq->cachethis;
> +	/* Always set the cache entry cachethis for solo sequence */
> +	if (nfsd4_is_solo_sequence(resp))
> +		slot->sl_cache_entry.ce_cachethis = 1;
>  
>  	cstate->slot = slot;
>  
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 60db854..a8bb04a 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2984,7 +2984,7 @@ nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
>  	return nfserr;
>  }
>  
> -static __be32
> +__be32
>  nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
>  		      struct nfsd4_sequence *seq)
>  {
> @@ -3204,7 +3204,8 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  	BUG_ON(iov->iov_len > PAGE_SIZE);
>  #ifdef CONFIG_NFSD_V4_1
>  	if (resp->cstate.slot != NULL) {
> -		if (resp->cstate.status == nfserr_replay_cache) {
> +		if (resp->cstate.status == nfserr_replay_cache &&
> +				!nfsd4_no_page_in_cache(resp)) {
>  			iov->iov_len = resp->cstate.iovlen;
>  		} else {
>  			nfsd4_set_cache_entry(resp);
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 49d89fd..47c7836 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -110,6 +110,7 @@ struct nfsd4_cache_entry {
>  	__be32		ce_status;
>  	struct kvec	ce_datav; /* encoded NFSv4.1 data in rq_res.head[0] */
>  	struct page	*ce_respages[NFSD_PAGES_PER_SLOT + 1];
> +	int		ce_cachethis;
>  	short		ce_resused;
>  	int		ce_opcnt;
>  	int		ce_rpchdrlen;
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index c7bf0a1..641e5cd 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -482,6 +482,18 @@ struct nfsd4_compoundres {
>  	struct nfsd4_compound_state	cstate;
>  };
>  
> +static inline u32 nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
> +{
> +	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
> +	return args->opcnt == 1 ? 1 : 0;

Drop the redundant "? 1: 0", and make the return int (or boolean, if you
want).

> +}
> +
> +static inline u32 nfsd4_no_page_in_cache(struct nfsd4_compoundres *resp)

Ditto on the return type.

> +{
> +	return (resp->cstate.slot->sl_cache_entry.ce_cachethis == 0 ||
> +			nfsd4_is_solo_sequence(resp));

Drop the extra parentheses.

--b.

> +}
> +
>  #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
>  
>  static inline void
> @@ -513,7 +525,8 @@ extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  		struct nfsd4_setclientid_confirm *setclientid_confirm);
>  #if defined(CONFIG_NFSD_V4_1)
>  extern void nfsd4_set_cache_entry(struct nfsd4_compoundres *resp);
> -extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp);
> +extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
> +		struct nfsd4_sequence *seq);
>  extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
>  		struct nfsd4_compound_state *,
>  struct nfsd4_exchange_id *);
> -- 
> 1.6.2.1
> 
