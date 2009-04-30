From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [pnfs] [RFC 09/10] nfsd41: cb_sequence callback
Date: Thu, 30 Apr 2009 19:52:45 -0400
Message-ID: <1241135565.15476.111.camel@heimdal.trondhjem.org>
References: <49FA2D86.8060402@panasas.com>
	 <1241132806-32655-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:54781 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763987AbZD3Xw6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2009 19:52:58 -0400
In-Reply-To: <1241132806-32655-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-01 at 02:06 +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Implement the cb_sequence callback conforming to draft-ietf-nfsv4-minorversion1
> 
> Note: highest slot id and target highest slot id do not have to be 0
> as was previously implemented.  They can be greater than what the
> nfs server sent if the client supports a larger slot table on the
> backchannel.  At this point we just ignore that.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
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
> ---
>  fs/nfsd/nfs4callback.c |   72 ++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4state.c    |    1 +
>  2 files changed, 73 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 2bf2cd4..78f4dd2 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -264,6 +264,27 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec,
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
> @@ -325,6 +346,57 @@ decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
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
> +	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
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
> +	READ32(dummy); 	/* highest slotid */
          ^^^^^^^^^^^^^

> +	READ32(dummy); 	/* target highest slotid */
          ^^^^^^^^^^^^^^

Why do you need those?

> +	status = 0;
> +out:
> +	return status;
> +}
> +
> +
>  static int
>  nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
>  {
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d7b4028..6f3cf47 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1400,6 +1400,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  			svc_xprt_get(unconf->cl_cb_xprt);
>  			unconf->cl_callback.cb_minorversion =
>  				cstate->minorversion;
> +			unconf->cl_cb_seq_nr = 1;
>  			unconf->cl_callback.cb_prog = cr_ses->callback_prog;
>  			nfsd4_probe_callback(unconf);
>  		}
> -- 
> 1.6.2.1
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs


