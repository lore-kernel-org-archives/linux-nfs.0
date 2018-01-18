Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:46162 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754513AbeARSjI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Jan 2018 13:39:08 -0500
Subject: Re: [PATCH 02/20] SUNRPC: add 'struct cred *' to auth_cred and
 rpc_cred
To: NeilBrown <neilb@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
References: <151538903497.25812.13293229343061416612.stgit@noble>
 <151538917875.25812.10005878132438571890.stgit@noble>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <ea9fad0d-a718-aba8-3dd1-042644577c81@Netapp.com>
Date: Thu, 18 Jan 2018 13:39:00 -0500
MIME-Version: 1.0
In-Reply-To: <151538917875.25812.10005878132438571890.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

On 01/08/2018 12:26 AM, NeilBrown wrote:
> The SUNRPC credential framework was put together before
> Linux has 'struct cred'.  Now that we have it, it makes sense to
> use it.
> This first step just includes a suitable 'struct cred *' pointer
> in every 'struct auth_cred' and almost every 'struct rpc_cred'.
> 
> The rpc_cred used for auth_null has a NULL 'struct cred *' as nothing
> else really makes sense.
> 
> For rpc_cred, the pointer is reference counted.
> For auth_cred it isn't.  struct auth_cred are either allocated on
> the stack, in which case the thread owns a reference to the auth,
> or are part of 'struct generic_cred' in which case gc_base owns the
> reference and acred shares it.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c |   17 +++++++++++++++++
>  fs/nfsd/nfs4callback.c                 |   13 ++++++++++++-
>  include/linux/sunrpc/auth.h            |    2 ++
>  net/sunrpc/auth.c                      |   15 +++++++++++++--
>  net/sunrpc/auth_generic.c              |    7 ++++++-
>  net/sunrpc/auth_gss/auth_gss.c         |    1 +
>  6 files changed, 51 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index c75ad982bcfc..b727579a1508 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -9,6 +9,7 @@
>  #include <linux/nfs_fs.h>
>  #include <linux/nfs_page.h>
>  #include <linux/module.h>
> +#include <linux/sched/mm.h>
>  
>  #include <linux/sunrpc/metrics.h>
>  
> @@ -415,6 +416,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
>  		struct nfs4_ff_layout_mirror *mirror;
>  		struct auth_cred acred = { .group_info = ff_zero_group };
>  		struct rpc_cred	__rcu *cred;
> +		struct cred *kcred;
>  		u32 ds_count, fh_count, id;
>  		int j;
>  
> @@ -491,8 +493,23 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
>  
>  		acred.gid = make_kgid(&init_user_ns, id);
>  
> +		if (gfp_flags & __GFP_FS)
> +			kcred = prepare_kernel_cred(NULL);
> +		else {
> +			unsigned int nofs_flags = memalloc_nofs_save();
> +			kcred = prepare_kernel_cred(NULL);
> +			memalloc_nofs_restore(nofs_flags);
> +		}
> +		rc = -ENOMEM;
> +		if (!kcred)
> +			goto out_err_free;
> +		kcred->fsuid = acred.uid;
> +		kcred->fsgid = acred.gid;
> +		acred.cred = kcred;
> +
>  		/* find the cred for it */
>  		rcu_assign_pointer(cred, rpc_lookup_generic_cred(&acred, 0, gfp_flags));
> +		put_cred(kcred);
>  		if (IS_ERR(cred)) {
>  			rc = PTR_ERR(cred);
>  			goto out_err_free;
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 49b0a9e7ff18..fc5b38ee6c70 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -773,10 +773,21 @@ static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc
>  	} else {
>  		struct rpc_auth *auth = client->cl_auth;
>  		struct auth_cred acred = {};
> +		struct cred *kcred;
> +		struct rpc_cred *ret;
> +
> +		kcred = prepare_kernel_cred(NULL);
> +		if (!acred.cred)
> +			return NULL;
>  
>  		acred.uid = ses->se_cb_sec.uid;
>  		acred.gid = ses->se_cb_sec.gid;
> -		return auth->au_ops->lookup_cred(client->cl_auth, &acred, 0);
> +		kcred->uid = acred.uid;
> +		kcred->gid = acred.gid;
> +		acred.cred = kcred;
> +		ret = auth->au_ops->lookup_cred(client->cl_auth, &acred, 0);
> +		put_cred(kcred);
> +		return ret;
>  	}
>  }
>  
> diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
> index d9af474a857d..57633e241d4a 100644
> --- a/include/linux/sunrpc/auth.h
> +++ b/include/linux/sunrpc/auth.h
> @@ -46,6 +46,7 @@ enum {
>  
>  /* Work around the lack of a VFS credential */
>  struct auth_cred {
> +	const struct cred *cred;
>  	kuid_t	uid;
>  	kgid_t	gid;
>  	struct group_info *group_info;
> @@ -68,6 +69,7 @@ struct rpc_cred {
>  	unsigned long		cr_expire;	/* when to gc */
>  	unsigned long		cr_flags;	/* various flags */
>  	atomic_t		cr_count;	/* ref count */
> +	const struct cred	*cr_cred;
>  
>  	kuid_t			cr_uid;
>  
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index d2623b9f23d6..fd9635dbc17f 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -634,6 +634,7 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
>  	acred.uid = cred->fsuid;
>  	acred.gid = cred->fsgid;
>  	acred.group_info = cred->group_info;
> +	acred.cred = cred;
>  	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
>  	return ret;
>  }
> @@ -649,6 +650,7 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
>  	cred->cr_auth = auth;
>  	cred->cr_ops = ops;
>  	cred->cr_expire = jiffies;
> +	cred->cr_cred = get_cred(acred->cred);
>  	cred->cr_uid = acred->uid;
>  }
>  EXPORT_SYMBOL_GPL(rpcauth_init_cred);
> @@ -669,11 +671,15 @@ rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
>  	struct auth_cred acred = {
>  		.uid = GLOBAL_ROOT_UID,
>  		.gid = GLOBAL_ROOT_GID,
> +		.cred = get_task_cred(&init_task),

Is there a patch somewhere to add "EXPORT_SYMBOL_GPL(get_task_cred)" to kernel/cred.c?
I'm getting: 
    ERROR: "get_task_cred" [net/sunrpc/sunrpc.ko] undefined!
when I compile.

Thanks,
Anna

>  	};
> +	struct rpc_cred *ret;
>  
>  	dprintk("RPC: %5u looking up %s cred\n",
>  		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
> -	return auth->au_ops->lookup_cred(auth, &acred, lookupflags);
> +	ret = auth->au_ops->lookup_cred(auth, &acred, lookupflags);
> +	put_cred(acred.cred);
> +	return ret;
>  }
>  
>  static struct rpc_cred *
> @@ -715,8 +721,11 @@ put_rpccred(struct rpc_cred *cred)
>  		return;
>  	/* Fast path for unhashed credentials */
>  	if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) == 0) {
> -		if (atomic_dec_and_test(&cred->cr_count))
> +		if (atomic_dec_and_test(&cred->cr_count)) {
> +			if (cred->cr_cred)
> +				put_cred(cred->cr_cred);
>  			cred->cr_ops->crdestroy(cred);
> +		}
>  		return;
>  	}
>  
> @@ -739,6 +748,8 @@ put_rpccred(struct rpc_cred *cred)
>  		}
>  	}
>  	spin_unlock(&rpc_credcache_lock);
> +	if (cred->cr_cred)
> +		put_cred(cred->cr_cred);
>  	cred->cr_ops->crdestroy(cred);
>  	return;
>  out_nodestroy:
> diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
> index f1df9837f1ac..08bc5fac1865 100644
> --- a/net/sunrpc/auth_generic.c
> +++ b/net/sunrpc/auth_generic.c
> @@ -61,11 +61,15 @@ struct rpc_cred *rpc_lookup_machine_cred(const char *service_name)
>  		.gid = RPC_MACHINE_CRED_GROUPID,
>  		.principal = service_name,
>  		.machine_cred = 1,
> +		.cred = get_task_cred(&init_task),
>  	};
> +	struct rpc_cred *ret;
>  
>  	dprintk("RPC:       looking up machine cred for service %s\n",
>  			service_name);
> -	return generic_auth.au_ops->lookup_cred(&generic_auth, &acred, 0);
> +	ret = generic_auth.au_ops->lookup_cred(&generic_auth, &acred, 0);
> +	put_cred(acred.cred);
> +	return ret;
>  }
>  EXPORT_SYMBOL_GPL(rpc_lookup_machine_cred);
>  
> @@ -110,6 +114,7 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, g
>  	gcred->acred.uid = acred->uid;
>  	gcred->acred.gid = acred->gid;
>  	gcred->acred.group_info = acred->group_info;
> +	gcred->acred.cred = gcred->gc_base.cr_cred;
>  	gcred->acred.ac_flags = 0;
>  	if (gcred->acred.group_info != NULL)
>  		get_group_info(gcred->acred.group_info);
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 9463af4b32e8..82301105b4f6 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1553,6 +1553,7 @@ static int gss_renew_cred(struct rpc_task *task)
>  	struct rpc_auth *auth = oldcred->cr_auth;
>  	struct auth_cred acred = {
>  		.uid = oldcred->cr_uid,
> +		.cred = oldcred->cr_cred,
>  		.principal = gss_cred->gc_principal,
>  		.machine_cred = (gss_cred->gc_principal != NULL ? 1 : 0),
>  	};
> 
> 
