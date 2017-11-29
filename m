Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:62540 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751960AbdK2UQs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Nov 2017 15:16:48 -0500
Subject: Re: [PATCH] nfs: fix a deadlock in nfs client initialization
To: Scott Mayhew <smayhew@redhat.com>,
        <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
References: <20171120212819.3yxutvgmigxc7at5@tonberry.usersys.redhat.com>
 <20171120214118.4240-1-smayhew@redhat.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <62264a3c-db93-285f-a019-340bd0107b46@Netapp.com>
Date: Wed, 29 Nov 2017 15:16:41 -0500
MIME-Version: 1.0
In-Reply-To: <20171120214118.4240-1-smayhew@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Scott,

On 11/20/2017 04:41 PM, Scott Mayhew wrote:
> The following deadlock can occur between a process waiting for a client
> to initialize in while walking the client list and another process
> waiting for the nfs_clid_init_mutex so it can initialize that client:
> 
> Process 1                               Process 2
> ---------                               ---------
> spin_lock(&nn->nfs_client_lock);
> list_add_tail(&CLIENTA->cl_share_link,
>         &nn->nfs_client_list);
> spin_unlock(&nn->nfs_client_lock);
>                                         spin_lock(&nn->nfs_client_lock);
>                                         list_add_tail(&CLIENTB->cl_share_link,
>                                                 &nn->nfs_client_list);
>                                         spin_unlock(&nn->nfs_client_lock);
>                                         mutex_lock(&nfs_clid_init_mutex);
>                                         nfs41_walk_client_list(clp, result, cred);
>                                         nfs_wait_client_init_complete(CLIENTA);
> (waiting for nfs_clid_init_mutex)
> 
> Add and initilize the client with the nfs_clid_init_mutex held in
> order to prevent that deadlock.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/client.c    | 21 +++++++++++++++++++--
>  fs/nfs/nfs4state.c |  4 ----
>  2 files changed, 19 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 0ac2fb1..db38c47 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -60,6 +60,7 @@ static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
>  static DEFINE_SPINLOCK(nfs_version_lock);
>  static DEFINE_MUTEX(nfs_version_mutex);
>  static LIST_HEAD(nfs_versions);
> +static DEFINE_MUTEX(nfs_clid_init_mutex);
>  
>  /*
>   * RPC cruft for NFS
> @@ -386,7 +387,7 @@ nfs_found_client(const struct nfs_client_initdata *cl_init,
>   */
>  struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
>  {
> -	struct nfs_client *clp, *new = NULL;
> +	struct nfs_client *clp, *new = NULL, *result = NULL;
>  	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
>  	const struct nfs_rpc_ops *rpc_ops = cl_init->nfs_mod->rpc_ops;
>  
> @@ -407,11 +408,27 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
>  			return nfs_found_client(cl_init, clp);
>  		}
>  		if (new) {
> +			/* add and initialize the client with the
> +			 * nfs_clid_init_mutex held to prevent a deadlock
> +			 * with the server trunking detection
> +			 */
> +			spin_unlock(&nn->nfs_client_lock);
> +			mutex_lock(&nfs_clid_init_mutex);
> +			spin_lock(&nn->nfs_client_lock);
> +			clp = nfs_match_client(cl_init);
> +			if (clp) {
> +				spin_unlock(&nn->nfs_client_lock);
> +				mutex_unlock(&nfs_clid_init_mutex);
> +				new->rpc_ops->free_client(new);
> +				return nfs_found_client(cl_init, clp);
> +			}

Is there any reason you can't just grab the nfs_clid_init_mutex at the very beginning of the do/while loop, right before getting the nn->nfs_client_lock?  Then you wouldn't need to repeat the nfs_match_client() check, which might help clean the code up a bit.

Thanks,
Anna


>  			list_add_tail(&new->cl_share_link,
>  					&nn->nfs_client_list);
>  			spin_unlock(&nn->nfs_client_lock);
>  			new->cl_flags = cl_init->init_flags;
> -			return rpc_ops->init_client(new, cl_init);
> +			result = rpc_ops->init_client(new, cl_init);
> +			mutex_unlock(&nfs_clid_init_mutex);
> +			return result;
>  		}
>  
>  		spin_unlock(&nn->nfs_client_lock);
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 54fd56d..668164e 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -77,8 +77,6 @@ const nfs4_stateid invalid_stateid = {
>  	.type = NFS4_INVALID_STATEID_TYPE,
>  };
>  
> -static DEFINE_MUTEX(nfs_clid_init_mutex);
> -
>  int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>  {
>  	struct nfs4_setclientid_res clid = {
> @@ -2164,7 +2162,6 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
>  	clnt = clp->cl_rpcclient;
>  	i = 0;
>  
> -	mutex_lock(&nfs_clid_init_mutex);
>  again:
>  	status  = -ENOENT;
>  	cred = nfs4_get_clid_cred(clp);
> @@ -2232,7 +2229,6 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
>  	}
>  
>  out_unlock:
> -	mutex_unlock(&nfs_clid_init_mutex);
>  	dprintk("NFS: %s: status = %d\n", __func__, status);
>  	return status;
>  }
> 
