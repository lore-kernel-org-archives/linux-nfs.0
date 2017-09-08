Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35468 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756652AbdIHTih (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Sep 2017 15:38:37 -0400
Date: Fri, 8 Sep 2017 15:38:36 -0400
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 27/42] NFSD: allow inter server COPY to have a STALE
 source server fh
Message-ID: <20170908193836.GB18220@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-28-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170711164416.1982-28-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some questions below, but really I think this approach can't work.  Keep
in mind this has to work not just for the one compound the current
client uses, but for *any* compound containing a COPY, including those
sent by future clients that may do something more complicated, or by
malcious clients that may intentionally send weird compounds to make the
server crash.

I think we want to flag the filehandle itself somehow, not the cstate.

And check very carefully to make sure that ops other than COPY can't get
tripped up by one of these foreign filehandles.

On Tue, Jul 11, 2017 at 12:44:01PM -0400, Olga Kornievskaia wrote:
> The inter server to server COPY source server filehandle
> is guaranteed to be stale as the COPY is sent to the destination
> server.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c | 47 ++++++++++++++++++++++++++++++++++++++++++++++-
>  fs/nfsd/nfs4xdr.c  | 26 +++++++++++++++++++++++++-
>  fs/nfsd/nfsd.h     |  2 ++
>  fs/nfsd/xdr4.h     |  4 ++++
>  4 files changed, 77 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index b49ff31..ceee852 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -496,11 +496,19 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
>  nfsd4_putfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	    struct nfsd4_putfh *putfh)
>  {
> +	__be32 ret;
> +
>  	fh_put(&cstate->current_fh);
>  	cstate->current_fh.fh_handle.fh_size = putfh->pf_fhlen;
>  	memcpy(&cstate->current_fh.fh_handle.fh_base, putfh->pf_fhval,
>  	       putfh->pf_fhlen);
> -	return fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_GSS);
> +	ret = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_GSS);
> +	if (ret == nfserr_stale && HAS_CSTATE_FLAG(cstate, NO_VERIFY_FH)) {
> +		CLEAR_CSTATE_FLAG(cstate, NO_VERIFY_FH);
> +		SET_CSTATE_FLAG(cstate, IS_STALE_FH);
> +		ret = 0;
> +	}
> +	return ret;
>  }
>  
>  static __be32
> @@ -533,6 +541,16 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
>  nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	     void *arg)
>  {
> +	/**
> +	* This is either an inter COPY (most likely) or an intra COPY with a
> +	* stale file handle. If the latter, nfsd4_copy will reset the PUTFH to
> +	* return nfserr_stale. No fh_dentry, just copy the file handle
> +	* to use with the inter COPY READ.
> +	*/
> +	if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH)) {
> +		cstate->save_fh = cstate->current_fh;
> +		return nfs_ok;
> +	}
>  	if (!cstate->current_fh.fh_dentry)
>  		return nfserr_nofilehandle;
>  
> @@ -1067,6 +1085,13 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  	if (status)
>  		goto out;
>  
> +	/* Intra copy source fh is stale. PUTFH will fail with ESTALE */
> +	if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH)) {
> +		CLEAR_CSTATE_FLAG(cstate, IS_STALE_FH);
> +		cstate->status = nfserr_copy_stalefh;
> +		goto out_put;
> +	}
> +
>  	bytes = nfsd_copy_file_range(src, copy->cp_src_pos,
>  			dst, copy->cp_dst_pos, copy->cp_count);
>  
> @@ -1081,6 +1106,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  		status = nfs_ok;
>  	}
>  
> +out_put:
>  	fput(src);
>  	fput(dst);
>  out:
> @@ -1759,6 +1785,7 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  	struct nfsd4_compound_state *cstate = &resp->cstate;
>  	struct svc_fh *current_fh = &cstate->current_fh;
>  	struct svc_fh *save_fh = &cstate->save_fh;
> +	int		i;
>  	__be32		status;
>  
>  	svcxdr_init_encode(rqstp, resp);
> @@ -1791,6 +1818,12 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  		goto encode_op;
>  	}
>  
> +	/* NFSv4.2 COPY source file handle may be from a different server */
> +	for (i = 0; i < args->opcnt; i++) {
> +		op = &args->ops[i];
> +		if (op->opnum == OP_COPY)
> +			SET_CSTATE_FLAG(cstate, NO_VERIFY_FH);
> +	}

So, if a compound has a COPY anywhere in it, then a PUTFH with a stale
filehandle anywhere in the compound will temporarily succeed and result in
IS_STALE_FH being set.

>  	while (!status && resp->opcnt < args->opcnt) {
>  		op = &args->ops[resp->opcnt++];
>  
> @@ -1810,6 +1843,9 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  
>  		opdesc = OPDESC(op);
>  
> +		if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH))
> +			goto call_op;
> +

That means that once IS_STALE_FH is set, we will skip:

	- nofilehandle checking
	- moved checking
	- fh_clear_wcc()
	- resp_size checking
	- current stateid capture

on every subsequent op.  Can that really be right?

