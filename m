From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/44] nfsd41: move channel attributes from
	nfsd4_session to a nfsd4_channel_attr struct
Date: Tue, 16 Jun 2009 13:17:17 -0400
Message-ID: <20090616171717.GA2272@fieldses.org>
References: <1245115153-6832-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48808 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758222AbZFPRRR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 13:17:17 -0400
In-Reply-To: <1245115153-6832-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:19:13AM +0300, Benny Halevy wrote:
> From: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
> 
> the change is valid for both the forechannel and the backchannel (currently dummy)

Thanks, applied.

--b.

> 
> Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c        |   28 +++++++++++++++-------------
>  fs/nfsd/nfs4xdr.c          |    2 +-
>  include/linux/nfsd/state.h |   18 +++++++++++++-----
>  include/linux/nfsd/xdr4.h  |   11 -----------
>  4 files changed, 29 insertions(+), 30 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b276624..d2851cc 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -444,8 +444,8 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
>   * fchan holds the client values on input, and the server values on output
>   */
>  static int init_forechannel_attrs(struct svc_rqst *rqstp,
> -				    struct nfsd4_session *session,
> -				    struct nfsd4_channel_attrs *fchan)
> +				  struct nfsd4_channel_attrs *session_fchan,
> +				  struct nfsd4_channel_attrs *fchan)
>  {
>  	int status = 0;
>  	__u32   maxcount = svc_max_payload(rqstp);
> @@ -455,21 +455,21 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
>  	/* Use the client's max request and max response size if possible */
>  	if (fchan->maxreq_sz > maxcount)
>  		fchan->maxreq_sz = maxcount;
> -	session->se_fmaxreq_sz = fchan->maxreq_sz;
> +	session_fchan->maxreq_sz = fchan->maxreq_sz;
>  
>  	if (fchan->maxresp_sz > maxcount)
>  		fchan->maxresp_sz = maxcount;
> -	session->se_fmaxresp_sz = fchan->maxresp_sz;
> +	session_fchan->maxresp_sz = fchan->maxresp_sz;
>  
>  	/* Set the max response cached size our default which is
>  	 * a multiple of PAGE_SIZE and small */
> -	session->se_fmaxresp_cached = NFSD_PAGES_PER_SLOT * PAGE_SIZE;
> -	fchan->maxresp_cached = session->se_fmaxresp_cached;
> +	session_fchan->maxresp_cached = NFSD_PAGES_PER_SLOT * PAGE_SIZE;
> +	fchan->maxresp_cached = session_fchan->maxresp_cached;
>  
>  	/* Use the client's maxops if possible */
>  	if (fchan->maxops > NFSD_MAX_OPS_PER_COMPOUND)
>  		fchan->maxops = NFSD_MAX_OPS_PER_COMPOUND;
> -	session->se_fmaxops = fchan->maxops;
> +	session_fchan->maxops = fchan->maxops;
>  
>  	/* try to use the client requested number of slots */
>  	if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
> @@ -481,7 +481,7 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
>  	 */
>  	status = set_forechannel_maxreqs(fchan);
>  
> -	session->se_fnumslots = fchan->maxreqs;
> +	session_fchan->maxreqs = fchan->maxreqs;
>  	return status;
>  }
>  
> @@ -495,12 +495,14 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
>  	memset(&tmp, 0, sizeof(tmp));
>  
>  	/* FIXME: For now, we just accept the client back channel attributes. */
> -	status = init_forechannel_attrs(rqstp, &tmp, &cses->fore_channel);
> +	tmp.se_bchannel = cses->back_channel;
> +	status = init_forechannel_attrs(rqstp, &tmp.se_fchannel,
> +					&cses->fore_channel);
>  	if (status)
>  		goto out;
>  
>  	/* allocate struct nfsd4_session and slot table in one piece */
> -	slotsize = tmp.se_fnumslots * sizeof(struct nfsd4_slot);
> +	slotsize = tmp.se_fchannel.maxreqs * sizeof(struct nfsd4_slot);
>  	new = kzalloc(sizeof(*new) + slotsize, GFP_KERNEL);
>  	if (!new)
>  		goto out;
> @@ -574,7 +576,7 @@ free_session(struct kref *kref)
>  	int i;
>  
>  	ses = container_of(kref, struct nfsd4_session, se_ref);
> -	for (i = 0; i < ses->se_fnumslots; i++) {
> +	for (i = 0; i < ses->se_fchannel.maxreqs; i++) {
>  		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
>  		nfsd4_release_respages(e->ce_respages, e->ce_resused);
>  	}
> @@ -1131,7 +1133,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
>  	 * is sent (lease renewal).
>  	 */
>  	if (seq && nfsd4_not_cached(resp)) {
> -		seq->maxslots = resp->cstate.session->se_fnumslots;
> +		seq->maxslots = resp->cstate.session->se_fchannel.maxreqs;
>  		return nfs_ok;
>  	}
>  
> @@ -1474,7 +1476,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  		goto out;
>  
>  	status = nfserr_badslot;
> -	if (seq->slotid >= session->se_fnumslots)
> +	if (seq->slotid >= session->se_fchannel.maxreqs)
>  		goto out;
>  
>  	slot = &session->se_slots[seq->slotid];
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index ab005fc..c4eda89 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3191,7 +3191,7 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
>  	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
>  		length, xb->page_len, tlen, pad);
>  
> -	if (length <= session->se_fmaxresp_cached)
> +	if (length <= session->se_fchannel.maxresp_cached)
>  		return status;
>  	else
>  		return nfserr_rep_too_big_to_cache;
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index c0c4921..105cc10 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -115,6 +115,17 @@ struct nfsd4_slot {
>  	struct nfsd4_cache_entry	sl_cache_entry;
>  };
>  
> +struct nfsd4_channel_attrs {
> +	u32		headerpadsz;
> +	u32		maxreq_sz;
> +	u32		maxresp_sz;
> +	u32		maxresp_cached;
> +	u32		maxops;
> +	u32		maxreqs;
> +	u32		nr_rdma_attrs;
> +	u32		rdma_attrs;
> +};
> +
>  struct nfsd4_session {
>  	struct kref		se_ref;
>  	struct list_head	se_hash;	/* hash by sessionid */
> @@ -122,11 +133,8 @@ struct nfsd4_session {
>  	u32			se_flags;
>  	struct nfs4_client	*se_client;	/* for expire_client */
>  	struct nfs4_sessionid	se_sessionid;
> -	u32			se_fmaxreq_sz;
> -	u32			se_fmaxresp_sz;
> -	u32			se_fmaxresp_cached;
> -	u32			se_fmaxops;
> -	u32			se_fnumslots;
> +	struct nfsd4_channel_attrs se_fchannel;
> +	struct nfsd4_channel_attrs se_bchannel;
>  	struct nfsd4_slot	se_slots[];	/* forward channel slots */
>  };
>  
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index d0f050f..2bacf75 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -366,17 +366,6 @@ struct nfsd4_exchange_id {
>  	int		spa_how;
>  };
>  
> -struct nfsd4_channel_attrs {
> -	u32		headerpadsz;
> -	u32		maxreq_sz;
> -	u32		maxresp_sz;
> -	u32		maxresp_cached;
> -	u32		maxops;
> -	u32		maxreqs;
> -	u32		nr_rdma_attrs;
> -	u32		rdma_attrs;
> -};
> -
>  struct nfsd4_create_session {
>  	clientid_t		clientid;
>  	struct nfs4_sessionid	sessionid;
> -- 
> 1.6.3
> 
