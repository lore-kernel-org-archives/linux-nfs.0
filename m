From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 20/85] nfs41: slot table init and destroy
Date: Mon, 17 Nov 2008 15:46:23 +0200
Message-ID: <492175AF.8080708@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348480-7851-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:17401 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751751AbYKQNq1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:46:27 -0500
In-Reply-To: <1226348480-7851-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:21 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Code to initialize and destroy the slot table.
> Uses bitmap-based allocation.
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c            |   88 ++++++++++++++++++++++++++++++++++++++++++
>  include/linux/nfs4_session.h |   17 ++++++++
>  2 files changed, 105 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d0b6ca1..08e7129 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3683,6 +3683,92 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
>  }
>  
>  #ifdef CONFIG_NFS_V4_1
> +/*
> + * Initialize slot table
> + *
> + * Note: the "used" bitmap points to _used_slots id max_slots <= BITS_PER_LONG.
> + * Otherwise, we dynamically allocate enough ulongs to hold max_slots bits.
> + */
> +static int nfs4_init_slot_table(struct nfs4_channel *channel)
> +{
> +	struct nfs4_slot_table *tbl = &channel->slot_table;
> +	int i, max_slots = channel->chan_attrs.max_reqs;
> +	struct nfs4_slot *slot;
> +	unsigned long *used;
> +	int ret = -ENOMEM;
> +
> +	dprintk("--> %s: max_reqs=%u\n", __func__,
> +		channel->chan_attrs.max_reqs);
> +	slot = kzalloc(max_slots * sizeof(struct nfs4_slot), GFP_ATOMIC);
> +	if (!slot)
> +		goto out;
> +	for (i = 0; i < max_slots; ++i)
> +		slot[i].seq_nr = 1;
> +
> +	if (max_slots <= BITS_PER_LONG)
> +		used = &tbl->_used_slots;	/* use word in tbl */
> +	else {
> +		/* allocate enough unsigned longs for max_slots bits */
> +		used = kzalloc(sizeof(unsigned long) *
> +				DIV_ROUND_UP(max_slots, BITS_PER_LONG),
> +			       GFP_ATOMIC);
> +		if (!used)
> +			goto out_free;
> +	}
> +	ret = 0;
> +
> +	spin_lock(&tbl->slot_tbl_lock);
> +	if (tbl->slots != NULL) {
> +		spin_unlock(&tbl->slot_tbl_lock);
> +		dprintk("%s: slot table already initialized. tbl=%p slots=%p\n",
> +			__func__, tbl, tbl->slots);
> +		WARN_ON(1);
> +		goto out_free;
> +	}
> +	tbl->max_slots = max_slots;
> +	tbl->slots = slot;
> +	tbl->used_slots = used;
> +	tbl->lowest_free_slotid = 0;	/* first slot is free */
> +	tbl->highest_used_slotid = -1;	/* no slot is currently used */
> +	spin_unlock(&tbl->slot_tbl_lock);
> +	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
> +		tbl, tbl->slots, tbl->max_slots);
> +out:
> +	dprintk("<-- %s: return %d\n", __func__, ret);
> +	return ret;
> +out_free:
> +	kfree(slot);
> +	if (used != &tbl->_used_slots)
> +		kfree(used);
> +	goto out;
> +}
> +
> +/* Destroy the slot table */
> +static void nfs4_destroy_slot_table(struct nfs4_channel *channel)
> +{
> +	if (channel->slot_table.slots == NULL)
> +		return;
> +	kfree(channel->slot_table.slots);
> +	channel->slot_table.slots = NULL;
> +	/* Was the "used" bitmap dynamically allocated? */
> +	if (channel->slot_table.used_slots != &channel->slot_table._used_slots)
> +		kfree(channel->slot_table.used_slots);
> +
> +	return;
> +}
> +
> +static int nfs4_init_channel(struct nfs4_channel *channel)
> +{
> +	struct nfs4_slot_table *tbl;
> +
> +	tbl = &channel->slot_table;
> +
> +	spin_lock_init(&tbl->slot_tbl_lock);
> +	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "Slot table");
> +
> +	return 0;
> +}
> +
>  struct nfs4_session *nfs4_alloc_session(void)
>  {
>  	struct nfs4_session *session;
> @@ -3693,6 +3779,7 @@ struct nfs4_session *nfs4_alloc_session(void)
>  
>  	atomic_set(&session->ref_count, 1);
>  
> +	nfs4_init_channel(&session->fore_channel);
>  	return session;
>  }
>  
> @@ -3706,6 +3793,7 @@ void nfs4_put_session(struct nfs4_session **session)
>  {
>  	dprintk("--> nfs4_put_session()\n");
>  	if (atomic_dec_and_test(&((*session)->ref_count))) {
> +		nfs4_destroy_slot_table(&((*session)->fore_channel));
>  		nfs4_free_session(*session);
>  		*session = NULL;
>  	}
> diff --git a/include/linux/nfs4_session.h b/include/linux/nfs4_session.h
> index 36c0f94..d534269 100644
> --- a/include/linux/nfs4_session.h
> +++ b/include/linux/nfs4_session.h
> @@ -17,9 +17,26 @@ struct nfs4_channel_attrs {
>  	u32			rdma_attrs;
>  };
>  
> +struct nfs4_slot {
> +	u32		 	seq_nr;
> +};
> +
> +struct nfs4_slot_table {
> +	struct nfs4_slot *slots;		/* seqid per slot */
> +	unsigned long	*used_slots;		/* used/unused bitmap */
> +	unsigned long	_used_slots;		/* used when max_slots fits */

review 11-14: just limit to 128 bits, no dynamic allocation

> +	spinlock_t	slot_tbl_lock;
> +	struct rpc_wait_queue	slot_tbl_waitq;	/* allocators may wait here */
> +	int		max_slots;		/* # slots in table */
> +	int		lowest_free_slotid;	/* lower bound hint */
> +	int		highest_used_slotid;	/* sent to server on each SEQ.
> +						 * op for dynamic resizing */
> +};
> +
>  struct nfs4_channel {
>  	struct nfs4_channel_attrs 	chan_attrs;
>  	struct rpc_clnt 		*rpc_client;
> +	struct nfs4_slot_table		slot_table;
>  };
>  
>  /*
