From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 29/85] nfs41: nfs41_sequence_done
Date: Mon, 17 Nov 2008 15:50:42 +0200
Message-ID: <492176B2.5060305@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348597-8187-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:9547 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752089AbYKQNup (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:50:45 -0500
In-Reply-To: <1226348597-8187-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:23 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Handle session level errors, update slot sequence id and
> sessions bookeeping, free slot.
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c       |   61 +++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/nfs_xdr.h |    3 ++
>  2 files changed, 64 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index af9ee0e..217f891 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -296,6 +296,66 @@ nfs41_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
>  	rpc_wake_up_next(&tbl->slot_tbl_waitq);
>  }
>  
> +/* For pNFS filelayout data servers:
> + * the nfs_client is NULL - to signal no lease update.
> + * session is the data server.
> + */
> +static void nfs41_sequence_done(struct nfs_client *clp,
> +				struct nfs41_sequence_res *res,
> +				int rpc_status)

review 11-14: cache the seq_status in struct nfs41_sequence_res.
initialize to non zero so that we intercept rpc level failures
in which we do not go through decode_sequence, which will be the
only place where res->seq_status will be set to 0.
get rid of SEQ4_STATUS_USE_TK_STATUS.
no need to pass rpc_status either.

> +{
> +	unsigned long timestamp;
> +	struct nfs4_slot_table *tbl;
> +	struct nfs4_slot *slot;
> +	int status = NFS4_OK;
> +
> +	if (res->sr_flags & SEQ4_STATUS_USE_TK_STATUS)
> +		status =  rpc_status;
> +
> +	tbl = &res->sr_session->fore_channel.slot_table;
> +	slot = res->sr_slot;
> +
> +	switch (status) {
> +	case NFS4_OK:
> +		/*
> +		 * The sequence call was successful,
> +		 * Update the slot's sequence and client's lease renewal timers
> +		 */
> +		++slot->seq_nr;
> +		if (!clp)
> +			break;
> +		timestamp = res->sr_renewal_time;
> +		spin_lock(&clp->cl_lock);
> +		if (time_before(clp->cl_last_renewal, timestamp))
> +			clp->cl_last_renewal = timestamp;
> +		spin_unlock(&clp->cl_lock);
> +		break;
> +
> +	case -NFS4ERR_BADSESSION:
> +	case -NFS4ERR_BADSLOT:
> +	case -NFS4ERR_BADXDR:
> +	case -NFS4ERR_BAD_HIGH_SLOT:
> +	case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
> +	case -NFS4ERR_DEADSESSION:
> +	case -NFS4ERR_DELAY:
> +	case -NFS4ERR_REP_TOO_BIG:
> +	case -NFS4ERR_REP_TOO_BIG_TO_CACHE:
> +	case -NFS4ERR_REQ_TOO_BIG:
> +	case -NFS4ERR_RETRY_UNCACHED_REP:
> +	case -NFS4ERR_SEQUENCE_POS:
> +	case -NFS4ERR_SEQ_FALSE_RETRY:
> +	case -NFS4ERR_SEQ_MISORDERED:
> +	case -NFS4ERR_TOO_MANY_OPS:
> +		dprintk("%s: status %d\n", __func__, status);
> +		break;
> +
> +	default:
> +		printk(KERN_WARNING "%s: Unexpected status %d\n", __func__,
> +			status);
> +	}
> +	nfs41_free_slot(tbl, slot);
> +}
> +
>  /*
>   * nfs4_find_slot - efficiently look for a free slot
>   *
> @@ -373,6 +433,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
>  	dprintk("<-- %s slot=%p slotid=%d seqid=%d\n", __func__,
>  		slot, slot_idx(tbl, slot), slot->seq_nr);
>  
> +	res->sr_session = session;
>  	res->sr_slot = slot;
>  	res->sr_renewal_time = jiffies;
>  	return 0;
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 9cefe0d..4144ea2 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -134,8 +134,11 @@ struct nfs41_sequence_args {
>  #define SEQ4_STATUS_RECALLABLE_STATE_REVOKED	0x00000040
>  #define SEQ4_STATUS_LEASE_MOVED			0x00000080
>  #define SEQ4_STATUS_RESTART_RECLAIM_NEEDED	0x00000100
> +#define SEQ4_STATUS_USE_TK_STATUS		0x10000000 /* internal error */
>  
>  struct nfs41_sequence_res {
> +	struct nfs4_session	*sr_session;
> +	u32			sr_flags;
>  	struct nfs4_slot	*sr_slot;	/* slot used to send request */
>  	unsigned long		sr_renewal_time;
>  };
