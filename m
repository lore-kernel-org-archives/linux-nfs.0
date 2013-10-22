Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53245 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950Ab3JVOWp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:22:45 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/3] GSSD add cc_name to upcall
Date: Tue, 22 Oct 2013 10:22:35 -0400
Message-ID: <1382451757-3032-2-git-send-email-andros@netapp.com>
In-Reply-To: <1382451757-3032-1-git-send-email-andros@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd_proc.c | 37 +++++++++++++++++++++++++++++++++----
 utils/gssd/krb5_util.c |  2 +-
 utils/gssd/krb5_util.h |  1 +
 3 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 2d3dbec..8df61a4 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -966,7 +966,7 @@ create_auth_rpc_client(struct clnt_info *clp,
  */
 static void
 process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
-		    char *service)
+		    char *service, char *cc_name)
 {
 	CLIENT			*rpc_clnt = NULL;
 	AUTH			*auth = NULL;
@@ -980,7 +980,8 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	gss_cred_id_t		gss_cred;
 	OM_uint32		maj_stat, min_stat, lifetime_rec;
 
-	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
+	printerr(1, "handling krb5 upcall (%s) cc_name %p\n", clp->dirname,
+		cc_name);
 
 	token.length = 0;
 	token.value = NULL;
@@ -1011,6 +1012,18 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		 service ? service : "<null>");
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
 				service == NULL)) {
+	/* Use the ccache name from the upcall */
+	if (cc_name != NULL) {
+		printerr(2, "using %s as credentials cache for client "
+			"with uid %u for server %s\n", cc_name,
+			uid, clp->servername);
+		gssd_set_krb5_ccache_name(cc_name);
+		create_resp = create_auth_rpc_client(clp,
+						&rpc_clnt, &auth, uid,
+						AUTHTYPE_KRB5, gss_cred);
+		if (create_resp == 0)
+			goto resp_found;
+	}
 		/* Tell krb5 gss which credentials cache to use */
 		/* Try first to acquire credentials directly via GSSAPI */
 		err = gssd_acquire_user_cred(uid, &gss_cred);
@@ -1083,6 +1096,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		}
 	}
 
+resp_found:
 	if (!authgss_get_private_data(auth, &pd)) {
 		printerr(1, "WARNING: Failed to obtain authentication "
 			    "data for user with uid %d for server %s\n",
@@ -1137,7 +1151,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 		return;
 	}
 
-	process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL);
+	process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL, NULL);
 }
 
 void
@@ -1151,6 +1165,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 	char			*target = NULL;
 	char			*service = NULL;
 	char			*enctypes = NULL;
+	char			*cc_name = NULL;
 
 	printerr(1, "handling gssd upcall (%s)\n", clp->dirname);
 
@@ -1245,9 +1260,23 @@ handle_gssd_upcall(struct clnt_info *clp)
 			goto out;
 		}
 	}
+	/* read the ccache name. */
+	if ((p = strstr(lbuf, "ccache=")) != NULL) {
+		printerr(2, "CC_NAME to parse\n");
+		cc_name = malloc(lbuflen);
+		if (!cc_name)
+			goto out;
+		if (sscanf(p, "ccache=%s", cc_name) != 1) {
+			printerr(2, "WARNING: handle_gssd_upcall: "
+				    "failed to parse cc_name "
+				    "in upcall string '%s'\n", lbuf);
+			goto out;
+		}
+	}
 
 	if (strcmp(mech, "krb5") == 0)
-		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service);
+		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service,
+				    cc_name);
 	else
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			    "received unknown gss mech '%s'\n", mech);
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 83b9651..1bb0da6 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -471,7 +471,7 @@ gssd_get_single_krb5_cred(krb5_context context,
  * Depending on the version of Kerberos, we either need to use
  * a private function, or simply set the environment variable.
  */
-static void
+void
 gssd_set_krb5_ccache_name(char *ccname)
 {
 #ifdef USE_GSS_KRB5_CCACHE_NAME
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index eed1294..16119a8 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -23,6 +23,7 @@ struct gssd_k5_kt_princ {
 };
 
 
+void gssd_set_krb5_ccache_name(char *ccname);
 int gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername,
 				     char *dirname);
 int  gssd_get_krb5_machine_cred_list(char ***list);
-- 
1.8.3.1

