Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:34838 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933870AbcHERei convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Aug 2016 13:34:38 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Adamson William Andros <andros@netapp.com>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 7 7/8] NFS test session trunking with exchange id
Date: Fri, 5 Aug 2016 17:34:29 +0000
Message-ID: <13D6BF4C-E372-44D0-A9D1-0F40ABB0F7D3@primarydata.com>
References: <1469645000-19791-1-git-send-email-andros@netapp.com>
 <1469645000-19791-8-git-send-email-andros@netapp.com>
In-Reply-To: <1469645000-19791-8-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 27, 2016, at 14:43, andros@netapp.com wrote:
> 
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/nfs4_fs.h           |  5 +++
> fs/nfs/nfs4proc.c          | 97 +++++++++++++++++++++++++++++++++++++++++++---
> net/sunrpc/xprtmultipath.c |  2 +
> 3 files changed, 98 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index eb315e1..b2a94ca 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -203,6 +203,11 @@ struct nfs4_state_recovery_ops {
> 		struct rpc_cred *);
> };
> 
> +struct nfs4_add_xprt_data {
> +	struct nfs_client	*clp;
> +	struct rpc_cred		*cred;
> +};
> +
> struct nfs4_state_maintenance_ops {
> 	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *, unsigned);
> 	struct rpc_cred * (*get_state_renewal_cred_locked)(struct nfs_client *);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index e29f5ce..fa9ae75 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -44,6 +44,7 @@
> #include <linux/printk.h>
> #include <linux/slab.h>
> #include <linux/sunrpc/clnt.h>
> +#include <linux/sunrpc/addr.h>
> #include <linux/nfs.h>
> #include <linux/nfs4.h>
> #include <linux/nfs_fs.h>
> @@ -7050,10 +7051,16 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
> 
> 	return 0;
> }
> +struct nfs41_test_xprt_data {
> +	struct rpc_xprt *xprt;
> +	struct rpc_xprt_switch *xps;
> +};
> 
> struct nfs41_exchange_id_data {
> 	struct nfs41_exchange_id_res res;
> 	struct nfs41_exchange_id_args args;
> +	struct nfs41_test_xprt_data xdata;
> +	int session_trunk;
> 	int rpc_status;
> };
> 
> @@ -7068,6 +7075,10 @@ static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
> 
> 	if (status == 0)
> 		status = nfs4_check_cl_exchange_flags(cdata->res.flags);
> +
> +	if (cdata->session_trunk)
> +		goto session_trunk;
> +
> 	if (status  == 0)
> 		status = nfs4_sp4_select_mode(clp, &cdata->res.state_protect);
> 
> @@ -7105,7 +7116,15 @@ static void nfs4_exchange_id_done(struct rpc_task *task, void *data)
> 			cdata->res.server_scope = NULL;
> 		}
> 	}
> +out:
> 	cdata->rpc_status = status;
> +	return;
> +
> +session_trunk:
> +	if (status == 0)
> +		status = nfs4_detect_session_trunking(clp, &cdata->res,
> +						      cdata->xdata.xprt);
> +	goto out;
> }
> 
> static void nfs4_exchange_id_release(void *data)
> @@ -7114,6 +7133,10 @@ static void nfs4_exchange_id_release(void *data)
> 					(struct nfs41_exchange_id_data *)data;
> 
> 	nfs_put_client(cdata->args.client);
> +	if (cdata->session_trunk) {
> +		xprt_put(cdata->xdata.xprt);
> +		xprt_switch_put(cdata->xdata.xps);
> +	}
> 	kfree(cdata->res.impl_id);
> 	kfree(cdata->res.server_scope);
> 	kfree(cdata->res.server_owner);
> @@ -7131,7 +7154,7 @@ static const struct rpc_call_ops nfs4_exchange_id_call_ops = {
>  * Wrapper for EXCHANGE_ID operation.
>  */
> static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
> -	u32 sp4_how)
> +			u32 sp4_how, struct nfs41_test_xprt_data *xdata)
> {
> 	nfs4_verifier verifier;
> 	struct rpc_message msg = {
> @@ -7151,6 +7174,11 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
> 	if (!atomic_inc_not_zero(&clp->cl_count))
> 		goto out;
> 
> +	/* Don't test session trunking against the established mount rpc_xprt */
> +	if (xdata &&
> +	    xdata->xprt == rcu_access_pointer(clp->cl_rpcclient->cl_xprt))
> +		return 1;
> +
> 	status = -ENOMEM;
> 	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
> 	if (!calldata)
> @@ -7196,7 +7224,14 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
> 		status = -EINVAL;
> 		goto out_impl_id;
> 	}
> -
> +	if (xdata) {
> +		calldata->session_trunk = 1;
> +		calldata->xdata.xprt = xdata->xprt;
> +		calldata->xdata.xps = xdata->xps;
> +		task_setup_data.rpc_xprt = xdata->xprt;
> +		task_setup_data.flags =
> +				RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC;
> +	}
> 	calldata->args.verifier = &verifier;
> 	calldata->args.client = clp;
> #ifdef CONFIG_NFS_V4_1_MIGRATION
> @@ -7217,9 +7252,13 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
> 		goto out_impl_id;
> 	}
> 
> -	status = rpc_wait_for_completion_task(task);
> -	if (!status)
> +	if (!xdata) {
> +		status = rpc_wait_for_completion_task(task);
> +		if (!status)
> +			status = calldata->rpc_status;
> +	} else	/* session trunking test */
> 		status = calldata->rpc_status;
> +
> 	rpc_put_task(task);
> out:
> 	if (clp->cl_implid != NULL)
> @@ -7262,13 +7301,59 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
> 	/* try SP4_MACH_CRED if krb5i/p	*/
> 	if (authflavor == RPC_AUTH_GSS_KRB5I ||
> 	    authflavor == RPC_AUTH_GSS_KRB5P) {
> -		status = _nfs4_proc_exchange_id(clp, cred, SP4_MACH_CRED);
> +		status = _nfs4_proc_exchange_id(clp, cred, SP4_MACH_CRED, NULL);
> 		if (!status)
> 			return 0;
> 	}
> 
> 	/* try SP4_NONE */
> -	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE);
> +	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE, NULL);
> +}
> +
> +/**
> + * nfs4_test_session_trunk
> + * Test the connection with an rpc null ping.
> + * Test for session trunking with an asynchronous exchange_id call.
> + * Upon success, add a new transport
> + * to the rpc_clnt
> + *
> + * @clnt: struct rpc_clnt to get new transport
> + * @xps:  the rpc_xprt_switch to hold the new transport

I’d strongly prefer that we don’t let struct rpc_xprt_switch leak out of the RPC layer.
Can't we replace this with struct rpc_clnt?

> + * @xprt: the rpc_xprt to test
> + * @data: call data for _nfs4_proc_exchange_id.
> + */
> +int nfs4_test_session_trunk(struct rpc_clnt *clnt, struct rpc_xprt_switch *xps,
> +			    struct rpc_xprt *xprt, void *data)
> +{
> +	struct nfs4_add_xprt_data *adata = (struct nfs4_add_xprt_data *)data;
> +	struct nfs41_test_xprt_data xdata = {
> +		.xprt = xprt,
> +		.xps = xps,
> +	};
> +	u32 sp4_how;
> +	int status;
> +
> +	dprintk("--> %s try %s\n", __func__,
> +		xprt->address_strings[RPC_DISPLAY_ADDR]);
> +
> +	xprt = xprt_get(xprt);
> +	/* Test the connection */
> +	status = rpc_clnt_test_xprt(clnt, xprt);
> +	if (status < 0) {
> +		dprintk(" %s rpc_clnt_test_xprt failed for %s\n", __func__,
> +			xprt->address_strings[RPC_DISPLAY_ADDR]);
> +		xprt_put(xprt);
> +		goto out;
> +	}
> +	xps = xprt_switch_get(xps);
> +
> +	sp4_how = (adata->clp->cl_sp4_flags == 0 ? SP4_NONE : SP4_MACH_CRED);
> +
> +	/* Test connection for session trunking. Async exchange_id call */
> +	status = _nfs4_proc_exchange_id(adata->clp, adata->cred, sp4_how,
> +					&xdata);
> +out:
> +	return status;
> }
> 
> static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
> diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
> index 66c9d63..505d3b9 100644
> --- a/net/sunrpc/xprtmultipath.c
> +++ b/net/sunrpc/xprtmultipath.c
> @@ -145,6 +145,7 @@ struct rpc_xprt_switch *xprt_switch_get(struct rpc_xprt_switch *xps)
> 		return xps;
> 	return NULL;
> }
> +EXPORT_SYMBOL_GPL(xprt_switch_get);
> 
> /**
>  * xprt_switch_put - Release a reference to a rpc_xprt_switch
> @@ -157,6 +158,7 @@ void xprt_switch_put(struct rpc_xprt_switch *xps)
> 	if (xps != NULL)
> 		kref_put(&xps->xps_kref, xprt_switch_free);
> }
> +EXPORT_SYMBOL_GPL(xprt_switch_put);
> 
> /**
>  * rpc_xprt_switch_set_roundrobin - Set a round-robin policy on rpc_xprt_switch
> -- 
> 1.8.3.1
> 

