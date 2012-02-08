Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50460 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753362Ab2BHQXX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 11:23:23 -0500
Date: Wed, 8 Feb 2012 11:23:22 -0500
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 1/2] NFSv4.1: Convert slotid from u8 to u32
Message-ID: <20120208162322.GA13315@fieldses.org>
References: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 06, 2012 at 07:57:16PM -0500, Trond Myklebust wrote:
> It is perfectly legal to negotiate up to 2^32-1 slots in the protocol,
> and with 10GigE, we are already seeing that 255 slots is far too limiting.

Seems like an entirely reasonable change, but just out of curiosity,
what workload are you using to hit that limit?

(If it's just bulk IO over a local 10GigE network, then surely the
problem is elsewhere?  Even on 10GigE I think you'd need fairly high
latencies (a little over 200ms, if my math is right?) to keep that much
data in flight.  Or are you testing much smaller operations?)

--b.

> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/callback.h         |    2 +-
>  fs/nfs/callback_xdr.c     |    6 +++---
>  fs/nfs/nfs4proc.c         |   21 ++++++++++-----------
>  include/linux/nfs_fs_sb.h |    7 ++++---
>  include/linux/nfs_xdr.h   |    2 +-
>  5 files changed, 19 insertions(+), 19 deletions(-)
> 
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 197e0d3..a5527c9 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -38,7 +38,7 @@ enum nfs4_callback_opnum {
>  struct cb_process_state {
>  	__be32			drc_status;
>  	struct nfs_client	*clp;
> -	int			slotid;
> +	u32			slotid;
>  	struct net		*net;
>  };
>  
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 2e37224..5466829 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -759,14 +759,14 @@ static void nfs4_callback_free_slot(struct nfs4_session *session)
>  	 * Let the state manager know callback processing done.
>  	 * A single slot, so highest used slotid is either 0 or -1
>  	 */
> -	tbl->highest_used_slotid = -1;
> +	tbl->highest_used_slotid = NFS4_NO_SLOT;
>  	nfs4_check_drain_bc_complete(session);
>  	spin_unlock(&tbl->slot_tbl_lock);
>  }
>  
>  static void nfs4_cb_free_slot(struct cb_process_state *cps)
>  {
> -	if (cps->slotid != -1)
> +	if (cps->slotid != NFS4_NO_SLOT)
>  		nfs4_callback_free_slot(cps->clp->cl_session);
>  }
>  
> @@ -860,7 +860,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>  	struct cb_process_state cps = {
>  		.drc_status = 0,
>  		.clp = NULL,
> -		.slotid = -1,
> +		.slotid = NFS4_NO_SLOT,
>  		.net = rqstp->rq_xprt->xpt_net,
>  	};
>  	unsigned int nops = 0;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 482ed97..0dc5dfb 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -402,7 +402,7 @@ static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
>  		return;
>  	}
>  
> -	if (ses->fc_slot_table.highest_used_slotid != -1)
> +	if (ses->fc_slot_table.highest_used_slotid != NFS4_NO_SLOT)
>  		return;
>  
>  	dprintk("%s COMPLETE: Session Fore Channel Drained\n", __func__);
> @@ -415,7 +415,7 @@ static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
>  void nfs4_check_drain_bc_complete(struct nfs4_session *ses)
>  {
>  	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state) ||
> -	    ses->bc_slot_table.highest_used_slotid != -1)
> +	    ses->bc_slot_table.highest_used_slotid != NFS4_NO_SLOT)
>  		return;
>  	dprintk("%s COMPLETE: Session Back Channel Drained\n", __func__);
>  	complete(&ses->bc_slot_table.complete);
> @@ -514,14 +514,13 @@ static int nfs4_sequence_done(struct rpc_task *task,
>   *
>   * Note: must be called with under the slot_tbl_lock.
>   */
> -static u8
> +static u32
>  nfs4_find_slot(struct nfs4_slot_table *tbl)
>  {
> -	int slotid;
> -	u8 ret_id = NFS4_MAX_SLOT_TABLE;
> -	BUILD_BUG_ON((u8)NFS4_MAX_SLOT_TABLE != (int)NFS4_MAX_SLOT_TABLE);
> +	u32 slotid;
> +	u32 ret_id = NFS4_NO_SLOT;
>  
> -	dprintk("--> %s used_slots=%04lx highest_used=%d max_slots=%d\n",
> +	dprintk("--> %s used_slots=%04lx highest_used=%u max_slots=%u\n",
>  		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
>  		tbl->max_slots);
>  	slotid = find_first_zero_bit(tbl->used_slots, tbl->max_slots);
> @@ -555,7 +554,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
>  {
>  	struct nfs4_slot *slot;
>  	struct nfs4_slot_table *tbl;
> -	u8 slotid;
> +	u32 slotid;
>  
>  	dprintk("--> %s\n", __func__);
>  	/* slot already allocated? */
> @@ -5144,7 +5143,7 @@ static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
>  	spin_lock(&tbl->slot_tbl_lock);
>  	tbl->max_slots = max_slots;
>  	tbl->slots = slot;
> -	tbl->highest_used_slotid = -1;  /* no slot is currently used */
> +	tbl->highest_used_slotid = NFS4_NO_SLOT;  /* no slot is currently used */
>  	spin_unlock(&tbl->slot_tbl_lock);
>  	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
>  		tbl, tbl->slots, tbl->max_slots);
> @@ -5196,13 +5195,13 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
>  		return NULL;
>  
>  	tbl = &session->fc_slot_table;
> -	tbl->highest_used_slotid = -1;
> +	tbl->highest_used_slotid = NFS4_NO_SLOT;
>  	spin_lock_init(&tbl->slot_tbl_lock);
>  	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
>  	init_completion(&tbl->complete);
>  
>  	tbl = &session->bc_slot_table;
> -	tbl->highest_used_slotid = -1;
> +	tbl->highest_used_slotid = NFS4_NO_SLOT;
>  	spin_lock_init(&tbl->slot_tbl_lock);
>  	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
>  	init_completion(&tbl->complete);
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 9e101c1..2ae57f2 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -191,6 +191,7 @@ struct nfs_server {
>  
>  /* maximum number of slots to use */
>  #define NFS4_MAX_SLOT_TABLE (128U)
> +#define NFS4_NO_SLOT ((u32)-1)
>  
>  #if defined(CONFIG_NFS_V4)
>  
> @@ -201,10 +202,10 @@ struct nfs4_slot_table {
>  	unsigned long   used_slots[SLOT_TABLE_SZ]; /* used/unused bitmap */
>  	spinlock_t	slot_tbl_lock;
>  	struct rpc_wait_queue	slot_tbl_waitq;	/* allocators may wait here */
> -	int		max_slots;		/* # slots in table */
> -	int		highest_used_slotid;	/* sent to server on each SEQ.
> +	u32		max_slots;		/* # slots in table */
> +	u32		highest_used_slotid;	/* sent to server on each SEQ.
>  						 * op for dynamic resizing */
> -	int		target_max_slots;	/* Set by CB_RECALL_SLOT as
> +	u32		target_max_slots;	/* Set by CB_RECALL_SLOT as
>  						 * the new max_slots */
>  	struct completion complete;
>  };
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 144419a..adbc84a 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -181,7 +181,7 @@ struct nfs4_slot {
>  
>  struct nfs4_sequence_args {
>  	struct nfs4_session	*sa_session;
> -	u8			sa_slotid;
> +	u32			sa_slotid;
>  	u8			sa_cache_this;
>  };
>  
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
