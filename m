Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmfepo202.cox.net ([68.230.241.217]:39995 "EHLO
	eastrmfepo202.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756538Ab1DFTHS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Apr 2011 15:07:18 -0400
Message-ID: <4D9CB9E4.1090902@excfb.com>
Date: Wed, 06 Apr 2011 14:07:16 -0500
From: Tom Haynes <tdh@excfb.com>
To: Jim Rees <rees@umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Olga Kornievskaia <aglo@citi.umich.edu>, Joe Perches <joe@perches.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: rc4-hmac-md5 mount failure
References: <AANLkTikRJad_vR1qxL1Wr4AO0OfP32oCYj4X0cTnVwv+@mail.gmail.com> <1302110267.7020.8.camel@lade.trondhjem.org> <20110406173631.GA8741@merit.edu>
In-Reply-To: <20110406173631.GA8741@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 4/6/11 12:36 PM, Jim Rees wrote:
> Trond Myklebust wrote:
>
>    >  diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_
>    >  index 0326446..8a4d083c 100644
>    >  --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
>    >  +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
>    >  @@ -422,7 +422,7 @@ static int
>    >   context_derive_keys_rc4(struct krb5_ctx *ctx)
>    >   {
>    >         struct crypto_hash *hmac;
>    >  -       char sigkeyconstant[] = "signaturekey";
>    >  +       static const char sigkeyconstant[] = "signaturekey";
>    >         int slen = strlen(sigkeyconstant) + 1;  /* include null terminator */
>    >         struct hash_desc desc;
>    >         struct scatterlist sg[1];
>    >
>    >  Solution: if this commit is undone, rc4-based mount works without
>    >  issues. verified with linux and windows clients.
>
>    Hi Olga,
>
>    Thanks for the report! I'll revert this commit in upstream and the
>    stable kernels.
>
> But why does this fix it?
> --

Because it is no longer on the stack?

If whatever referenced it lived longer than the call to 
context_derive_keys_rc4(),
then it would be referencing garbage.
