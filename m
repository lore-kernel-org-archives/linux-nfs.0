From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/3] nfs-utils: free buffer allocated by gssd_k5_err_msg
Date: Sat,  7 Mar 2009 07:45:28 -0500
Message-ID: <1236429928-4680-4-git-send-email-jlayton@redhat.com>
References: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	chuck.lever@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55532 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754805AbZCGMph (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Mar 2009 07:45:37 -0500
In-Reply-To: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no way for the caller of gssd_k5_err_msg to know whether to free
the string it returns. It can call krb5_get_error_message which returns
a string that must be freed via krb5_free_error_string. The other ways
that it can return a string require that the memory not be freed.

Deal with this by copying the string to a new buffer in all cases. Then
we can properly free the string allocated by krb5_get_error_message.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/context_heimdal.c |   25 ++++++----
 utils/gssd/krb5_util.c       |  105 +++++++++++++++++++++++++-----------------
 utils/gssd/krb5_util.h       |    3 +-
 3 files changed, 78 insertions(+), 55 deletions(-)

diff --git a/utils/gssd/context_heimdal.c b/utils/gssd/context_heimdal.c
index ddf064d..6f3b8fd 100644
--- a/utils/gssd/context_heimdal.c
+++ b/utils/gssd/context_heimdal.c
@@ -69,19 +69,19 @@ int write_heimdal_enc_key(char **p, char *end, gss_ctx_id_t ctx)
 	krb5_context context;
 	krb5_error_code ret;
 	int i;
-	char *skd, *dkd;
+	char *skd, *dkd, *k5err = NULL;
 	int code = -1;
 
 	if ((ret = krb5_init_context(&context))) {
-		printerr(0, "ERROR: initializing krb5_context: %s\n",
-			gssd_k5_err_msg(NULL, ret));
+		k5err = gssd_k5_err_msg(NULL, ret);
+		printerr(0, "ERROR: initializing krb5_context: %s\n", k5err);
 		goto out_err;
 	}
 
 	if ((ret = krb5_auth_con_getlocalsubkey(context,
 						ctx->auth_context, &key))){
-		printerr(0, "ERROR: getting auth_context key: %s\n",
-			gssd_k5_err_msg(context, ret));
+		k5err = gssd_k5_err_msg(context, ret);
+		printerr(0, "ERROR: getting auth_context key: %s\n", k5err);
 		goto out_err_free_context;
 	}
 
@@ -97,9 +97,9 @@ int write_heimdal_enc_key(char **p, char *end, gss_ctx_id_t ctx)
 	enc_key.keyvalue.length = key->keyvalue.length;
 	if ((enc_key.keyvalue.data =
 				calloc(1, enc_key.keyvalue.length)) == NULL) {
-
+		k5err = gssd_k5_err_msg(context, ENOMEM);
 		printerr(0, "ERROR: allocating memory for enc key: %s\n",
-			gssd_k5_err_msg(context, ENOMEM));
+			 k5err);
 		goto out_err_free_key;
 	}
 	skd = (char *) key->keyvalue.data;
@@ -119,6 +119,7 @@ int write_heimdal_enc_key(char **p, char *end, gss_ctx_id_t ctx)
     out_err_free_context:
 	krb5_free_context(context);
     out_err:
+	free(k5err);
 	printerr(2, "write_heimdal_enc_key: %s\n", code ? "FAILED" : "SUCCESS");
 	return(code);
 }
@@ -128,18 +129,19 @@ int write_heimdal_seq_key(char **p, char *end, gss_ctx_id_t ctx)
 	krb5_keyblock *key;
 	krb5_context context;
 	krb5_error_code ret;
+	char *k5err = NULL;
 	int code = -1;
 
 	if ((ret = krb5_init_context(&context))) {
-		printerr(0, "ERROR: initializing krb5_context: %s\n",
-			gssd_k5_err_msg(NULL, ret));
+		k5err = gssd_k5_err_msg(NULL, ret);
+		printerr(0, "ERROR: initializing krb5_context: %s\n", k5err);
 		goto out_err;
 	}
 
 	if ((ret = krb5_auth_con_getlocalsubkey(context,
 						ctx->auth_context, &key))){
-		printerr(0, "ERROR: getting auth_context key: %s\n",
-			gssd_k5_err_msg(context, ret));
+		k5err = gssd_k5_err_msg(context, ret);
+		printerr(0, "ERROR: getting auth_context key: %s\n", k5err);
 		goto out_err_free_context;
 	}
 
