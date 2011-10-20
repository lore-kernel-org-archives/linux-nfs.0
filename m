Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33609 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756296Ab1JTJex (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 05:34:53 -0400
Date: Thu, 20 Oct 2011 05:34:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: implement DESTROY_CLIENTID operation
Message-ID: <20111020093452.GD5444@fieldses.org>
References: <4E9FE112.3080907@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E9FE112.3080907@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 04:51:30PM +0800, Mi Jinlong wrote:
> According to rfc5661 18.50, implement DESTROY_CLIENTID operation.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4proc.c  |    2 +-
>  fs/nfsd/nfs4state.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4xdr.c   |   12 +++++++++++-
>  fs/nfsd/xdr4.h      |    5 +++++
>  4 files changed, 68 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index e807776..8412a22 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1433,7 +1433,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_name = "OP_SEQUENCE",
>  	},
>  	[OP_DESTROY_CLIENTID] = {
> -		.op_func = NULL,
> +		.op_func = (nfsd4op_func)nfsd4_destroy_clientid,
>  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
>  		.op_name = "OP_DESTROY_CLIENTID",
>  	},
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3787ec1..d46cbbe 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1858,6 +1858,57 @@ out:
>  	return status;
>  }
>  
> +static inline bool has_resources(struct nfs4_client *clp)
> +{
> +	return !list_empty(&clp->cl_openowners)
> +		|| !list_empty(&clp->cl_delegations)
> +		|| !list_empty(&clp->cl_sessions)
> +		|| !list_empty(&clp->cl_callbacks);

I don't think the existance of callbacks should prevent destroying the
client.

> +}
> +
> +__be32
> +nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_destroy_clientid *dc)
> +{
> +	struct nfs4_client *conf, *unconf, *clp;
> +	int status = 0;
> +
> +	nfs4_lock_state();
> +	unconf = find_unconfirmed_client(&dc->clientid);
> +	conf = find_confirmed_client(&dc->clientid);
> +
> +	if (conf) {
> +		clp = conf;
> +
> +		if (!is_client_expired(conf) && has_resources(conf)) {
> +			status = nfserr_clientid_busy;
> +			goto out;
> +		}
> +
> +		/*
> +		 * DESTROY_CLIENTID MAY be preceded with a SEQUENCE operation as
> +		 * long as the client ID derived from the session ID of SEQUENCE
> +		 * is not the same as the client ID to be destroyed. 
> +		 * If the client IDs are the same, then the server MUST return
> +		 * NFS4ERR_CLIENTID_BUSY.
> +		 */

Let's just replace that comment by:

		/* rfc 551 18.50.3: */

(I agree that it's useful to have a reference to explain where this
requirement came from, but I don't think it's necessary to write out the
whole thing, as the behavior is obvious enough from the following code.)

Looks fine to me otherwise, thanks!

--b.

> +		if (cstate->session && conf == cstate->session->se_client) {
> +			status = nfserr_clientid_busy;
> +			goto out;
> +		}
> +	} else if (unconf)
> +		clp = unconf;
> +	else {
> +		status = nfserr_stale_clientid;
> +		goto out;
> +	}
> +
> +	expire_client(clp);
> +out:
> +	nfs4_unlock_state();
> +	dprintk("%s return %d\n", __func__, ntohl(status));
> +	return status;
> +}
> +
>  __be32
>  nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_reclaim_complete *rc)
>  {
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index c8bf405..5d9fff5 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1326,6 +1326,16 @@ xdr_error:
>  	goto out;
>  }
>  
> +static __be32 nfsd4_decode_destroy_clientid(struct nfsd4_compoundargs *argp, struct nfsd4_destroy_clientid *dc)
> +{
> +	DECODE_HEAD;
> +
> +	READ_BUF(8);
> +	COPYMEM(&dc->clientid, 8);
> +
> +	DECODE_TAIL;
> +}
> +
>  static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, struct nfsd4_reclaim_complete *rc)
>  {
>  	DECODE_HEAD;
> @@ -1447,7 +1457,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
>  	[OP_SET_SSV]		= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_test_stateid,
>  	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
> -	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_destroy_clientid,
>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
>  };
>  
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index d2a8d044..d67d680 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -405,6 +405,10 @@ struct nfsd4_destroy_session {
>  	struct nfs4_sessionid	sessionid;
>  };
>  
> +struct nfsd4_destroy_clientid {
> +	clientid_t clientid;
> +};
> +
>  struct nfsd4_reclaim_complete {
>  	u32 rca_one_fs;
>  };
> @@ -558,6 +562,7 @@ extern __be32 nfsd4_sequence(struct svc_rqst *,
>  extern __be32 nfsd4_destroy_session(struct svc_rqst *,
>  		struct nfsd4_compound_state *,
>  		struct nfsd4_destroy_session *);
> +extern __be32 nfsd4_destroy_clientid(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_destroy_clientid *);
>  __be32 nfsd4_reclaim_complete(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_reclaim_complete *);
>  extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
>  		struct nfsd4_open *open);
> -- 
> 1.7.6
> 
> 
