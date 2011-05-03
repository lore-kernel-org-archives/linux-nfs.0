From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd41: Make sure nfs server can distinguish client's
 retry RECLAIM_COMPLETE.
Date: Mon, 2 May 2011 22:46:29 -0400
Message-ID: <20110503024629.GC11472@fieldses.org>
References: <4DB76DF6.2040902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49547 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753909Ab1ECCqb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2011 22:46:31 -0400
In-Reply-To: <4DB76DF6.2040902@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 27, 2011 at 09:14:30AM +0800, Mi Jinlong wrote:
> Make sure nfs server can distinguish client's retry RECLAIM_COMPLETE.

Applying for 2.6.40, thanks.--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c |   19 ++++++++++++++-----
>  1 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 43cda94..8d521d8 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1804,6 +1804,8 @@ out:
>  __be32
>  nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_reclaim_complete *rc)
>  {
> +	int status = 0;
> +
>  	if (rc->rca_one_fs) {
>  		if (!cstate->current_fh.fh_dentry)
>  			return nfserr_nofilehandle;
> @@ -1813,9 +1815,14 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
>  		 */
>  		 return nfs_ok;
>  	}
> +
>  	nfs4_lock_state();
> -	if (is_client_expired(cstate->session->se_client)) {
> -		nfs4_unlock_state();
> +	status = nfserr_complete_already;
> +	if (cstate->session->se_client->cl_firststate)
> +		goto out;
> +
> +	status = nfserr_stale_clientid;
> +	if (is_client_expired(cstate->session->se_client))
>  		/*
>  		 * The following error isn't really legal.
>  		 * But we only get here if the client just explicitly
> @@ -1823,11 +1830,13 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
>  		 * error it gets back on an operation for the dead
>  		 * client.
>  		 */
> -		return nfserr_stale_clientid;
> -	}
> +		goto out;
> +
> +	status = nfs_ok;
>  	nfsd4_create_clid_dir(cstate->session->se_client);
> +out:
>  	nfs4_unlock_state();
> -	return nfs_ok;
> +	return status;
>  }
>  
>  __be32
> -- 
> 1.7.4.1
> 
> 
> 
