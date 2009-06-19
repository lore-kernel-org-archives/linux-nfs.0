From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 34/44] nfsd41: Backchannel: cleanup nfs4.0 callback
	encode routines
Date: Thu, 18 Jun 2009 21:34:30 -0400
Message-ID: <20090619013430.GD16785@fieldses.org>
References: <1245115250-7923-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:50639 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbZFSBe2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 21:34:28 -0400
In-Reply-To: <1245115250-7923-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:20:50AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Mimic the client and prepare to share the back channel xdr with NFSv4.1.
> Bump the number of operations in each encode routine, then backfill the
> number of operations.

Thanks, applied.--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c |   24 ++++++++++++++++--------
>  1 files changed, 16 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index f4fab69..353eb4a 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -140,8 +140,9 @@ struct nfs4_cb_compound_hdr {
>  	int		status;
>  	u32		ident;
>  	u32		nops;
> +	__be32		*nops_p;
>  	u32		taglen;
> -	char *		tag;
> +	char		*tag;
>  };
>  
>  static struct {
> @@ -201,7 +202,7 @@ nfs_cb_stat_to_errno(int stat)
>   * XDR encode
>   */
>  
> -static int
> +static void
>  encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
>  {
>  	__be32 * p;
> @@ -210,12 +211,18 @@ encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
>  	WRITE32(0);            /* tag length is always 0 */
>  	WRITE32(NFS4_MINOR_VERSION);
>  	WRITE32(hdr->ident);
> +	hdr->nops_p = p;
>  	WRITE32(hdr->nops);
> -	return 0;
>  }
>  
> -static int
> -encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp)
> +static void encode_cb_nops(struct nfs4_cb_compound_hdr *hdr)
> +{
> +	*hdr->nops_p = htonl(hdr->nops);
> +}
> +
> +static void
> +encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
> +		struct nfs4_cb_compound_hdr *hdr)
>  {
>  	__be32 *p;
>  	int len = dp->dl_fh.fh_size;
> @@ -227,7 +234,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp)
>  	WRITE32(0); /* truncate optimization not implemented */
>  	WRITE32(len);
>  	WRITEMEM(&dp->dl_fh.fh_base, len);
> -	return 0;
> +	hdr->nops++;
>  }
>  
>  static int
> @@ -246,12 +253,13 @@ nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_delegation *
>  	struct xdr_stream xdr;
>  	struct nfs4_cb_compound_hdr hdr = {
>  		.ident = args->dl_ident,
> -		.nops   = 1,
>  	};
>  
>  	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>  	encode_cb_compound_hdr(&xdr, &hdr);
> -	return (encode_cb_recall(&xdr, args));
> +	encode_cb_recall(&xdr, args, &hdr);
> +	encode_cb_nops(&hdr);
> +	return 0;
>  }
>  
>  
> -- 
> 1.6.3
> 
