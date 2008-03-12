From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 03/19] sunrpc: make token header values less confusing
Date: Wed, 12 Mar 2008 12:31:04 -0400
Message-ID: <20080312163104.GC10015@fieldses.org>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu> <20080221184402.19195.57873.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, aglo@citi.umich.edu
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54807 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312AbYCLQbF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2008 12:31:05 -0400
In-Reply-To: <20080221184402.19195.57873.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2008 at 01:44:02PM -0500, Kevin Coffman wrote:
> g_make_token_header() and g_token_size() add two too many, and
> therefore their callers pass in "(logical_value - 2)" rather
> than "logical_value" as hard-coded values which causes confusion.
> 
> This dates back to the original g_make_token_header which took an
> optional token type (token_id) value and added it to the token.
> This was removed, but the routine always adds room for the token_id
> rather than not.

Looks fine, thanks, but:

> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> ---
> 
>  net/sunrpc/auth_gss/gss_generic_token.c |    4 ++--
>  net/sunrpc/auth_gss/gss_krb5_seal.c     |    4 ++--
>  net/sunrpc/auth_gss/gss_krb5_wrap.c     |    4 ++--
>  net/sunrpc/auth_gss/gss_spkm3_seal.c    |    2 +-
>  4 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_generic_token.c b/net/sunrpc/auth_gss/gss_generic_token.c
> index ea8c92e..d83b881 100644
> --- a/net/sunrpc/auth_gss/gss_generic_token.c
> +++ b/net/sunrpc/auth_gss/gss_generic_token.c
> @@ -148,7 +148,7 @@ int
>  g_token_size(struct xdr_netobj *mech, unsigned int body_size)
>  {
>  	/* set body_size to sequence contents size */
> -	body_size += 4 + (int) mech->len;         /* NEED overflow check */
> +	body_size += 2 + (int) mech->len;         /* NEED overflow check */
>  	return(1 + der_length_size(body_size) + body_size);
>  }
>  
> @@ -161,7 +161,7 @@ void
>  g_make_token_header(struct xdr_netobj *mech, int body_size, unsigned char **buf)
>  {
>  	*(*buf)++ = 0x60;
> -	der_write_length(buf, 4 + mech->len + body_size);
> +	der_write_length(buf, 2 + mech->len + body_size);
>  	*(*buf)++ = 0x06;
>  	*(*buf)++ = (unsigned char) mech->len;
>  	TWRITE_STR(*buf, mech->data, ((int) mech->len));
> diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
> index dedcbd6..b2fa785 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_seal.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
> @@ -87,10 +87,10 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
>  
>  	now = get_seconds();
>  
> -	token->len = g_token_size(&ctx->mech_used, 22);
> +	token->len = g_token_size(&ctx->mech_used, 24);
>  
>  	ptr = token->data;
> -	g_make_token_header(&ctx->mech_used, 22, &ptr);
> +	g_make_token_header(&ctx->mech_used, 24, &ptr);
>  
>  	*ptr++ = (unsigned char) ((KG_TOK_MIC_MSG>>8)&0xff);
>  	*ptr++ = (unsigned char) (KG_TOK_MIC_MSG&0xff);
> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> index 3bdc527..a2c92f1 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> @@ -137,7 +137,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
>  	BUG_ON((buf->len - offset) % blocksize);
>  	plainlen = blocksize + buf->len - offset;
>  
> -	headlen = g_token_size(&kctx->mech_used, 22 + plainlen) -
> +	headlen = g_token_size(&kctx->mech_used, 24 + plainlen) -
>  						(buf->len - offset);
>  
>  	ptr = buf->head[0].iov_base + offset;
> @@ -149,7 +149,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
>  	buf->len += headlen;
>  	BUG_ON((buf->len - offset - headlen) % blocksize);
>  
> -	g_make_token_header(&kctx->mech_used, 22 + plainlen, &ptr);
> +	g_make_token_header(&kctx->mech_used, 24 + plainlen, &ptr);
>  
>  
>  	*ptr++ = (unsigned char) ((KG_TOK_WRAP_MSG>>8)&0xff);
> diff --git a/net/sunrpc/auth_gss/gss_spkm3_seal.c b/net/sunrpc/auth_gss/gss_spkm3_seal.c
> index abf17ce..88505d5 100644
> --- a/net/sunrpc/auth_gss/gss_spkm3_seal.c
> +++ b/net/sunrpc/auth_gss/gss_spkm3_seal.c
> @@ -104,7 +104,7 @@ spkm3_make_token(struct spkm3_ctx *ctx,
>  			goto out_err;
>  
>  		asn1_bitstring_len(&md5cksum, &md5elen, &md5zbit);
> -		tokenlen = 10 + ctxelen + 1 + md5elen + 1;
> +		tokenlen = 12 + ctxelen + 1 + md5elen + 1;
>  
>  		/* Create token header using generic routines */
>  		token->len = g_token_size(&ctx->mech_used, tokenlen);

Could you double-check this spkm3 case?  It looks like tokenlen is
passed to spkm3_make_mic_token as well as the two functions you've
modified.

--b.
