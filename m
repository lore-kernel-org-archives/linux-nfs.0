Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54991 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424AbaAVSMp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jan 2014 13:12:45 -0500
Date: Wed, 22 Jan 2014 13:12:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Luis Henriques <luis.henriques@canonical.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] gss_krb5: use lcm from kernel lib
Message-ID: <20140122181242.GB13704@fieldses.org>
References: <20140119215040.GA7978@hercules>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140119215040.GA7978@hercules>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 19, 2014 at 09:50:51PM +0000, Luis Henriques wrote:
> Replace hardcoded lowest common multiple algorithm by the lcm()
> function in kernel lib.

Looks OK to me.  Applying for 3.14 if Trond hasn't already picked it up.

--b.

> 
> Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
> ---
>  net/sunrpc/auth_gss/gss_krb5_keys.c | 17 ++++-------------
>  1 file changed, 4 insertions(+), 13 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
> index 76e42e6..a16c5b6 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_keys.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
> @@ -59,6 +59,7 @@
>  #include <linux/crypto.h>
>  #include <linux/sunrpc/gss_krb5.h>
>  #include <linux/sunrpc/xdr.h>
> +#include <linux/lcm.h>
>  
>  #ifdef RPC_DEBUG
>  # define RPCDBG_FACILITY        RPCDBG_AUTH
> @@ -72,7 +73,7 @@
>  static void krb5_nfold(u32 inbits, const u8 *in,
>  		       u32 outbits, u8 *out)
>  {
> -	int a, b, c, lcm;
> +	unsigned long ulcm;
>  	int byte, i, msbit;
>  
>  	/* the code below is more readable if I make these bytes
> @@ -82,17 +83,7 @@ static void krb5_nfold(u32 inbits, const u8 *in,
>  	outbits >>= 3;
>  
>  	/* first compute lcm(n,k) */
> -
> -	a = outbits;
> -	b = inbits;
> -
> -	while (b != 0) {
> -		c = b;
> -		b = a%b;
> -		a = c;
> -	}
> -
> -	lcm = outbits*inbits/a;
> +	ulcm = lcm(inbits, outbits);
>  
>  	/* now do the real work */
>  
> @@ -101,7 +92,7 @@ static void krb5_nfold(u32 inbits, const u8 *in,
>  
>  	/* this will end up cycling through k lcm(k,n)/k times, which
>  	   is correct */
> -	for (i = lcm-1; i >= 0; i--) {
> +	for (i = ulcm-1; i >= 0; i--) {
>  		/* compute the msbit in k which gets added into this byte */
>  		msbit = (
>  			/* first, start with the msbit in the first,
> -- 
> 1.8.3.2
> 
> Cheers,
> --
> Luis
