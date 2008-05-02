From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [enctypes round 2: PATCH 03/26] rpcauth: update and document
	available space in xdr_buf when doing privacy
Date: Fri, 2 May 2008 17:28:12 -0400
Message-ID: <20080502212812.GJ21918@fieldses.org>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu> <20080430164603.16010.25894.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47484 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756283AbYEBV2O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 17:28:14 -0400
In-Reply-To: <20080430164603.16010.25894.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 30, 2008 at 12:46:03PM -0400, Kevin Coffman wrote:
> Make the client and server code consistent regarding the extra buffer
> space made available for the auth code when wrapping data.
> 
> Add some comments/documentation about the available buffer space
> in the xdr_buf head and tail when gss_wrap is called.
> 
> Add a compile-time check to make sure we are not exceeding the available
> buffer space.
> 
> Add a central function to shift head data.

I do wish we could find a way to make this code inherently simpler to
understand, but the extra documentation does seem like a step forward;
applied.

--b.

> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> ---
> 
>  include/linux/sunrpc/gss_krb5.h       |   25 +++++++++++++++
>  net/sunrpc/auth_gss/auth_gss.c        |   14 ++++++--
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |   56 +++++++++++++++++++++++++++++++++
>  net/sunrpc/auth_gss/gss_krb5_wrap.c   |    7 ++--
>  net/sunrpc/auth_gss/gss_mech_switch.c |   14 ++++++++
>  net/sunrpc/auth_gss/svcauth_gss.c     |   15 +++++++++
>  6 files changed, 123 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
> index e7bbdba..5bb227e 100644
> --- a/include/linux/sunrpc/gss_krb5.h
> +++ b/include/linux/sunrpc/gss_krb5.h
> @@ -40,6 +40,12 @@
>  #include <linux/sunrpc/gss_err.h>
>  #include <linux/sunrpc/gss_asn1.h>
>  
> +/* Maximum checksum function output for the supported crypto algorithms */
> +#define GSS_KRB5_MAX_CKSUM_LEN  (20)
> +
> +/* Maximum blocksize for the supported crypto algorithms */
> +#define GSS_KRB5_MAX_BLOCKSIZE  (16)
> +
>  struct krb5_ctx {
>  	int			initiate; /* 1 = initiating, 0 = accepting */
>  	struct crypto_blkcipher	*enc;
> @@ -113,6 +119,22 @@ enum seal_alg {
>  #define ENCTYPE_DES3_CBC_SHA1   0x0010
>  #define ENCTYPE_UNKNOWN         0x01ff
>  
> +/*
> + * This compile-time check verifies that we will not exceed the
> + * slack space allotted by the client and server auth_gss code
> + * before they call gss_wrap().
> + */
> +#define GSS_KRB5_SLACK_CHECK \
> +	BUILD_BUG_ON(GSS_KRB5_TOK_HDR_LEN      /* gss token header */         \
> +		     + GSS_KRB5_MAX_CKSUM_LEN  /* gss token checksum */       \
> +		     + GSS_KRB5_MAX_BLOCKSIZE  /* confounder */               \
> +		     + GSS_KRB5_MAX_BLOCKSIZE  /* possible padding */         \
> +		     + GSS_KRB5_TOK_HDR_LEN    /* encrypted hdr in v2 token */\
> +		     + GSS_KRB5_MAX_CKSUM_LEN  /* encryption hmac */          \
> +		     + 4 + 4                   /* RPC verifier */             \
> +		     + GSS_KRB5_TOK_HDR_LEN                                   \
> +		     + GSS_KRB5_MAX_CKSUM_LEN > RPC_MAX_AUTH_SIZE)
> +
>  s32
>  make_checksum(char *, char *header, int hdrlen, struct xdr_buf *body,
>  		   int body_offset, struct xdr_netobj *cksum);
> @@ -157,3 +179,6 @@ s32
>  krb5_get_seq_num(struct crypto_blkcipher *key,
>  	       unsigned char *cksum,
>  	       unsigned char *buf, int *direction, u32 *seqnum);
> +
> +int
> +shift_head_data(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen);
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index cc12d5f..53e027e 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -65,7 +65,7 @@ static const struct rpc_credops gss_nullops;
>  
>  #define NFS_NGROUPS	16
>  
> -#define GSS_CRED_SLACK		1024		/* XXX: unused */
> +#define GSS_CRED_SLACK		(RPC_MAX_AUTH_SIZE * 2)
>  /* length of a krb5 verifier (48), plus data added before arguments when
>   * using integrity (two 4-byte integers): */
>  #define GSS_VERF_SLACK		100
> @@ -1137,15 +1137,21 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
>  	inpages = snd_buf->pages + first;
>  	snd_buf->pages = rqstp->rq_enc_pages;
>  	snd_buf->page_base -= first << PAGE_CACHE_SHIFT;
> -	/* Give the tail its own page, in case we need extra space in the
> -	 * head when wrapping: */
> +	/*
> +	 * Give the tail its own page, in case we need extra space in the
> +	 * head when wrapping:
> +	 *
> +	 * call_allocate() allocates twice the slack space required
> +	 * by the authentication flavor to rq_callsize.
> +	 * For GSS, slack is GSS_CRED_SLACK.
> +	 */
>  	if (snd_buf->page_len || snd_buf->tail[0].iov_len) {
>  		tmp = page_address(rqstp->rq_enc_pages[rqstp->rq_enc_pages_num - 1]);
>  		memcpy(tmp, snd_buf->tail[0].iov_base, snd_buf->tail[0].iov_len);
>  		snd_buf->tail[0].iov_base = tmp;
>  	}
>  	maj_stat = gss_wrap(ctx->gc_gss_ctx, offset, snd_buf, inpages);
> -	/* RPC_SLACK_SPACE should prevent this ever happening: */
> +	/* slack space should prevent this ever happening: */
>  	BUG_ON(snd_buf->len > snd_buf->buflen);
>  	status = -EIO;
>  	/* We're assuming that when GSS_S_CONTEXT_EXPIRED, the encryption was
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index c93fca2..d0f3371 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -326,3 +326,59 @@ gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
>  
>  	return xdr_process_buf(buf, offset, buf->len - offset, decryptor, &desc);
>  }
> +
> +/*
> + * This function makes the assumption that it was ultimately called
> + * from gss_wrap().
> + *
> + * The client auth_gss code moves any existing tail data into a
> + * separate page before calling gss_wrap.
> + * The server svcauth_gss code ensures that both the head and the
> + * tail have slack space of RPC_MAX_AUTH_SIZE before calling gss_wrap.
> + *
> + * Even with that guarantee, this function may be called more than
> + * once in the processing of gss_wrap().  The best we can do is
> + * verify at compile-time (see GSS_KRB5_SLACK_CHECK) that the
> + * largest expected shift will fit within RPC_MAX_AUTH_SIZE.
> + * At run-time we can verify that a single invocation of this
> + * function doesn't attempt to use more the RPC_MAX_AUTH_SIZE.
> + */
> +
> +int
> +shift_head_data(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen)
> +{
> +	u8 *p;
> +
> +	if (shiftlen == 0)
> +		return 0;
> +
> +	GSS_KRB5_SLACK_CHECK;
> +	BUG_ON(shiftlen > RPC_MAX_AUTH_SIZE);
> +
> +	/*
> +	 * If there is a tail, and it shares a page with the head,
> +	 * make sure we don't clobber the tail.  This is a just a
> +	 * defensive check.
> +	 */
> +	if (buf->tail[0].iov_base != NULL) {
> +		if ((((long)buf->tail[0].iov_base >> PAGE_CACHE_SHIFT) ==
> +		     ((long)buf->head[0].iov_base >> PAGE_CACHE_SHIFT)) &&
> +		    buf->tail[0].iov_base - buf->head[0].iov_base < shiftlen) {
> +			dprintk("%s: collision: head %p:%zu, tail %p:%zu, "
> +				"shiftlen %u\n",
> +				__func__, buf->head[0].iov_base,
> +				buf->head[0].iov_len, buf->tail[0].iov_base,
> +				buf->tail[0].iov_len, shiftlen);
> +			return 1;
> +		}
> +	}
> +
> +	p = buf->head[0].iov_base + base;
> +
> +	memmove(p + shiftlen, p, buf->head[0].iov_len - base);
> +
> +	buf->head[0].iov_len += shiftlen;
> +	buf->len += shiftlen;
> +
> +	return 0;
> +}
> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> index 283cb25..e809571 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> @@ -130,6 +130,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
>  
>  	dprintk("RPC:       gss_wrap_kerberos\n");
>  
> +	GSS_KRB5_SLACK_CHECK;
>  	now = get_seconds();
>  
>  	blocksize = crypto_blkcipher_blocksize(kctx->enc);
> @@ -142,11 +143,9 @@ gss_wrap_kerberos(struct gss_ctx *ctx, int offset,
>  
>  	ptr = buf->head[0].iov_base + offset;
>  	/* shift data to make room for header. */
> +	shift_head_data(buf, offset, headlen);
> +
>  	/* XXX Would be cleverer to encrypt while copying. */
> -	/* XXX bounds checking, slack, etc. */
> -	memmove(ptr + headlen, ptr, buf->head[0].iov_len - offset);
> -	buf->head[0].iov_len += headlen;
> -	buf->len += headlen;
>  	BUG_ON((buf->len - offset - headlen) % blocksize);
>  
>  	g_make_token_header(&kctx->mech_used,
> diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
> index bce9d52..3cfc197 100644
> --- a/net/sunrpc/auth_gss/gss_mech_switch.c
> +++ b/net/sunrpc/auth_gss/gss_mech_switch.c
> @@ -285,6 +285,20 @@ gss_verify_mic(struct gss_ctx		*context_handle,
>  				 mic_token);
>  }
>  
> +/*
> + * This function is called from both the client and server code.
> + * Each makes guarantees about how much "slack" space is available
> + * for the underlying function in "buf"'s head and tail while
> + * performing the wrap.
> + *
> + * The client and server code allocate RPC_MAX_AUTH_SIZE extra
> + * space in both the head and tail which is available for use by
> + * the wrap function.
> + *
> + * Underlying functions should verify they do not use more than
> + * RPC_MAX_AUTH_SIZE of extra space in either the head or tail
> + * when performing the wrap.
> + */
>  u32
>  gss_wrap(struct gss_ctx	*ctx_id,
>  	 int		offset,
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 5905d56..675adeb 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1287,6 +1287,14 @@ svcauth_gss_wrap_resp_priv(struct svc_rqst *rqstp)
>  	inpages = resbuf->pages;
>  	/* XXX: Would be better to write some xdr helper functions for
>  	 * nfs{2,3,4}xdr.c that place the data right, instead of copying: */
> +
> +	/*
> +	 * If there is currently tail data, make sure there is
> +	 * room for the head, tail, and 2 * RPC_MAX_AUTH_SIZE in
> +	 * the page, and move the current tail data such that
> +	 * there is RPC_MAX_AUTH_SIZE slack space available in
> +	 * both the head and tail.
> +	 */
>  	if (resbuf->tail[0].iov_base) {
>  		BUG_ON(resbuf->tail[0].iov_base >= resbuf->head[0].iov_base
>  							+ PAGE_SIZE);
> @@ -1299,6 +1307,13 @@ svcauth_gss_wrap_resp_priv(struct svc_rqst *rqstp)
>  			resbuf->tail[0].iov_len);
>  		resbuf->tail[0].iov_base += RPC_MAX_AUTH_SIZE;
>  	}
> +	/*
> +	 * If there is no current tail data, make sure there is
> +	 * room for the head data, and 2 * RPC_MAX_AUTH_SIZE in the
> +	 * allotted page, and set up tail information such that there
> +	 * is RPC_MAX_AUTH_SIZE slack space available in both the
> +	 * head and tail.
> +	 */
>  	if (resbuf->tail[0].iov_base == NULL) {
>  		if (resbuf->head[0].iov_len + 2*RPC_MAX_AUTH_SIZE > PAGE_SIZE)
>  			return -ENOMEM;
> 