@@ -162,6 +164,7 @@ int write_heimdal_seq_key(char **p, char *end, gss_ctx_id_t ctx)
     out_err_free_context:
 	krb5_free_context(context);
     out_err:
+	free(k5err);
 	printerr(2, "write_heimdal_seq_key: %s\n", code ? "FAILED" : "SUCCESS");
 	return(code);
 }
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 8923b3b..92eedce 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -376,6 +376,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 	time_t now = time(0);
 	char *cache_type;
 	char *pname = NULL;
+	char *k5err = NULL;
 
 	memset(&my_creds, 0, sizeof(my_creds));
 
@@ -398,8 +399,8 @@ gssd_get_single_krb5_cred(krb5_context context,
 #if HAVE_KRB5_GET_INIT_CREDS_OPT_SET_ADDRESSLESS
 	code = krb5_get_init_creds_opt_alloc(context, &init_opts);
 	if (code) {
-		printerr(0, "ERROR: %s allocating gic options\n",
-			 gssd_k5_err_msg(context, code));
+		k5err = gssd_k5_err_msg(context, code);
+		printerr(0, "ERROR: %s allocating gic options\n", k5err);
 		goto out;
 	}
 	if (krb5_get_init_creds_opt_set_addressless(context, init_opts, 1))
@@ -426,9 +427,9 @@ gssd_get_single_krb5_cred(krb5_context context,
 
 	if ((code = krb5_get_init_creds_keytab(context, &my_creds, ple->princ,
 					       kt, 0, NULL, opts))) {
+		k5err = gssd_k5_err_msg(context, code);
 		printerr(1, "WARNING: %s while getting initial ticket for "
-			 "principal '%s' using keytab '%s'\n",
-			 gssd_k5_err_msg(context, code),
+			 "principal '%s' using keytab '%s'\n", k5err,
 			 pname ? pname : "<unparsable>", kt_name);
 		goto out;
 	}
@@ -456,19 +457,21 @@ gssd_get_single_krb5_cred(krb5_context context,
 		goto out;
 	}
 	if ((code = krb5_cc_resolve(context, cc_name, &ccache))) {
+		k5err = gssd_k5_err_msg(context, code);
 		printerr(0, "ERROR: %s while opening credential cache '%s'\n",
-			 gssd_k5_err_msg(context, code), cc_name);
+			 k5err, cc_name);
 		goto out;
 	}
 	if ((code = krb5_cc_initialize(context, ccache, ple->princ))) {
+		k5err = gssd_k5_err_msg(context, code);
 		printerr(0, "ERROR: %s while initializing credential "
-			 "cache '%s'\n", gssd_k5_err_msg(context, code),
-			 cc_name);
+			 "cache '%s'\n", k5err, cc_name);
 		goto out;
 	}
 	if ((code = krb5_cc_store_cred(context, ccache, &my_creds))) {
+		k5err = gssd_k5_err_msg(context, code);
 		printerr(0, "ERROR: %s while storing credentials in '%s'\n",
-			 gssd_k5_err_msg(context, code), cc_name);
+			 k5err, cc_name);
 		goto out;
 	}
 
@@ -485,6 +488,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 	if (ccache)
 		krb5_cc_close(context, ccache);
 	krb5_free_cred_contents(context, &my_creds);
+	free(k5err);
 	return (code);
 }
 
@@ -708,6 +712,7 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 	int retval = -1;
 	char kt_name[BUFSIZ];
 	char *pname;
+	char *k5err = NULL;
 
 	if (found == NULL) {
 		retval = EINVAL;
@@ -721,15 +726,15 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 	 * save info in the global principal list (gssd_k5_kt_princ_list).
 	 */
 	if ((code = krb5_kt_get_name(context, kt, kt_name, BUFSIZ))) {
-		printerr(0, "ERROR: %s attempting to get keytab name\n",
-			 gssd_k5_err_msg(context, code));
+		k5err = gssd_k5_err_msg(context, code);
+		printerr(0, "ERROR: %s attempting to get keytab name\n", k5err);
 		retval = code;
 		goto out;
 	}
 	if ((code = krb5_kt_start_seq_get(context, kt, &cursor))) {
+		k5err = gssd_k5_err_msg(context, code);
 		printerr(0, "ERROR: %s while beginning keytab scan "
-			    "for keytab '%s'\n",
-			gssd_k5_err_msg(context, code), kt_name);
+			    "for keytab '%s'\n", k5err, kt_name);
 		retval = code;
 		goto out;
 	}