>  		if (!current_fh->fh_dentry) {
>  			if (!(opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
>  				op->status = nfserr_nofilehandle;
> @@ -1844,6 +1880,7 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  
>  		if (opdesc->op_get_currentstateid)
>  			opdesc->op_get_currentstateid(cstate, &op->u);
> +call_op:
>  		op->status = opdesc->op_func(rqstp, cstate, &op->u);
>  
>  		/* Only from SEQUENCE */
> @@ -1862,6 +1899,14 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  			if (need_wrongsec_check(rqstp))
>  				op->status = check_nfsd_access(current_fh->fh_export, rqstp);
>  		}
> +		/* Only from intra COPY */
> +		if (cstate->status == nfserr_copy_stalefh) {
> +			dprintk("%s NFS4.2 intra COPY stale src filehandle\n",
> +				__func__);
> +			status = nfserr_stale;
> +			nfsd4_adjust_encode(resp);

Are you sure it's safe just to throw away any operations since that
stale PUTFH?  What if some of those operations had side effects?

> +			goto out;
> +		}
>  encode_op:
>  		if (op->status == nfserr_replay_me) {
>  			op->replay = &cstate->replay_owner->so_replay;
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 3e08c15..2896a11 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -4624,15 +4624,28 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 respsize)
>  	return nfserr_rep_too_big;
>  }
>  
> +/** Rewind the encoding to return nfserr_stale on the PUTFH
> + * in this failed Intra COPY compound
> + */
> +void
> +nfsd4_adjust_encode(struct nfsd4_compoundres *resp)
> +{
> +	__be32 *p;
> +
> +	p = resp->cstate.putfh_errp;
> +	*p++ = nfserr_stale;
> +}
> +
>  void
>  nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
>  {
>  	struct xdr_stream *xdr = &resp->xdr;
>  	struct nfs4_stateowner *so = resp->cstate.replay_owner;
> +	struct nfsd4_compound_state *cstate = &resp->cstate;
>  	struct svc_rqst *rqstp = resp->rqstp;
>  	int post_err_offset;
>  	nfsd4_enc encoder;
> -	__be32 *p;
> +	__be32 *p, *statp;
>  
>  	p = xdr_reserve_space(xdr, 8);
>  	if (!p) {
> @@ -4641,9 +4654,20 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 respsize)
>  	}
>  	*p++ = cpu_to_be32(op->opnum);
>  	post_err_offset = xdr->buf->len;
> +	statp = p;
>  
>  	if (op->opnum == OP_ILLEGAL)
>  		goto status;
> +
> +	/** This is a COPY compound with a stale source server file handle.
> +	 * If OP_COPY processing determines that this is an intra server to
> +	 * server COPY, then this PUTFH should return nfserr_ stale so the
> +	 * putfh_errp will be set to nfserr_stale. If this is an inter server
> +	 * to server COPY, ignore the nfserr_stale.
> +	 */
> +	if (op->opnum == OP_PUTFH && HAS_CSTATE_FLAG(cstate, IS_STALE_FH))
> +		cstate->putfh_errp = statp;
> +
>  	BUG_ON(op->opnum < 0 || op->opnum >= ARRAY_SIZE(nfsd4_enc_ops) ||
>  	       !nfsd4_enc_ops[op->opnum]);
>  	encoder = nfsd4_enc_ops[op->opnum];
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index d966068..8d6fb0f 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -272,6 +272,8 @@ static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
>  #define	nfserr_replay_me	cpu_to_be32(11001)
>  /* nfs41 replay detected */
>  #define	nfserr_replay_cache	cpu_to_be32(11002)
> +/* nfs42 intra copy failed with nfserr_stale */
> +#define nfserr_copy_stalefh	cpu_to_be32(1103)
>  
>  /* Check for dir entries '.' and '..' */
>  #define isdotent(n, l)	(l < 3 && n[0] == '.' && (l == 1 || n[1] == '.'))
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 38fcb4f..aa94295 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -45,6 +45,8 @@
>  
>  #define CURRENT_STATE_ID_FLAG (1<<0)
>  #define SAVED_STATE_ID_FLAG (1<<1)
> +#define NO_VERIFY_FH (1<<2)
> +#define IS_STALE_FH  (1<<3)
>  
>  #define SET_CSTATE_FLAG(c, f) ((c)->sid_flags |= (f))
>  #define HAS_CSTATE_FLAG(c, f) ((c)->sid_flags & (f))
> @@ -63,6 +65,7 @@ struct nfsd4_compound_state {
>  	size_t			iovlen;
>  	u32			minorversion;
>  	__be32			status;
> +	__be32			*putfh_errp;
>  	stateid_t	current_stateid;
>  	stateid_t	save_stateid;
>  	/* to indicate current and saved state id presents */
> @@ -705,6 +708,7 @@ int nfs4svc_decode_compoundargs(struct svc_rqst *, __be32 *,
>  int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
>  		struct nfsd4_compoundres *);
>  __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
> +void nfsd4_adjust_encode(struct nfsd4_compoundres *);
>  void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
>  void nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op);
>  __be32 nfsd4_encode_fattr_to_buf(__be32 **p, int words,
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
