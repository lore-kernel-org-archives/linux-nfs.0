Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx62.netapp.com ([216.240.31.182]:7038 "EHLO mx62.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751304AbcIGU5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Sep 2016 16:57:36 -0400
Subject: Re: [PATCH Version 9 RESEND 04/12] NFS detect session trunking
To: <andros@netapp.com>, <trondmy@primarydata.com>
References: <1472744693-124241-1-git-send-email-andros@netapp.com>
 <1472744693-124241-5-git-send-email-andros@netapp.com>
CC: <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <e63daf92-6097-9eec-238b-e382eee894e0@Netapp.com>
Date: Wed, 7 Sep 2016 16:47:48 -0400
MIME-Version: 1.0
In-Reply-To: <1472744693-124241-5-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

On 09/01/2016 11:44 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4_fs.h    |  2 ++
>  fs/nfs/nfs4client.c | 93 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 95 insertions(+)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 4be567a..eb315e1 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -277,6 +277,8 @@ extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
>  		struct nfs_fsinfo *fsinfo);
>  extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
>  				  bool sync);
> +extern int nfs4_detect_session_trunking(struct nfs_client *clp,
> +		struct nfs41_exchange_id_res *res, struct rpc_xprt *xprt);
>  
>  static inline bool
>  is_ds_only_client(struct nfs_client *clp)
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index f356d50..4e15ae1 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -595,6 +595,99 @@ out_major_mismatch:
>  	return false;
>  }
>  
> +/*
> + * Returns true if server minor ids match
> + */
> +static bool
> +nfs4_check_serverowner_minor_id(struct nfs41_server_owner *o1,
> +				struct nfs41_server_owner *o2)
> +{
> +	/* Check eir_server_owner so_minor_id */
> +	if (o1->minor_id != o2->minor_id)
> +		goto out_minor_mismatch;
> +
> +	dprintk("NFS: --> %s server owner minor IDs match\n", __func__);
> +	return true;
> +
> +out_minor_mismatch:
> +	dprintk("NFS: --> %s server owner minor IDs do not match\n", __func__);
> +	return false;
> +}
> +
> +/*
> + * Returns true if the server scopes match
> + */
> +static bool
> +nfs4_check_server_scope(struct nfs41_server_scope *s1,
> +			struct nfs41_server_scope *s2)
> +{
> +	if (s1->server_scope_sz != s2->server_scope_sz)
> +		goto out_scope_mismatch;
> +	if (memcmp(s1->server_scope, s2->server_scope,
> +		   s1->server_scope_sz) != 0)
> +		goto out_scope_mismatch;
> +
> +	dprintk("NFS: --> %s server scopes match\n", __func__);
> +	return true;
> +
> +out_scope_mismatch:
> +	dprintk("NFS: --> %s server scopes do not match\n",
> +		__func__);
> +	return false;
> +}
> +
> +/**
> + * nfs4_detect_session_trunking - Checks for session trunking called
> + * after a successful EXCHANGE_ID testing a multi-addr connection to be
> + * potentially added as a session trunk
> + *
> + * @clp:    original mount nfs_client
> + * @res:    result structure from an exchange_id using the original mount
> + *          nfs_client with a new multi_addr transport
> + *
> + * Returns zero on success, otherwise -EINVAL
> + *
> + * Note: since the exchange_id for the new multi_addr transport uses the
> + * same nfs_client from the original mount, the cl_owner_id is reused,
> + * so eir_clientowner is the same.
> + */
> +int nfs4_detect_session_trunking(struct nfs_client *clp,
> +				 struct nfs41_exchange_id_res *res,
> +				 struct rpc_xprt *xprt)
> +{
> +	int status = -EINVAL;
> +	/* Check eir_clientid */
> +	if (!nfs4_match_clientids(clp->cl_clientid, res->clientid))
> +		goto out;
> +
> +	/* Check eir_server_owner so_major_id */
> +	if (!nfs4_check_serverowner_major_id(clp->cl_serverowner,
> +					     res->server_owner))
> +		goto out;
> +
> +	/* Check eir_server_owner so_minor_id */
> +	if (!nfs4_check_serverowner_minor_id(clp->cl_serverowner,
> +					     res->server_owner))
> +		goto out;
> +
> +	/* Check eir_server_scope */
> +	if (!nfs4_check_server_scope(clp->cl_serverscope, res->server_scope))
> +		goto out;
> +
> +	status = 0;
> +out:
> +	if (status)
> +		pr_info("NFS:  %s: Session trunking failed for %s status %d\n",
> +			clp->cl_hostname,
> +			xprt->address_strings[RPC_DISPLAY_ADDR], status);
> +	else
> +		pr_info("NFS:  %s: Session trunking succeeded for %s\n",
> +			clp->cl_hostname,
> +			xprt->address_strings[RPC_DISPLAY_ADDR]);

I'm not a fan of the if/else status check here.  I think it might be cleaner if you match the style of nfs4_check_server_scope() and create an out_err label that prints the failed message and returns -EINVAL directly.  Then you can get rid of the "status" variable all together and avoid the if/else check at the end.

Thanks,
Anna

> +
> +	return status;
> +}
> +
>  /**
>   * nfs41_walk_client_list - Find nfs_client that matches a client/server owner
>   *
> 

