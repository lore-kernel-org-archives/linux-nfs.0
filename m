Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49133 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214Ab2LREPv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 23:15:51 -0500
Date: Mon, 17 Dec 2012 23:15:50 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/7] NFSD: Convert the slot table to use a linked list
Message-ID: <20121218041550.GE31843@fieldses.org>
References: <1355251459-18034-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1355251459-18034-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2012 at 01:44:13PM -0500, Trond Myklebust wrote:
> In preparation for the dynamic slot table allocation, convert the nfsd
> slot table to a linked list model.

Thanks!  This looks OK to me.  But as long this is somewhat
experimental, and we're late in the cycle, I'm going to drop this for
now.

--b.

> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfsd/nfs4state.c | 151 +++++++++++++++++++++++++++++++++++++++++-----------
>  fs/nfsd/state.h     |  10 +++-
>  2 files changed, 129 insertions(+), 32 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d0237f8..5717ea1 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -704,15 +704,6 @@ gen_sessionid(struct nfsd4_session *ses)
>   */
>  #define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
>  
> -static void
> -free_session_slots(struct nfsd4_session *ses)
> -{
> -	int i;
> -
> -	for (i = 0; i < ses->se_fchannel.maxreqs; i++)
> -		kfree(ses->se_slots[i]);
> -}
> -
>  /*
>   * We don't actually need to cache the rpc and session headers, so we
>   * can allocate a little less for each slot:
> @@ -758,29 +749,127 @@ static void nfsd4_put_drc_mem(int slotsize, int num)
>  	spin_unlock(&nfsd_drc_lock);
>  }
>  
> -static struct nfsd4_session *__alloc_session(int slotsize, int numslots)
> +static void nfsd4_free_slot(struct nfsd4_slot *slot)
>  {
> -	struct nfsd4_session *new;
> -	int mem, i;
> +	kfree(slot);
> +}
> +
> +static struct nfsd4_slot *nfsd4_new_slot(size_t slotsize, gfp_t gfp_mask)
> +{
> +	return kzalloc(sizeof(struct nfsd4_slot) + slotsize, gfp_mask);
> +}
> +
> +static struct nfsd4_slot *nfsd4_find_slot_locked(const struct nfsd4_slot_table *tbl,
> +		u32 slotid)
> +{
> +	struct nfsd4_slot *slot;
> +
> +	list_for_each_entry(slot, &tbl->slt_head, sl_list) {
> +		if (slot->sl_slotid == slotid)
> +			return slot;
> +	}
> +	return NULL;
> +}
> +
> +static struct nfsd4_slot *nfsd4_find_slot(struct nfsd4_slot_table *tbl,
> +		u32 slotid)
> +{
> +	struct nfsd4_slot *slot;
> +
> +	spin_lock(&tbl->slt_lock);
> +	slot = nfsd4_find_slot_locked(tbl, slotid);
> +	spin_unlock(&tbl->slt_lock);
> +	return slot;
> +}
> +
> +static struct nfsd4_slot *nfsd4_find_last_slot_locked(const struct nfsd4_slot_table *tbl)
> +{
> +	if (list_empty(&tbl->slt_head))
> +		return NULL;
> +	return list_entry(tbl->slt_head.prev, struct nfsd4_slot, sl_list);
> +}
> +
> +static bool nfsd4_grow_slot_table_locked(struct nfsd4_slot_table *tbl,
> +		u32 slotid, gfp_t gfp_mask)
> +{
> +	struct nfsd4_slot *slot = NULL;
> +	struct nfsd4_slot *prev;
> +	u32 next_slotid;
> +
> +	for (;;) {
> +		prev = nfsd4_find_last_slot_locked(tbl);
> +		if (prev != NULL) {
> +			if (prev->sl_slotid >= slotid)
> +				break;
> +			next_slotid = prev->sl_slotid + 1;
> +		} else
> +			next_slotid = 0;
> +		if (slot != NULL){
> +			slot->sl_slotid = next_slotid;
> +			list_add_tail(&slot->sl_list, &tbl->slt_head);
> +		}
> +		spin_unlock(&tbl->slt_lock);
> +		slot = nfsd4_new_slot(tbl->slt_slotsize, gfp_mask);
> +		spin_lock(&tbl->slt_lock);
> +		if (slot == NULL)
> +			return false;
> +	}
> +	nfsd4_free_slot(slot);
> +	return true;
> +}
> +
> +static bool nfsd4_grow_slot_table(struct nfsd4_slot_table *tbl,
> +		u32 slotid, gfp_t gfp_mask)
> +{
> +	bool ret;
> +
> +	spin_lock(&tbl->slt_lock);
> +	ret = nfsd4_grow_slot_table_locked(tbl, slotid, gfp_mask);
> +	spin_unlock(&tbl->slt_lock);
> +	return ret;
> +}
> +
> +static void nfsd4_truncate_slot_table_locked(struct nfsd4_slot_table *tbl,
> +		u32 slotid)
> +{
> +	struct nfsd4_slot *slot;
> +
> +	for (;;) {
> +		slot = nfsd4_find_last_slot_locked(tbl);
> +		if (slot == NULL || slot->sl_slotid < slotid)
> +			break;
> +		list_del(&slot->sl_list);
> +		nfsd4_free_slot(slot);
> +	}
> +}
> +
> +static void nfsd4_free_slot_table(struct nfsd4_slot_table *tbl)
> +{
> +	spin_lock(&tbl->slt_lock);
> +	nfsd4_truncate_slot_table_locked(tbl, 0);
> +	spin_unlock(&tbl->slt_lock);
> +}
> +
> +static void nfsd4_init_slot_table(struct nfsd4_slot_table *tbl, size_t slotsize)
> +{
> +	INIT_LIST_HEAD(&tbl->slt_head);
> +	spin_lock_init(&tbl->slt_lock);
> +	tbl->slt_slotsize = slotsize;
> +}
>  
> -	BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nfsd4_slot *)
> -			+ sizeof(struct nfsd4_session) > PAGE_SIZE);
> -	mem = numslots * sizeof(struct nfsd4_slot *);
> +static struct nfsd4_session *__alloc_session(size_t slotsize, u32 highest_slotid)
> +{
> +	struct nfsd4_session *new;
>  
> -	new = kzalloc(sizeof(*new) + mem, GFP_KERNEL);
> +	new = kzalloc(sizeof(*new), GFP_KERNEL);
>  	if (!new)
>  		return NULL;
> +	nfsd4_init_slot_table(&new->se_slots, slotsize);
>  	/* allocate each struct nfsd4_slot and data cache in one piece */
> -	for (i = 0; i < numslots; i++) {
> -		mem = sizeof(struct nfsd4_slot) + slotsize;
> -		new->se_slots[i] = kzalloc(mem, GFP_KERNEL);
> -		if (!new->se_slots[i])
> -			goto out_free;
> -	}
> -	return new;
> -out_free:
> -	while (i--)
> -		kfree(new->se_slots[i]);
> +	if (nfsd4_grow_slot_table(&new->se_slots, highest_slotid, GFP_KERNEL))
> +		return new;
> +
> +	nfsd4_free_slot_table(&new->se_slots);
>  	kfree(new);
>  	return NULL;
>  }
> @@ -899,7 +988,7 @@ static void nfsd4_del_conns(struct nfsd4_session *s)
>  static void __free_session(struct nfsd4_session *ses)
>  {
>  	nfsd4_put_drc_mem(slot_bytes(&ses->se_fchannel), ses->se_fchannel.maxreqs);
> -	free_session_slots(ses);
> +	nfsd4_free_slot_table(&ses->se_slots);
>  	kfree(ses);
>  }
>  
> @@ -936,7 +1025,7 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan)
>  	if (numslots < 1)
>  		return NULL;
>  
> -	new = __alloc_session(slotsize, numslots);
> +	new = __alloc_session(slotsize, numslots - 1);
>  	if (!new) {
>  		nfsd4_put_drc_mem(slotsize, fchan->maxreqs);
>  		return NULL;
> @@ -2032,11 +2121,11 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	if (nfsd4_request_too_big(rqstp, session))
>  		goto out;
>  
> +	/* Note: nfsd4_find_slot checks the validity of seq->slotid */
>  	status = nfserr_badslot;
> -	if (seq->slotid >= session->se_fchannel.maxreqs)
> +	slot = nfsd4_find_slot(&session->se_slots, seq->slotid);
> +	if (slot == NULL)
>  		goto out;
> -
> -	slot = session->se_slots[seq->slotid];
>  	dprintk("%s: slotid %d\n", __func__, seq->slotid);
>  
>  	/* We do not negotiate the number of slots yet, so set the
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index e036894..7d319e9a 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -128,6 +128,8 @@ static inline struct nfs4_delegation *delegstateid(struct nfs4_stid *s)
>  		(NFSD_CACHE_SIZE_SLOTS_PER_SESSION * NFSD_SLOT_CACHE_SIZE)
>  
>  struct nfsd4_slot {
> +	struct list_head sl_list;
> +	u32	sl_slotid;
>  	u32	sl_seqid;
>  	__be32	sl_status;
>  	u32	sl_datalen;
> @@ -139,6 +141,12 @@ struct nfsd4_slot {
>  	char	sl_data[];
>  };
>  
> +struct nfsd4_slot_table {
> +	struct list_head	slt_head;
> +	spinlock_t		slt_lock;
> +	size_t			slt_slotsize;
> +};
> +
>  struct nfsd4_channel_attrs {
>  	u32		headerpadsz;
>  	u32		maxreq_sz;
> @@ -195,7 +203,7 @@ struct nfsd4_session {
>  	struct list_head	se_conns;
>  	u32			se_cb_prog;
>  	u32			se_cb_seq_nr;
> -	struct nfsd4_slot	*se_slots[];	/* forward channel slots */
> +	struct nfsd4_slot_table	se_slots;
>  };
>  
>  extern void nfsd4_put_session(struct nfsd4_session *ses);
> -- 
> 1.7.11.7
> 
