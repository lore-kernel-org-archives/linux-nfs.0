From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [PATCH 2/2] nfs41: Don't clear DRAINING flag on
 NFS4ERR_STALE_CLIENTID
Date: Mon, 07 Dec 2009 00:13:32 -0800
Message-ID: <C741F92C.109E5%ricardo.labiaga@netapp.com>
References: <1260122560.11862.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17580 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758825AbZLGIN1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 03:13:27 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB78DXX8020866
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2009 00:13:34 -0800 (PST)
In-Reply-To: <1260122560.11862.11.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/6/09 10:02 AM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Sun, 2009-12-06 at 03:16 -0800, Ricardo Labiaga wrote:
>> If CREATE_SESSION fails with NFS4ERR_STALE_CLIENTID, don't clear the
>> NFS4CLNT_SESSION_DRAINING flag and don't wake RPCs waiting for the
>> session to be reestablished.  We don't have a session yet, so there
>> is no reason to wake other RPCs.
>> 
>> This avoids sending spurious compounds with bogus sequenceID during
>> session and state recovery.
> 
> How about the following instead? It ensures that we drain the session
> before renewing the lease too.
> 

Looks good, I tested it as well.

- ricardo

> Cheers
>   Trond
> ------------------------------------------------------------------------------
> --------- 
> nfs41: Don't clear DRAINING flag on NFS4ERR_STALE_CLIENTID
> 
> From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> 
> If CREATE_SESSION fails with NFS4ERR_STALE_CLIENTID, don't clear the
> NFS4CLNT_SESSION_DRAINING flag and don't wake RPCs waiting for the
> session to be reestablished.  We don't have a session yet, so there
> is no reason to wake other RPCs.
> 
> This avoids sending spurious compounds with bogus sequenceID during
> session and state recovery.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [Trond.Myklebust@netapp.com: cleaned up patch by adding the
>                              nfs41_begin/end_drain_session() helpers]
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/nfs4proc.c  |    2 ++
>  fs/nfs/nfs4state.c |   59
> ++++++++++++++++++++++++++++++++++++----------------
>  2 files changed, 43 insertions(+), 18 deletions(-)
> 
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 4be0369..fbae2c9 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4586,10 +4586,12 @@ struct nfs4_session *nfs4_alloc_session(struct
> nfs_client *clp)
> init_completion(&session->complete);
>  
> tbl = &session->fc_slot_table;
> + tbl->highest_used_slotid = -1;
> spin_lock_init(&tbl->slot_tbl_lock);
> rpc_init_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
>  
> tbl = &session->bc_slot_table;
> + tbl->highest_used_slotid = -1;
> spin_lock_init(&tbl->slot_tbl_lock);
> rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
>  
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 9cfe686..1b629cc 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -135,16 +135,43 @@ static int nfs41_setup_state_renewal(struct nfs_client
> *clp)
> return status;
>  }
>  
> +static void nfs41_end_drain_session(struct nfs_client *clp,
> +  struct nfs4_session *ses)
> +{
> + if (test_and_clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state))
> +  rpc_wake_up(&ses->fc_slot_table.slot_tbl_waitq);
> +}
> +
> +static int nfs41_begin_drain_session(struct nfs_client *clp,
> +  struct nfs4_session *ses)
> +{
> + struct nfs4_slot_table *tbl = &ses->fc_slot_table;
> +
> + spin_lock(&tbl->slot_tbl_lock);
> + set_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
> + if (tbl->highest_used_slotid != -1) {
> +  INIT_COMPLETION(ses->complete);
> +  spin_unlock(&tbl->slot_tbl_lock);
> +  return wait_for_completion_interruptible(&ses->complete);
> + }
> + spin_unlock(&tbl->slot_tbl_lock);
> + return 0;
> +}
> +
>  int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>  {
> int status;
>  
> + status = nfs41_begin_drain_session(clp, clp->cl_session);
> + if (status != 0)
> +  goto out;
> status = nfs4_proc_exchange_id(clp, cred);
> if (status != 0)
> goto out;
> status = nfs4_proc_create_session(clp);
> if (status != 0)
> goto out;
> + nfs41_end_drain_session(clp, clp->cl_session);
> nfs41_setup_state_renewal(clp);
> nfs_mark_client_ready(clp, NFS_CS_READY);
>  out:
> @@ -1239,20 +1266,11 @@ static void nfs4_session_recovery_handle_error(struct
> nfs_client *clp, int err)
>  static int nfs4_reset_session(struct nfs_client *clp)
>  {
> struct nfs4_session *ses = clp->cl_session;
> - struct nfs4_slot_table *tbl = &ses->fc_slot_table;
> int status;
>  
> - spin_lock(&tbl->slot_tbl_lock);
> - set_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
> - if (tbl->highest_used_slotid != -1) {
> -  INIT_COMPLETION(ses->complete);
> -  spin_unlock(&tbl->slot_tbl_lock);
> -  status = wait_for_completion_interruptible(&ses->complete);
> -  if (status) /* -ERESTARTSYS */
> -   goto out;
> - } else {
> -  spin_unlock(&tbl->slot_tbl_lock);
> - }
> + status = nfs41_begin_drain_session(clp, ses);
> + if (status != 0)
> +  return status;
>  
> status = nfs4_proc_destroy_session(clp->cl_session);
> if (status && status != -NFS4ERR_BADSESSION &&
> @@ -1265,13 +1283,18 @@ static int nfs4_reset_session(struct nfs_client *clp)
> status = nfs4_proc_create_session(clp);
> if (status)
> nfs4_session_recovery_handle_error(clp, status);
> -  /* fall through*/
> +
>  out:
> - /* Wake up the next rpc task even on error */
> - clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
> - rpc_wake_up(&clp->cl_session->fc_slot_table.slot_tbl_waitq);
> - if (status == 0)
> -  nfs41_setup_state_renewal(clp);
> + /*
> +  * Let the state manager reestablish state
> +  * without waking other tasks yet.
> +  */
> + if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
> +  /* Wake up the next rpc task */
> +  nfs41_end_drain_session(clp, ses);
> +  if (status == 0)
> +   nfs41_setup_state_renewal(clp);
> + }
> return status;
>  }
>  
> 

