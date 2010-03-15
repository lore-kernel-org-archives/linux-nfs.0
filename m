From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 13/22] gss_krb5: add support for new token formats in
 rfc4121
Date: Mon, 15 Mar 2010 12:34:46 -0400
Message-ID: <1268670886.2993.108.camel@localhost.localdomain>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
	 <1268655627-18712-14-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41562 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964955Ab0COQew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Mar 2010 12:34:52 -0400
In-Reply-To: <1268655627-18712-14-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-03-15 at 08:20 -0400, steved@redhat.com wrote: 
> From: Kevin Coffman <kwc@citi.umich.edu>
> 
> This is a step toward support for AES encryption types which are
> required to use the new token formats defined in rfc4121.
> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  include/linux/sunrpc/gss_krb5.h       |   28 ++++
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |   74 ++++++++++
>  net/sunrpc/auth_gss/gss_krb5_seal.c   |   70 +++++++++
>  net/sunrpc/auth_gss/gss_krb5_unseal.c |   61 ++++++++
>  net/sunrpc/auth_gss/gss_krb5_wrap.c   |  247 +++++++++++++++++++++++++++++++++
>  5 files changed, 480 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
> index c686fa9..c6bb014 100644
> --- a/include/linux/sunrpc/gss_krb5.h
> +++ b/include/linux/sunrpc/gss_krb5.h
> @@ -53,6 +53,8 @@
>  /* Maximum blocksize for the supported crypto algorithms */
>  #define GSS_KRB5_MAX_BLOCKSIZE  (16)
>  
> +struct krb5_ctx;
> +
>  struct gss_krb5_enctype {
>  	const u32		etype;		/* encryption (key) type */
>  	const u32		ctype;		/* checksum type */
> @@ -75,6 +77,12 @@ struct gss_krb5_enctype {
>  	u32 (*mk_key) (struct gss_krb5_enctype *gk5e,
>  		       struct xdr_netobj *in,
>  		       struct xdr_netobj *out);	/* complete key generation */
> +	u32 (*encrypt_v2) (struct krb5_ctx *kctx, u32 offset,
> +			   struct xdr_buf *buf, int ec,
> +			   struct page **pages); /* v2 encryption function */
> +	u32 (*decrypt_v2) (struct krb5_ctx *kctx, u32 offset,
> +			   struct xdr_buf *buf, u32 *headskip,
> +			   u32 *tailskip);	/* v2 decryption function */
>  };
>  
>  /* krb5_ctx flags definitions */
> @@ -112,6 +120,18 @@ extern spinlock_t krb5_seq_lock;
>  #define KG_TOK_MIC_MSG    0x0101
>  #define KG_TOK_WRAP_MSG   0x0201
>  
> +#define KG2_TOK_INITIAL     0x0101
> +#define KG2_TOK_RESPONSE    0x0202
> +#define KG2_TOK_MIC         0x0404
> +#define KG2_TOK_WRAP        0x0504
> +
> +#define KG2_TOKEN_FLAG_SENTBYACCEPTOR   0x01
> +#define KG2_TOKEN_FLAG_SEALED           0x02
> +#define KG2_TOKEN_FLAG_ACCEPTORSUBKEY   0x04
> +
> +#define KG2_RESP_FLAG_ERROR             0x0001
> +#define KG2_RESP_FLAG_DELEG_OK          0x0002
> +
>  enum sgn_alg {
>  	SGN_ALG_DES_MAC_MD5 = 0x0000,
>  	SGN_ALG_MD2_5 = 0x0001,
> @@ -136,6 +156,9 @@ enum seal_alg {
>  #define CKSUMTYPE_RSA_MD5_DES		0x0008
>  #define CKSUMTYPE_NIST_SHA		0x0009
>  #define CKSUMTYPE_HMAC_SHA1_DES3	0x000c
> +#define CKSUMTYPE_HMAC_SHA1_96_AES128   0x000f
> +#define CKSUMTYPE_HMAC_SHA1_96_AES256   0x0010
> +#define CKSUMTYPE_HMAC_MD5_ARCFOUR      -138 /* Microsoft md5 hmac cksumtype */
>  
>  /* from gssapi_err_krb5.h */
>  #define KG_CCACHE_NOMATCH                        (39756032L)
> @@ -212,6 +235,11 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
>  		struct xdr_buf *body, int body_offset, u8 *cksumkey,
>  		struct xdr_netobj *cksumout);
>  
> +u32
> +make_checksum_v2(struct krb5_ctx *, char *header, int hdrlen,
> +		 struct xdr_buf *body, int body_offset, u8 *key,
> +		 struct xdr_netobj *cksum);
> +
>  u32 gss_get_mic_kerberos(struct gss_ctx *, struct xdr_buf *,
>  		struct xdr_netobj *);
>  
> diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
> index ba86910..6f01d87 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_seal.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
> @@ -134,6 +161,46 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
>  }
>  
>  u32
> +gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
> +		struct xdr_netobj *token)
> +{
> +	char cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
> +	struct xdr_netobj cksumobj = { .len = sizeof(cksumdata),
> +				       .data = cksumdata};
> +	void *krb5_hdr;
> +	s32 now;
> +	u64 seq_send;
> +	u8 *cksumkey;
> +
> +	dprintk("RPC:       %s\n", __func__);
> +	BUG_ON(ctx == NULL);
          ^^^^^^^^^^^^^^^^^^^^

We shouldn't need a BUG_ON for this. If ctx == NULL we will Oops anyway.


> +
> +	krb5_hdr = setup_token_v2(ctx, token);
> +
> +	/* Set up the sequence number. Now 64-bits in clear
> +	 * text and w/o direction indicator */
> +	spin_lock(&krb5_seq_lock);
> +	seq_send = ctx->seq_send64++;
> +	spin_unlock(&krb5_seq_lock);
> +	*((u64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
> +
> +	if (ctx->initiate)
> +		cksumkey = ctx->initiator_sign;
> +	else
> +		cksumkey = ctx->acceptor_sign;
> +
> +	if (make_checksum_v2(ctx, krb5_hdr, GSS_KRB5_TOK_HDR_LEN,
> +			     text, 0, cksumkey, &cksumobj))
> +		return GSS_S_FAILURE;
> +
> +	memcpy(krb5_hdr + GSS_KRB5_TOK_HDR_LEN, cksumobj.data, cksumobj.len);
> +
> +	now = get_seconds();
> +
> +	return (ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE;
> +}
> +
> +u32
>  gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
>  		     struct xdr_netobj *token)
>  {
> @@ -155,6 +213,9 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
>  	case ENCTYPE_DES_CBC_RAW:
>  	case ENCTYPE_DES3_CBC_RAW:
>  		return gss_verify_mic_v1(ctx, message_buffer, read_token);
> +	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
> +	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
> +		return gss_verify_mic_v2(ctx, message_buffer, read_token);
>  	}
>  }
>  
> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> index c541d20..0c47bdd 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> @@ -342,6 +342,247 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
>  	return GSS_S_COMPLETE;
>  }
>  
> +#define TEST_ROTATE 0
> +#define TEST_EXTRA_COUNT  0
> +
> +#if TEST_ROTATE
^^^^^^^^^^^^^^^^^^^^^^^
Eh??????????????



