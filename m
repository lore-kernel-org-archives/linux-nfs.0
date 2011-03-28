Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53258 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257Ab1C1U4w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 16:56:52 -0400
Received: by iwn34 with SMTP id 34so4081951iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2011 13:56:52 -0700 (PDT)
Date: Mon, 28 Mar 2011 16:56:51 -0400
Message-ID: <AANLkTikRJad_vR1qxL1Wr4AO0OfP32oCYj4X0cTnVwv+@mail.gmail.com>
Subject: rc4-hmac-md5 mount failure
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I apologize I have posted an incomplete problem/solution and possibly
to the wrong thread.

Problem: linux client mounting linux server using rc4-hmac-md5
enctype. gssd fails with create a context after receiving a reply from
the server.

Diagnose: putting printout statements in the server kernel and
kerberos libraries revealed that client and server derived different
integrity keys.

Server kernel code was at fault due the the commit

[aglo@skydive linux-pnfs]$ git show 411b5e05617593efebc06241dbc56f42150f2abe
commit 411b5e05617593efebc06241dbc56f42150f2abe
Author: Joe Perches <joe@perches.com>
Date:   Mon Sep 13 12:48:01 2010 -0700

   net/sunrpc: Use static const char arrays

   Signed-off-by: Joe Perches <joe@perches.com>
   Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_
index 0326446..8a4d083c 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -422,7 +422,7 @@ static int
 context_derive_keys_rc4(struct krb5_ctx *ctx)
 {
       struct crypto_hash *hmac;
-       char sigkeyconstant[] = "signaturekey";
+       static const char sigkeyconstant[] = "signaturekey";
       int slen = strlen(sigkeyconstant) + 1;  /* include null terminator */
       struct hash_desc desc;
       struct scatterlist sg[1];

Solution: if this commit is undone, rc4-based mount works without
issues. verified with linux and windows clients.
