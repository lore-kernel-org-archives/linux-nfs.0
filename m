Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20586 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105Ab3FGTwn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jun 2013 15:52:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFS: Use root's credential for lease management
 when keytab is missing
Date: Fri, 7 Jun 2013 19:52:41 +0000
Message-ID: <1370634757.3033.2.camel@leira.trondhjem.org>
References: <20130607194140.1296.54746.stgit@seurat.1015granger.net>
	 <20130607194510.1296.69923.stgit@seurat.1015granger.net>
In-Reply-To: <20130607194510.1296.69923.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-06-07 at 15:45 -0400, Chuck Lever wrote:
> Commit 05f4c350 "NFS: Discover NFSv4 server trunking when mounting"
> Fri Sep 14 17:24:32 2012 introduced Uniform Client String support,
> which forces our NFS client to establish a client ID immediately
> during a mount operation rather than waiting until a user wants to
> open a file.
> 
> Normally machine credentials (eg. from a keytab) are used to perform
> a mount operation that is protected by Kerberos.  Before 05fc350,
> SETCLIENTID used a machine credential, or fell back to a regular
> user's credential if no keytab is available.
> 
> On clients that don't have a keytab, performing SETCLIENTID early
> means there's no user credential to fall back on, since no regular
> user has kinit'd yet.  05f4c350 seems to have broken the ability
> to mount with sec=krb5 on clients that don't have a keytab in
> kernels 3.7 - 3.9.
> 
> To address this regression, commit 4edaa308 (NFS: Use "krb5i" to
> establish NFSv4 state whenever possible), Sat Mar 16 15:56:20 2013,
> was merged in 3.10.  This commit forces the NFS client to fall back
> to AUTH_SYS for lease management operations if no keytab is
> available.
> 
> Neil Brown noticed that, since root is required to kinit to do a
> sec=krb5 mount when a client doesn't have a keytab, we can try to
> use root's Kerberos credential before AUTH_SYS.
> 
> Now, when determining a principal and flavor to use for lease
> management, the NFS client tries in this order:
> 
>   1.  Flavor: AUTH_GSS, krb5i
>       Principal: service principal (via keytab)
> 
>   2.  Flavor: AUTH_GSS, krb5i
>       Principal: user principal established for UID 0 (via kinit)
> 
>   3.  Flavor: AUTH_SYS
>       Principal: UID 0 / GID 0
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfs/nfs4proc.c  |   21 ++++++++++++++-------
>  fs/nfs/nfs4state.c |   16 ++++++++--------
>  2 files changed, 22 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 5ba38b3..4d76fae 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4356,7 +4356,8 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
>  	dprintk("NFS call  setclientid auth=%s, '%.*s'\n",
>  		clp->cl_rpcclient->cl_auth->au_ops->au_name,
>  		setclientid.sc_name_len, setclientid.sc_name);
> -	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> +	status = rpc_call_sync(clp->cl_rpcclient, &msg,
> +					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);

We are certainly _not_ resurrecting the RPC_TASK_ROOTCREDS abomination.

For one thing is overrides the machine creds that are what we really
want to use when available.

NACK...

>  	dprintk("NFS reply setclientid: %d\n", status);
>  	return status;
>  }
> @@ -4383,7 +4384,8 @@ int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
>  	dprintk("NFS call  setclientid_confirm auth=%s, (client ID %llx)\n",
>  		clp->cl_rpcclient->cl_auth->au_ops->au_name,
>  		clp->cl_clientid);
> -	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> +	status = rpc_call_sync(clp->cl_rpcclient, &msg,
> +					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
>  	dprintk("NFS reply setclientid_confirm: %d\n", status);
>  	return status;
>  }
> @@ -5461,7 +5463,8 @@ int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred
>  		goto out;
>  	}
>  
> -	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> +	status = rpc_call_sync(clp->cl_rpcclient, &msg,
> +					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
>  	if (status == 0) {
>  		if (memcmp(res.session->sess_id.data,
>  		    clp->cl_session->sess_id.data, NFS4_MAX_SESSIONID_LEN)) {
> @@ -5545,7 +5548,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
>  		goto out_server_scope;
>  	}
>  
> -	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> +	status = rpc_call_sync(clp->cl_rpcclient, &msg,
> +					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
>  	if (status == 0)
>  		status = nfs4_check_cl_exchange_flags(res.flags);
>  
> @@ -5605,7 +5609,8 @@ static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
>  	};
>  	int status;
>  
> -	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> +	status = rpc_call_sync(clp->cl_rpcclient, &msg,
> +					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
>  	if (status)
>  		dprintk("NFS: Got error %d from the server %s on "
>  			"DESTROY_CLIENTID.", status, clp->cl_hostname);
> @@ -5871,7 +5876,8 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
>  	nfs4_init_channel_attrs(&args);
>  	args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
>  
> -	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> +	status = rpc_call_sync(session->clp->cl_rpcclient, &msg,
> +					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
>  
>  	if (!status) {
>  		/* Verify the session's negotiated channel_attrs values */
> @@ -5934,7 +5940,8 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
>  	if (session->clp->cl_cons_state != NFS_CS_READY)
>  		return status;
>  
> -	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
> +	status = rpc_call_sync(session->clp->cl_rpcclient, &msg,
> +					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
>  
>  	if (status)
>  		dprintk("NFS: Got error %d from the server on DESTROY_SESSION. "
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 4949ce5..d8068ab 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1811,10 +1811,9 @@ static int nfs4_establish_lease(struct nfs_client *clp)
>  	int status;
>  
>  	cred = ops->get_clid_cred(clp);
> -	if (cred == NULL)
> -		return -ENOENT;
>  	status = ops->establish_clid(clp, cred);
> -	put_rpccred(cred);
> +	if (cred)
> +		put_rpccred(cred);
>  	if (status != 0)
>  		return status;
>  	pnfs_destroy_all_layouts(clp);
> @@ -1885,11 +1884,9 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
>  again:
>  	status  = -ENOENT;
>  	cred = ops->get_clid_cred(clp);
> -	if (cred == NULL)
> -		goto out_unlock;
> -
>  	status = ops->detect_trunking(clp, result, cred);
> -	put_rpccred(cred);
> +	if (cred)
> +		put_rpccred(cred);
>  	switch (status) {
>  	case 0:
>  		break;
> @@ -1902,6 +1899,10 @@ again:
>  			__func__, status);
>  		goto again;
>  	case -EACCES:
> +		if (clp->cl_machine_cred != NULL) {
> +			nfs4_clear_machine_cred(clp);
> +			goto again;
> +		}
>  		if (i++)
>  			break;
>  	case -NFS4ERR_CLID_INUSE:
> @@ -1935,7 +1936,6 @@ again:
>  		status = -EIO;
>  	}
>  
> -out_unlock:
>  	mutex_unlock(&nfs_clid_init_mutex);
>  	dprintk("NFS: %s: status = %d\n", __func__, status);
>  	return status;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
