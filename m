From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: [PATCH 2/6] SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
Date: Thu, 13 Mar 2008 15:11:22 -0400
Message-ID: <47D97C5A.6020100@citi.umich.edu>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080313174807.13840.38440.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:10052 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754181AbYCMTLX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 15:11:23 -0400
In-Reply-To: <20080313174807.13840.38440.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

    We were thinking of using RPCAUTH_LOOKUP_ROOTCREDS flag to acquire 
machine creds for authenticated callback.

Trond Myklebust wrote:
> The current RPCAUTH_LOOKUP_ROOTCREDS flag only works for AUTH_SYS
> authentication, and then only as a special case in the code. This patch
> removes the auth_sys special casing, and replaces it with generic code.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
>  include/linux/sunrpc/auth.h |    4 ++-
>  net/sunrpc/auth.c           |   35 +++++++++++++++------------
>  net/sunrpc/auth_unix.c      |   56 ++++++++++++++++++-------------------------
>  net/sunrpc/sched.c          |    4 ++-
>  4 files changed, 49 insertions(+), 50 deletions(-)
>
> diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
> index 84d5f3a..012566a 100644
> --- a/include/linux/sunrpc/auth.h
> +++ b/include/linux/sunrpc/auth.h
> @@ -89,7 +89,6 @@ struct rpc_auth {
>  
>  /* Flags for rpcauth_lookupcred() */
>  #define RPCAUTH_LOOKUP_NEW		0x01	/* Accept an uninitialised cred */
> -#define RPCAUTH_LOOKUP_ROOTCREDS	0x02	/* This really ought to go! */
>  
>  /*
>   * Client authentication ops
> @@ -136,7 +135,8 @@ void			rpcauth_release(struct rpc_auth *);
>  struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int);
>  void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
>  struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
> -struct rpc_cred *	rpcauth_bindcred(struct rpc_task *);
> +void			rpcauth_bindcred(struct rpc_task *);
> +void			rpcauth_bind_root_cred(struct rpc_task *);
>  void			rpcauth_holdcred(struct rpc_task *);
>  void			put_rpccred(struct rpc_cred *);
>  void			rpcauth_unbindcred(struct rpc_task *);
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index b38f6ee..b0f2b2e 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -285,9 +285,6 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
>  
>  	nr = hash_long(acred->uid, RPC_CREDCACHE_HASHBITS);
>  
> -	if (!(flags & RPCAUTH_LOOKUP_ROOTCREDS))
> -		nr = acred->uid & RPC_CREDCACHE_MASK;
> -
>  	rcu_read_lock();
>  	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
>  		if (!entry->cr_ops->crmatch(acred, entry, flags))
> @@ -378,30 +375,38 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
>  }
>  EXPORT_SYMBOL_GPL(rpcauth_init_cred);
>  
> -struct rpc_cred *
> -rpcauth_bindcred(struct rpc_task *task)
> +void
> +rpcauth_bind_root_cred(struct rpc_task *task)
>  {
>  	struct rpc_auth *auth = task->tk_client->cl_auth;
>  	struct auth_cred acred = {
> -		.uid = current->fsuid,
> -		.gid = current->fsgid,
> -		.group_info = current->group_info,
> +		.uid = 0,
> +		.gid = 0,
>  	};
>  	struct rpc_cred *ret;
> -	int flags = 0;
>  
>  	dprintk("RPC: %5u looking up %s cred\n",
>  		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
> -	get_group_info(acred.group_info);
> -	if (task->tk_flags & RPC_TASK_ROOTCREDS)
> -		flags |= RPCAUTH_LOOKUP_ROOTCREDS;
> -	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
> +	ret = auth->au_ops->lookup_cred(auth, &acred, 0);
> +	if (!IS_ERR(ret))
> +		task->tk_msg.rpc_cred = ret;
> +	else
> +		task->tk_status = PTR_ERR(ret);
> +}
> +
> +void
> +rpcauth_bindcred(struct rpc_task *task)
> +{
> +	struct rpc_auth *auth = task->tk_client->cl_auth;
> +	struct rpc_cred *ret;
> +
> +	dprintk("RPC: %5u looking up %s cred\n",
> +		task->tk_pid, auth->au_ops->au_name);
> +	ret = rpcauth_lookupcred(auth, 0);
>  	if (!IS_ERR(ret))
>  		task->tk_msg.rpc_cred = ret;
>  	else
>  		task->tk_status = PTR_ERR(ret);
> -	put_group_info(acred.group_info);
> -	return ret;
>  }
>  
>  void
> diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
> index 5ed91e5..b763710 100644
> --- a/net/sunrpc/auth_unix.c
> +++ b/net/sunrpc/auth_unix.c
> @@ -60,7 +60,8 @@ static struct rpc_cred *
>  unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
>  {
>  	struct unx_cred	*cred;
> -	int		i;
> +	unsigned int groups = 0;
> +	unsigned int i;
>  
>  	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
>  			acred->uid, acred->gid);
> @@ -70,21 +71,17 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
>  
>  	rpcauth_init_cred(&cred->uc_base, acred, auth, &unix_credops);
>  	cred->uc_base.cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
> -	if (flags & RPCAUTH_LOOKUP_ROOTCREDS) {
> -		cred->uc_uid = 0;
> -		cred->uc_gid = 0;
> -		cred->uc_gids[0] = NOGROUP;
> -	} else {
> -		int groups = acred->group_info->ngroups;
> -		if (groups > NFS_NGROUPS)
> -			groups = NFS_NGROUPS;
> -
> -		cred->uc_gid = acred->gid;
> -		for (i = 0; i < groups; i++)
> -			cred->uc_gids[i] = GROUP_AT(acred->group_info, i);
> -		if (i < NFS_NGROUPS)
> -		  cred->uc_gids[i] = NOGROUP;
> -	}
> +
> +	if (acred->group_info != NULL)
> +		groups = acred->group_info->ngroups;
> +	if (groups > NFS_NGROUPS)
> +		groups = NFS_NGROUPS;
> +
> +	cred->uc_gid = acred->gid;
> +	for (i = 0; i < groups; i++)
> +		cred->uc_gids[i] = GROUP_AT(acred->group_info, i);
> +	if (i < NFS_NGROUPS)
> +		cred->uc_gids[i] = NOGROUP;
>  
>  	return &cred->uc_base;
>  }
> @@ -118,26 +115,21 @@ static int
>  unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
>  {
>  	struct unx_cred	*cred = container_of(rcred, struct unx_cred, uc_base);
> -	int		i;
> +	unsigned int groups = 0;
> +	unsigned int i;
>  
> -	if (!(flags & RPCAUTH_LOOKUP_ROOTCREDS)) {
> -		int groups;
>  
> -		if (cred->uc_uid != acred->uid
> -		 || cred->uc_gid != acred->gid)
> -			return 0;
> +	if (cred->uc_uid != acred->uid || cred->uc_gid != acred->gid)
> +		return 0;
>  
> +	if (acred->group_info != NULL)
>  		groups = acred->group_info->ngroups;
> -		if (groups > NFS_NGROUPS)
> -			groups = NFS_NGROUPS;
> -		for (i = 0; i < groups ; i++)
> -			if (cred->uc_gids[i] != GROUP_AT(acred->group_info, i))
> -				return 0;
> -		return 1;
> -	}
> -	return (cred->uc_uid == 0
> -	     && cred->uc_gid == 0
> -	     && cred->uc_gids[0] == (gid_t) NOGROUP);
> +	if (groups > NFS_NGROUPS)
> +		groups = NFS_NGROUPS;
> +	for (i = 0; i < groups ; i++)
> +		if (cred->uc_gids[i] != GROUP_AT(acred->group_info, i))
> +			return 0;
> +	return 1;
>  }
>  
>  /*
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index cae219c..7db956f 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -821,8 +821,10 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
>  		/* Bind the user cred */
>  		if (task->tk_msg.rpc_cred != NULL)
>  			rpcauth_holdcred(task);
> -		else
> +		else if (!(task_setup_data->flags & RPC_TASK_ROOTCREDS))
>  			rpcauth_bindcred(task);
> +		else
> +			rpcauth_bind_root_cred(task);
>  		if (task->tk_action == NULL)
>  			rpc_call_start(task);
>  	}
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   
