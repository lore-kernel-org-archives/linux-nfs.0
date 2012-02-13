Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:46789 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399Ab2BMNtc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Feb 2012 08:49:32 -0500
Message-ID: <4F3914EB.7090908@netapp.com>
Date: Mon, 13 Feb 2012 08:49:31 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: andros@netapp.com
CC: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 7 2/3] NFSv4.1 prepare for dynamic session slots
References: <1329069176-8349-1-git-send-email-andros@netapp.com> <1329069176-8349-3-git-send-email-andros@netapp.com>
In-Reply-To: <1329069176-8349-3-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/12/12 12:52, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 18b095a..11f4e96 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -350,6 +350,127 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
>  #if defined(CONFIG_NFS_V4_1)
>  
>  /*
> + * Slot table hlist functions
> + */
> +
> +static inline u32 slot_tbl_hash(u8 slotid)
> +{
> +	return (u32)slotid % SLOT_HASH_TBL_SZ;
> +}
> +
> +/*
> + * Allocate the slot the requested slotid.
> + * Called outside of the slot_tbl_lock. If the slot is already allocated,
> + * return success.
> + */
> +static int
> +nfs4_alloc_insert_slot(struct nfs4_slot_table *tbl, int ivalue, int slotid,
> +		    gfp_t gfp_flags)
> +{
> +	struct nfs4_slot *new;
> +	u32 hash = slot_tbl_hash(slotid);
> +
> +	dprintk("--> %s slotid=%u\n", __func__, slotid);
> +
> +	new = kzalloc(sizeof(struct nfs4_slot), gfp_flags);
> +	if (!new)
> +		return -ENOMEM;
> +	INIT_HLIST_NODE(&new->node);
> +	new->slot_id = slotid;
> +	new->seq_nr = ivalue;
> +	spin_lock(&tbl->slot_tbl_lock);
> +	hlist_add_head(&new->node, &tbl->slots[hash]);
> +	tbl->max_slots++;
> +	spin_unlock(&tbl->slot_tbl_lock);
> +	return 0;
> +}
> +
> +/*
> + * Allocate the negotiated number of slots and place them in the hlist.
> + * Called at session initialization, or session reset (with session
> + * drained).
> + *
> + * @start - the slotid where allocation starts.
> + * @num   - the number of slots to allocate.
> + *
> + */
> +static int nfs4_alloc_slots(struct nfs4_slot_table *tbl, int ivalue,
> +			    int start, int num, gfp_t gfp_flags)
> +{
> +int i, ret = 0;


Not a big deal, but I think a tab got lost here.

- Bryan

> +
> +	for (i = start; i < start + num; i++) {
> +		ret = nfs4_alloc_insert_slot(tbl, ivalue, i, gfp_flags);
> +		if (ret)
> +			break;
> +	}
> +	return ret;
> +}


