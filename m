Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:32900 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720Ab1EJAH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 20:07:26 -0400
Received: by wwa36 with SMTP id 36so6292274wwa.1
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 17:07:25 -0700 (PDT)
Message-ID: <4DC88159.8010704@panasas.com>
Date: Tue, 10 May 2011 03:05:45 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: use scope from exchange_id to skip reclaim
References: <1304975677-21419-1-git-send-email-dros@netapp.com> <1304975677-21419-2-git-send-email-dros@netapp.com>
In-Reply-To: <1304975677-21419-2-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=windows-1255
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-10 00:14, Weston Andros Adamson wrote:
>>From Section 8.4.2.1 of the rfc 5661 - We can determine if a RECLAIM_REBOOT
> can be skipped if the "eir_server_scope" from the exchange_id proc differs from
> previous calls.
> 
> Also, in the future server_scope will be useful for determining whether client
> trunking is available
> ---
>  fs/nfs/nfs4_fs.h          |    2 ++
>  fs/nfs/nfs4proc.c         |   12 ++++++++++++
>  fs/nfs/nfs4state.c        |   42 +++++++++++++++++++++++++++++++++++++++++-
>  fs/nfs/nfs4xdr.c          |    8 +++++++-
>  include/linux/nfs_fs_sb.h |    3 +++
>  include/linux/nfs_xdr.h   |    1 +
>  6 files changed, 66 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index c4a6983..bfde1c1 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -48,6 +48,7 @@ enum nfs4_client_state {
>  	NFS4CLNT_SESSION_RESET,
>  	NFS4CLNT_RECALL_SLOT,
>  	NFS4CLNT_LEASE_CONFIRM,
> +	NFS4CLNT_SERVER_SCOPE_MISMATCH,
>  };
>  
>  enum nfs4_session_state {
> @@ -349,6 +350,7 @@ extern void nfs4_schedule_state_manager(struct nfs_client *);
>  extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
>  extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
>  extern void nfs41_handle_recall_slot(struct nfs_client *clp);
> +extern void nfs41_handle_server_scope(struct nfs_client *, struct server_scope **);
>  extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
>  extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
>  extern void nfs4_copy_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t, pid_t);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 69c0f3c..2e62974 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4793,9 +4793,21 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>  				init_utsname()->domainname,
>  				clp->cl_rpcclient->cl_auth->au_flavor);
>  
> +	res.server_scope = kzalloc(sizeof(struct server_scope), GFP_KERNEL);
> +	if (unlikely(!res.server_scope))
> +		return -ENOMEM;
> +
>  	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> +

nit: extraneous newline

>  	if (!status)
>  		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
> +
> +	if (!status)
> +		nfs41_handle_server_scope(clp, &res.server_scope);
> +
> +	/* free if not consumed by nfs41_handle_server_scope() */

Even if defined here, it seems over complicated to hide this
side effect in nfs41_handle_server_scope.

I'd consider open-coding nfs41_handle_server_scope here
and defining its comparison helper statically in this source file.

> +	kfree(res.server_scope);
> +
>  	dprintk("<-- %s status= %d\n", __func__, status);
>  	return status;
>  }
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 036f5ad..26b0780 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1619,6 +1619,39 @@ static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
>  	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
>  }
>  
> +static int
> +nfs41_cmp_server_scope(struct server_scope *a, struct server_scope *b)
> +{
> +	int res;
> +
> +	res = memcmp(a->server_scope, b->server_scope,
> +		     min(a->server_scope_sz, b->server_scope_sz));
> +
> +	if (!res)
> +		res = a->server_scope_sz - b->server_scope_sz;

I'm confused :-/
What's the point of doing the memcmp if the sizes differ?
It's much faster to break out of this function by comparing
the sizes first.

Also, since you're just interested in equality just return
a bool value and call the function nfs41_same_server_scope.

For pedantic layering, if really required, just define a helper
in nfs4state.c to set NFS4CLNT_SERVER_SCOPE_MISMATCH.


> +
> +	return res;
> +}
> +
> +void
> +nfs41_handle_server_scope(struct nfs_client *clp,
> +			  struct server_scope **server_scopep)
> +{
> +	struct server_scope *server_scope = *server_scopep;
> +
> +	if (clp->server_scope) {
> +		/* if same server_scope, do nothing */
> +		if (!nfs41_cmp_server_scope(clp->server_scope, server_scope))
> +			return;
> +
> +		set_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH, &clp->cl_state);
> +		kfree(clp->server_scope);

need to kfree also in nfs_free_client

> +	}
> +
> +	clp->server_scope = server_scope;
> +	*server_scopep = NULL;
> +}
> +
>  static void nfs4_state_manager(struct nfs_client *clp)
>  {
>  	int status = 0;
> @@ -1639,7 +1672,14 @@ static void nfs4_state_manager(struct nfs_client *clp)
>  				goto out_error;
>  			}
>  			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
> -			set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
> +
> +			if (test_and_clear_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH,
> +					       &clp->cl_state))
> +				nfs4_state_start_reclaim_nograce(clp);
> +			else
> +				set_bit(NFS4CLNT_RECLAIM_REBOOT,
> +					&clp->cl_state);
> +
>  			pnfs_destroy_all_layouts(clp);
>  		}
>  
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index c3ccd2c..09a19ca 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -4909,11 +4909,17 @@ static int decode_exchange_id(struct xdr_stream *xdr,
>  	if (unlikely(status))
>  		return status;
>  
> -	/* Throw away server_scope */
> +	/* Save server_scope */
>  	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
>  	if (unlikely(status))
>  		return status;
>  
> +	if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
> +		return -EIO;
> +
> +	memcpy(res->server_scope->server_scope, dummy_str, dummy);
> +	res->server_scope->server_scope_sz = dummy;
> +
>  	/* Throw away Implementation id array */
>  	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
>  	if (unlikely(status))
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 87694ca..baf72a4 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -16,6 +16,7 @@ struct nfs4_sequence_args;
>  struct nfs4_sequence_res;
>  struct nfs_server;
>  struct nfs4_minor_version_ops;
> +struct server_scope;
>  
>  /*
>   * The nfs_client identifies our client state to the server.
> @@ -83,6 +84,8 @@ struct nfs_client {
>  #ifdef CONFIG_NFS_FSCACHE
>  	struct fscache_cookie	*fscache;	/* client index cache cookie */
>  #endif
> +
> +	struct server_scope *server_scope;	/* from exchange_id */

nit: align field same as all other members of this struct.

Benny

>  };
>  
>  /*
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 890dce2..31d6df4 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1039,6 +1039,7 @@ struct server_scope {
>  struct nfs41_exchange_id_res {
>  	struct nfs_client		*client;
>  	u32				flags;
> +	struct server_scope		*server_scope;
>  };
>  
>  struct nfs41_create_session_args {

