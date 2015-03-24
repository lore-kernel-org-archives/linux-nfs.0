Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33263 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbbCXRCm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2015 13:02:42 -0400
Received: by pdnc3 with SMTP id c3so227166934pdn.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 Mar 2015 10:02:41 -0700 (PDT)
Message-ID: <551198A4.7050205@gmail.com>
Date: Wed, 25 Mar 2015 01:02:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] NFSv4: Ensure that we drain the session before
 shutting it down
References: <CAHQdGtTn5me9ZBfv9D8qZOmp6MFc29ppn4DqD8hOuMqRgRY8Rg@mail.gmail.com> <1427142109-91216-1-git-send-email-trond.myklebust@primarydata.com> <55119813.70405@gmail.com>
In-Reply-To: <55119813.70405@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2015/3/25 1:00, Kinglong Mee wrote:
> With those two patches, the problem also exist.
> After debugging, i found,
> 1. Before unmount, nfs client holds a read delegation.
> 2. When unmountting, nfs_kill_super will be called.
> 2.1, In nfs_kill_super, generic_shutdown_super() will be called,
>      which will causes delegation return (async).
>      DELEGRETURN is sent though **server->client**.
> 2.2, after that (delegreturn's reply maybe not received), 
>      nfs_free_server() will be called.
> 3. In nfs_free_server(), 
> 3.1, rpc_shutdown_client(server->client); will call rpc_killall_tasks()
>      to killing all tasks in server->client RPC client.
>      So, DELEGRETURN maybe killed here.
> 3.2, nfs_put_client(server->nfs_client); will destroy session 
>      and clientid.
>      DESTROY_SESSION and DESTROY_CLIENTID are sent though 
>      *server->nfs_client->cl_rpcclient*.
> 
> And, server->client is a clone of server->nfs_client->cl_rpcclient,
> they are two different rpcclient.
> 
> So, the really problem is 3.1, rpc_killall_tasks may kill DELEGRETURN,
> which maybe be processed by nfsd, nfs will **clean the used slot**.
> 
> Before DELEGRETURN reply, the used slot have be cleaned, so that,
> 3.2's DESTROY_SESSION request will be sent to nfsd immediately,
> and return an error NFS4ERR_DELAY for client's delegation.

After fixing the new race, I will test with those patches.

thanks,
Kinglong Mee

> On 2015/3/24 4:21, Trond Myklebust wrote:
>> Kinglong Mee reports that the call to DESTROY_SESSION in NFSv4.1
>> are racing with the asynchronous DELEGRETURN calls that precede it.
>> This points to the root cause being that we're not waiting for the
>> session to drain before we destroy it.
>>
>> This patch ensures that we do so for both NFSv4 and NFSv4.1.
>>
>> Reported-by: Kinglong Mee <kinglongmee@gmail.com>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/nfs4client.c  |  7 ++-----
>>  fs/nfs/nfs4session.c | 45 +++++++++++++++++++++++++++++++++++++++++++--
>>  fs/nfs/nfs4session.h |  4 ++++
>>  fs/nfs/nfs4state.c   | 15 ++++++++++++---
>>  4 files changed, 61 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index 86d6214ea022..ffb12efb1596 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -160,7 +160,7 @@ void nfs41_shutdown_client(struct nfs_client *clp)
>>  {
>>  	if (nfs4_has_session(clp)) {
>>  		nfs4_shutdown_ds_clients(clp);
>> -		nfs4_destroy_session(clp->cl_session);
>> +		nfs41_shutdown_session(clp->cl_session);
>>  		nfs4_destroy_clientid(clp);
>>  	}
>>  
>> @@ -169,10 +169,7 @@ void nfs41_shutdown_client(struct nfs_client *clp)
>>  
>>  void nfs40_shutdown_client(struct nfs_client *clp)
>>  {
>> -	if (clp->cl_slot_tbl) {
>> -		nfs4_shutdown_slot_table(clp->cl_slot_tbl);
>> -		kfree(clp->cl_slot_tbl);
>> -	}
>> +	nfs40_shutdown_session(clp);
>>  }
>>  
>>  struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
>> diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
>> index e23366effcfb..67c002a24d8f 100644
>> --- a/fs/nfs/nfs4session.c
>> +++ b/fs/nfs/nfs4session.c
>> @@ -59,8 +59,14 @@ static void nfs4_shrink_slot_table(struct nfs4_slot_table  *tbl, u32 newsize)
>>   */
>>  void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl)
>>  {
>> -	if (nfs4_slot_tbl_draining(tbl))
>> -		complete(&tbl->complete);
>> +	/* Note: no need for atomicity between test and clear, so we can
>> +	 * optimise for the read-only case where NFS4_SLOT_TBL_WAIT_EMPTY
>> +	 * is not set.
>> +	 */
>> +	if (test_bit(NFS4_SLOT_TBL_WAIT_EMPTY, &tbl->slot_tbl_state)) {
>> +		clear_bit(NFS4_SLOT_TBL_WAIT_EMPTY, &tbl->slot_tbl_state);
>> +		complete_all(&tbl->complete);
>> +	}
>>  }
>>  
>>  /*
>> @@ -319,7 +325,42 @@ void nfs41_wake_slot_table(struct nfs4_slot_table *tbl)
>>  	}
>>  }
>>  
>> +void nfs40_shutdown_session(struct nfs_client *clp)
>> +{
>> +	struct nfs4_slot_table  *tbl = clp->cl_slot_tbl;
>> +
>> +	if (tbl) {
>> +		nfs4_wait_empty_slot_tbl(tbl);
>> +		nfs4_shutdown_slot_table(tbl);
>> +		clp->cl_slot_tbl = NULL;
>> +		kfree(tbl);
>> +	}
>> +}
>> +
>>  #if defined(CONFIG_NFS_V4_1)
>> +static void nfs41_shutdown_session_bc(struct nfs4_session *session)
>> +{
>> +	if (session->flags & SESSION4_BACK_CHAN) {
>> +		session->flags &= ~SESSION4_BACK_CHAN;
>> +		/* wait for back channel to drain */
>> +		nfs4_wait_empty_slot_tbl(&session->bc_slot_table);
>> +	}
>> +}
>> +
>> +static void nfs41_shutdown_session_fc(struct nfs4_session *session)
>> +{
>> +	/* just wait for forward channel to drain */
>> +	nfs4_wait_empty_slot_tbl(&session->bc_slot_table);
>> +}
>> +
>> +void nfs41_shutdown_session(struct nfs4_session *session)
>> +{
>> +	if (!test_bit(NFS4_SESSION_ESTABLISHED, &session->session_state))
>> +		return;
>> +	nfs41_shutdown_session_bc(session);
>> +	nfs41_shutdown_session_fc(session);
>> +	nfs4_destroy_session(session);
>> +}
>>  
>>  static void nfs41_set_max_slotid_locked(struct nfs4_slot_table *tbl,
>>  		u32 target_highest_slotid)
>> diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
>> index e3ea2c5324d6..1912b250fcab 100644
>> --- a/fs/nfs/nfs4session.h
>> +++ b/fs/nfs/nfs4session.h
>> @@ -27,6 +27,7 @@ struct nfs4_slot {
>>  /* Sessions */
>>  enum nfs4_slot_tbl_state {
>>  	NFS4_SLOT_TBL_DRAINING,
>> +	NFS4_SLOT_TBL_WAIT_EMPTY,
>>  };
>>  
>>  #define SLOT_TABLE_SZ DIV_ROUND_UP(NFS4_MAX_SLOT_TABLE, 8*sizeof(long))
>> @@ -78,10 +79,12 @@ extern int nfs4_setup_slot_table(struct nfs4_slot_table *tbl,
>>  extern void nfs4_shutdown_slot_table(struct nfs4_slot_table *tbl);
>>  extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
>>  extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
>> +extern int nfs4_wait_empty_slot_tbl(struct nfs4_slot_table *tbl);
>>  extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
>>  bool nfs41_wake_and_assign_slot(struct nfs4_slot_table *tbl,
>>  		struct nfs4_slot *slot);
>>  void nfs41_wake_slot_table(struct nfs4_slot_table *tbl);
>> +extern void nfs40_shutdown_session(struct nfs_client *clp);
>>  
>>  static inline bool nfs4_slot_tbl_draining(struct nfs4_slot_table *tbl)
>>  {
>> @@ -101,6 +104,7 @@ extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
>>  extern void nfs4_destroy_session(struct nfs4_session *session);
>>  extern int nfs4_init_session(struct nfs_client *clp);
>>  extern int nfs4_init_ds_session(struct nfs_client *, unsigned long);
>> +extern void nfs41_shutdown_session(struct nfs4_session *session);
>>  
>>  /*
>>   * Determine if sessions are in use.
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index f95e3b58bbc3..bd5293db4e5b 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -239,12 +239,13 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
>>  	}
>>  }
>>  
>> -static int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
>> +int nfs4_wait_empty_slot_tbl(struct nfs4_slot_table *tbl)
>>  {
>> -	set_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
>>  	spin_lock(&tbl->slot_tbl_lock);
>>  	if (tbl->highest_used_slotid != NFS4_NO_SLOT) {
>> -		reinit_completion(&tbl->complete);
>> +		if (!test_and_set_bit(NFS4_SLOT_TBL_WAIT_EMPTY,
>> +					&tbl->slot_tbl_state))
>> +			reinit_completion(&tbl->complete);
>>  		spin_unlock(&tbl->slot_tbl_lock);
>>  		return wait_for_completion_interruptible(&tbl->complete);
>>  	}
>> @@ -252,6 +253,14 @@ static int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
>>  	return 0;
>>  }
>>  
>> +int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
>> +{
>> +	/* Block new RPC calls */
>> +	set_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
>> +	/* Wait on outstanding RPC calls to complete */
>> +	return nfs4_wait_empty_slot_tbl(tbl);
>> +}
>> +
>>  static int nfs4_begin_drain_session(struct nfs_client *clp)
>>  {
>>  	struct nfs4_session *ses = clp->cl_session;
>>
