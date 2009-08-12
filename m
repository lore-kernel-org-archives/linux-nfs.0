From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH RFC 13/13] nfs: nfs4xdr: get rid of READ_BUF
Date: Wed, 12 Aug 2009 17:05:09 -0400
Message-ID: <1250111109.5973.41.camel@heimdal.trondhjem.org>
References: <4A82DC7B.3090600@panasas.com>
	 <1250090578-9927-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21356 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750847AbZHLVGS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2009 17:06:18 -0400
In-Reply-To: <1250090578-9927-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-12 at 18:22 +0300, Benny Halevy wrote:
> Open code return pointer assignment and error checking using
> a read_buf helper (macro), yet keep the dprintk on failure using an
> internal __read_buf helper that gets the function name for printing.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4xdr.c |  386 ++++++++++++++++++++++++++++++++++++++---------------
>  1 files changed, 277 insertions(+), 109 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index ed9bbd2..fb10a77 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2438,26 +2438,17 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
>  }
>  #endif /* CONFIG_NFS_V4_1 */
>  
> -/*
> - * START OF "GENERIC" DECODE ROUTINES.
> - *   These may look a little ugly since they are imported from a "generic"
> - * set of XDR encode/decode routines which are intended to be shared by
> - * all of our NFSv4 implementations (OpenBSD, MacOS X...).
> - *
> - * If the pain of reading these is too great, it should be a straightforward
> - * task to translate them into Linux-specific versions which are more
> - * consistent with the style used in NFSv2/v3...
> - */
> -#define READ_BUF(nbytes)  do { \
> -	p = xdr_inline_decode(xdr, nbytes); \
> -	if (unlikely(!p)) { \
> -		dprintk("nfs: %s: prematurely hit end of receive" \
> -				" buffer\n", __func__); \
> -		dprintk("nfs: %s: xdr->p=%p, bytes=%u, xdr->end=%p\n", \
> -				__func__, xdr->p, nbytes, xdr->end); \
> -		return -EIO; \
> -	} \
> -} while (0)
> +static __be32 *__read_buf(struct xdr_stream *xdr, size_t nbytes, char *func)
> +{
> +	__be32 *p = xdr_inline_decode(xdr, nbytes);
> +	if (unlikely(!p))
> +		dprintk("nfs: %s: prematurely hit end of receive buffer: "
> +			"xdr->p=%p, bytes=%u, xdr->end=%p\n",
> +			func, xdr->p, nbytes, xdr->end);
> +	return p;
> +}
> +
> +#define read_buf(xdr, nbytes)	__read_buf(xdr, nbytes, __func__)
>  
>  static __be32 *copymem(void *x, __be32 *p, u32 nbytes)
>  {
> @@ -2469,9 +2460,13 @@ static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char
>  {
>  	__be32 *p;
>  
> -	READ_BUF(4);
> +	p = read_buf(xdr, 4);
> +	if (unlikely(!p))
> +		return -EIO;
>  	p = xdr_decode_int(p, len);
> -	READ_BUF(*len);
> +	p = read_buf(xdr, *len);
> +	if (unlikely(!p))
> +		return -EIO;
>  	*string = (char *)p;
>  	return 0;
>  }

I'd do this a little differently.

static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
{
	dprintk("nfs: %s: prematurely hit end of receive buffer."
		"Remaining buffer length is %tu words.\n",
		func, xdr->end - xdr->p);
}

static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char **string)
{
	__be32 *p;

	p = xdr_inline_decode(xdr, 4);
	if (unlikely(!p))
		goto out_overflow;
	*len = be32_to_cpu(*p++);
	p = xdr_inline_decode(xdr, *len);
	if (unlikely(!p))
		goto out_overflow;
	*string = (char *)p;
	return 0;
out_overflow:
	print_overflow_msg(__func__, xdr);
	return -EIO;
}

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
