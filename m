From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 22/51] nfsd41: proc stubs
Date: Mon, 17 Nov 2008 16:07:17 +0200
Message-ID: <49217A95.7050309@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350091-10923-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:9406 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751689AbYKQOHV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:07:21 -0500
In-Reply-To: <1226350091-10923-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:48 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4proc.c        |   30 +++++++++++++++++++++++++++++-
>  fs/nfsd/nfs4state.c       |   34 ++++++++++++++++++++++++++++++++++
>  include/linux/nfsd/xdr4.h |   14 ++++++++++++++
>  3 files changed, 77 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 26aae5d..6f6d221 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1021,7 +1021,13 @@ out:
>  	return status;
>  }
>  
> -static struct nfsd4_operation nfsd4_ops[OP_RELEASE_LOCKOWNER+1] = {
> +#if defined(CONFIG_NFSD_V4_1)
> +#define NFSD4_LAST_OP OP_RECLAIM_COMPLETE
> +#else /* CONFIG_NFSD_V4_1 */
> +#define NFSD4_LAST_OP OP_RELEASE_LOCKOWNER
> +#endif /* CONFIG_NFSD_V4_1 */
> +
> +static struct nfsd4_operation nfsd4_ops[NFSD4_LAST_OP+1] = {

review 11-13: get rid of NFSD4_LAST_OP

>  	[OP_ACCESS] = {
>  		.op_func = (nfsd4op_func)nfsd4_access,
>  		.op_name = "OP_ACCESS",
> @@ -1171,6 +1177,28 @@ static struct nfsd4_operation nfsd4_ops[OP_RELEASE_LOCKOWNER+1] = {
>  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
>  		.op_name = "OP_RELEASE_LOCKOWNER",
>  	},
> +#if defined(CONFIG_NFSD_V4_1)
> +	[OP_EXCHANGE_ID] = {
> +		.op_func = (nfsd4op_func)nfsd4_exchange_id,
> +		.op_flags = ALLOWED_WITHOUT_FH,
> +		.op_name = "OP_EXCHANGE_ID",
> +	},
> +	[OP_CREATE_SESSION] = {
> +		.op_func = (nfsd4op_func)nfsd4_create_session,
> +		.op_flags = ALLOWED_WITHOUT_FH,
> +		.op_name = "OP_CREATE_SESSION",
> +	},
> +	[OP_DESTROY_SESSION] = {
> +		.op_func = (nfsd4op_func)nfsd4_destroy_session,
> +		.op_flags = ALLOWED_WITHOUT_FH,
> +		.op_name = "OP_DESTROY_SESSION",
> +	},
> +	[OP_SEQUENCE] = {
> +		.op_func = (nfsd4op_func)nfsd4_sequence,
> +		.op_flags = ALLOWED_WITHOUT_FH,
> +		.op_name = "OP_SEQUENCE",
> +	},
> +#endif /* CONFIG_NFSD_V4_1 */
>  };
>  
>  static const char *nfsd4_op_name(unsigned opnum)
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index ca2e3e0..5c96c39 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -780,6 +780,40 @@ out_err:
>  	return;
>  }
>  
> +#if defined(CONFIG_NFSD_V4_1)
> +__be32
> +nfsd4_exchange_id(struct svc_rqst *rqstp,
> +		  struct nfsd4_compound_state *cstate,
> +		  struct nfsd4_exchange_id *clid)
> +{
> +	return -1;	/* stub */
> +}
> +
> +__be32
> +nfsd4_create_session(struct svc_rqst *rqstp,
> +		     struct nfsd4_compound_state *cstate,
> +		     struct nfsd4_create_session *cr_ses)
> +{
> +	return -1;	/* stub */
> +}
> +
> +__be32
> +nfsd4_destroy_session(struct svc_rqst *r,
> +		      struct nfsd4_compound_state *cstate,
> +		      struct nfsd4_destroy_session *sessionid)
> +{
> +	return -1;	/* stub */
> +}
> +
> +__be32
> +nfsd4_sequence(struct svc_rqst *r,
> +	       struct nfsd4_compound_state *cstate,
> +	       struct nfsd4_sequence *seq)
> +{
> +	return -1;	/* stub */
> +}
> +#endif /* CONFIG_NFSD_V4_1 */
> +
>  __be32
>  nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		  struct nfsd4_setclientid *setclid)
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index b864007..d7dbdab 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -480,6 +480,20 @@ extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
>  extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  		struct nfsd4_compound_state *,
>  		struct nfsd4_setclientid_confirm *setclientid_confirm);
> +#if defined(CONFIG_NFSD_V4_1)
> +extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
> +		struct nfsd4_compound_state *,
> +		struct nfsd4_exchange_id *);
> +extern __be32 nfsd4_create_session(struct svc_rqst *,
> +		struct nfsd4_compound_state *,
> +		struct nfsd4_create_session *);
> +extern __be32 nfsd4_sequence(struct svc_rqst *,
> +		struct nfsd4_compound_state *,
> +		struct nfsd4_sequence *);
> +extern __be32 nfsd4_destroy_session(struct svc_rqst *,
> +		struct nfsd4_compound_state *,
> +		struct nfsd4_destroy_session *);
> +#endif /* CONFIG_NFSD_V4_1 */
>  extern __be32 nfsd4_process_open1(struct nfsd4_open *open);
>  extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
>  		struct svc_fh *current_fh, struct nfsd4_open *open);
