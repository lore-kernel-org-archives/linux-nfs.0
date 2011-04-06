Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57767 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537Ab1DFRS4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Apr 2011 13:18:56 -0400
Subject: Re: rc4-hmac-md5 mount failure
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Olga Kornievskaia <aglo@citi.umich.edu>, Joe Perches <joe@perches.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <AANLkTikRJad_vR1qxL1Wr4AO0OfP32oCYj4X0cTnVwv+@mail.gmail.com>
References: <AANLkTikRJad_vR1qxL1Wr4AO0OfP32oCYj4X0cTnVwv+@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Apr 2011 10:17:47 -0700
Message-ID: <1302110267.7020.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-03-28 at 16:56 -0400, Olga Kornievskaia wrote:
> I apologize I have posted an incomplete problem/solution and possibly
> to the wrong thread.
> 
> Problem: linux client mounting linux server using rc4-hmac-md5
> enctype. gssd fails with create a context after receiving a reply from
> the server.
> 
> Diagnose: putting printout statements in the server kernel and
> kerberos libraries revealed that client and server derived different
> integrity keys.
> 
> Server kernel code was at fault due the the commit
> 
> [aglo@skydive linux-pnfs]$ git show 411b5e05617593efebc06241dbc56f42150f2abe
> commit 411b5e05617593efebc06241dbc56f42150f2abe
> Author: Joe Perches <joe@perches.com>
> Date:   Mon Sep 13 12:48:01 2010 -0700
> 
>    net/sunrpc: Use static const char arrays
> 
>    Signed-off-by: Joe Perches <joe@perches.com>
>    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_
> index 0326446..8a4d083c 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
> @@ -422,7 +422,7 @@ static int
>  context_derive_keys_rc4(struct krb5_ctx *ctx)
>  {
>        struct crypto_hash *hmac;
> -       char sigkeyconstant[] = "signaturekey";
> +       static const char sigkeyconstant[] = "signaturekey";
>        int slen = strlen(sigkeyconstant) + 1;  /* include null terminator */
>        struct hash_desc desc;
>        struct scatterlist sg[1];
> 
> Solution: if this commit is undone, rc4-based mount works without
> issues. verified with linux and windows clients.

Hi Olga,

Thanks for the report! I'll revert this commit in upstream and the
stable kernels.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

