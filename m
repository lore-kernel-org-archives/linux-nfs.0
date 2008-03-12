From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 05/19] Correct grammer/typos in dprintks
Date: Wed, 12 Mar 2008 12:38:11 -0400
Message-ID: <20080312163811.GE10015@fieldses.org>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu> <20080221184412.19195.93743.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42120 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbYCLQiM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2008 12:38:12 -0400
In-Reply-To: <20080221184412.19195.93743.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2008 at 01:44:12PM -0500, Kevin Coffman wrote:
> cleanup:  Fix grammer/typos to use "too" instead of "to"

Thanks; applied.--b.

> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> ---
> 
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index 0dd7923..1d52308 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -66,8 +66,8 @@ krb5_encrypt(
>  		goto out;
>  
>  	if (crypto_blkcipher_ivsize(tfm) > 16) {
> -		dprintk("RPC:       gss_k5encrypt: tfm iv size to large %d\n",
> -			 crypto_blkcipher_ivsize(tfm));
> +		dprintk("RPC:       gss_k5encrypt: tfm iv size too large %d\n",
> +			crypto_blkcipher_ivsize(tfm));
>  		goto out;
>  	}
>  
> @@ -102,7 +102,7 @@ krb5_decrypt(
>  		goto out;
>  
>  	if (crypto_blkcipher_ivsize(tfm) > 16) {
> -		dprintk("RPC:       gss_k5decrypt: tfm iv size to large %d\n",
> +		dprintk("RPC:       gss_k5decrypt: tfm iv size too large %d\n",
>  			crypto_blkcipher_ivsize(tfm));
>  		goto out;
>  	}
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
