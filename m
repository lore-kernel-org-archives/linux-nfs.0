Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:30102 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab1CJPEf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 10:04:35 -0500
Subject: Re: [PATCH v2 1/4] NFSv4/4.1: Fix nfs4_schedule_state_recovery abuses
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1299716359-30977-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Thu, 10 Mar 2011 10:03:44 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <CA01BDF2-D798-4D87-868D-FA877E232D06@oracle.com>
References: <1299716359-30977-1-git-send-email-Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is roughly what I'm doing to add migration recovery support: introducing helpers that are specific to handling NFS4ERR_MOVED and NFS4ERR_LEASE_MOVED.

This patch will conflict with my migration work, but the resolution shouldn't be difficult.

I haven't looked closely at the specifics, but I like the architectural change.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

On Mar 9, 2011, at 7:19 PM, Trond Myklebust wrote:

> nfs4_schedule_state_recovery() should only be used when we need to force
> the state manager to check the lease. If we just want to start the
> state manager in order to handle a state recovery situation, we should be
> using nfs4_schedule_state_manager().
> 
> This patch fixes the abuses of nfs4_schedule_state_recovery() by replacing
> its use with a set of helper functions that do the right thing.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/nfs4_fs.h          |    8 +++++++-
> fs/nfs/nfs4proc.c         |   45 +++++++++++++++++++++++----------------------
> fs/nfs/nfs4state.c        |   25 +++++++++++++++++++------
> include/linux/nfs_fs_sb.h |    8 +++-----
> 4 files changed, 52 insertions(+), 34 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 7a74740..42884b3 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -298,6 +298,11 @@ struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
> #if defined(CONFIG_NFS_V4_1)
> struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
> struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp);
> +extern void nfs4_schedule_session_recovery(struct nfs4_session *);
> +#else
> +static inline void nfs4_schedule_session_recovery(struct nfs4_session *)
> +{
> +}
> #endif /* CONFIG_NFS_V4_1 */
> 
> extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
> @@ -307,8 +312,9 @@ extern void nfs4_put_open_state(struct nfs4_state *);
> extern void nfs4_close_state(struct path *, struct nfs4_state *, fmode_t);
> extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
> extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
> -extern void nfs4_schedule_state_recovery(struct nfs_client *);
> +extern void nfs4_schedule_lease_recovery(struct nfs_client *);
> extern void nfs4_schedule_state_manager(struct nfs_client *);
> +extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
> extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
> extern int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state);
> extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index e091fd8..32713dd 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -257,12 +257,13 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
> 		case -NFS4ERR_OPENMODE:
> 			if (state == NULL)
> 				break;
> -			nfs4_state_mark_reclaim_nograce(clp, state);
> -			goto do_state_recovery;
> +			nfs4_schedule_stateid_recovery(server, state);
> +			goto wait_on_recovery;
> 		case -NFS4ERR_STALE_STATEID:
> 		case -NFS4ERR_STALE_CLIENTID:
> 		case -NFS4ERR_EXPIRED:
> -			goto do_state_recovery;
> +			nfs4_schedule_lease_recovery(clp);
> +			goto wait_on_recovery;
> #if defined(CONFIG_NFS_V4_1)
> 		case -NFS4ERR_BADSESSION:
> 		case -NFS4ERR_BADSLOT:
> @@ -273,7 +274,7 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
> 		case -NFS4ERR_SEQ_MISORDERED:
> 			dprintk("%s ERROR: %d Reset session\n", __func__,
> 				errorcode);
> -			nfs4_schedule_state_recovery(clp);
> +			nfs4_schedule_session_recovery(clp->cl_session);
> 			exception->retry = 1;
> 			break;
> #endif /* defined(CONFIG_NFS_V4_1) */
> @@ -296,8 +297,7 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
> 	}
> 	/* We failed to handle the error */
> 	return nfs4_map_errors(ret);
> -do_state_recovery:
> -	nfs4_schedule_state_recovery(clp);
> +wait_on_recovery:
> 	ret = nfs4_wait_clnt_recover(clp);
> 	if (ret == 0)
> 		exception->retry = 1;
> @@ -1256,14 +1256,13 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
> 			case -NFS4ERR_BAD_HIGH_SLOT:
> 			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
> 			case -NFS4ERR_DEADSESSION:
> -				nfs4_schedule_state_recovery(
> -					server->nfs_client);
> +				nfs4_schedule_session_recovery(server->nfs_client->cl_session);
> 				goto out;
> 			case -NFS4ERR_STALE_CLIENTID:
> 			case -NFS4ERR_STALE_STATEID:
> 			case -NFS4ERR_EXPIRED:
> 				/* Don't recall a delegation if it was lost */
> -				nfs4_schedule_state_recovery(server->nfs_client);
> +				nfs4_schedule_lease_recovery(server->nfs_client);
> 				goto out;
> 			case -ERESTARTSYS:
> 				/*
> @@ -1272,7 +1271,7 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
> 				 */
> 			case -NFS4ERR_ADMIN_REVOKED:
> 			case -NFS4ERR_BAD_STATEID:
> -				nfs4_state_mark_reclaim_nograce(server->nfs_client, state);
> +				nfs4_schedule_stateid_recovery(server, state);
> 			case -EKEYEXPIRED:
> 				/*
> 				 * User RPCSEC_GSS context has expired.
> @@ -1588,7 +1587,7 @@ static int nfs4_recover_expired_lease(struct nfs_server *server)
> 		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
> 		    !test_bit(NFS4CLNT_CHECK_LEASE,&clp->cl_state))
> 			break;
> -		nfs4_schedule_state_recovery(clp);
> +		nfs4_schedule_state_manager(clp);
> 		ret = -EIO;
> 	}
> 	return ret;
> @@ -3179,7 +3178,7 @@ static void nfs4_renew_done(struct rpc_task *task, void *calldata)
> 	if (task->tk_status < 0) {
> 		/* Unless we're shutting down, schedule state recovery! */
> 		if (test_bit(NFS_CS_RENEWD, &clp->cl_res_state) != 0)
> -			nfs4_schedule_state_recovery(clp);
> +			nfs4_schedule_lease_recovery(clp);
> 		return;
> 	}
> 	do_renew_lease(clp, timestamp);
> @@ -3504,12 +3503,13 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
> 		case -NFS4ERR_OPENMODE:
> 			if (state == NULL)
> 				break;
> -			nfs4_state_mark_reclaim_nograce(clp, state);
> -			goto do_state_recovery;
> +			nfs4_schedule_stateid_recovery(server, state);
> +			goto wait_on_recovery;
> 		case -NFS4ERR_STALE_STATEID:
> 		case -NFS4ERR_STALE_CLIENTID:
> 		case -NFS4ERR_EXPIRED:
> -			goto do_state_recovery;
> +			nfs4_schedule_lease_recovery(clp);
> +			goto wait_on_recovery;
> #if defined(CONFIG_NFS_V4_1)
> 		case -NFS4ERR_BADSESSION:
> 		case -NFS4ERR_BADSLOT:
> @@ -3520,7 +3520,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
> 		case -NFS4ERR_SEQ_MISORDERED:
> 			dprintk("%s ERROR %d, Reset session\n", __func__,
> 				task->tk_status);
> -			nfs4_schedule_state_recovery(clp);
> +			nfs4_schedule_session_recovery(clp->cl_session);
> 			task->tk_status = 0;
> 			return -EAGAIN;
> #endif /* CONFIG_NFS_V4_1 */
> @@ -3537,9 +3537,8 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
> 	}
> 	task->tk_status = nfs4_map_errors(task->tk_status);
> 	return 0;
> -do_state_recovery:
> +wait_on_recovery:
> 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
> -	nfs4_schedule_state_recovery(clp);
> 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
> 		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
> 	task->tk_status = 0;
> @@ -4406,12 +4405,14 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
> 			case -NFS4ERR_EXPIRED:
> 			case -NFS4ERR_STALE_CLIENTID:
> 			case -NFS4ERR_STALE_STATEID:
> +				nfs4_schedule_lease_recovery(server->nfs_client);
> +				goto out;
> 			case -NFS4ERR_BADSESSION:
> 			case -NFS4ERR_BADSLOT:
> 			case -NFS4ERR_BAD_HIGH_SLOT:
> 			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
> 			case -NFS4ERR_DEADSESSION:
> -				nfs4_schedule_state_recovery(server->nfs_client);
> +				nfs4_schedule_session_recovery(server->nfs_client->cl_session);
> 				goto out;
> 			case -ERESTARTSYS:
> 				/*
> @@ -4421,7 +4422,7 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
> 			case -NFS4ERR_ADMIN_REVOKED:
> 			case -NFS4ERR_BAD_STATEID:
> 			case -NFS4ERR_OPENMODE:
> -				nfs4_state_mark_reclaim_nograce(server->nfs_client, state);
> +				nfs4_schedule_stateid_recovery(server, state);
> 				err = 0;
> 				goto out;
> 			case -EKEYEXPIRED:
> @@ -5150,7 +5151,7 @@ static int nfs41_sequence_handle_errors(struct rpc_task *task, struct nfs_client
> 		rpc_delay(task, NFS4_POLL_RETRY_MAX);
> 		return -EAGAIN;
> 	default:
> -		nfs4_schedule_state_recovery(clp);
> +		nfs4_schedule_lease_recovery(clp);
> 	}
> 	return 0;
> }
> @@ -5291,7 +5292,7 @@ static int nfs41_reclaim_complete_handle_errors(struct rpc_task *task, struct nf
> 		rpc_delay(task, NFS4_POLL_RETRY_MAX);
> 		return -EAGAIN;
> 	default:
> -		nfs4_schedule_state_recovery(clp);
> +		nfs4_schedule_lease_recovery(clp);
> 	}
> 	return 0;
> }
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index e6742b5..47c8dcd 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1007,9 +1007,9 @@ void nfs4_schedule_state_manager(struct nfs_client *clp)
> }
> 
> /*
> - * Schedule a state recovery attempt
> + * Schedule a lease recovery attempt
>  */
> -void nfs4_schedule_state_recovery(struct nfs_client *clp)
> +void nfs4_schedule_lease_recovery(struct nfs_client *clp)
> {
> 	if (!clp)
> 		return;
> @@ -1041,6 +1041,14 @@ int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *s
> 	return 1;
> }
> 
> +void nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4_state *state)
> +{
> +	struct nfs_client *clp = server->nfs_client;
> +
> +	nfs4_state_mark_reclaim_nograce(clp, state);
> +	nfs4_schedule_state_manager(clp);
> +}
> +
> static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_recovery_ops *ops)
> {
> 	struct inode *inode = state->inode;
> @@ -1436,10 +1444,15 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
> }
> 
> #ifdef CONFIG_NFS_V4_1
> +void nfs4_schedule_session_recovery(struct nfs4_session *session)
> +{
> +	nfs4_schedule_lease_recovery(session->clp);
> +}
> +
> void nfs41_handle_recall_slot(struct nfs_client *clp)
> {
> 	set_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
> -	nfs4_schedule_state_recovery(clp);
> +	nfs4_schedule_state_manager(clp);
> }
> 
> static void nfs4_reset_all_state(struct nfs_client *clp)
> @@ -1447,7 +1460,7 @@ static void nfs4_reset_all_state(struct nfs_client *clp)
> 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
> 		clp->cl_boot_time = CURRENT_TIME;
> 		nfs4_state_start_reclaim_nograce(clp);
> -		nfs4_schedule_state_recovery(clp);
> +		nfs4_schedule_state_manager(clp);
> 	}
> }
> 
> @@ -1455,7 +1468,7 @@ static void nfs41_handle_server_reboot(struct nfs_client *clp)
> {
> 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
> 		nfs4_state_start_reclaim_reboot(clp);
> -		nfs4_schedule_state_recovery(clp);
> +		nfs4_schedule_state_manager(clp);
> 	}
> }
> 
> @@ -1475,7 +1488,7 @@ static void nfs41_handle_cb_path_down(struct nfs_client *clp)
> {
> 	nfs_expire_all_delegations(clp);
> 	if (test_and_set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state) == 0)
> -		nfs4_schedule_state_recovery(clp);
> +		nfs4_schedule_state_manager(clp);
> }
> 
> void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 6beb33e..3e112de 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -68,9 +68,7 @@ struct nfs_client {
> 	unsigned char		cl_id_uniquifier;
> 	u32			cl_cb_ident;	/* v4.0 callback identifier */
> 	const struct nfs4_minor_version_ops *cl_mvops;
> -#endif /* CONFIG_NFS_V4 */
> 
> -#ifdef CONFIG_NFS_V4_1
> 	/* The sequence id to use for the next CREATE_SESSION */
> 	u32			cl_seqid;
> 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
> @@ -78,7 +76,7 @@ struct nfs_client {
> 	struct nfs4_session	*cl_session; 	/* sharred session */
> 	struct list_head	cl_layouts;
> 	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
> -#endif /* CONFIG_NFS_V4_1 */
> +#endif /* CONFIG_NFS_V4 */
> 
> #ifdef CONFIG_NFS_FSCACHE
> 	struct fscache_cookie	*fscache;	/* client index cache cookie */
> @@ -183,7 +181,7 @@ struct nfs_server {
> /* maximum number of slots to use */
> #define NFS4_MAX_SLOT_TABLE RPC_MAX_SLOT_TABLE
> 
> -#if defined(CONFIG_NFS_V4_1)
> +#if defined(CONFIG_NFS_V4)
> 
> /* Sessions */
> #define SLOT_TABLE_SZ (NFS4_MAX_SLOT_TABLE/(8*sizeof(long)))
> @@ -223,5 +221,5 @@ struct nfs4_session {
> 	struct nfs_client		*clp;
> };
> 
> -#endif /* CONFIG_NFS_V4_1 */
> +#endif /* CONFIG_NFS_V4 */
> #endif
> -- 
> 1.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




