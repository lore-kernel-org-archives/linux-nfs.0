Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54436 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864AbcDCD7F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Apr 2016 23:59:05 -0400
Date: Sat, 2 Apr 2016 23:59:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-nfs@vger.kernel.org, linux-crypto@vger.kernel.org
Subject: Re: nfs/krb5 crash on 4.6-rc1
Message-ID: <20160403035900.GB14318@fieldses.org>
References: <20160403001319.GB12588@fieldses.org>
 <20160403010952.GA25687@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160403010952.GA25687@gondor.apana.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 03, 2016 at 09:09:52AM +0800, Herbert Xu wrote:
> On Sat, Apr 02, 2016 at 08:13:19PM -0400, J. Bruce Fields wrote:
> > As of 3b5cf20c "sunrpc: Use skcipher and ahash/shash", I get a NULL
> > dereference in krb5_encrypt on an NFS server when a client attempts to
> > mount using krb5.  I haven't tried to figure out what's going on beyond
> > that....
> 
> Oops, looks like I missed a couple of set_tfm calls.

Thanks.  It's getting further now, but appears to be freezing later.
Possibly unrelated.  I'm travelling, and it'll be Monday or Wednesday
till I can take another look.

--b.

> 
> ---8<--
> Subject: sunrpc: Add missing skcipher_request_set_tfm calls
> 
> A couple of skcipher_request users were missing set_tfm calls which
> leads to a crash when they are called.
> 
> Fixes: 3b5cf20cf439 ("sunrpc: Use skcipher and ahash/shash")
> Reported-by: J. Bruce Fields <bfields@fieldses.org>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index d94a8e1..ccc59aa 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -78,6 +78,7 @@ krb5_encrypt(
>  	memcpy(out, in, length);
>  	sg_init_one(sg, out, length);
>  
> +	skcipher_request_set_tfm(req, tfm);
>  	skcipher_request_set_callback(req, 0, NULL, NULL);
>  	skcipher_request_set_crypt(req, sg, sg, length, local_iv);
>  
> @@ -115,6 +116,7 @@ krb5_decrypt(
>  	memcpy(out, in, length);
>  	sg_init_one(sg, out, length);
>  
> +	skcipher_request_set_tfm(req, tfm);
>  	skcipher_request_set_callback(req, 0, NULL, NULL);
>  	skcipher_request_set_crypt(req, sg, sg, length, local_iv);
>  
> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
