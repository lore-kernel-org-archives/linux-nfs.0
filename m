Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60108 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423441Ab2LFV3K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 16:29:10 -0500
Date: Thu, 6 Dec 2012 16:29:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Add support for dynamic slot changes
Message-ID: <20121206212908.GB17115@fieldses.org>
References: <1354159063-17343-1-git-send-email-Trond.Myklebust@netapp.com>
 <1354159063-17343-2-git-send-email-Trond.Myklebust@netapp.com>
 <1354159063-17343-3-git-send-email-Trond.Myklebust@netapp.com>
 <1354159063-17343-4-git-send-email-Trond.Myklebust@netapp.com>
 <1354159063-17343-5-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1354159063-17343-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 28, 2012 at 10:17:43PM -0500, Trond Myklebust wrote:
> The algorithm chosen for growing/shrinking the dynamic slot table
> size is as follows:
> 
> If the client is sending a sa_highest_slotid value that is greater than
> or equal to the our server target_highest_slotid, then multiply the
> value of the latter by 5/4.
> 
> If, on the other hand, the sa_highest_slotid value is smaller than
> our target_highest_slotid, then try adjusting the latter to half its
> current value, or to the value of sa_highest_slotid+1, whichever is larger.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfsd/nfs4state.c | 72 +++++++++++++++++++++++++++++++++++++++++++++++++----
>  fs/nfsd/state.h     |  2 ++
>  2 files changed, 69 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a1208cc..88d0de9 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -807,6 +807,7 @@ static bool nfsd4_grow_slot_table_locked(struct nfsd4_slot_table *tbl,
>  		if (slot != NULL){
>  			if (!nfsd4_get_drc_mem(tbl))
>  				break;
> +			slot->sl_generation = tbl->slt_generation - 1;
>  			slot->sl_slotid = next_slotid;
>  			list_add_tail(&slot->sl_list, &tbl->slt_head);
>  		}
> @@ -853,6 +854,30 @@ static void nfsd4_free_slot_table(struct nfsd4_slot_table *tbl)
>  	spin_unlock(&tbl->slt_lock);
>  }
>  
> +static void nfsd4_fc_set_highest_slotid_locked(struct nfsd4_session *session,
> +		struct nfsd4_slot_table *tbl,
> +		u32 target_highest_slotid,
> +		u32 highest_slotid)
> +{
> +	/* Lower limit for target_highest_slotid is negotiated limit */
> +	target_highest_slotid = max(target_highest_slotid,
> +			session->se_fchannel.maxreqs - 1);
> +	/* Lower limit for highest_slotid is target_highest_slotid */
> +	highest_slotid = max(highest_slotid, target_highest_slotid);
> +
> +	if (target_highest_slotid == tbl->slt_target_highest_slotid &&
> +			highest_slotid == tbl->slt_highest_slotid)
> +		return;
> +
> +	if (!nfsd4_grow_slot_table_locked(tbl, highest_slotid, GFP_KERNEL))
> +		return;
> +
> +	tbl->slt_target_highest_slotid = target_highest_slotid;
> +	tbl->slt_highest_slotid = highest_slotid;
> +	tbl->slt_generation++;
> +	nfsd4_truncate_slot_table_locked(tbl, tbl->slt_highest_slotid);
> +}
> +
>  static void nfsd4_init_slot_table(struct nfsd4_slot_table *tbl,
>  		size_t slotsize, u32 highest_slotid)
>  {
> @@ -2039,6 +2064,45 @@ out:
>  	return status;
>  }
>  
> +static void nfsd4_sequence_adjust_slot_table(struct nfsd4_session *session,
> +		struct nfsd4_slot *slot, u32 sa_highest_slotid,
> +		struct nfsd4_sequence *res)
> +{
> +	struct nfsd4_slot_table *tbl = &session->se_slots;
> +	u32 next_target;
> +	u32 next_highest;
> +
> +	spin_lock(&tbl->slt_lock);
> +	/*
> +	 * If this slot hasn't seen our previous values, then don't trust
> +	 * that the client has seen them. Don't adjust the slot table yet.
> +	 */
> +	if (slot->sl_generation != tbl->slt_generation)
> +		goto out;
> +
> +	next_target = tbl->slt_target_highest_slotid;
> +
> +	/* Is the client bumping against our current window limits? */
> +	if (sa_highest_slotid >= tbl->slt_target_highest_slotid) {
> +		/* Yes! Grow the window size by 1/4 */
> +		next_target += 1 + (tbl->slt_target_highest_slotid >> 2);
> +		next_highest = next_target;
> +	} else {
> +		/* No! Try to shrink the window size by 1/2 */
> +		next_target >>= 1;
> +		if (sa_highest_slotid + 1 > next_target)
> +			next_target = sa_highest_slotid + 1;
> +		next_highest = tbl->slt_target_highest_slotid;
> +	}
> +	nfsd4_fc_set_highest_slotid_locked(session, tbl,
> +			next_target, next_highest);
> +out:
> +	slot->sl_generation = tbl->slt_generation;
> +	res->highest_slotid = tbl->slt_highest_slotid;
> +	res->target_highest_slotid = tbl->slt_target_highest_slotid;
> +	spin_unlock(&tbl->slt_lock);
> +}
> +
>  static struct nfsd4_conn *__nfsd4_find_conn(struct svc_xprt *xpt, struct nfsd4_session *s)
>  {
>  	struct nfsd4_conn *c;
> @@ -2159,11 +2223,9 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	else
>  		slot->sl_flags &= ~NFSD4_SLOT_CACHETHIS;
>  
> -	/* Retrieve new target/highest slotid values */
> -	spin_lock(&session->se_slots.slt_lock);
> -	seq->target_highest_slotid = session->se_slots.slt_target_highest_slotid;
> -	seq->highest_slotid = session->se_slots.slt_highest_slotid;
> -	spin_unlock(&session->se_slots.slt_lock);
> +	/* Adjust slot table, and retrieve new target/highest slotid values */
> +	nfsd4_sequence_adjust_slot_table(session, slot,
> +			seq->highest_slotid, seq);

This is allocating under a spin lock (see the client_lock that most of
nfsd4_sequence is under.)

(But I'm not sure what we should be doing instead.)

--b.

>  
>  	cstate->slot = slot;
>  	cstate->session = session;
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 7a0d8e4..c2f897f 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -129,6 +129,7 @@ static inline struct nfs4_delegation *delegstateid(struct nfs4_stid *s)
>  
>  struct nfsd4_slot {
>  	struct list_head sl_list;
> +	unsigned long sl_generation;
>  	u32	sl_slotid;
>  	u32	sl_seqid;
>  	__be32	sl_status;
> @@ -146,6 +147,7 @@ struct nfsd4_slot_table {
>  	spinlock_t		slt_lock;
>  	size_t			slt_slotsize;
>  	unsigned long		slt_memused;
> +	unsigned long		slt_generation;
>  	u32			slt_target_highest_slotid;
>  	u32			slt_highest_slotid;
>  };
> -- 
> 1.7.11.7
> 
