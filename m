From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH] gssd: don't assume machine credentials cache can't disappear
Date: Mon, 31 Aug 2009 17:22:25 -0400
Message-ID: <20090831212225.20804.85556.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Lukas Hejtmanek <xhejtman@ics.muni.cz>,
	Kevin Coffman <kwc@citi.umich.edu>
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:39885 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751556AbZHaVWX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2009 17:22:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Lukas Hejtmanek <xhejtman@ics.muni.cz>

E.g., if someone deletes /tmp/krb5cc_machine_REALM, rpc.gss does not create
new one until the old one expires. Also, it has problems with clock skew, if
time goes back and gssd thinks that machine credentials are not expired yet.

The following patch tries to use an existing credentials cache, but in case
of failure, it tries again creating a fresh credentials cache from the keytab.

Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd_proc.c |   76 +++++++++++++++++++++++++++---------------------
 utils/gssd/krb5_util.c |   13 ++++----
 utils/gssd/krb5_util.h |    3 +-
 3 files changed, 51 insertions(+), 41 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 02239d2..2185554 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -840,42 +840,50 @@ handle_krb5_upcall(struct clnt_info *clp)
 	}
 	if (create_resp != 0) {
 		if (uid == 0 && root_uses_machine_creds == 1) {
+			int nocache = 0;
 			int success = 0;
-
-			gssd_refresh_krb5_machine_credential(clp->servername,
-							     NULL);
-			/*
-			 * Get a list of credential cache names and try each
-			 * of them until one works or we've tried them all
-			 */
-			if (gssd_get_krb5_machine_cred_list(&credlist)) {
-				printerr(0, "ERROR: No credentials found "
-					 "for connection to server %s\n",
-					 clp->servername);
-					goto out_return_error;
-			}
-			for (ccname = credlist; ccname && *ccname; ccname++) {
-				gssd_setup_krb5_machine_gss_ccache(*ccname);
-				if ((create_auth_rpc_client(clp, &rpc_clnt,
-							    &auth, uid,
-							    AUTHTYPE_KRB5)) == 0) {
-					/* Success! */
-					success++;
-					break;
+			do {
+				gssd_refresh_krb5_machine_credential(clp->servername,
+								     NULL, nocache);
+				/*
+				 * Get a list of credential cache names and try each
+				 * of them until one works or we've tried them all
+				 */
+				if (gssd_get_krb5_machine_cred_list(&credlist)) {
+					printerr(0, "ERROR: No credentials found "
+						 "for connection to server %s\n",
+						 clp->servername);
+						goto out_return_error;
 				}
-				printerr(2, "WARNING: Failed to create krb5 context "
-					 "for user with uid %d with credentials "
-					 "cache %s for server %s\n",
-					 uid, *ccname, clp->servername);
-			}
-			gssd_free_krb5_machine_cred_list(credlist);
-			if (!success) {
-				printerr(1, "WARNING: Failed to create krb5 context "
-					 "for user with uid %d with any "
-					 "credentials cache for server %s\n",
-					 uid, clp->servername);
-				goto out_return_error;
-			}
+				for (ccname = credlist; ccname && *ccname; ccname++) {
+					gssd_setup_krb5_machine_gss_ccache(*ccname);
+					if ((create_auth_rpc_client(clp, &rpc_clnt,
+								    &auth, uid,
+								    AUTHTYPE_KRB5)) == 0) {
+						/* Success! */
+						success++;
+						break;
+					}
+					printerr(2, "WARNING: Failed to create machine krb5 context "
+						 "with credentials cache %s for server %s\n",
+						 *ccname, clp->servername);
+				}
+				gssd_free_krb5_machine_cred_list(credlist);
+				if (!success) {
+					if (nocache == 0) {
+						nocache++;
+						printerr(2, "WARNING: Failed to create machine "
+							 "krb5 context.  Re-trying with fresh "
+						         "credentials cache for server %s\n",
+							 clp->servername);
+					} else {
+						printerr(1, "WARNING: Failed to create machine "
+							 "krb5 context with any credentials cache "
+							 "for server %s\n", clp->servername);
+						goto out_return_error;
+					}
+				}
+			} while (!success);
 		} else {
 			printerr(1, "WARNING: Failed to create krb5 context "
 				 "for user with uid %d for server %s\n",
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 3009cc5..78e9775 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -137,7 +137,7 @@ static int select_krb5_ccache(const struct dirent *d);
 static int gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
 		struct dirent **d);
 static int gssd_get_single_krb5_cred(krb5_context context,
-		krb5_keytab kt, struct gssd_k5_kt_princ *ple);
+		krb5_keytab kt, struct gssd_k5_kt_princ *ple, int nocache);
 static int query_krb5_ccache(const char* cred_cache, char **ret_princname,
 		char **ret_realm);
 
@@ -359,7 +359,8 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
 static int
 gssd_get_single_krb5_cred(krb5_context context,
 			  krb5_keytab kt,
-			  struct gssd_k5_kt_princ *ple)
+			  struct gssd_k5_kt_princ *ple,
+			  int nocache)
 {
 #if HAVE_KRB5_GET_INIT_CREDS_OPT_SET_ADDRESSLESS
 	krb5_get_init_creds_opt *init_opts = NULL;
@@ -379,7 +380,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 
 	memset(&my_creds, 0, sizeof(my_creds));
 
-	if (ple->ccname && ple->endtime > now) {
+	if (ple->ccname && ple->endtime > now && !nocache) {
 		printerr(2, "INFO: Credentials in CC '%s' are good until %d\n",
 			 ple->ccname, ple->endtime);
 		code = 0;
@@ -1095,7 +1096,7 @@ gssd_get_krb5_machine_cred_list(char ***list)
 	for (ple = gssd_k5_kt_princ_list; ple; ple = ple->next) {
 		if (ple->ccname) {
 			/* Make sure cred is up-to-date before returning it */
-			retval = gssd_refresh_krb5_machine_credential(NULL, ple);
+			retval = gssd_refresh_krb5_machine_credential(NULL, ple, 0);
 			if (retval)
 				continue;
 			if (i + 1 > listsize) {
@@ -1185,7 +1186,7 @@ gssd_destroy_krb5_machine_creds(void)
  */
 int
 gssd_refresh_krb5_machine_credential(char *hostname,
-				     struct gssd_k5_kt_princ *ple)
+				     struct gssd_k5_kt_princ *ple, int nocache)
 {
 	krb5_error_code code = 0;
 	krb5_context context;
@@ -1240,7 +1241,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
 			goto out;
 		}
 	}
-	retval = gssd_get_single_krb5_cred(context, kt, ple);
+	retval = gssd_get_single_krb5_cred(context, kt, ple, nocache);
 out:
 	if (kt)
 		krb5_kt_close(context, kt);
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index 3d39300..e86f9ba 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -30,7 +30,8 @@ void gssd_free_krb5_machine_cred_list(char **list);
 void gssd_setup_krb5_machine_gss_ccache(char *servername);
 void gssd_destroy_krb5_machine_creds(void);
 int  gssd_refresh_krb5_machine_credential(char *hostname,
-					  struct gssd_k5_kt_princ *ple);
+					  struct gssd_k5_kt_princ *ple,
+					  int nocache);
 char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
 void gssd_k5_get_default_realm(char **def_realm);
 