@@ -737,9 +742,10 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 	while ((code = krb5_kt_next_entry(context, kt, kte, &cursor)) == 0) {
 		if ((code = krb5_unparse_name(context, kte->principal,
 					      &pname))) {
+			k5err = gssd_k5_err_msg(context, code);
 			printerr(0, "WARNING: Skipping keytab entry because "
 				 "we failed to unparse principal name: %s\n",
-				 gssd_k5_err_msg(context, code));
+				 k5err);
 			k5_free_kt_entry(context, kte);
 			continue;
 		}
@@ -773,13 +779,14 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 	}
 
 	if ((code = krb5_kt_end_seq_get(context, kt, &cursor))) {
+		k5err = gssd_k5_err_msg(context, code);
 		printerr(0, "WARNING: %s while ending keytab scan for "
-			    "keytab '%s'\n",
-			 gssd_k5_err_msg(context, code), kt_name);
+			    "keytab '%s'\n", k5err, kt_name);
 	}
 
 	retval = 0;
   out:
+	free(k5err);
 	return retval;
 }
 
@@ -799,6 +806,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
 	int i, j, retval;
 	char *default_realm = NULL;
 	char *realm;
+	char *k5err = NULL;
 	int tried_all = 0, tried_default = 0;
 	krb5_principal princ;
 
@@ -812,8 +820,8 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
 	/* Get full local hostname */
 	retval = gethostname(myhostname, sizeof(myhostname));
 	if (retval) {
-		printerr(1, "%s while getting local hostname\n",
-			 gssd_k5_err_msg(context, retval));
+		k5err = gssd_k5_err_msg(context, retval);
+		printerr(1, "%s while getting local hostname\n", k5err);
 		goto out;
 	}
 	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
@@ -823,8 +831,8 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
 	code = krb5_get_default_realm(context, &default_realm);
 	if (code) {
 		retval = code;
-		printerr(1, "%s while getting default realm name\n",
-			 gssd_k5_err_msg(context, code));
+		k5err = gssd_k5_err_msg(context, code);
+		printerr(1, "%s while getting default realm name\n", k5err);
 		goto out;
 	}
 
@@ -836,8 +844,9 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
 	 */
 	code = krb5_get_host_realm(context, targethostname, &realmnames);
 	if (code) {
+		k5err = gssd_k5_err_msg(context, code);
 		printerr(0, "ERROR: %s while getting realm(s) for host '%s'\n",
-			 gssd_k5_err_msg(context, code), targethostname);
+			 k5err, targethostname);
 		retval = code;
 		goto out;
 	}
