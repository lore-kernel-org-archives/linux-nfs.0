From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 28/47] nfsd41: check encode size for sessions
	maxresponse cached
Date: Wed, 1 Apr 2009 17:54:44 -0400
Message-ID: <20090401215444.GG8899@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229218-11143-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:32882 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934508AbZDAVyt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 17:54:49 -0400
In-Reply-To: <1238229218-11143-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2009 at 11:33:38AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Calculate the space the compound response has taken after encoding the current
> operation.
> 
> pad: add on 8 bytes for the next operation's op_code and status so that
> there is room to cache a failure on the next operation.

Looks like setattr always has a bitmap regardless of status, so that
should be at least 12.  There might be some other odd case like that
too--someone should look through the xdr and check.

> Compare this length to the session se_fmaxresp_cached and return
> nfserr_rep_too_big_to_cache if the length is too large.
> 
> Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
> will be at least a page and will therefore hold the xdr_buf head.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [nfsd41: non-page DRC for solo sequence responses]
> [fixed nfsd4_check_drc_limit cosmetics]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4xdr.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 58 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index a2682e8..52ca833 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3089,6 +3089,61 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>  #endif /* CONFIG_NFSD_V4_1 */
>  };
>  
> +#if defined(CONFIG_NFSD_V4_1)
> +/*
> + * Calculate the total amount of memory that the compound response has taken
> + * after encoding the current operation.
> + *
> + * pad: add on 8 bytes for the next operation's op_code and status so that
> + * there is room to cache a failure on the next operation.
> + *
> + * Compare this length to the session se_fmaxresp_cached.
> + *
> + * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
> + * will be at least a page and will therefore hold the xdr_buf head.
> + */
> +static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
> +{
> +	int status = 0;

Note that status and the return value should be __be32.

Ditto for anything holding an nfs error or the server side.  I haven't
been checking for this as I've been reading these.

Probably we should be running sparse regularly (install it, then build
the kernel with 'make C=1' or 'C=2')--I think it checks for this.

> +	struct xdr_buf *xb = &resp->rqstp->rq_res;
> +	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
> +	struct nfsd4_session *session = NULL;
> +	struct nfsd4_slot *slot = resp->cstate.slot;
> +	u32 length, tlen = 0, pad = 8;
> +
> +	if (!nfsd4_has_session(&resp->cstate))
> +		return status;
> +
> +	session = slot->sl_session;
> +	if (session == NULL || slot->sl_cache_entry.ce_cachethis == 0)
> +		return status;
> +
> +	if (resp->opcnt >= args->opcnt)
> +		pad = 0; /* this is the last operation */
> +
> +	if (xb->page_len == 0) {
> +		length = (char *)resp->p - (char *)xb->head[0].iov_base + pad;
> +	} else {
> +		if (xb->tail[0].iov_base && xb->tail[0].iov_len > 0)
> +			tlen = (char *)resp->p - (char *)xb->tail[0].iov_base;
> +
> +		length = xb->head[0].iov_len + xb->page_len + tlen + pad;
> +	}
> +	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
> +		length, xb->page_len, tlen, pad);
> +
> +	if (length <= session->se_fmaxresp_cached)
> +		return status;
> +	else
> +		return nfserr_rep_too_big_to_cache;
> +}
> +#else /* CONFIG_NFSD_V4_1 */
> +static inline int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_NFSD_V4_1 */
> +
>  void
>  nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
>  {
> @@ -3105,6 +3160,9 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
>  	BUG_ON(op->opnum < 0 || op->opnum >= ARRAY_SIZE(nfsd4_enc_ops) ||
>  	       !nfsd4_enc_ops[op->opnum]);
>  	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
> +	/* nfsd4_check_drc_limit guarantees enough room for error status */
> +	if (!op->status && nfsd4_check_drc_limit(resp))

Hm, but note you aren't actually using the return value from
nfsd4_check_drc_limit().

> +		op->status = nfserr_rep_too_big_to_cache;

This means you can end up writing the error after you've already encoded
a succesful reply.  That doesn't work--the result will be invalid xdr.

I think there's no alternative but to estimate the size of the result
before actually performing the operation, because once we decide to
process an operation which the client has asked us to cache, we're
committed to caching the result.

Maybe add a field to struct nfsd4_operation consisting of a function
like

	estimate_reply_size(void *arg)

which does the calculation for each op.  Or maybe there's some clever
way to avoid duplicating a lot of information that's already implicit in
the xdr-encoding routines.

Am I missing something?

--b.

>  status:
>  	/*
>  	 * Note: We write the status directly, instead of using WRITE32(),
> -- 
> 1.6.2.1
> 
