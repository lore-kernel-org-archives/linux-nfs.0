From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [enctypes round 2: PATCH 02/26] gss_krb5: move gss_krb5_crypto
	into the krb5 module
Date: Fri, 2 May 2008 16:15:16 -0400
Message-ID: <20080502201516.GH21918@fieldses.org>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu> <20080430164558.16010.1610.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58211 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762017AbYEBUPR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 16:15:17 -0400
In-Reply-To: <20080430164558.16010.1610.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 30, 2008 at 12:45:58PM -0400, Kevin Coffman wrote:
> The gss_krb5_crypto.o object belongs in the rpcsec_gss_krb5 module.
> Also, there is no need to export symbols from gss_krb5_crypto.c

Thanks; applied.--b.

> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> ---
> 
>  net/sunrpc/auth_gss/Makefile          |    4 ++--
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |   10 ----------
>  2 files changed, 2 insertions(+), 12 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/Makefile b/net/sunrpc/auth_gss/Makefile
> index f3431a7..4de8bcf 100644
> --- a/net/sunrpc/auth_gss/Makefile
> +++ b/net/sunrpc/auth_gss/Makefile
> @@ -5,12 +5,12 @@
>  obj-$(CONFIG_SUNRPC_GSS) += auth_rpcgss.o
>  
>  auth_rpcgss-objs := auth_gss.o gss_generic_token.o \
> -	gss_mech_switch.o svcauth_gss.o gss_krb5_crypto.o
> +	gss_mech_switch.o svcauth_gss.o
>  
>  obj-$(CONFIG_RPCSEC_GSS_KRB5) += rpcsec_gss_krb5.o
>  
>  rpcsec_gss_krb5-objs := gss_krb5_mech.o gss_krb5_seal.o gss_krb5_unseal.o \
> -	gss_krb5_seqnum.o gss_krb5_wrap.o
> +	gss_krb5_seqnum.o gss_krb5_wrap.o gss_krb5_crypto.o
>  
>  obj-$(CONFIG_RPCSEC_GSS_SPKM3) += rpcsec_gss_spkm3.o
>  
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index 1d52308..c93fca2 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -83,8 +83,6 @@ out:
>  	return ret;
>  }
>  
> -EXPORT_SYMBOL(krb5_encrypt);
> -
>  u32
>  krb5_decrypt(
>       struct crypto_blkcipher *tfm,
> @@ -118,8 +116,6 @@ out:
>  	return ret;
>  }
>  
> -EXPORT_SYMBOL(krb5_decrypt);
> -
>  static int
>  checksummer(struct scatterlist *sg, void *data)
>  {
> @@ -161,8 +157,6 @@ out:
>  	return err ? GSS_S_FAILURE : 0;
>  }
>  
> -EXPORT_SYMBOL(make_checksum);
> -
>  struct encryptor_desc {
>  	u8 iv[8]; /* XXX hard-coded blocksize */
>  	struct blkcipher_desc desc;
> @@ -262,8 +256,6 @@ gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
>  	return ret;
>  }
>  
> -EXPORT_SYMBOL(gss_encrypt_xdr_buf);
> -
>  struct decryptor_desc {
>  	u8 iv[8]; /* XXX hard-coded blocksize */
>  	struct blkcipher_desc desc;
> @@ -334,5 +326,3 @@ gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
>  
>  	return xdr_process_buf(buf, offset, buf->len - offset, decryptor, &desc);
>  }
> -
> -EXPORT_SYMBOL(gss_decrypt_xdr_buf);
> 
