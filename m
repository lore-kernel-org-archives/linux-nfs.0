From: steved@redhat.com
Subject: [PATCH 1/3] gssd: move function limit_krb5_enctypes into the exported functions area
Date: Wed, 14 Apr 2010 15:18:47 -0400
Message-ID: <1271272729-24422-2-git-send-email-steved@redhat.com>
References: <1271272729-24422-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:49710 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752978Ab0DNTSw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Apr 2010 15:18:52 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1O286s-0006m9-6g
	for linux-nfs@vger.kernel.org; Wed, 14 Apr 2010 15:18:50 -0400
In-Reply-To: <1271272729-24422-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

cleanup: Move function limit_krb5_enctypes() from the section
containing static functions into the section containing
externally visible functions.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/krb5_util.c |  109 ++++++++++++++++++++++++------------------------
 1 files changed, 54 insertions(+), 55 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 1295f57..1c10bd4 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -292,61 +292,6 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 	return err;
 }
 
-
-#ifdef HAVE_SET_ALLOWABLE_ENCTYPES
-/*
- * this routine obtains a credentials handle via gss_acquire_cred()
- * then calls gss_krb5_set_allowable_enctypes() to limit the encryption
- * types negotiated.
- *
- * XXX Should call some function to determine the enctypes supported
- * by the kernel. (Only need to do that once!)
- *
- * Returns:
- *	0 => all went well
- *     -1 => there was an error
- */
-
-int
-limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
-{
-	u_int maj_stat, min_stat;
-	gss_cred_id_t credh;
-	gss_OID_set_desc  desired_mechs;
-	krb5_enctype enctypes[] = { ENCTYPE_DES_CBC_CRC,
-				    ENCTYPE_DES_CBC_MD5,
-				    ENCTYPE_DES_CBC_MD4 };
-	int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
-
-	/* We only care about getting a krb5 cred */
-	desired_mechs.count = 1;
-	desired_mechs.elements = &krb5oid;
-
-	maj_stat = gss_acquire_cred(&min_stat, NULL, 0,
-				    &desired_mechs, GSS_C_INITIATE,
-				    &credh, NULL, NULL);
-
-	if (maj_stat != GSS_S_COMPLETE) {
-		if (get_verbosity() > 0)
-			pgsserr("gss_acquire_cred",
-				maj_stat, min_stat, &krb5oid);
-		return -1;
-	}
-
-	maj_stat = gss_set_allowable_enctypes(&min_stat, credh, &krb5oid,
-					     num_enctypes, &enctypes);
-	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_set_allowable_enctypes",
-			maj_stat, min_stat, &krb5oid);
-		gss_release_cred(&min_stat, &credh);
-		return -1;
-	}
-	sec->cred = credh;
-
-	return 0;
-}
-#endif	/* HAVE_SET_ALLOWABLE_ENCTYPES */
-
 /*
  * Obtain credentials via a key in the keytab given
  * a keytab handle and a gssd_k5_kt_princ structure.
@@ -1304,3 +1249,57 @@ gssd_k5_get_default_realm(char **def_realm)
 
 	krb5_free_context(context);
 }
+
+#ifdef HAVE_SET_ALLOWABLE_ENCTYPES
+/*
+ * this routine obtains a credentials handle via gss_acquire_cred()
+ * then calls gss_krb5_set_allowable_enctypes() to limit the encryption
+ * types negotiated.
+ *
+ * XXX Should call some function to determine the enctypes supported
+ * by the kernel. (Only need to do that once!)
+ *
+ * Returns:
+ *	0 => all went well
+ *     -1 => there was an error
+ */
+
+int
+limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
+{
+	u_int maj_stat, min_stat;
+	gss_cred_id_t credh;
+	gss_OID_set_desc  desired_mechs;
+	krb5_enctype enctypes[] = { ENCTYPE_DES_CBC_CRC,
+				    ENCTYPE_DES_CBC_MD5,
+				    ENCTYPE_DES_CBC_MD4 };
+	int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
+
+	/* We only care about getting a krb5 cred */
+	desired_mechs.count = 1;
+	desired_mechs.elements = &krb5oid;
+
+	maj_stat = gss_acquire_cred(&min_stat, NULL, 0,
+				    &desired_mechs, GSS_C_INITIATE,
+				    &credh, NULL, NULL);
+
+	if (maj_stat != GSS_S_COMPLETE) {
+		if (get_verbosity() > 0)
+			pgsserr("gss_acquire_cred",
+				maj_stat, min_stat, &krb5oid);
+		return -1;
+	}
+
+	maj_stat = gss_set_allowable_enctypes(&min_stat, credh, &krb5oid,
+					     num_enctypes, &enctypes);
+	if (maj_stat != GSS_S_COMPLETE) {
+		pgsserr("gss_set_allowable_enctypes",
+			maj_stat, min_stat, &krb5oid);
+		gss_release_cred(&min_stat, &credh);
+		return -1;
+	}
+	sec->cred = credh;
+
+	return 0;
+}
+#endif	/* HAVE_SET_ALLOWABLE_ENCTYPES */
-- 
1.6.6.1

