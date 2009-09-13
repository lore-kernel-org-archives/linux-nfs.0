From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 09/12] nfsd41: Backchannel: cb_sequence callback
Date: Sun, 13 Sep 2009 16:27:18 -0400
Message-ID: <20090913202718.GC13109@fieldses.org>
References: <4AA8C597.8080809@panasas.com> <1252574811-30314-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47313 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138AbZIMU1S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Sep 2009 16:27:18 -0400
In-Reply-To: <1252574811-30314-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 10, 2009 at 12:26:51PM +0300, Benny Halevy wrote:
> Implement the cb_sequence callback conforming to draft-ietf-nfsv4-minorversion1
> 
> Note: highest slot id and target highest slot id do not have to be 0
> as was previously implemented.  They can be greater than what the
> nfs server sent if the client supports a larger slot table on the
> backchannel.  At this point we just ignore that.

Minor point (applying as is), but, in future: a changelog that says how
this version of the patch differs from a previous version won't be
useful to someone reading the git history (and lacking the previous
versions).  If you think the above mistake is one that someone might
risk making again, a comment in the appropriate spot in the code might
be more useful.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [Rework the back channel xdr using the shared v4.0 and v4.1 framework.]
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [fixed indentation]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: use nfsd4_cb_sequence for callback minorversion]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: fix verification of CB_SEQUENCE highest slot id[
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: Backchannel: Remove old backchannel serialization]
> [nfsd41: Backchannel: First callback sequence ID should be 1]
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: decode_cb_sequence does not need to actually decode ignored fields]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c |   72 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 72 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index e79e3a4..5e9659c 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -256,6 +256,27 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
>  	hdr->nops++;
>  }
>  
> +static void
> +encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *args,
> +		   struct nfs4_cb_compound_hdr *hdr)
> +{
> +	__be32 *p;
> +
> +	if (hdr->minorversion == 0)
> +		return;
> +
> +	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
> +
> +	WRITE32(OP_CB_SEQUENCE);
> +	WRITEMEM(args->cbs_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
> +	WRITE32(args->cbs_clp->cl_cb_seq_nr);
> +	WRITE32(0);		/* slotid, always 0 */
> +	WRITE32(0);		/* highest slotid always 0 */
> +	WRITE32(0);		/* cachethis always 0 */
> +	WRITE32(0); /* FIXME: support referring_call_lists */
> +	hdr->nops++;
> +}
> +
>  static int
>  nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
>  {
> @@ -317,6 +338,57 @@ decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
>  	return 0;
>  }
>  
> +/*
> + * Our current back channel implmentation supports a single backchannel
> + * with a single slot.
> + */
> +static int
> +decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
> +		   struct rpc_rqst *rqstp)
> +{
> +	struct nfs4_sessionid id;
> +	int status;
> +	u32 dummy;
> +	__be32 *p;
> +
> +	if (res->cbs_minorversion == 0)
> +		return 0;
> +
> +	status = decode_cb_op_hdr(xdr, OP_CB_SEQUENCE);
> +	if (status)
> +		return status;
> +
> +	/*
> +	 * If the server returns different values for sessionID, slotID or
> +	 * sequence number, the server is looney tunes.
> +	 */
> +	status = -ESERVERFAULT;
> +
> +	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
> +	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
> +	p += XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN);
> +	if (memcmp(id.data, res->cbs_clp->cl_sessionid.data,
> +		   NFS4_MAX_SESSIONID_LEN)) {
> +		dprintk("%s Invalid session id\n", __func__);
> +		goto out;
> +	}
> +	READ32(dummy);
> +	if (dummy != res->cbs_clp->cl_cb_seq_nr) {
> +		dprintk("%s Invalid sequence number\n", __func__);
> +		goto out;
> +	}
> +	READ32(dummy); 	/* slotid must be 0 */
> +	if (dummy != 0) {
> +		dprintk("%s Invalid slotid\n", __func__);
> +		goto out;
> +	}
> +	/* FIXME: process highest slotid and target highest slotid */
> +	status = 0;
> +out:
> +	return status;
> +}
> +
> +
>  static int
>  nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
>  {
> -- 
> 1.6.4
> 