@@ -868,19 +877,19 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
 							myhostname,
 							NULL);
 			if (code) {
+				k5err = gssd_k5_err_msg(context, code);
 				printerr(1, "%s while building principal for "
-					 "'%s/%s@%s'\n",
-					 gssd_k5_err_msg(context, code),
-					 svcnames[j], myhostname, realm);
+					 "'%s/%s@%s'\n", k5err, svcnames[j],
+					 myhostname, realm);
 				continue;
 			}
 			code = krb5_kt_get_entry(context, kt, princ, 0, 0, kte);
 			krb5_free_principal(context, princ);
 			if (code) {
+				k5err = gssd_k5_err_msg(context, code);
 				printerr(3, "%s while getting keytab entry for "
-					 "'%s/%s@%s'\n",
-					 gssd_k5_err_msg(context, code),
-					 svcnames[j], myhostname, realm);
+					 "'%s/%s@%s'\n", k5err, svcnames[j],
+					 myhostname, realm);
 			} else {
 				printerr(3, "Success getting keytab entry for "
 					 "'%s/%s@%s'\n",
@@ -915,6 +924,7 @@ out:
 		k5_free_default_realm(context, default_realm);
 	if (realmnames)
 		krb5_free_host_realm(context, realmnames);
+	free(k5err);
 	return retval;
 }
 
@@ -1140,11 +1150,12 @@ gssd_destroy_krb5_machine_creds(void)
 	krb5_error_code code = 0;
 	krb5_ccache ccache;
 	struct gssd_k5_kt_princ *ple;
+	char *k5err = NULL;
 
 	code = krb5_init_context(&context);
 	if (code) {
-		printerr(0, "ERROR: %s while initializing krb5\n",
-			 gssd_k5_err_msg(NULL, code));
+		k5err = gssd_k5_err_msg(NULL, code);
+		printerr(0, "ERROR: %s while initializing krb5\n", k5err);
 		goto out;
 	}
 
@@ -1152,19 +1163,21 @@ gssd_destroy_krb5_machine_creds(void)
 		if (!ple->ccname)
 			continue;
 		if ((code = krb5_cc_resolve(context, ple->ccname, &ccache))) {
+			k5err = gssd_k5_err_msg(context, code);
 			printerr(0, "WARNING: %s while resolving credential "
-				    "cache '%s' for destruction\n",
-				 gssd_k5_err_msg(context, code), ple->ccname);
+				    "cache '%s' for destruction\n", k5err,
+				    ple->ccname);
 			continue;
 		}
 
 		if ((code = krb5_cc_destroy(context, ccache))) {
+			k5err = gssd_k5_err_msg(context, code);
 			printerr(0, "WARNING: %s while destroying credential "
-				    "cache '%s'\n",
-				 gssd_k5_err_msg(context, code), ple->ccname);
+				    "cache '%s'\n", k5err, ple->ccname);
 		}
 	}
   out:
+	free(k5err);
 	krb5_free_context(context);
 }
 
@@ -1179,22 +1192,24 @@ gssd_refresh_krb5_machine_credential(char *hostname,
 	krb5_context context;
 	krb5_keytab kt = NULL;;
 	int retval = 0;
+	char *k5err = NULL;
 
 	if (hostname == NULL && ple == NULL)
 		return EINVAL;
 
 	code = krb5_init_context(&context);
 	if (code) {
+		k5err = gssd_k5_err_msg(NULL, code);
 		printerr(0, "ERROR: %s: %s while initializing krb5 context\n",
-			 __FUNCTION__, gssd_k5_err_msg(NULL, code));
+			 __func__, k5err);
 		retval = code;
 		goto out;
 	}
 
 	if ((code = krb5_kt_resolve(context, keytabfile, &kt))) {
+		k5err = gssd_k5_err_msg(context, code);
 		printerr(0, "ERROR: %s: %s while resolving keytab '%s'\n",
-			 __FUNCTION__, gssd_k5_err_msg(context, code),
-			 keytabfile);
+			 __func__, k5err, keytabfile);
 		goto out;
 	}
 
@@ -1231,29 +1246,35 @@ out:
 	if (kt)
 		krb5_kt_close(context, kt);
 	krb5_free_context(context);
+	free(k5err);
 	return retval;
 }
 
 /*
  * A common routine for getting the Kerberos error message
  */
-const char *
+char *
 gssd_k5_err_msg(krb5_context context, krb5_error_code code)
 {
-	const char *msg = NULL;
+	const char *origmsg;
+	char *msg = NULL;
+
 #if HAVE_KRB5_GET_ERROR_MESSAGE
-	if (context != NULL)
-		msg = krb5_get_error_message(context, code);
+	if (context != NULL) {
+		origmsg = krb5_get_error_message(context, code);
+		msg = strdup(origmsg);
+		krb5_free_error_message(context, origmsg);
+	}
 #endif
 	if (msg != NULL)
 		return msg;
 #if HAVE_KRB5
-	return error_message(code);
+	return strdup(error_message(code));
 #else
 	if (context != NULL)
-		return krb5_get_err_text(context, code);
+		return strdup(krb5_get_err_text(context, code));
 	else
-		return error_message(code);
+		return strdup(error_message(code));
 #endif
 }
 
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index 4b2da6b..62f37d6 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -25,8 +25,7 @@ void gssd_setup_krb5_machine_gss_ccache(char *servername);
 void gssd_destroy_krb5_machine_creds(void);
 int  gssd_refresh_krb5_machine_credential(char *hostname,
 					  struct gssd_k5_kt_princ *ple);
-const char *
-gssd_k5_err_msg(krb5_context context, krb5_error_code code);
+char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
 void gssd_k5_get_default_realm(char **def_realm);
 
 #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
-- 
1.6.0.6

