Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60660 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757042AbbIUPKo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 11:10:44 -0400
Date: Mon, 21 Sep 2015 11:10:43 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] NFSv4: Unify synchronous and asynchronous error
 handling
Message-ID: <20150921151043.GB11256@fieldses.org>
References: <1442781911-76248-1-git-send-email-trond.myklebust@primarydata.com>
 <1442781911-76248-2-git-send-email-trond.myklebust@primarydata.com>
 <1442781911-76248-3-git-send-email-trond.myklebust@primarydata.com>
 <1442781911-76248-4-git-send-email-trond.myklebust@primarydata.com>
 <1442781911-76248-5-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1442781911-76248-5-git-send-email-trond.myklebust@primarydata.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 20, 2015 at 04:45:11PM -0400, Trond Myklebust wrote:
> They now only differ in the way we handle waiting, so let's unify.

Neat, yes, nice not to have that big switch duplicated....

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 115 +++++++++++++++++++-----------------------------------
>  1 file changed, 41 insertions(+), 74 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index af3168c2b35d..18079763f5d0 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -78,7 +78,6 @@ struct nfs4_opendata;
>  static int _nfs4_proc_open(struct nfs4_opendata *data);
>  static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
>  static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
> -static int nfs4_async_handle_error(struct rpc_task *, struct nfs_server *, struct nfs4_state *, long *);
>  static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
>  static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
>  static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
> @@ -465,6 +464,47 @@ out_retry:
>  	return ret;
>  }
>  
> +static int
> +nfs4_async_handle_error(struct rpc_task *task, struct nfs_server *server,
> +			struct nfs4_state *state, long *timeout)
> +{
> +	struct nfs_client *clp = server->nfs_client;
> +	struct nfs4_exception exception = {
> +		.state = state,
> +	};
> +	int ret;
> +
> +	if (task->tk_status >= 0)
> +		return 0;
> +	if (timeout)
> +		exception.timeout = *timeout;
> +	ret = nfs4_do_handle_exception(server, task->tk_status, &exception);
> +	if (exception.delay) {
> +		nfs_inc_server_stats(server, NFSIOS_DELAY);
> +		rpc_delay(task, nfs4_update_delay(&exception.timeout));
> +		if (timeout)
> +			*timeout = exception.timeout;
> +		goto out_retry;
> +	}
> +	if (exception.recovering) {
> +		rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
> +		if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
> +			rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
> +		goto out_retry;
> +	}
> +	task->tk_status = ret;
> +	if (exception.retry)
> +		return -EAGAIN;
> +	return 0;
> +out_retry:
> +	if (test_bit(NFS_MIG_FAILED, &server->mig_status)) {
> +		task->tk_status = -EIO;
> +		return 0;
> +	}
> +	task->tk_status = 0;
> +	return -EAGAIN;
> +}
> +
>  /*
>   * Return 'true' if 'clp' is using an rpc_client that is integrity protected
>   * or 'false' otherwise.
> @@ -4953,79 +4993,6 @@ out:
>  #endif	/* CONFIG_NFS_V4_SECURITY_LABEL */
>  
>  
> -static int
> -nfs4_async_handle_error(struct rpc_task *task, struct nfs_server *server,
> -			struct nfs4_state *state, long *timeout)
> -{
> -	struct nfs_client *clp = server->nfs_client;
> -
> -	if (task->tk_status >= 0)
> -		return 0;
> -	switch(task->tk_status) {
> -		case -NFS4ERR_DELEG_REVOKED:
> -		case -NFS4ERR_ADMIN_REVOKED:
> -		case -NFS4ERR_BAD_STATEID:
> -		case -NFS4ERR_OPENMODE:
> -			if (state == NULL)
> -				break;
> -			if (nfs4_schedule_stateid_recovery(server, state) < 0)
> -				goto recovery_failed;
> -			goto wait_on_recovery;
> -		case -NFS4ERR_EXPIRED:
> -			if (state != NULL) {
> -				if (nfs4_schedule_stateid_recovery(server, state) < 0)
> -					goto recovery_failed;
> -			}
> -		case -NFS4ERR_STALE_STATEID:
> -		case -NFS4ERR_STALE_CLIENTID:
> -			nfs4_schedule_lease_recovery(clp);
> -			goto wait_on_recovery;
> -		case -NFS4ERR_MOVED:
> -			if (nfs4_schedule_migration_recovery(server) < 0)
> -				goto recovery_failed;
> -			goto wait_on_recovery;
> -		case -NFS4ERR_LEASE_MOVED:
> -			nfs4_schedule_lease_moved_recovery(clp);
> -			goto wait_on_recovery;
> -#if defined(CONFIG_NFS_V4_1)
> -		case -NFS4ERR_BADSESSION:
> -		case -NFS4ERR_BADSLOT:
> -		case -NFS4ERR_BAD_HIGH_SLOT:
> -		case -NFS4ERR_DEADSESSION:
> -		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
> -		case -NFS4ERR_SEQ_FALSE_RETRY:
> -		case -NFS4ERR_SEQ_MISORDERED:
> -			dprintk("%s ERROR %d, Reset session\n", __func__,
> -				task->tk_status);
> -			nfs4_schedule_session_recovery(clp->cl_session, task->tk_status);
> -			goto wait_on_recovery;
> -#endif /* CONFIG_NFS_V4_1 */
> -		case -NFS4ERR_DELAY:
> -			nfs_inc_server_stats(server, NFSIOS_DELAY);
> -			rpc_delay(task, nfs4_update_delay(timeout));
> -			goto restart_call;
> -		case -NFS4ERR_GRACE:
> -			rpc_delay(task, NFS4_POLL_RETRY_MAX);
> -		case -NFS4ERR_RETRY_UNCACHED_REP:
> -		case -NFS4ERR_OLD_STATEID:
> -			goto restart_call;
> -	}
> -	task->tk_status = nfs4_map_errors(task->tk_status);
> -	return 0;
> -recovery_failed:
> -	task->tk_status = -EIO;
> -	return 0;
> -wait_on_recovery:
> -	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
> -	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
> -		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
> -	if (test_bit(NFS_MIG_FAILED, &server->mig_status))
> -		goto recovery_failed;
> -restart_call:
> -	task->tk_status = 0;
> -	return -EAGAIN;
> -}
> -
>  static void nfs4_init_boot_verifier(const struct nfs_client *clp,
>  				    nfs4_verifier *bootverf)
>  {
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
