Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:41761 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752618AbcHLU73 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Aug 2016 16:59:29 -0400
Subject: Re: [PATCH Version 8 11/12] NFS test session trunking with exchange
 id
To: <andros@netapp.com>, <trond.myklebust@primarydata.com>
References: <1470951574-18441-1-git-send-email-andros@netapp.com>
 <1470951574-18441-12-git-send-email-andros@netapp.com>
CC: <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <59ccb376-6c4c-effc-57ad-014ca3b9c3c2@Netapp.com>
Date: Fri, 12 Aug 2016 16:59:04 -0400
MIME-Version: 1.0
In-Reply-To: <1470951574-18441-12-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

On 08/11/2016 05:39 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Use an async exchange id call to test for session trunking
> 
> To conform with RFC 5661 section 18.35.4, the Non-Update on
> Existing Clientid case, save the exchange id verifier in
> cl_confirm and use it for the session trunking exhange id test.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4_fs.h  |  5 +++++
>  fs/nfs/nfs4proc.c | 52 ++++++++++++++++++++++++++++++++++++++++++++--------
>  2 files changed, 49 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index eb315e1..b2a94ca 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -203,6 +203,11 @@ struct nfs4_state_recovery_ops {
>  		struct rpc_cred *);
>  };
>  
> +struct nfs4_add_xprt_data {
> +	struct nfs_client	*clp;
> +	struct rpc_cred		*cred;
> +};
> +
>  struct nfs4_state_maintenance_ops {
>  	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *, unsigned);
>  	struct rpc_cred * (*get_state_renewal_cred_locked)(struct nfs_client *);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index e29f5ce..ffe578c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7054,6 +7054,7 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
>  struct nfs41_exchange_id_data {
>  	struct nfs41_exchange_id_res res;
>  	struct nfs41_exchange_id_args args;
> +	struct rpc_xprt *xprt;
>  	int rpc_status;
>  };
>  
> @@ -7068,6 +7069,10 @@ static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
>  
>  	if (status == 0)
>  		status = nfs4_check_cl_exchange_flags(cdata->res.flags);
> +
> +	if (cdata->xprt)
> +		goto session_trunk;
> +
>  	if (status  == 0)
>  		status = nfs4_sp4_select_mode(clp, &cdata->res.state_protect);
>  
> @@ -7104,8 +7109,23 @@ static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
>  			clp->cl_serverscope = cdata->res.server_scope;
>  			cdata->res.server_scope = NULL;
>  		}
> +		/* Save the EXCHANGE_ID verifier session trunk tests */
> +		memcpy(clp->cl_confirm.data, cdata->args.verifier->data,
> +		       sizeof(clp->cl_confirm.data));
>  	}
> +out:
>  	cdata->rpc_status = status;
> +	return;
> +
> +session_trunk:
> +	if (status == 0) {
> +		status = nfs4_detect_session_trunking(clp, &cdata->res,
> +						      cdata->xprt);
> +		if (status == 0)
> +			rpc_clnt_xprt_switch_add_xprt(clp->cl_rpcclient,
> +						      cdata->xprt);

Would it make sense to have nfs4_detect_session_trunking() call rpc_clnt_xprt_switch_add_xprt() on success?  Then you might be able to get by without calling it directly from your if (cdata->xprt) check (above), rather than adding the extra goto.

Thoughts?
Anna

> +	}
> +	goto out;
>  }
>  
>  static void nfs4_exchange_id_release(void *data)
> @@ -7114,6 +7134,10 @@ static void nfs4_exchange_id_release(void *data)
>  					(struct nfs41_exchange_id_data *)data;
>  
>  	nfs_put_client(cdata->args.client);
> +	if (cdata->xprt) {
> +		xprt_put(cdata->xprt);
> +		rpc_clnt_xprt_switch_put(cdata->args.client->cl_rpcclient);
> +	}
>  	kfree(cdata->res.impl_id);
>  	kfree(cdata->res.server_scope);
>  	kfree(cdata->res.server_owner);
> @@ -7131,7 +7155,7 @@ static const struct rpc_call_ops nfs4_exchange_id_call_ops = {
>   * Wrapper for EXCHANGE_ID operation.
>   */
>  static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
> -	u32 sp4_how)
> +			u32 sp4_how, struct rpc_xprt *xprt)
>  {
>  	nfs4_verifier verifier;
>  	struct rpc_message msg = {
> @@ -7156,7 +7180,8 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
>  	if (!calldata)
>  		goto out;
>  
> -	nfs4_init_boot_verifier(clp, &verifier);
> +	if (!xprt)
> +		nfs4_init_boot_verifier(clp, &verifier);
>  
>  	status = nfs4_init_uniform_client_string(clp);
>  	if (status)
> @@ -7196,8 +7221,15 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
>  		status = -EINVAL;
>  		goto out_impl_id;
>  	}
> -
> -	calldata->args.verifier = &verifier;
> +	if (xprt) {
> +		calldata->xprt = xprt;
> +		task_setup_data.rpc_xprt = xprt;
> +		task_setup_data.flags =
> +				RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC;
> +		calldata->args.verifier = &clp->cl_confirm;
> +	} else {
> +		calldata->args.verifier = &verifier;
> +	}
>  	calldata->args.client = clp;
>  #ifdef CONFIG_NFS_V4_1_MIGRATION
>  	calldata->args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
> @@ -7217,9 +7249,13 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
>  		goto out_impl_id;
>  	}
>  
> -	status = rpc_wait_for_completion_task(task);
> -	if (!status)
> +	if (!xprt) {
> +		status = rpc_wait_for_completion_task(task);
> +		if (!status)
> +			status = calldata->rpc_status;
> +	} else	/* session trunking test */
>  		status = calldata->rpc_status;
> +
>  	rpc_put_task(task);
>  out:
>  	if (clp->cl_implid != NULL)
> @@ -7262,13 +7298,13 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>  	/* try SP4_MACH_CRED if krb5i/p	*/
>  	if (authflavor == RPC_AUTH_GSS_KRB5I ||
>  	    authflavor == RPC_AUTH_GSS_KRB5P) {
> -		status = _nfs4_proc_exchange_id(clp, cred, SP4_MACH_CRED);
> +		status = _nfs4_proc_exchange_id(clp, cred, SP4_MACH_CRED, NULL);
>  		if (!status)
>  			return 0;
>  	}
>  
>  	/* try SP4_NONE */
> -	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE);
> +	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE, NULL);
>  }
>  
>  static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
> 

