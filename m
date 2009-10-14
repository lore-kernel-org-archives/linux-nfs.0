From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/1] nfs41: resolve some race conditions with queued
 SEQUENCE operations when unmounting
Date: Wed, 14 Oct 2009 17:30:09 -0400
Message-ID: <1255555809.6308.34.camel@heimdal.trondhjem.org>
References: <1255561029-2925-1-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:40466 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759085AbZJNVat (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2009 17:30:49 -0400
In-Reply-To: <1255561029-2925-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-10-14 at 15:57 -0700, Alexandros Batsakis wrote:
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
>  fs/nfs/nfs4_fs.h   |    1 +
>  fs/nfs/nfs4proc.c  |    3 +++
>  fs/nfs/nfs4state.c |   11 ++++++++---
>  3 files changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 6ea07a3..554af98 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -45,6 +45,7 @@ enum nfs4_client_state {
>  	NFS4CLNT_RECLAIM_NOGRACE,
>  	NFS4CLNT_DELEGRETURN,
>  	NFS4CLNT_SESSION_SETUP,
> +	NFS4CLNT_SESSION_DESTROY,
>  };
>  
>  /*
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c321002..9eb21d2 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -359,6 +359,8 @@ static void nfs41_sequence_done(struct nfs_client *clp,
>  	struct nfs4_slot_table *tbl;
>  	struct nfs4_slot *slot;
>  
> +	if (!nfs4_has_session(clp))
> +		goto out;
>  	/*
>  	 * sr_status remains 1 if an RPC level error occurred. The server
>  	 * may or may not have processed the sequence operation..
> @@ -4616,6 +4618,7 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
>  
>  void nfs4_destroy_session(struct nfs4_session *session)
>  {
> +	set_bit(NFS4CLNT_SESSION_DESTROY, &session->clp->cl_state);
>  	nfs4_proc_destroy_session(session);
>  	dprintk("%s Destroy backchannel for xprt %p\n",
>  		__func__, session->clp->cl_rpcclient->cl_xprt);
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 1394dfb..a509b26 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1253,11 +1253,16 @@ static void nfs4_state_manager(struct nfs_client *clp)
>  		}
>  		/* Initialize or reset the session */
>  		if (test_and_clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
> -		   && nfs4_has_session(clp)) {
> +		    && nfs4_has_session(clp)) {
>  			if (clp->cl_cons_state == NFS_CS_SESSION_INITING)
>  				status = nfs4_initialize_session(clp);
> -			else
> -				status = nfs4_reset_session(clp);
> +			else {
> +				if (test_bit(NFS4CLNT_SESSION_DESTROY,
> +					     &clp->cl_state))
> +					status = -EIO;
> +				else
> +					status = nfs4_reset_session(clp);
> +			}
>  			if (status) {
>  				if (status == -NFS4ERR_STALE_CLIENTID)
>  					continue;

Wait... Why is all this needed?

AFAICS, nfs_destroy_session() is only called by nfs_free_client() once
the very last reference to the nfs_client has been released. Now since
the state manager keeps a reference to the nfs_client all the time while
it is running (see nfs4_run_state_manager()), we _can't_ have a race
between it and nfs4_destroy_session().

