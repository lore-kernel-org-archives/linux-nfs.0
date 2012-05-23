Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18162 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757259Ab2EWShf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2012 14:37:35 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4NIbXgt007226
	for <linux-nfs@vger.kernel.org>; Wed, 23 May 2012 11:37:34 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4.1: Fix session initialisation races
Date: Wed, 23 May 2012 18:37:31 +0000
Message-ID: <3BB64A14-905A-47D1-B3C2-65F7368C6007@netapp.com>
References: <1337794363-11905-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1337794363-11905-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On May 23, 2012, at 1:32 PM, Trond Myklebust wrote:

> Session initialisation is not complete until the lease manager
> has run. We need to ensure that both nfs4_init_session and
> nfs4_init_ds_session do so, and that they check for any resulting
> errors in clp->cl_cons_state.
> 
> Only after this is done, can nfs4_ds_connect check the contents
> of clp->cl_exchange_flags.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Andy Adamson <andros@netapp.com>
> ---
> fs/nfs/client.c            |   16 ---------
> fs/nfs/internal.h          |    3 +-
> fs/nfs/nfs4filelayoutdev.c |   23 +------------
> fs/nfs/nfs4proc.c          |   77 ++++++++++++++++++++++++++++---------------
> 4 files changed, 52 insertions(+), 67 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 60f7e4e..78970a1 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -593,22 +593,6 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
> }
> 
> /*
> - * With sessions, the client is not marked ready until after a
> - * successful EXCHANGE_ID and CREATE_SESSION.
> - *
> - * Map errors cl_cons_state errors to EPROTONOSUPPORT to indicate
> - * other versions of NFS can be tried.
> - */
> -int nfs4_check_client_ready(struct nfs_client *clp)
> -{
> -	if (!nfs4_has_session(clp))
> -		return 0;
> -	if (clp->cl_cons_state < NFS_CS_READY)
> -		return -EPROTONOSUPPORT;
> -	return 0;
> -}
> -
> -/*
>  * Initialise the timeout values for a connection
>  */
> static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index b777bda..00b66de 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -168,7 +168,6 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
> 					   struct nfs_fattr *,
> 					   rpc_authflavor_t);
> extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
> -extern int nfs4_check_client_ready(struct nfs_client *clp);
> extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
> 					     const struct sockaddr *ds_addr,
> 					     int ds_addrlen, int ds_proto);
> @@ -237,7 +236,7 @@ extern const u32 nfs41_maxwrite_overhead;
> extern struct rpc_procinfo nfs4_procedures[];
> #endif
> 
> -extern int nfs4_init_ds_session(struct nfs_client *clp);
> +extern int nfs4_init_ds_session(struct nfs_client *, unsigned long);
> 
> /* proc.c */
> void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index c9cff9a..0764c98 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -176,28 +176,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
> 		goto out;
> 	}
> 
> -	if ((clp->cl_exchange_flags & EXCHGID4_FLAG_MASK_PNFS) != 0) {
> -		if (!is_ds_client(clp)) {
> -			status = -ENODEV;
> -			goto out_put;
> -		}
> -		ds->ds_clp = clp;
> -		dprintk("%s [existing] server=%s\n", __func__,
> -			ds->ds_remotestr);
> -		goto out;
> -	}
> -
> -	/*
> -	 * Do not set NFS_CS_CHECK_LEASE_TIME instead set the DS lease to
> -	 * be equal to the MDS lease. Renewal is scheduled in create_session.
> -	 */
> -	spin_lock(&mds_srv->nfs_client->cl_lock);
> -	clp->cl_lease_time = mds_srv->nfs_client->cl_lease_time;
> -	spin_unlock(&mds_srv->nfs_client->cl_lock);
> -	clp->cl_last_renewal = jiffies;
> -
> -	/* New nfs_client */
> -	status = nfs4_init_ds_session(clp);
> +	status = nfs4_init_ds_session(clp, mds_srv->nfs_client->cl_lease_time);
> 	if (status)
> 		goto out_put;
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 99650aa..272c4ad 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5605,53 +5605,76 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
> 	return status;
> }
> 
> +/*
> + * With sessions, the client is not marked ready until after a
> + * successful EXCHANGE_ID and CREATE_SESSION.
> + *
> + * Map errors cl_cons_state errors to EPROTONOSUPPORT to indicate
> + * other versions of NFS can be tried.
> + */
> +static int nfs41_check_session_ready(struct nfs_client *clp)
> +{
> +	int ret;
> +	
> +	ret = nfs4_client_recover_expired_lease(clp);
> +	if (ret)
> +		return ret;
> +	if (clp->cl_cons_state < NFS_CS_READY)
> +		return -EPROTONOSUPPORT;
> +	return 0;
> +}
> +
> int nfs4_init_session(struct nfs_server *server)
> {
> 	struct nfs_client *clp = server->nfs_client;
> 	struct nfs4_session *session;
> 	unsigned int rsize, wsize;
> -	int ret;
> 
> 	if (!nfs4_has_session(clp))
> 		return 0;
> 
> 	session = clp->cl_session;
> -	if (!test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state))
> -		return 0;
> +	spin_lock(&clp->cl_lock);
> +	if (test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state)) {
> 
> -	rsize = server->rsize;
> -	if (rsize == 0)
> -		rsize = NFS_MAX_FILE_IO_SIZE;
> -	wsize = server->wsize;
> -	if (wsize == 0)
> -		wsize = NFS_MAX_FILE_IO_SIZE;
> +		rsize = server->rsize;
> +		if (rsize == 0)
> +			rsize = NFS_MAX_FILE_IO_SIZE;
> +		wsize = server->wsize;
> +		if (wsize == 0)
> +			wsize = NFS_MAX_FILE_IO_SIZE;
> 
> -	session->fc_attrs.max_rqst_sz = wsize + nfs41_maxwrite_overhead;
> -	session->fc_attrs.max_resp_sz = rsize + nfs41_maxread_overhead;
> +		session->fc_attrs.max_rqst_sz = wsize + nfs41_maxwrite_overhead;
> +		session->fc_attrs.max_resp_sz = rsize + nfs41_maxread_overhead;
> +	}
> +	spin_unlock(&clp->cl_lock);
> 
> -	ret = nfs4_recover_expired_lease(server);
> -	if (!ret)
> -		ret = nfs4_check_client_ready(clp);
> -	return ret;
> +	return nfs41_check_session_ready(clp);
> }
> 
> -int nfs4_init_ds_session(struct nfs_client *clp)
> +int nfs4_init_ds_session(struct nfs_client *clp, unsigned long lease_time)
> {
> 	struct nfs4_session *session = clp->cl_session;
> 	int ret;
> 
> -	if (!test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state))
> -		return 0;
> -
> -	ret = nfs4_client_recover_expired_lease(clp);
> -	if (!ret)
> -		/* Test for the DS role */
> -		if (!is_ds_client(clp))
> -			ret = -ENODEV;
> -	if (!ret)
> -		ret = nfs4_check_client_ready(clp);
> -	return ret;
> +	spin_lock(&clp->cl_lock);
> +	if (test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state)) {
> +		/*
> +		 * Do not set NFS_CS_CHECK_LEASE_TIME instead set the
> +		 * DS lease to be equal to the MDS lease.
> +		 */
> +		clp->cl_lease_time = lease_time;
> +		clp->cl_last_renewal = jiffies;
> +	}
> +	spin_unlock(&clp->cl_lock);
> 
> +	ret = nfs41_check_session_ready(clp);

If I read the code correctly, on an existing client,  this call needlessly waits for the state manager to finish whatever it is doing. As the state manager could be operating on a different file system than the DS belongs to,  and recovering a bunch of state,  it might be worth while to avoid.  That was the intention of checking the cl_exchange_flags in nfs4_ds_connect.
In fact, on an existing client, nfs4_init_ds_session does not need to be called.

-->Andy

> +	if (ret)
> +		return ret;
> +	/* Test for the DS role */
> +	if (!is_ds_client(clp))
> +		return -ENODEV;
> +	return 0;
> }
> EXPORT_SYMBOL_GPL(nfs4_init_ds_session);
> 
> -- 
> 1.7.7.6
> 

