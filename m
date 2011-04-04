Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753678Ab1DDMMi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Apr 2011 08:12:38 -0400
Message-ID: <4D99B5B3.8040701@RedHat.com>
Date: Mon, 04 Apr 2011 08:12:35 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Olga Kornievskaia <aglo@citi.umich.edu>
CC: linux-nfs <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: rc4-hmac-md5 mount failure
References: <AANLkTikRJad_vR1qxL1Wr4AO0OfP32oCYj4X0cTnVwv+@mail.gmail.com>
In-Reply-To: <AANLkTikRJad_vR1qxL1Wr4AO0OfP32oCYj4X0cTnVwv+@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On 03/28/2011 04:56 PM, Olga Kornievskaia wrote:
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

With https://bugzilla.redhat.com/show_bug.cgi?id=690754
I can verify that commit 411b5e0 does indeed cause 
mount failure when using  -o sec=krb5 and reverting this
commit does fix the problem... 

steved.

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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
