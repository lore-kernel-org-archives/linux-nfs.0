Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:58470 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183Ab3C0OUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Mar 2013 10:20:32 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1UKrDf-0002Z9-8s
	for linux-nfs@vger.kernel.org; Wed, 27 Mar 2013 15:20:52 +0100
Received: from 60-241-78-133.static.tpgi.com.au ([60.241.78.133])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 27 Mar 2013 15:20:51 +0100
Received: from oakad by 60-241-78-133.static.tpgi.com.au with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 27 Mar 2013 15:20:51 +0100
To: linux-nfs@vger.kernel.org
From: Alex Dubov <oakad@yahoo.com>
Subject: [PATCH] gssd: fix build against Heimdal and remove dependency on  libgssglue
Date: Wed, 27 Mar 2013 14:20:08 +0000 (UTC)
Message-ID: <loom.20130327T151933-617@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a preliminary patch, aiming to enable a clean build of gssd
on systems with Heimdal kerberos flavour. A major part of Heimdal
breakage until now was caused by problems with gssglue. Now that
libtirpc can be build independently from libgssglue, why not gssd?

Unfortunately, I could not test this patch againts mit-krb5, hopefully
somebody can give me a hand here.

Signed-off-by: Alex Dubov <oakad@yahoo.com>
---
 aclocal/kerberos5.m4       |    5 ++-
 aclocal/rpcsec_vers.m4     |    2 +-
 utils/gssd/context_lucid.c |   10 ++++----
 utils/gssd/krb5_util.c     |   45 ++++++++++++++++++++++++++++++++++++-------
 utils/gssd/svcgssd_krb5.c  |    2 +-
 5 files changed, 47 insertions(+), 17 deletions(-)

diff --git a/aclocal/kerberos5.m4 b/aclocal/kerberos5.m4
index 7574e2d..76914d6 100644
--- a/aclocal/kerberos5.m4
+++ b/aclocal/kerberos5.m4
@@ -54,9 +54,10 @@ AC_DEFUN([AC_KERBEROS_V5],[
          break
       dnl The following ugly hack brought on by the split installation
       dnl of Heimdal Kerberos on SuSe
-      elif test \( -f $dir/include/heim_err.h -o\
+      elif test \( \( -f $dir/include/heim_err.h -o\
       		 -f $dir/include/heimdal/heim_err.h \) -a \
-                -f $dir/lib/libroken.a; then
+                 \( -f $dir/lib/libroken.a -o\
+                 -f $dir/lib/libroken.so \) \) ; then
          AC_DEFINE(HAVE_HEIMDAL, 1, [Define this if you have Heimdal Kerberos
libraries])
          KRBDIR="$dir"
          gssapi_lib=gssapi
diff --git a/aclocal/rpcsec_vers.m4 b/aclocal/rpcsec_vers.m4
index 8218372..9cf7556 100644
--- a/aclocal/rpcsec_vers.m4
+++ b/aclocal/rpcsec_vers.m4
@@ -1,7 +1,7 @@
 dnl Checks librpcsec version
 AC_DEFUN([AC_RPCSEC_VERSION], [
 
-  PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.3])
+#  PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.3])
 
   dnl TI-RPC replaces librpcsecgss
   if test "$enable_tirpc" = no; then
diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index 64146d7..82171da 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -266,10 +266,10 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf,
int32_t *endtime)
 	int retcode = 0;
 
 	printerr(2, "DEBUG: %s: lucid version!\n", __FUNCTION__);
-	maj_stat = gss_export_lucid_sec_context(&min_stat, &ctx,
-						1, &return_ctx);
+	maj_stat = gss_krb5_export_lucid_sec_context(&min_stat, &ctx,
+							1, &return_ctx);
 	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_export_lucid_sec_context",
+		pgsserr("gss_krb5_export_lucid_sec_context",
 			maj_stat, min_stat, &krb5oid);
 		goto out_err;
 	}
@@ -302,9 +302,9 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf,
int32_t *endtime)
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
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 20b55b3..958ed57 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -115,7 +115,7 @@
 #include <errno.h>
 #include <time.h>
 #include <gssapi/gssapi.h>
-#ifdef USE_PRIVATE_KRB5_FUNCTIONS
+#if defined(USE_PRIVATE_KRB5_FUNCTIONS) || defined(HAVE_HEIMDAL)
 #include <gssapi/gssapi_krb5.h>
 #endif
 #include <krb5.h>
@@ -958,9 +958,38 @@ check_for_tgt(krb5_context context, krb5_ccache ccache,
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
@@ -980,7 +1009,7 @@ check_for_tgt(krb5_context context, krb5_ccache ccache,
 		krb5_free_cred_contents(context, &creds);
 	}
 	krb5_cc_end_seq_get(context, ccache, &cur);
-
+#endif
 	return found;
 }
 
@@ -1328,7 +1357,7 @@ gssd_k5_err_msg(krb5_context context, krb5_error_code code)
 	return strdup(error_message(code));
 #else
 	if (context != NULL)
-		return strdup(krb5_get_err_text(context, code));
+		return strdup(krb5_get_error_message(context, code));
 	else
 		return strdup(error_message(code));
 #endif
@@ -1397,11 +1426,11 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec)
 	 * list of supported enctypes, use local default here.
 	 */
 	if (krb5_enctypes == NULL || limit_to_legacy_enctypes)
-		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
-					&krb5oid, num_enctypes, enctypes);
+		maj_stat = gss_krb5_set_allowable_enctypes(&min_stat, credh,
+					num_enctypes, enctypes);
 	else
-		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
-					&krb5oid, num_krb5_enctypes, krb5_enctypes);
+		maj_stat = gss_krb5_set_allowable_enctypes(&min_stat, credh,
+					num_krb5_enctypes, krb5_enctypes);
 
 	if (maj_stat != GSS_S_COMPLETE) {
 		pgsserr("gss_set_allowable_enctypes",
diff --git a/utils/gssd/svcgssd_krb5.c b/utils/gssd/svcgssd_krb5.c
index 1d44d34..3b10bde 100644
--- a/utils/gssd/svcgssd_krb5.c
+++ b/utils/gssd/svcgssd_krb5.c
@@ -217,7 +217,7 @@ svcgssd_limit_krb5_enctypes(void)
 			"enctypes from defaults\n", __func__, num_enctypes);
 	}
 
-	maj_stat = gss_set_allowable_enctypes(&min_stat, gssd_creds,
+	maj_stat = gss_krb5_set_allowable_enctypes(&min_stat, gssd_creds,
 			&krb5oid, num_enctypes, enctypes);
 	if (maj_stat != GSS_S_COMPLETE) {
 		printerr(1, "WARNING: gss_set_allowable_enctypes failed\n");
-- 
1.7.4.5



