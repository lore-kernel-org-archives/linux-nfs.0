Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42275 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908Ab0LGSyK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 13:54:10 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oB7Is937006607
	for <linux-nfs@vger.kernel.org>; Tue, 7 Dec 2010 10:54:09 -0800 (PST)
Subject: Re: [PATCH 1/1] NFS add session back channel draining
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1291393741-2851-1-git-send-email-andros@netapp.com>
References: <1291393741-2851-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Dec 2010 13:54:07 -0500
Message-ID: <1291748047.3049.14.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-12-03 at 11:29 -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Currently session draining only drains the fore channel.
> The back channel processing must also be drained.
> 
> Use the back channel highest_slot_used to indicate that a callback is being
> processed by the callback thread.  Move the session complete to be per channel.
> 
> When the session is draininig, wait for any current back channel processing
> to complete and stop all new back channel processing by returning NFS4ERR_DELAY
> to the back channel client.
> 
> Drain the back channel, then the fore channel.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback_proc.c    |    6 ++++++
>  fs/nfs/callback_xdr.c     |   19 +++++++++++++++++++
>  fs/nfs/internal.h         |    1 +
>  fs/nfs/nfs4proc.c         |   26 +++++++++++++++++++-------
>  fs/nfs/nfs4state.c        |   29 +++++++++++++++++++++++++----
>  include/linux/nfs_fs_sb.h |    2 +-
>  6 files changed, 71 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index aa62342..bcad3c1 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -251,6 +251,12 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
>  	if (clp == NULL)
>  		goto out;
>  
> +	/* state manager is resetting the session */
> +	if (test_bit(NFS4_SESSION_DRAINING, &clp->cl_session->session_state)) {
> +		status = NFS4ERR_DELAY;
> +		goto err_putclient;
> +	}
> +
>  	status = validate_seqid(&clp->cl_session->bc_slot_table, args);
>  	if (status)
>  		goto err_putclient;
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 85cbb8f..d21f17c 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -596,6 +596,22 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
>  	return htonl(NFS_OK);
>  }
>  
> +static void nfs4_callback_free_slot(struct nfs4_session *session)
> +{
> +	struct nfs4_slot_table *tbl = &session->bc_slot_table;
> +
> +	spin_lock(&tbl->slot_tbl_lock);
> +	/*
> +	 * Let the state manager know callback processing done.
> +	 * A single slot, so highest used slotid is either 0 or -1
> +	 */
> +	tbl->highest_used_slotid--;
> +	nfs4_check_drain_bc_complete(session);
> +	spin_unlock(&tbl->slot_tbl_lock);
> +	dprintk("%s highest_used_slotid %d\n", __func__,
> +	tbl->highest_used_slotid);
> +}
> +
>  #else /* CONFIG_NFS_V4_1 */
>  
>  static __be32
> @@ -604,6 +620,9 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
>  	return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
>  }
>  
> +static void nfs4_callback_free_slot(struct nfs4_session *session)
> +{
> +}
>  #endif /* CONFIG_NFS_V4_1 */
>  
>  static __be32
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index f65602c..0b5d99e 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -281,6 +281,7 @@ extern int _nfs4_call_sync_session(struct nfs_server *server,
>  				   struct nfs4_sequence_res *res,
>  				   int cache_reply);
>  
> +void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
>  /*
>   * Determine the device name as a string
>   */
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index a241957..c244000 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -355,9 +355,9 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *free_slot)
>  }
>  
>  /*
> - * Signal state manager thread if session is drained
> + * Signal state manager thread if session fore channel is drained
>   */
> -static void nfs41_check_drain_session_complete(struct nfs4_session *ses)
> +static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
>  {
>  	struct rpc_task *task;
>  
> @@ -371,8 +371,20 @@ static void nfs41_check_drain_session_complete(struct nfs4_session *ses)
>  	if (ses->fc_slot_table.highest_used_slotid != -1)
>  		return;
>  
> -	dprintk("%s COMPLETE: Session Drained\n", __func__);
> -	complete(&ses->complete);
> +	dprintk("%s COMPLETE: Session Fore Channel Drained\n", __func__);
> +	complete(&ses->fc_slot_table.complete);
> +}
> +
> +/*
> + * Signal state manager thread if session back channel is drained
> + */
> +void nfs4_check_drain_bc_complete(struct nfs4_session *ses)
> +{
> +	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state) ||
> +	    ses->bc_slot_table.highest_used_slotid != -1)
> +		return;
> +	dprintk("%s COMPLETE: Session Back Channel Drained\n", __func__);
> +	complete(&ses->bc_slot_table.complete);
>  }
>  
>  static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
> @@ -389,7 +401,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
>  
>  	spin_lock(&tbl->slot_tbl_lock);
>  	nfs4_free_slot(tbl, res->sr_slot);
> -	nfs41_check_drain_session_complete(res->sr_session);
> +	nfs4_check_drain_fc_complete(res->sr_session);
>  	spin_unlock(&tbl->slot_tbl_lock);
>  	res->sr_slot = NULL;
>  }
> @@ -4772,17 +4784,17 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
>  	if (!session)
>  		return NULL;
>  
> -	init_completion(&session->complete);
> -
>  	tbl = &session->fc_slot_table;
>  	tbl->highest_used_slotid = -1;
>  	spin_lock_init(&tbl->slot_tbl_lock);
>  	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
> +	init_completion(&tbl->complete);
>  
>  	tbl = &session->bc_slot_table;
>  	tbl->highest_used_slotid = -1;
>  	spin_lock_init(&tbl->slot_tbl_lock);
>  	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
> +	init_completion(&tbl->complete);
>  
>  	session->session_state = 1<<NFS4_SESSION_INITING;
>  
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 11290de..3445b01 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -143,6 +143,11 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
>  	return status;
>  }
>  
> +/*
> + * Back channel returns NFS4ERR_DELAY for new requests when
> + * NFS4_SESSION_DRAINING is set so there is no work to be done when draining
> + * is ended.
> + */
>  static void nfs4_end_drain_session(struct nfs_client *clp)
>  {
>  	struct nfs4_session *ses = clp->cl_session;
> @@ -170,16 +175,32 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
>  {
>  	struct nfs4_session *ses = clp->cl_session;
>  	struct nfs4_slot_table *tbl = &ses->fc_slot_table;
> +	int ret = 0;
>  
> -	spin_lock(&tbl->slot_tbl_lock);
>  	set_bit(NFS4_SESSION_DRAINING, &ses->session_state);
> +	/* back channel */
> +	tbl = &ses->bc_slot_table;
> +	spin_lock(&tbl->slot_tbl_lock);
>  	if (tbl->highest_used_slotid != -1) {
> -		INIT_COMPLETION(ses->complete);
> +		INIT_COMPLETION(tbl->complete);
>  		spin_unlock(&tbl->slot_tbl_lock);
> -		return wait_for_completion_interruptible(&ses->complete);
> +		ret = wait_for_completion_interruptible(&tbl->complete);
> +		if (ret)
> +			goto out;
> +		goto forechannel;
>  	}

Use an 'else' instead of the goto here?

>  	spin_unlock(&tbl->slot_tbl_lock);
> -	return 0;
> +forechannel:
> +	/* fore channel */
> +	spin_lock(&tbl->slot_tbl_lock);
> +	if (tbl->highest_used_slotid != -1) {
> +		INIT_COMPLETION(tbl->complete);
> +		spin_unlock(&tbl->slot_tbl_lock);
> +		return wait_for_completion_interruptible(&tbl->complete);

Perhaps make a generic 'nfs4_wait_on_slot()', since we appear to be
doing the above more than once?

> +	}
> +	spin_unlock(&tbl->slot_tbl_lock);
> +out:
> +	return ret;
>  }
>  
>  int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 1eaa054..e93ada0 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -197,6 +197,7 @@ struct nfs4_slot_table {
>  						 * op for dynamic resizing */
>  	int		target_max_slots;	/* Set by CB_RECALL_SLOT as
>  						 * the new max_slots */
> +	struct completion complete;
>  };
>  
>  static inline int slot_idx(struct nfs4_slot_table *tbl, struct nfs4_slot *sp)
> @@ -213,7 +214,6 @@ struct nfs4_session {
>  	unsigned long			session_state;
>  	u32				hash_alg;
>  	u32				ssv_len;
> -	struct completion		complete;
>  
>  	/* The fore and back channel */
>  	struct nfs4_channel_attrs	fc_attrs;

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

