From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 01/12] NFSD: Update XDR encoders in NFSv4 callback client
Date: Wed, 17 Nov 2010 20:07:08 +0200
Message-ID: <4CE419CC.1090509@panasas.com>
References: <20101117175317.29429.90956.stgit@matisse.1015granger.net> <20101117175953.29429.43098.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16992 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934809Ab0KQSHL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 13:07:11 -0500
In-Reply-To: <20101117175953.29429.43098.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nit: why call this patch (and the next one) "NFSD:" and not "NFS:"?

Benny

On 2010-11-17 19:59, Chuck Lever wrote:
> Clean up.
> 
> Remove old-style NFSv4 XDR macros in favor of the style now used in
> fs/nfs/nfs4xdr.c.  These were forgotten during the recent nfs4xdr.c
> rewrite.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Tested-by: J. Bruce Fields <bfields@redhat.com>
> ---
> 
>  fs/nfsd/nfs4callback.c |  255 ++++++++++++++++++++++++++++++++++--------------
>  1 files changed, 178 insertions(+), 77 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 143da2e..d8148cc 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -50,11 +50,6 @@ enum {
>  	NFSPROC4_CLNT_CB_SEQUENCE,
>  };
>  
> -enum nfs_cb_opnum4 {
> -	OP_CB_RECALL            = 4,
> -	OP_CB_SEQUENCE          = 11,
> -};
> -
>  #define NFS4_MAXTAGLEN		20
>  
>  #define NFS4_enc_cb_null_sz		0
> @@ -80,30 +75,6 @@ enum nfs_cb_opnum4 {
>  					op_dec_sz)
>  
>  /*
> -* Generic encode routines from fs/nfs/nfs4xdr.c
> -*/
> -static inline __be32 *
> -xdr_writemem(__be32 *p, const void *ptr, int nbytes)
> -{
> -	int tmp = XDR_QUADLEN(nbytes);
> -	if (!tmp)
> -		return p;
> -	p[tmp-1] = 0;
> -	memcpy(p, ptr, nbytes);
> -	return p + tmp;
> -}
> -
> -#define WRITE32(n)               *p++ = htonl(n)
> -#define WRITEMEM(ptr,nbytes)     do {                           \
> -	p = xdr_writemem(p, ptr, nbytes);                       \
> -} while (0)
> -#define RESERVE_SPACE(nbytes)   do {                            \
> -	p = xdr_reserve_space(xdr, nbytes);                     \
> -	if (!p) dprintk("NFSD: RESERVE_SPACE(%d) failed in function %s\n", (int) (nbytes), __func__); \
> -	BUG_ON(!p);                                             \
> -} while (0)
> -
> -/*
>   * Generic decode routines from fs/nfs/nfs4xdr.c
>   */
>  #define DECODE_TAIL                             \
> @@ -197,102 +168,232 @@ nfs_cb_stat_to_errno(int stat)
>  	return stat;
>  }
>  
> +static __be32 *xdr_encode_empty_array(__be32 *p)
> +{
> +	*p++ = xdr_zero;
> +	return p;
> +}
> +
> +/*
> + * Encode/decode NFSv4 CB basic data types
> + *
> + * Basic NFSv4 callback data types are defined in section 15 of RFC
> + * 3530: "Network File System (NFS) version 4 Protocol" and section
> + * 20 of RFC 5661: "Network File System (NFS) Version 4 Minor Version
> + * 1 Protocol"
> + */
> +
> +/*
> + *	nfs_cb_opnum4
> + *
> + *	enum nfs_cb_opnum4 {
> + *		OP_CB_GETATTR		= 3,
> + *		  ...
> + *	};
> + */
> +enum nfs_cb_opnum4 {
> +	OP_CB_GETATTR			= 3,
> +	OP_CB_RECALL			= 4,
> +	OP_CB_LAYOUTRECALL		= 5,
> +	OP_CB_NOTIFY			= 6,
> +	OP_CB_PUSH_DELEG		= 7,
> +	OP_CB_RECALL_ANY		= 8,
> +	OP_CB_RECALLABLE_OBJ_AVAIL	= 9,
> +	OP_CB_RECALL_SLOT		= 10,
> +	OP_CB_SEQUENCE			= 11,
> +	OP_CB_WANTS_CANCELLED		= 12,
> +	OP_CB_NOTIFY_LOCK		= 13,
> +	OP_CB_NOTIFY_DEVICEID		= 14,
> +	OP_CB_ILLEGAL			= 10044
> +};
> +
> +static void encode_nfs_cb_opnum4(struct xdr_stream *xdr, enum nfs_cb_opnum4 op)
> +{
> +	__be32 *p;
> +
> +	p = xdr_reserve_space(xdr, 4);
> +	*p = cpu_to_be32(op);
> +}
> +
> +/*
> + * nfs_fh4
> + *
> + *	typedef opaque nfs_fh4<NFS4_FHSIZE>;
> + */
> +static void encode_nfs_fh4(struct xdr_stream *xdr, const struct knfsd_fh *fh)
> +{
> +	u32 length = fh->fh_size;
> +	__be32 *p;
> +
> +	BUG_ON(length > NFS4_FHSIZE);
> +	p = xdr_reserve_space(xdr, 4 + length);
> +	xdr_encode_opaque(p, &fh->fh_base, length);
> +}
> +
>  /*
> - * XDR encode
> + * stateid4
> + *
> + *	struct stateid4 {
> + *		uint32_t	seqid;
> + *		opaque		other[12];
> + *	};
>   */
> +static void encode_stateid4(struct xdr_stream *xdr, const stateid_t *sid)
> +{
> +	__be32 *p;
> +
> +	p = xdr_reserve_space(xdr, NFS4_STATEID_SIZE);
> +	*p++ = cpu_to_be32(sid->si_generation);
> +	xdr_encode_opaque_fixed(p, &sid->si_opaque, NFS4_STATEID_OTHER_SIZE);
> +}
>  
> -static void
> -encode_stateid(struct xdr_stream *xdr, stateid_t *sid)
> +/*
> + * sessionid4
> + *
> + *	typedef opaque sessionid4[NFS4_SESSIONID_SIZE];
> + */
> +static void encode_sessionid4(struct xdr_stream *xdr,
> +			      const struct nfsd4_session *session)
>  {
>  	__be32 *p;
>  
> -	RESERVE_SPACE(sizeof(stateid_t));
> -	WRITE32(sid->si_generation);
> -	WRITEMEM(&sid->si_opaque, sizeof(stateid_opaque_t));
> +	p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN);
> +	xdr_encode_opaque_fixed(p, session->se_sessionid.data,
> +					NFS4_MAX_SESSIONID_LEN);
>  }
>  
> -static void
> -encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
> +/*
> + * CB_COMPOUND4args
> + *
> + *	struct CB_COMPOUND4args {
> + *		utf8str_cs	tag;
> + *		uint32_t	minorversion;
> + *		uint32_t	callback_ident;
> + *		nfs_cb_argop4	argarray<>;
> + *	};
> +*/
> +static void encode_cb_compound4args(struct xdr_stream *xdr,
> +				    struct nfs4_cb_compound_hdr *hdr)
>  {
>  	__be32 * p;
>  
> -	RESERVE_SPACE(16);
> -	WRITE32(0);            /* tag length is always 0 */
> -	WRITE32(hdr->minorversion);
> -	WRITE32(hdr->ident);
> +	p = xdr_reserve_space(xdr, 4 + 4 + 4 + 4);
> +	p = xdr_encode_empty_array(p);		/* empty tag */
> +	*p++ = cpu_to_be32(hdr->minorversion);
> +	*p++ = cpu_to_be32(hdr->ident);
> +
>  	hdr->nops_p = p;
> -	WRITE32(hdr->nops);
> +	*p = cpu_to_be32(hdr->nops);		/* argarray element count */
>  }
>  
> +/*
> + * Update argarray element count
> + */
>  static void encode_cb_nops(struct nfs4_cb_compound_hdr *hdr)
>  {
> -	*hdr->nops_p = htonl(hdr->nops);
> +	BUG_ON(hdr->nops > NFS4_MAX_BACK_CHANNEL_OPS);
> +	*hdr->nops_p = cpu_to_be32(hdr->nops);
>  }
>  
> -static void
> -encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
> -		struct nfs4_cb_compound_hdr *hdr)
> +/*
> + * CB_RECALL4args
> + *
> + *	struct CB_RECALL4args {
> + *		stateid4	stateid;
> + *		bool		truncate;
> + *		nfs_fh4		fh;
> + *	};
> + */
> +static void encode_cb_recall4args(struct xdr_stream *xdr,
> +				  const struct nfs4_delegation *dp,
> +				  struct nfs4_cb_compound_hdr *hdr)
>  {
>  	__be32 *p;
> -	int len = dp->dl_fh.fh_size;
> -
> -	RESERVE_SPACE(4);
> -	WRITE32(OP_CB_RECALL);
> -	encode_stateid(xdr, &dp->dl_stateid);
> -	RESERVE_SPACE(8 + (XDR_QUADLEN(len) << 2));
> -	WRITE32(0); /* truncate optimization not implemented */
> -	WRITE32(len);
> -	WRITEMEM(&dp->dl_fh.fh_base, len);
> +
> +	encode_nfs_cb_opnum4(xdr, OP_CB_RECALL);
> +	encode_stateid4(xdr, &dp->dl_stateid);
> +
> +	p = xdr_reserve_space(xdr, 4);
> +	*p++ = xdr_zero;			/* truncate */
> +
> +	encode_nfs_fh4(xdr, &dp->dl_fh);
> +
>  	hdr->nops++;
>  }
>  
> -static void
> -encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
> -		   struct nfs4_cb_compound_hdr *hdr)
> +/*
> + * CB_SEQUENCE4args
> + *
> + *	struct CB_SEQUENCE4args {
> + *		sessionid4		csa_sessionid;
> + *		sequenceid4		csa_sequenceid;
> + *		slotid4			csa_slotid;
> + *		slotid4			csa_highest_slotid;
> + *		bool			csa_cachethis;
> + *		referring_call_list4	csa_referring_call_lists<>;
> + *	};
> + */
> +static void encode_cb_sequence4args(struct xdr_stream *xdr,
> +				    const struct nfsd4_callback *cb,
> +				    struct nfs4_cb_compound_hdr *hdr)
>  {
> +	struct nfsd4_session *session = cb->cb_clp->cl_cb_session;
>  	__be32 *p;
> -	struct nfsd4_session *ses = cb->cb_clp->cl_cb_session;
>  
>  	if (hdr->minorversion == 0)
>  		return;
>  
> -	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
> +	encode_nfs_cb_opnum4(xdr, OP_CB_SEQUENCE);
> +	encode_sessionid4(xdr, session);
> +
> +	p = xdr_reserve_space(xdr, 4 + 4 + 4 + 4 + 4);
> +	*p++ = cpu_to_be32(session->se_cb_seq_nr);	/* csa_sequenceid */
> +	*p++ = xdr_zero;			/* csa_slotid */
> +	*p++ = xdr_zero;			/* csa_highest_slotid */
> +	*p++ = xdr_zero;			/* csa_cachethis */
> +	xdr_encode_empty_array(p);		/* csa_referring_call_lists */
>  
> -	WRITE32(OP_CB_SEQUENCE);
> -	WRITEMEM(ses->se_sessionid.data, NFS4_MAX_SESSIONID_LEN);
> -	WRITE32(ses->se_cb_seq_nr);
> -	WRITE32(0);		/* slotid, always 0 */
> -	WRITE32(0);		/* highest slotid always 0 */
> -	WRITE32(0);		/* cachethis always 0 */
> -	WRITE32(0); /* FIXME: support referring_call_lists */
>  	hdr->nops++;
>  }
>  
> -static int
> -nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
> +/*
> + * NFSv4.0 and NFSv4.1 XDR encode functions
> + *
> + * NFSv4.0 callback argument types are defined in section 15 of RFC
> + * 3530: "Network File System (NFS) version 4 Protocol" and section 20
> + * of RFC 5661:  "Network File System (NFS) Version 4 Minor Version 1
> + * Protocol".
> + */
> +
> +/*
> + * NB: Without this zero space reservation, callbacks over krb5p fail
> + */
> +static int nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p, void *__unused)
>  {
>  	struct xdr_stream xdrs, *xdr = &xdrs;
>  
>  	xdr_init_encode(&xdrs, &req->rq_snd_buf, p);
> -        RESERVE_SPACE(0);
> +	xdr_reserve_space(xdr, 0);
>  	return 0;
>  }
>  
> -static int
> -nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
> -		struct nfsd4_callback *cb)
> +/*
> + * 20.2. Operation 4: CB_RECALL - Recall a Delegation
> + */
> +static int nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
> +				  const struct nfsd4_callback *cb)
>  {
>  	struct xdr_stream xdr;
> -	struct nfs4_delegation *args = cb->cb_op;
> +	const struct nfs4_delegation *args = cb->cb_op;
>  	struct nfs4_cb_compound_hdr hdr = {
>  		.ident = cb->cb_clp->cl_cb_ident,
>  		.minorversion = cb->cb_minorversion,
>  	};
>  
>  	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
> -	encode_cb_compound_hdr(&xdr, &hdr);
> -	encode_cb_sequence(&xdr, cb, &hdr);
> -	encode_cb_recall(&xdr, args, &hdr);
> +	encode_cb_compound4args(&xdr, &hdr);
> +	encode_cb_sequence4args(&xdr, cb, &hdr);
> +	encode_cb_recall4args(&xdr, args, &hdr);
>  	encode_cb_nops(&hdr);
>  	return 0;
>  }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
