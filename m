Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from permutation-city.suchdamage.org ([69.25.196.28]:52218 "EHLO
	mail.suchdamage.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751871Ab1FIOhz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 10:37:55 -0400
From: Sam Hartman <hartmans@debian.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Cc: Didier Raboud <odyx@debian.org>, linux-nfs@vger.kernel.org,
        629553@bugs.debian.org, 629692@bugs.debian.org
Subject: Re: libgssglue: incompatible with krb5 1.9
References: <tsl1uz57fa1.fsf@mit.edu>
	<20110609013756.GA5304@master.debian.org>
	<BANLkTikKC5jdJG0KtrKxONmnSWSTm-9iyA@mail.gmail.com>
Date: Thu, 09 Jun 2011 10:29:03 -0400
In-Reply-To: <BANLkTikKC5jdJG0KtrKxONmnSWSTm-9iyA@mail.gmail.com> (Kevin
	Coffman's message of "Thu, 9 Jun 2011 01:18:43 -0400")
Message-ID: <tsl8vtbyt74.fsf@mit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's the MIT diff that introduces the types:
commit 21479bb4df589793a4fc25aedb59d599043eb95b
Author: lhoward <lhoward@dc483132-0cff-0310-8789-dd5450dbe970>
Date:   Sun Apr 3 08:02:53 2011 +0000

    Use RFC 5587 const types for draft-josefsson-gss-capsulate APIs
    
    git-svn-id: svn://anonsvn.mit.edu/svn/krb5/trunk@24821 dc483132-0cff-0310-8789-dd5450dbe970
    (cherry picked from commit 4a46936a36f47e54134b24d7083cfd45a2d009bc)

diff --git a/src/lib/gssapi/generic/gssapi_ext.h b/src/lib/gssapi/generic/gssapi_ext.h
index a2a8bcd..31d972b 100644
--- a/src/lib/gssapi/generic/gssapi_ext.h
+++ b/src/lib/gssapi/generic/gssapi_ext.h
@@ -387,22 +387,22 @@ OM_uint32 KRB5_CALLCONV gss_release_any_name_mapping
 /* draft-josefsson-gss-capsulate */
 OM_uint32 KRB5_CALLCONV gss_encapsulate_token
 (
-    const gss_buffer_t, /* input_token */
-    const gss_OID,      /* token_oid */
-    const gss_buffer_t  /* output_token */
+    gss_const_buffer_t, /* input_token */
+    gss_const_OID,      /* token_oid */
+    gss_buffer_t        /* output_token */
 );
 
 OM_uint32 KRB5_CALLCONV gss_decapsulate_token
 (
-    const gss_buffer_t, /* input_token */
-    const gss_OID,      /* token_oid */
+    gss_const_buffer_t, /* input_token */
+    gss_const_OID,      /* token_oid */
     gss_buffer_t        /* output_token */
 );
 
 int KRB5_CALLCONV gss_oid_equal
 (
-    const gss_OID,      /* first_oid */
-    const gss_OID       /* second_oid */
+    gss_const_OID,      /* first_oid */
+    gss_const_OID       /* second_oid */
 );
 
 #ifdef __cplusplus
diff --git a/src/lib/gssapi/mechglue/g_decapsulate_token.c b/src/lib/gssapi/mechglue/g_decapsulate_token.c
index a12d8f7..42b9e07 100644
--- a/src/lib/gssapi/mechglue/g_decapsulate_token.c
+++ b/src/lib/gssapi/mechglue/g_decapsulate_token.c
@@ -33,8 +33,8 @@
 #include "mglueP.h"
 
 OM_uint32
-gss_decapsulate_token(const gss_buffer_t input_token,
-                      const gss_OID token_oid,
+gss_decapsulate_token(gss_const_buffer_t input_token,
+                      gss_const_OID token_oid,
                       gss_buffer_t output_token)
 {
     OM_uint32 minor;
diff --git a/src/lib/gssapi/mechglue/g_encapsulate_token.c b/src/lib/gssapi/mechglue/g_encapsulate_token.c
index a60c796..b26e147 100644
--- a/src/lib/gssapi/mechglue/g_encapsulate_token.c
+++ b/src/lib/gssapi/mechglue/g_encapsulate_token.c
@@ -33,8 +33,8 @@
 #include "mglueP.h"
 
 OM_uint32
-gss_encapsulate_token(const gss_buffer_t input_token,
-                      const gss_OID token_oid,
+gss_encapsulate_token(gss_const_buffer_t input_token,
+                      gss_const_OID token_oid,
                       gss_buffer_t output_token)
 {
     unsigned int tokenSize;
diff --git a/src/lib/gssapi/mechglue/g_oid_ops.c b/src/lib/gssapi/mechglue/g_oid_ops.c
index aa6d807..db3cd78 100644
--- a/src/lib/gssapi/mechglue/g_oid_ops.c
+++ b/src/lib/gssapi/mechglue/g_oid_ops.c
@@ -111,8 +111,8 @@ gssint_copy_oid_set(
 
 int
 gss_oid_equal(
-    const gss_OID first_oid,
-    const gss_OID second_oid)
+    gss_const_OID first_oid,
+    gss_const_OID second_oid)
 {
     return g_OID_equal(first_oid, second_oid);
 }
