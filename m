Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59838 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752090AbeC1VMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Mar 2018 17:12:18 -0400
Date: Wed, 28 Mar 2018 17:12:17 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Eric Biggers <ebiggers@google.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Michael Young <m.a.young@durham.ac.uk>, stable@vger.kernel.org
Subject: Re: [PATCH] sunrpc: remove incorrect HMAC request initialization
Message-ID: <20180328211217.GA7111@fieldses.org>
References: <20180328175722.193355-1-ebiggers@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180328175722.193355-1-ebiggers@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applying, thanks!--b.

On Wed, Mar 28, 2018 at 10:57:22AM -0700, Eric Biggers wrote:
> make_checksum_hmac_md5() is allocating an HMAC transform and doing
> crypto API calls in the following order:
> 
>     crypto_ahash_init()
>     crypto_ahash_setkey()
>     crypto_ahash_digest()
> 
> This is wrong because it makes no sense to init() the request before a
> key has been set, given that the initial state depends on the key.  And
> digest() is short for init() + update() + final(), so in this case
> there's no need to explicitly call init() at all.
> 
> Before commit 9fa68f620041 ("crypto: hash - prevent using keyed hashes
> without setting key") the extra init() had no real effect, at least for
> the software HMAC implementation.  (There are also hardware drivers that
> implement HMAC-MD5, and it's not immediately obvious how gracefully they
> handle init() before setkey().)  But now the crypto API detects this
> incorrect initialization and returns -ENOKEY.  This is breaking NFS
> mounts in some cases.
> 
> Fix it by removing the incorrect call to crypto_ahash_init().
> 
> Reported-by: Michael Young <m.a.young@durham.ac.uk>
> Fixes: 9fa68f620041 ("crypto: hash - prevent using keyed hashes without setting key")
> Fixes: fffdaef2eb4a ("gss_krb5: Add support for rc4-hmac encryption")
> Cc: stable@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  net/sunrpc/auth_gss/gss_krb5_crypto.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index 12649c9fedab..8654494b4d0a 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -237,9 +237,6 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
>  
>  	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
>  
> -	err = crypto_ahash_init(req);
> -	if (err)
> -		goto out;
>  	err = crypto_ahash_setkey(hmac_md5, cksumkey, kctx->gk5e->keylength);
>  	if (err)
>  		goto out;
> -- 
> 2.17.0.rc1.321.gba9d0f2565-goog
