From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 14/24] Removed warnings from krb5_util.c
Date: Wed,  4 Aug 2010 11:12:10 -0400
Message-ID: <1280934740-11366-15-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45175 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755290Ab0HDPvM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:51:12 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdn-0002SZ-Sy
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:24 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

krb5_util.c: In function 'realm_and_service_match':
krb5_util.c:617: warning: unused parameter 'context'
krb5_util.c: In function 'limit_krb5_enctypes':
krb5_util.c:1275: warning: unused parameter 'uid'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd_proc.c |    2 +-
 utils/gssd/krb5_util.c |   29 +++++++++++++++++++++--------
 utils/gssd/krb5_util.h |    2 +-
 3 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index a55418b..3902b95 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -859,7 +859,7 @@ int create_auth_rpc_client(struct clnt_info *clp,
 		 * Do this before creating rpc connection since we won't need
 		 * rpc connection if it fails!
 		 */
-		if (limit_krb5_enctypes(&sec, uid)) {
+		if (limit_krb5_enctypes(&sec)) {
 			printerr(1, "WARNING: Failed while limiting krb5 "
 				    "encryption types for user with uid %d\n",
 				 uid);
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index d23654f..f071600 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -613,24 +613,32 @@ out:
  * and has *any* instance (hostname), return 1.
  * Otherwise return 0, indicating no match.
  */
+#ifdef HAVE_KRB5
 static int
-realm_and_service_match(krb5_context context, krb5_principal p,
-			const char *realm, const char *service)
+realm_and_service_match(krb5_principal p, const char *realm, const char *service)
 {
-#ifdef HAVE_KRB5
 	/* Must have two components */
 	if (p->length != 2)
 		return 0;
+
 	if ((strlen(realm) == p->realm.length)
 	    && (strncmp(realm, p->realm.data, p->realm.length) == 0)
 	    && (strlen(service) == p->data[0].length)
 	    && (strncmp(service, p->data[0].data, p->data[0].length) == 0))
 		return 1;
+
+	return 0;
+}
 #else
+static int
+realm_and_service_match(krb5_context context, krb5_principal p,
+			const char *realm, const char *service)
+{
 	const char *name, *inst;
 
 	if (p->name.name_string.len != 2)
 		return 0;
+
 	name = krb5_principal_get_comp_string(context, p, 0);
 	inst = krb5_principal_get_comp_string(context, p, 1);
 	if (name == NULL || inst == NULL)
@@ -638,9 +646,10 @@ realm_and_service_match(krb5_context context, krb5_principal p,
 	if ((strcmp(realm, p->realm) == 0)
 	    && (strcmp(service, name) == 0))
 		return 1;
-#endif
+
 	return 0;
 }
+#endif
 
 /*
  * Search the given keytab file looking for an entry with the given
@@ -662,7 +671,7 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 	krb5_kt_cursor cursor;
 	krb5_error_code code;
 	struct gssd_k5_kt_princ *ple;
-	int retval = -1;
+	int retval = -1, status;
 	char kt_name[BUFSIZ];
 	char *pname;
 	char *k5err = NULL;
@@ -705,8 +714,12 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 		printerr(4, "Processing keytab entry for principal '%s'\n",
 			 pname);
 		/* Use the first matching keytab entry found */
-	        if ((realm_and_service_match(context, kte->principal, realm,
-					     service))) {
+#ifdef HAVE_KRB5
+		status = realm_and_service_match(kte->principal, realm, service);
+#else
+		status = realm_and_service_match(context, kte->principal, realm, service);
+#endif
+		if (status) {
 			printerr(4, "We WILL use this entry (%s)\n", pname);
 			ple = get_ple_by_princ(context, kte->principal);
 			/*
@@ -1272,7 +1285,7 @@ gssd_k5_get_default_realm(char **def_realm)
  */
 
 int
-limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
+limit_krb5_enctypes(struct rpc_gss_sec *sec)
 {
 	u_int maj_stat, min_stat;
 	gss_cred_id_t credh;
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index 4602cc3..b42b91e 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -36,7 +36,7 @@ char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
 void gssd_k5_get_default_realm(char **def_realm);
 
 #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
-int limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid);
+int limit_krb5_enctypes(struct rpc_gss_sec *sec);
 #endif
 
 /*
-- 
1.7.2

