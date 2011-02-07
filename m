Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13697 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab1BGRmv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Feb 2011 12:42:51 -0500
Message-ID: <4D502F19.7060705@panasas.com>
Date: Mon, 07 Feb 2011 19:42:49 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 37/40] pnfs-submit wave3 send zero stateid seqid on v4.1
 i/o
References: <1296855242-2592-1-git-send-email-andros@netapp.com> <1296855242-2592-22-git-send-email-andros@netapp.com> <1296855242-2592-23-git-send-email-andros@netapp.com> <1296855242-2592-24-git-send-email-andros@netapp.com> <1296855242-2592-25-git-send-email-andros@netapp.com> <1296855242-2592-26-git-send-email-andros@netapp.com> <1296855242-2592-27-git-send-email-andros@netapp.com> <1296855242-2592-28-git-send-email-andros@netapp.com> <1296855242-2592-29-git-send-email-andros@netapp.com> <1296855242-2592-30-git-send-email-andros@netapp.com> <1296855242-2592-31-git-send-email-andros@netapp.com> <1296855242-2592-32-git-send-email-andros@netapp.com> <1296855242-2592-33-git-send-email-andros@netapp.com> <1296855242-2592-34-git-send-email-andros@netapp.com> <1296855242-2592-35-git-send-email-andros@netapp.com> <1296855242-2592-36-git-send-email-andros@netapp.com> <1296855242-2592-37-git-send-email-andros@netapp.com> <1296855242-2592-38-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-38-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-04 23:33, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Data servers require a zero stateid seqid, and there is no advantage to not
> doing the same for all NFSv4.1
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4xdr.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 4e2c168..2380c45 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1384,7 +1384,7 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
>  	hdr->replen += decode_putrootfh_maxsz;
>  }
>  
> -static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx)
> +static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx, int zero_seqid)

nit: how about bool rather than int zero_stateid?

Benny

>  {
>  	nfs4_stateid stateid;
>  	__be32 *p;
> @@ -1392,6 +1392,8 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
>  	p = reserve_space(xdr, NFS4_STATEID_SIZE);
>  	if (ctx->state != NULL) {
>  		nfs4_copy_stateid(&stateid, ctx->state, l_ctx->lockowner, l_ctx->pid);
> +		if (zero_seqid)
> +			stateid.stateid.seqid = 0;
>  		xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
>  	} else
>  		xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
> @@ -1404,7 +1406,8 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
>  	p = reserve_space(xdr, 4);
>  	*p = cpu_to_be32(OP_READ);
>  
> -	encode_stateid(xdr, args->context, args->lock_context);
> +	encode_stateid(xdr, args->context, args->lock_context,
> +		       hdr->minorversion);
>  
>  	p = reserve_space(xdr, 12);
>  	p = xdr_encode_hyper(p, args->offset);
> @@ -1592,7 +1595,8 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
>  	p = reserve_space(xdr, 4);
>  	*p = cpu_to_be32(OP_WRITE);
>  
> -	encode_stateid(xdr, args->context, args->lock_context);
> +	encode_stateid(xdr, args->context, args->lock_context,
> +		       hdr->minorversion);
>  
>  	p = reserve_space(xdr, 16);
>  	p = xdr_encode_hyper(p, args->offset);
