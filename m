Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:59442 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535Ab1DFRgd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Apr 2011 13:36:33 -0400
Date: Wed, 6 Apr 2011 13:36:31 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, Joe Perches <joe@perches.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: rc4-hmac-md5 mount failure
Message-ID: <20110406173631.GA8741@merit.edu>
References: <AANLkTikRJad_vR1qxL1Wr4AO0OfP32oCYj4X0cTnVwv+@mail.gmail.com>
 <1302110267.7020.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1302110267.7020.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

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

But why does this fix it?
