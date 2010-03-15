From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 05/22] gss_krb5: introduce encryption type framework
Date: Mon, 15 Mar 2010 12:12:58 -0400
Message-ID: <1268669578.2993.98.camel@localhost.localdomain>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
	 <1268655627-18712-6-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57553 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965237Ab0COQND (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Mar 2010 12:13:03 -0400
In-Reply-To: <1268655627-18712-6-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-03-15 at 08:20 -0400, steved@redhat.com wrote: 
> From: Kevin Coffman <kwc@citi.umich.edu>
> 
> Add enctype framework and change functions to use the generic
> values from it rather than the values hard-coded for des.
> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  include/linux/sunrpc/gss_krb5.h       |   25 +++++++++-
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |   18 ++++----
>  net/sunrpc/auth_gss/gss_krb5_mech.c   |   85 +++++++++++++++++++++++++++-----
>  net/sunrpc/auth_gss/gss_krb5_seal.c   |   49 ++++++++++++-------
>  net/sunrpc/auth_gss/gss_krb5_unseal.c |   15 ++++--
>  net/sunrpc/auth_gss/gss_krb5_wrap.c   |   79 +++++++++++++++++++++++-------
>  6 files changed, 203 insertions(+), 68 deletions(-)
> 
> diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
> index 12bd0dd..8d79c44 100644
> --- a/include/linux/sunrpc/gss_krb5.h
> +++ b/include/linux/sunrpc/gss_krb5.h
> @@ -4,7 +4,7 @@
>   *  Adapted from MIT Kerberos 5-1.2.1 lib/include/krb5.h,
>   *  lib/gssapi/krb5/gssapiP_krb5.h, and others
>   *
> - *  Copyright (c) 2000 The Regents of the University of Michigan.
> + *  Copyright (c) 2000-2008 The Regents of the University of Michigan.
>   *  All rights reserved.
>   *
>   *  Andy Adamson   <andros@umich.edu>
> @@ -36,6 +36,7 @@
>   *
>   */
>  
> +#include <linux/crypto.h>
>  #include <linux/sunrpc/auth_gss.h>
>  #include <linux/sunrpc/gss_err.h>
>  #include <linux/sunrpc/gss_asn1.h>
> @@ -46,9 +47,31 @@
>  /* Maximum blocksize for the supported crypto algorithms */
>  #define GSS_KRB5_MAX_BLOCKSIZE  (16)
>  
> +struct gss_krb5_enctype {
> +	const u32		etype;		/* encryption (key) type */
> +	const u32		ctype;		/* checksum type */
> +	const char		*name;		/* "friendly" name */
> +	const char		*encrypt_name;	/* crypto encrypt name */
> +	const char		*cksum_name;	/* crypto checksum name */
> +	const u16		signalg;	/* signing algorithm */
> +	const u16		sealalg;	/* sealing algorithm */
> +	const u32		blocksize;	/* encryption blocksize */
> +	const u32		cksumlength;	/* checksum length */
> +	const u32		keyed_cksum;	/* is it a keyed cksum? */
> +	const u32		keybytes;	/* raw key len, in bytes */
> +	const u32		keylength;	/* final key len, in bytes */
> +	u32 (*encrypt) (struct crypto_blkcipher *tfm,
> +			void *iv, void *in, void *out,
> +			int length);		/* encryption function */
> +	u32 (*decrypt) (struct crypto_blkcipher *tfm,
> +			void *iv, void *in, void *out,
> +			int length);		/* decryption function */
> +};
> +
>  struct krb5_ctx {
>  	int			initiate; /* 1 = initiating, 0 = accepting */
>  	u32			enctype;
> +	struct gss_krb5_enctype *gk5e;		/* enctype-specific info */
         ^^^^^^^^
Should that be a 'const struct gss_krb5_enctype *'?

> 	struct crypto_blkcipher	*enc;
>  	struct crypto_blkcipher	*seq;
>  	s32			endtime;
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index d0f3371..d3025aa 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -1,7 +1,7 @@
>  /*
>   *  linux/net/sunrpc/gss_krb5_crypto.c
>   *
> - *  Copyright (c) 2000 The Regents of the University of Michigan.
> + *  Copyright (c) 2000-2008 The Regents of the University of Michigan.
>   *  All rights reserved.
>   *
>   *  Andy Adamson   <andros@umich.edu>
> @@ -59,13 +59,13 @@ krb5_encrypt(
>  {
>  	u32 ret = -EINVAL;
>  	struct scatterlist sg[1];
> -	u8 local_iv[16] = {0};
> +	u8 local_iv[GSS_KRB5_MAX_BLOCKSIZE] = {0};
>  	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
>  
>  	if (length % crypto_blkcipher_blocksize(tfm) != 0)
>  		goto out;
>  
> -	if (crypto_blkcipher_ivsize(tfm) > 16) {
> +	if (crypto_blkcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
>  		dprintk("RPC:       gss_k5encrypt: tfm iv size too large %d\n",
>  			crypto_blkcipher_ivsize(tfm));
>  		goto out;
> @@ -93,13 +93,13 @@ krb5_decrypt(
>  {
>  	u32 ret = -EINVAL;
>  	struct scatterlist sg[1];
> -	u8 local_iv[16] = {0};
> +	u8 local_iv[GSS_KRB5_MAX_BLOCKSIZE] = {0};
>  	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
>  
>  	if (length % crypto_blkcipher_blocksize(tfm) != 0)
>  		goto out;
>  
> -	if (crypto_blkcipher_ivsize(tfm) > 16) {
> +	if (crypto_blkcipher_ivsize(tfm) > GSS_KRB5_MAX_BLOCKSIZE) {
>  		dprintk("RPC:       gss_k5decrypt: tfm iv size too large %d\n",
>  			crypto_blkcipher_ivsize(tfm));
>  		goto out;
> @@ -158,7 +158,7 @@ out:
>  }
>  
>  struct encryptor_desc {
> -	u8 iv[8]; /* XXX hard-coded blocksize */
> +	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
>  	struct blkcipher_desc desc;
>  	int pos;
>  	struct xdr_buf *outbuf;
> @@ -199,7 +199,7 @@ encryptor(struct scatterlist *sg, void *data)
>  	desc->fraglen += sg->length;
>  	desc->pos += sg->length;
>  
> -	fraglen = thislen & 7; /* XXX hardcoded blocksize */
> +	fraglen = thislen & (crypto_blkcipher_blocksize(desc->desc.tfm) - 1);
>  	thislen -= fraglen;
>  
>  	if (thislen == 0)
> @@ -257,7 +257,7 @@ gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
>  }
>  
>  struct decryptor_desc {
> -	u8 iv[8]; /* XXX hard-coded blocksize */
> +	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
>  	struct blkcipher_desc desc;
>  	struct scatterlist frags[4];
>  	int fragno;
> @@ -279,7 +279,7 @@ decryptor(struct scatterlist *sg, void *data)
>  	desc->fragno++;
>  	desc->fraglen += sg->length;
>  
> -	fraglen = thislen & 7; /* XXX hardcoded blocksize */
> +	fraglen = thislen & (crypto_blkcipher_blocksize(desc->desc.tfm) - 1);
>  	thislen -= fraglen;
>  
>  	if (thislen == 0)
> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
> index cb01795..001cb6b 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
> @@ -1,7 +1,7 @@
>  /*
>   *  linux/net/sunrpc/gss_krb5_mech.c
>   *
> - *  Copyright (c) 2001 The Regents of the University of Michigan.
> + *  Copyright (c) 2001-2008 The Regents of the University of Michigan.
>   *  All rights reserved.
>   *
>   *  Andy Adamson <andros@umich.edu>
> @@ -48,6 +48,49 @@
>  # define RPCDBG_FACILITY	RPCDBG_AUTH
>  #endif
>  
> +static struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {

static const.... ?

> +	/*
> +	 * DES (All DES enctypes are mapped to the same gss functionality)
> +	 */
> +	{
> +	  .etype = ENCTYPE_DES_CBC_RAW,
> +	  .ctype = CKSUMTYPE_RSA_MD5,
> +	  .name = "des-cbc-crc",
> +	  .encrypt_name = "cbc(des)",
> +	  .cksum_name = "md5",
> +	  .encrypt = krb5_encrypt,
> +	  .decrypt = krb5_decrypt,
> +	  .signalg = SGN_ALG_DES_MAC_MD5,
> +	  .sealalg = SEAL_ALG_DES,
> +	  .keybytes = 7,
> +	  .keylength = 8,
> +	  .blocksize = 8,
> +	  .cksumlength = 8,
> +	},
> +};
> +
> +static int num_supported_enctypes = ARRAY_SIZE(supported_gss_krb5_enctypes);
         const...


> +
> +static int
> +supported_gss_krb5_enctype(int etype)
> +{
> +	int i;
> +	for (i = 0; i < num_supported_enctypes; i++)
> +		if (supported_gss_krb5_enctypes[i].etype == etype)
> +			return 1;
> +	return 0;
> +}
> +
> +static struct gss_krb5_enctype *
> +get_gss_krb5_enctype(int etype)
> +{
> +	int i;
> +	for (i = 0; i < num_supported_enctypes; i++)
> +		if (supported_gss_krb5_enctypes[i].etype == etype)
> +			return &supported_gss_krb5_enctypes[i];
> +	return NULL;
> +}
> +
>  static const void *
>  simple_get_bytes(const void *p, const void *end, void *res, int len)
>  {


