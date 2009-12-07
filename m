From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [PATCH 1/2] nfs41: nfs41_setup_state_renewal
Date: Mon, 07 Dec 2009 00:12:51 -0800
Message-ID: <C741F903.109E3%ricardo.labiaga@netapp.com>
References: <1260122555.11862.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31538 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757905AbZLGINP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 03:13:15 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB78Crr7029928
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2009 00:12:53 -0800 (PST)
In-Reply-To: <1260122555.11862.10.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 12/6/09 10:02 AM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Sun, 2009-12-06 at 03:16 -0800, Ricardo Labiaga wrote:
>> Move call to get the lease time and the setup of the state
>> renewal out of nfs4_create_session so that it can be called
>> after clearing the DRAINING flag.  We use the getattr RPC
>> to obtain the lease time, which requires a sequence slot.
>> 
>> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> <snip> 
>> status = nfs4_proc_exchange_id(clp, cred);
>> if (status == 0)
>> -  /* create session schedules state renewal upon success */
>> status = nfs4_proc_create_session(clp);
>> + if (status == 0 && test_and_clear_bit(
>> +   NFS4CLNT_SESSION_DRAINING, &clp->cl_state))
>> +  rpc_wake_up(&clp->cl_session->fc_slot_table.slot_tbl_waitq);
> 
> This was clearly supposed to be part of PATCH 2/2...
> 

Right.

>> + if (status == 0)
>> +  nfs41_setup_state_renewal(clp);
> 
> Hrm... Lots of tests of 'status == 0' without status actually changing.
> I've fixed this up (see below).

Looks good, thanks.

- ricardo

> 
>> if (status == 0)
>> nfs_mark_client_ready(clp, NFS_CS_READY);
>> return status;
> 
> ------------------------------------------------------------------------------
> -------------------------
> nfs41: nfs41_setup_state_renewal
> 
> From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> 
> Move call to get the lease time and the setup of the state
> renewal out of nfs4_create_session so that it can be called
> after clearing the DRAINING flag.  We use the getattr RPC
> to obtain the lease time, which requires a sequence slot.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/nfs4_fs.h   |    2 ++
>  fs/nfs/nfs4proc.c  |   13 -------------
>  fs/nfs/nfs4state.c |   34 +++++++++++++++++++++++++++++-----
>  3 files changed, 31 insertions(+), 18 deletions(-)
> 
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 50dd550..7e57b04 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -225,6 +225,8 @@ extern struct nfs4_session *nfs4_alloc_session(struct
> nfs_client *clp);
>  extern int nfs4_proc_create_session(struct nfs_client *);
>  extern int nfs4_proc_destroy_session(struct nfs4_session *);
>  extern int nfs4_init_session(struct nfs_server *server);
> +extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
> +  struct nfs_fsinfo *fsinfo);
>  #else /* CONFIG_NFS_v4_1 */
>  static inline int nfs4_setup_sequence(struct nfs_client *clp,
> struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b4ef570..4be0369 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4745,7 +4745,6 @@ int nfs4_proc_create_session(struct nfs_client *clp)
>  {
> int status;
> unsigned *ptr;
> - struct nfs_fsinfo fsinfo;
> struct nfs4_session *session = clp->cl_session;
>  
> dprintk("--> %s clp=%p session=%p\n", __func__, clp, session);
> @@ -4767,18 +4766,6 @@ int nfs4_proc_create_session(struct nfs_client *clp)
> ptr = (unsigned *)&session->sess_id.data[0];
> dprintk("%s client>seqid %d sessionid %u:%u:%u:%u\n", __func__,
> clp->cl_seqid, ptr[0], ptr[1], ptr[2], ptr[3]);
> -
> - /* Get the lease time */
> - status = nfs4_proc_get_lease_time(clp, &fsinfo);
> - if (status == 0) {
> -  /* Update lease time and schedule renewal */
> -  spin_lock(&clp->cl_lock);
> -  clp->cl_lease_time = fsinfo.lease_time * HZ;
> -  clp->cl_last_renewal = jiffies;
> -  spin_unlock(&clp->cl_lock);
> -
> -  nfs4_schedule_state_renewal(clp);
> - }
>  out:
> dprintk("<-- %s\n", __func__);
> return status;
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index ef9622e..9cfe686 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -116,16 +116,38 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct
> nfs_client *clp)
>  
>  #if defined(CONFIG_NFS_V4_1)
>  
> +static int nfs41_setup_state_renewal(struct nfs_client *clp)
> +{
> + int status;
> + struct nfs_fsinfo fsinfo;
> +
> + status = nfs4_proc_get_lease_time(clp, &fsinfo);
> + if (status == 0) {
> +  /* Update lease time and schedule renewal */
> +  spin_lock(&clp->cl_lock);
> +  clp->cl_lease_time = fsinfo.lease_time * HZ;
> +  clp->cl_last_renewal = jiffies;
> +  spin_unlock(&clp->cl_lock);
> +
> +  nfs4_schedule_state_renewal(clp);
> + }
> +
> + return status;
> +}
> +
>  int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>  {
> int status;
>  
> status = nfs4_proc_exchange_id(clp, cred);
> - if (status == 0)
> -  /* create session schedules state renewal upon success */
> -  status = nfs4_proc_create_session(clp);
> - if (status == 0)
> -  nfs_mark_client_ready(clp, NFS_CS_READY);
> + if (status != 0)
> +  goto out;
> + status = nfs4_proc_create_session(clp);
> + if (status != 0)
> +  goto out;
> + nfs41_setup_state_renewal(clp);
> + nfs_mark_client_ready(clp, NFS_CS_READY);
> +out:
> return status;
>  }
>  
> @@ -1248,6 +1270,8 @@ out:
> /* Wake up the next rpc task even on error */
> clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
> rpc_wake_up(&clp->cl_session->fc_slot_table.slot_tbl_waitq);
> + if (status == 0)
> +  nfs41_setup_state_renewal(clp);
> return status;
>  }
>  
> 
> 

