Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:58518 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737Ab3C0Bju (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 21:39:50 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1UKfLQ-0000I8-UT
	for linux-nfs@vger.kernel.org; Wed, 27 Mar 2013 02:40:05 +0100
Received: from 203.19.128.226 ([203.19.128.226])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 27 Mar 2013 02:40:04 +0100
Received: from oakad by 203.19.128.226 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 27 Mar 2013 02:40:04 +0100
To: linux-nfs@vger.kernel.org
From: Alex Dubov <oakad@yahoo.com>
Subject: Re: Allow building libtirpc directly against GSSAPI
Date: Wed, 27 Mar 2013 01:14:52 +0000 (UTC)
Message-ID: <loom.20130327T020327-984@post.gmane.org>
References: <1364308888.2660.119.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simo Sorce <simo@...> writes:

Hi,

If you've already mentioned the gssglue issue, there's a related one, namely, 
building nfs-utils against Heimdal.

Currently, the out of the box Heimdal support is broken, and most of the 
breakage comes out of the gssglue.

I'm looking at fixing nfs-utils to support Heimdal properly - currently my only 
remaining problem is to fix the configure and pkg-config scripts in both nfs-
utils and libgssglue (if this one is not dropped for good, and I personally 
think it should be; small, icky library on no real use).

Here is the code patch I'm using for my Heimdal build:

diff -ur nfs-utils-1.2.6.orig/utils/gssd/context_lucid.c nfs-utils-
1.2.6/utils/gssd/context_lucid.c
--- nfs-utils-1.2.6.orig/utils/gssd/context_lucid.c	2012-05-15 
00:40:52.000000000 +1000
+++ nfs-utils-1.2.6/utils/gssd/context_lucid.c	2013-03-26 19:03:10.096586556 
+1100
@@ -266,10 +266,10 @@
 	int retcode = 0;
 
 	printerr(2, "DEBUG: %s: lucid version!\n", __FUNCTION__);
-	maj_stat = gss_export_lucid_sec_context(&min_stat, &ctx,
-						1, &return_ctx);
+	maj_stat = gss_krb5_export_lucid_sec_context(&min_stat, &ctx,
+	- 						1, &return_ctx);
 	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_export_lucid_sec_context",
+		pgsserr("gss_krb5_export_lucid_sec_context",
 			maj_stat, min_stat, &krb5oid);
 		goto out_err;
 	}
@@ -302,9 +302,9 @@
 	else
 		retcode = prepare_krb5_rfc4121_buffer(lctx, buf, endtime);
 
-	maj_stat = gss_free_lucid_sec_context(&min_stat, ctx, return_ctx);
+	maj_stat = gss_krb5_free_lucid_sec_context(&min_stat, ctx);
 	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_free_lucid_sec_context",
+		pgsserr("gss_krb5_free_lucid_sec_context",
 			maj_stat, min_stat, &krb5oid);
 		printerr(0, "WARN: failed to free lucid sec context\n");
 	}
diff -ur nfs-utils-1.2.6.orig/utils/gssd/krb5_util.c nfs-utils-
1.2.6/utils/gssd/krb5_util.c
--- nfs-utils-1.2.6.orig/utils/gssd/krb5_util.c	2012-05-15 00:40:52.000000000 
+1000
+++ nfs-utils-1.2.6/utils/gssd/krb5_util.c	2013-03-26 19:18:40.204045067 
+1100
@@ -115,7 +115,7 @@
 #include <errno.h>
 #include <time.h>
 #include <gssapi/gssapi.h>
-#ifdef USE_PRIVATE_KRB5_FUNCTIONS
+#if defined(USE_PRIVATE_KRB5_FUNCTIONS) || defined(HAVE_HEIMDAL)
 #include <gssapi/gssapi_krb5.h>
 #endif
 #include <krb5.h>
@@ -936,9 +936,38 @@
 {
 	krb5_error_code ret;
 	krb5_creds creds;
-	krb5_cc_cursor cur;
 	int found = 0;
 
+#if defined (HAVE_HEIMDAL)
+	krb5_creds pattern;
+	krb5_const_realm client_realm;
+
+	krb5_cc_clear_mcred(&pattern);
+
+	client_realm = krb5_principal_get_realm(context, principal);
+
+	ret = krb5_make_principal(context, &pattern.server,
+				  client_realm, KRB5_TGS_NAME, client_realm,
+				  NULL);
+	if (ret)
+	  krb5_err(context, 1, ret, "krb5_make_principal");
+	pattern.client = principal;
+
+	ret = krb5_cc_retrieve_cred(context, ccache, 0, &pattern, &creds);
+	krb5_free_principal(context, pattern.server);
+	if (ret) {
+	  if (ret == KRB5_CC_END)
+            return 1;
+	  krb5_err(context, 1, ret, "krb5_cc_retrieve_cred");
+	}
+
+	found = creds.times.endtime > time(NULL);
+
+	krb5_free_cred_contents (context, &creds);
+#else
+	krb5_cc_cursor cur;
+
+
 	ret = krb5_cc_start_seq_get(context, ccache, &cur);
 	if (ret) 
 		return 0;
@@ -958,7 +987,7 @@
 		krb5_free_cred_contents(context, &creds);
 	}
 	krb5_cc_end_seq_get(context, ccache, &cur);
-
+#endif
 	return found;
 }
 
@@ -1278,7 +1307,7 @@
 	return strdup(error_message(code));
 #else
 	if (context != NULL)
-		return strdup(krb5_get_err_text(context, code));
+		return strdup(krb5_get_error_message(context, code));
 	else
 		return strdup(error_message(code));
 #endif
@@ -1347,11 +1376,11 @@
 	 * list of supported enctypes, use local default here.
 	 */
 	if (krb5_enctypes == NULL || limit_to_legacy_enctypes)
-		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
-					&krb5oid, num_enctypes, enctypes);
+		maj_stat = gss_krb5_set_allowable_enctypes(&min_stat, credh,
+					num_enctypes, enctypes);
 	else
-		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
-					&krb5oid, num_krb5_enctypes, 
krb5_enctypes);
+		maj_stat = gss_krb5_set_allowable_enctypes(&min_stat, credh,
+					num_krb5_enctypes, krb5_enctypes);
 
 	if (maj_stat != GSS_S_COMPLETE) {
 		pgsserr("gss_set_allowable_enctypes",


