Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4224 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408Ab1DTUS1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 16:18:27 -0400
Subject: Re: [RFC 07/27] pnfs: encode_layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1303320427-21218-1-git-send-email-bhalevy@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
	 <1303320427-21218-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 16:18:25 -0400
Message-ID: <1303330705.23206.38.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-20 at 20:27 +0300, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4xdr.c |   16 +++++++++++++---
>  fs/nfs/pnfs.h    |    4 ++++
>  2 files changed, 17 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 6b64dd8..4f7bef9 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1877,6 +1877,7 @@ encode_layoutget(struct xdr_stream *xdr,
>  
>  static int
>  encode_layoutcommit(struct xdr_stream *xdr,
> +		    struct inode *inode,
>  		    const struct nfs4_layoutcommit_args *args,
>  		    struct compound_hdr *hdr)
>  {
> @@ -1885,7 +1886,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
>  	dprintk("%s: lbw: %llu type: %d\n", __func__, args->lastbytewritten,
>  		NFS_SERVER(args->inode)->pnfs_curr_ld->id);
>  
> -	p = reserve_space(xdr, 48 + NFS4_STATEID_SIZE);
> +	p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
>  	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
>  	/* Only whole file layouts */
>  	p = xdr_encode_hyper(p, 0); /* offset */
> @@ -1896,7 +1897,14 @@ encode_layoutcommit(struct xdr_stream *xdr,
>  	p = xdr_encode_hyper(p, args->lastbytewritten);
>  	*p++ = cpu_to_be32(0); /* Never send time_modify_changed */
>  	*p++ = cpu_to_be32(NFS_SERVER(args->inode)->pnfs_curr_ld->id);/* type */
> -	*p++ = cpu_to_be32(0); /* no file layout payload */
> +
> +	if (NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit)
> +		NFS_SERVER(inode)->pnfs_curr_ld->encode_layoutcommit(
> +			NFS_I(inode)->layout, xdr, args);
> +	else {
> +		p = reserve_space(xdr, 4);
> +		*p = cpu_to_be32(0); /* no layout-type payload */
> +	}
>  
>  	hdr->nops++;
>  	hdr->replen += decode_layoutcommit_maxsz;
> @@ -2759,6 +2767,8 @@ static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
>  				      struct xdr_stream *xdr,
>  				      struct nfs4_layoutcommit_args *args)
>  {
> +	struct nfs4_layoutcommit_data *data =
> +		container_of(args, struct nfs4_layoutcommit_data, args);
>  	struct compound_hdr hdr = {
>  		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
>  	};
> @@ -2766,7 +2776,7 @@ static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
>  	encode_compound_hdr(xdr, req, &hdr);
>  	encode_sequence(xdr, &args->seq_args, &hdr);
>  	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
> -	encode_layoutcommit(xdr, args, &hdr);
> +	encode_layoutcommit(xdr, data->args.inode, args, &hdr);
>  	encode_getfattr(xdr, args->bitmask, &hdr);
>  	encode_nops(&hdr);
>  }
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 51dcbc1..011885e 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -99,6 +99,10 @@ struct pnfs_layoutdriver_type {
>  	/* device notification methods */
>  	void (*delete_deviceid)(struct nfs4_deviceid *);
>  
> +	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
> +				     struct xdr_stream *xdr,
> +				     const struct nfs4_layoutcommit_args *args);

This too is way too ugly. Can't the layout payload be pre-encoded by the
layout driver?


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

