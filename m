From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 05/12] nfsd41: Backchannel: callback infrastructure
Date: Mon, 14 Sep 2009 12:35:35 -0400
Message-ID: <20090914163535.GE30806@fieldses.org>
References: <4AA8C597.8080809@panasas.com> <1252574759-30176-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40231 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756204AbZINQfe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 12:35:34 -0400
In-Reply-To: <1252574759-30176-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 10, 2009 at 12:25:59PM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Keep the xprt used for create_session in cl_cb_xprt.
> Mark cl_callback.cb_minorversion = 1 and remember
> the client provided cl_callback.cb_prog rpc program number.
> Use it to probe the callback path.
> 
> Use the client's network address to initialize as the
> callback's address as expected by the xprt creation
> routines.
> 
> Define xdr sizes and code nfs4_cb_compound header to be able
> to send a null callback rpc.
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [get callback minorversion from fore channel's]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: change bc_sock to bc_xprt]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [pulled definition for cl_cb_xprt]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: set up backchannel's cb_addr]
> [moved rpc_create_args init to "nfsd: modify nfsd4.1 backchannel to use new xprt class"]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c     |   21 +++++++++++++++++++--
>  fs/nfsd/nfs4state.c        |   14 ++++++++++++++
>  include/linux/nfsd/state.h |    3 +++
>  3 files changed, 36 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 63bb384..3e3e15b 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -43,6 +43,7 @@
>  #include <linux/sunrpc/xdr.h>
>  #include <linux/sunrpc/svc.h>
>  #include <linux/sunrpc/clnt.h>
> +#include <linux/sunrpc/svcsock.h>
>  #include <linux/nfsd/nfsd.h>
>  #include <linux/nfsd/state.h>
>  #include <linux/sunrpc/sched.h>
> @@ -52,16 +53,19 @@
>  
>  #define NFSPROC4_CB_NULL 0
>  #define NFSPROC4_CB_COMPOUND 1
> +#define NFS4_STATEID_SIZE 16
>  
>  /* Index of predefined Linux callback client operations */
>  
>  enum {
>  	NFSPROC4_CLNT_CB_NULL = 0,
>  	NFSPROC4_CLNT_CB_RECALL,
> +	NFSPROC4_CLNT_CB_SEQUENCE,
>  };
>  
>  enum nfs_cb_opnum4 {
>  	OP_CB_RECALL            = 4,
> +	OP_CB_SEQUENCE          = 11,
>  };
>  
>  #define NFS4_MAXTAGLEN		20
> @@ -70,15 +74,22 @@ enum nfs_cb_opnum4 {
>  #define NFS4_dec_cb_null_sz		0
>  #define cb_compound_enc_hdr_sz		4
>  #define cb_compound_dec_hdr_sz		(3 + (NFS4_MAXTAGLEN >> 2))
> +#define sessionid_sz			(NFS4_MAX_SESSIONID_LEN >> 2)
> +#define cb_sequence_enc_sz		(sessionid_sz + 4 +             \
> +					1 /* no referring calls list yet */)
> +#define cb_sequence_dec_sz		(op_dec_sz + sessionid_sz + 4)
> +
>  #define op_enc_sz			1
>  #define op_dec_sz			2
>  #define enc_nfs4_fh_sz			(1 + (NFS4_FHSIZE >> 2))
>  #define enc_stateid_sz			(NFS4_STATEID_SIZE >> 2)
>  #define NFS4_enc_cb_recall_sz		(cb_compound_enc_hdr_sz +       \
> +					cb_sequence_enc_sz +            \
>  					1 + enc_stateid_sz +            \
>  					enc_nfs4_fh_sz)
>  
>  #define NFS4_dec_cb_recall_sz		(cb_compound_dec_hdr_sz  +      \
> +					cb_sequence_dec_sz +            \
>  					op_dec_sz)
>  
>  /*
> @@ -137,11 +148,13 @@ xdr_error:                                      \
>  } while (0)
>  
>  struct nfs4_cb_compound_hdr {
> -	int		status;
> -	u32		ident;
> +	/* args */
> +	u32		ident;	/* minorversion 0 only */
>  	u32		nops;
>  	__be32		*nops_p;
>  	u32		minorversion;
> +	/* res */
> +	int		status;
>  	u32		taglen;
>  	char		*tag;
>  };
> @@ -399,6 +412,10 @@ int setup_callback_client(struct nfs4_client *clp)
>  	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
>  		return -EINVAL;
>  
> +	dprintk("%s: program %s 0x%x nrvers %u version %u minorversion %u\n",
> +		__func__, args.program->name, args.prognumber,
> +		args.program->nrvers, args.version, cb->cb_minorversion);
> +
>  	/* Create RPC client */
>  	client = rpc_create(&args);
>  	if (IS_ERR(client)) {
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 46e9ac5..e4c3223 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -706,6 +706,8 @@ static inline void
>  free_client(struct nfs4_client *clp)
>  {
>  	shutdown_callback_client(clp);
> +	if (clp->cl_cb_xprt)
> +		svc_xprt_put(clp->cl_cb_xprt);
>  	if (clp->cl_cred.cr_group_info)
>  		put_group_info(clp->cl_cred.cr_group_info);
>  	kfree(clp->cl_principal);
> @@ -1321,6 +1323,18 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		cr_ses->flags &= ~SESSION4_PERSIST;
>  		cr_ses->flags &= ~SESSION4_RDMA;
>  
> +		if (cr_ses->flags & SESSION4_BACK_CHAN) {
> +			unconf->cl_cb_xprt = rqstp->rq_xprt;
> +			svc_xprt_get(unconf->cl_cb_xprt);
> +			rpc_copy_addr(
> +				(struct sockaddr *)&unconf->cl_cb_conn.cb_addr,
> +				sa);
> +			unconf->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
> +			unconf->cl_cb_conn.cb_minorversion =
> +				cstate->minorversion;
> +			unconf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
> +			nfsd4_probe_callback(unconf);

This results in a NULL deference in rpcauth_lookup_credcache()--probably
some callback parameters that aren't set up right yet.

--b.

> +		}
>  		conf = unconf;
>  	} else {
>  		status = nfserr_stale_clientid;
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 70ef5f4..243277b 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -212,6 +212,9 @@ struct nfs4_client {
>  	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
>  	u32			cl_exchange_flags;
>  	struct nfs4_sessionid	cl_sessionid;
> +
> +	/* for nfs41 callbacks */
> +	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
>  };
>  
>  /* struct nfs4_client_reset
> -- 
> 1.6.4
> 
