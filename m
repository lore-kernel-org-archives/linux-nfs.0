From: Benny Halevy <bhalevy@panasas.com>
Subject: Ping: [pnfs] [RFC 1/1] nfs4: optionally return status from state_manager
Date: Fri, 25 Sep 2009 07:30:54 +0300
Message-ID: <4ABC477E.4060709@panasas.com>
References: <4A9EDDE6.1090308@panasas.com> <1251990924-3904-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:37691 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751069AbZIYEax (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2009 00:30:53 -0400
In-Reply-To: <1251990924-3904-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

Is the patch below acceptable?

Benny

On Sep. 03, 2009, 18:15 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> Add an optional pointer to integer parameter to
> nfs4_schedule_state_manager and store the state_manager
> status in it, if not NULL.  Use it also if the state manager
> could not be scheduled for kthread_run's error.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> 
> Trond,
> 
> Here's an alternative approach to returning the state_manager
> status to whomever scheduled state recovery, requiring no
> additrional fields in struct nfs_client and returning
> the status atomically with the state_manager.
> 
> Benny
> 
>  fs/nfs/client.c     |    6 ++----
>  fs/nfs/delegation.c |    2 +-
>  fs/nfs/nfs4_fs.h    |    4 ++--
>  fs/nfs/nfs4proc.c   |   26 +++++++++++++++++---------
>  fs/nfs/nfs4state.c  |   44 ++++++++++++++++++++++++++++++++------------
>  5 files changed, 54 insertions(+), 28 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index d36925f..07ce3ae 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -541,10 +541,8 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
>   */
>  int nfs4_check_client_ready(struct nfs_client *clp)
>  {
> -	if (!nfs4_has_session(clp))
> -		return 0;
> -	if (clp->cl_cons_state < NFS_CS_READY)
> -		return -EPROTONOSUPPORT;
> +	if (clp->cl_cons_state < 0)
> +		return clp->cl_cons_state;
>  	return 0;
>  }
>  
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 6dd48a4..af2c3f0 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -386,7 +386,7 @@ static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
>  static void nfs_delegation_run_state_manager(struct nfs_client *clp)
>  {
>  	if (test_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state))
> -		nfs4_schedule_state_manager(clp);
> +		nfs4_schedule_state_manager(clp, NULL);
>  }
>  
>  void nfs_expire_all_delegations(struct nfs_client *clp)
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 6ea07a3..c2ec9bc 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -264,8 +264,8 @@ extern void nfs4_put_open_state(struct nfs4_state *);
>  extern void nfs4_close_state(struct path *, struct nfs4_state *, fmode_t);
>  extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
>  extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
> -extern void nfs4_schedule_state_recovery(struct nfs_client *);
> -extern void nfs4_schedule_state_manager(struct nfs_client *);
> +extern void nfs4_schedule_state_recovery(struct nfs_client *, int *statusp);
> +extern void nfs4_schedule_state_manager(struct nfs_client *, int *statusp);
>  extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
>  extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
>  extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 80635eb..d6dc30d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -247,7 +247,7 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
>  		case -NFS4ERR_STALE_CLIENTID:
>  		case -NFS4ERR_STALE_STATEID:
>  		case -NFS4ERR_EXPIRED:
> -			nfs4_schedule_state_recovery(clp);
> +			nfs4_schedule_state_recovery(clp, NULL);
>  			ret = nfs4_wait_clnt_recover(clp);
>  			if (ret == 0)
>  				exception->retry = 1;
> @@ -429,15 +429,18 @@ static int nfs4_recover_session(struct nfs4_session *session)
>  {
>  	struct nfs_client *clp = session->clp;
>  	unsigned int loop;
> -	int ret;
> +	int ret, status = 0;
>  
>  	for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
>  		ret = nfs4_wait_clnt_recover(clp);
>  		if (ret != 0)
>  			break;
> +		ret = status;
> +		if (ret != 0)
> +			break;
>  		if (!test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state))
>  			break;
> -		nfs4_schedule_state_manager(clp);
> +		nfs4_schedule_state_manager(clp, &status);
>  		ret = -EIO;
>  	}
>  	return ret;
> @@ -1183,7 +1186,8 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
>  			case -NFS4ERR_STALE_STATEID:
>  			case -NFS4ERR_EXPIRED:
>  				/* Don't recall a delegation if it was lost */
> -				nfs4_schedule_state_recovery(server->nfs_client);
> +				nfs4_schedule_state_recovery(server->nfs_client,
> +							     NULL);
>  				goto out;
>  			case -ERESTARTSYS:
>  				/*
> @@ -1448,16 +1452,19 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
>  static int nfs4_recover_expired_lease(struct nfs_client *clp)
>  {
>  	unsigned int loop;
> -	int ret;
> +	int ret, status = 0;
>  
>  	for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
>  		ret = nfs4_wait_clnt_recover(clp);
>  		if (ret != 0)
>  			break;
> +		ret = status;
> +		if (ret != 0)
> +			break;
>  		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
>  		    !test_bit(NFS4CLNT_CHECK_LEASE,&clp->cl_state))
>  			break;
> -		nfs4_schedule_state_recovery(clp);
> +		nfs4_schedule_state_recovery(clp, &status);
>  		ret = -EIO;
>  	}
>  	return ret;
> @@ -3053,7 +3060,7 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
>  	if (task->tk_status < 0) {
>  		/* Unless we're shutting down, schedule state recovery! */
>  		if (test_bit(NFS_CS_RENEWD, &clp->cl_res_state) != 0)
> -			nfs4_schedule_state_recovery(clp);
> +			nfs4_schedule_state_recovery(clp, NULL);
>  		return;
>  	}
>  	spin_lock(&clp->cl_lock);
> @@ -3333,7 +3340,7 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
>  		case -NFS4ERR_STALE_STATEID:
>  		case -NFS4ERR_EXPIRED:
>  			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
> -			nfs4_schedule_state_recovery(clp);
> +			nfs4_schedule_state_recovery(clp, NULL);
>  			if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
>  				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
>  			task->tk_status = 0;
> @@ -4170,7 +4177,8 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
>  			case -NFS4ERR_EXPIRED:
>  			case -NFS4ERR_STALE_CLIENTID:
>  			case -NFS4ERR_STALE_STATEID:
> -				nfs4_schedule_state_recovery(server->nfs_client);
> +				nfs4_schedule_state_recovery(server->nfs_client,
> +							     NULL);
>  				goto out;
>  			case -ERESTARTSYS:
>  				/*
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 65ca8c1..f99278a 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -779,10 +779,20 @@ unlock:
>  	return status;
>  }
>  
> +struct nfs_state_manager_args {
> +	struct nfs_client *clp;
> +	int *statusp;
> +};
> +
>  static int nfs4_run_state_manager(void *);
>  
> -static void nfs4_clear_state_manager_bit(struct nfs_client *clp)
> +static void nfs4_clear_state_manager_bit(struct nfs_state_manager_args *args,
> +					 int status)
>  {
> +	struct nfs_client *clp = args->clp;
> +	if (args->statusp)
> +		*args->statusp = status;
> +	kfree(args);
>  	smp_mb__before_clear_bit();
>  	clear_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state);
>  	smp_mb__after_clear_bit();
> @@ -793,20 +803,28 @@ static void nfs4_clear_state_manager_bit(struct nfs_client *clp)
>  /*
>   * Schedule the nfs_client asynchronous state management routine
>   */
> -void nfs4_schedule_state_manager(struct nfs_client *clp)
> +void nfs4_schedule_state_manager(struct nfs_client *clp, int *statusp)
>  {
>  	struct task_struct *task;
> +	struct nfs_state_manager_args *args;
>  
> +	args = kmalloc(sizeof(*args), GFP_KERNEL);
> +	if (!args)
> +		return;
> +	args->clp = clp;
> +	args->statusp = statusp;
>  	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
>  		return;
> +	if (statusp)
> +		*statusp = 0;
>  	__module_get(THIS_MODULE);
>  	atomic_inc(&clp->cl_count);
> -	task = kthread_run(nfs4_run_state_manager, clp, "%s-manager",
> +	task = kthread_run(nfs4_run_state_manager, args, "%s-manager",
>  				rpc_peeraddr2str(clp->cl_rpcclient,
>  							RPC_DISPLAY_ADDR));
>  	if (!IS_ERR(task))
>  		return;
> -	nfs4_clear_state_manager_bit(clp);
> +	nfs4_clear_state_manager_bit(args, PTR_ERR(task));
>  	nfs_put_client(clp);
>  	module_put(THIS_MODULE);
>  }
> @@ -814,13 +832,13 @@ void nfs4_schedule_state_manager(struct nfs_client *clp)
>  /*
>   * Schedule a state recovery attempt
>   */
> -void nfs4_schedule_state_recovery(struct nfs_client *clp)
> +void nfs4_schedule_state_recovery(struct nfs_client *clp, int *statusp)
>  {
>  	if (!clp)
>  		return;
>  	if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
>  		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
> -	nfs4_schedule_state_manager(clp);
> +	nfs4_schedule_state_manager(clp, statusp);
>  }
>  
>  static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
> @@ -1223,9 +1241,10 @@ static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
>  	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
>  }
>  
> -static void nfs4_state_manager(struct nfs_client *clp)
> +static void nfs4_state_manager(struct nfs_state_manager_args *args)
>  {
>  	int status = 0;
> +	struct nfs_client *clp = args->clp;
>  
>  	/* Ensure exclusive access to NFSv4 state */
>  	for(;;) {
> @@ -1298,7 +1317,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
>  			continue;
>  		}
>  
> -		nfs4_clear_state_manager_bit(clp);
> +		nfs4_clear_state_manager_bit(args, 0);
>  		/* Did we race with an attempt to give us more work? */
>  		if (clp->cl_state == 0)
>  			break;
> @@ -1311,16 +1330,17 @@ out_error:
>  			" with error %d\n", clp->cl_hostname, -status);
>  	if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
>  		nfs4_state_end_reclaim_reboot(clp);
> -	nfs4_clear_state_manager_bit(clp);
> +	nfs4_clear_state_manager_bit(args, status);
>  }
>  
>  static int nfs4_run_state_manager(void *ptr)
>  {
> -	struct nfs_client *clp = ptr;
> +	struct nfs_state_manager_args *args = ptr;
>  
>  	allow_signal(SIGKILL);
> -	nfs4_state_manager(clp);
> -	nfs_put_client(clp);
> +	nfs4_state_manager(args);
> +	nfs_put_client(args->clp);
> +	kfree(args);
>  	module_put_and_exit(0);
>  	return 0;
>  }
