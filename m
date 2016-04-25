Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:19274 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933157AbcDYQ6f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Apr 2016 12:58:35 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 3/3] gssd: always call gss_krb5_ccache_name
Date: Mon, 25 Apr 2016 12:58:33 -0400
Message-ID: <1461603513-67523-4-git-send-email-kolga@netapp.com>
In-Reply-To: <1461603513-67523-1-git-send-email-kolga@netapp.com>
References: <1461603513-67523-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Previously the location of the credential cache was passed in either
using environment variable KRB5CCNAME or gss_krb5_ccache_name() if
supported. For threaded-gssd, we can't use an environment variable
as it's shared among all thread. Thus always use the api call.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Reviewed-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd_proc.c | 12 +++++++++--
 utils/gssd/krb5_util.c | 56 +++++++++-----------------------------------------
 utils/gssd/krb5_util.h |  1 -
 3 files changed, 20 insertions(+), 49 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 487a4f5..c9ba399 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -554,7 +554,15 @@ krb5_use_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
 			goto out;
 		}
 		for (ccname = credlist; ccname && *ccname; ccname++) {
-			gssd_setup_krb5_machine_gss_ccache(*ccname);
+			u_int min_stat;
+
+			if (gss_krb5_ccache_name(&min_stat, *ccname, NULL) !=
+					GSS_S_COMPLETE) {
+				printerr(1, "WARNING: gss_krb5_ccache_name "
+					 "with name '%s' failed (%s)\n",
+					 *ccname, error_message(min_stat));
+				continue;
+			}
 			if ((create_auth_rpc_client(clp, tgtname, rpc_clnt,
 						&auth, uid,
 						AUTHTYPE_KRB5,
@@ -575,7 +583,7 @@ krb5_use_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
 					 "recreate cache for server %s\n",
 					clp->servername);
 			} else {
-				printerr(1, "WARNING: Failed to create machine"
+				printerr(0, "ERROR: Failed to create machine"
 					 "krb5 context with any credentials"
 					 "cache for server %s\n",
 					clp->servername);
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 3328696..7b74ab3 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -468,37 +468,6 @@ gssd_get_single_krb5_cred(krb5_context context,
 }
 
 /*
- * Depending on the version of Kerberos, we either need to use
- * a private function, or simply set the environment variable.
- */
-static void
-gssd_set_krb5_ccache_name(char *ccname)
-{
-#ifdef USE_GSS_KRB5_CCACHE_NAME
-	u_int	maj_stat, min_stat;
-
-	printerr(3, "using gss_krb5_ccache_name to select krb5 ccache %s\n",
-		 ccname);
-	maj_stat = gss_krb5_ccache_name(&min_stat, ccname, NULL);
-	if (maj_stat != GSS_S_COMPLETE) {
-		printerr(0, "WARNING: gss_krb5_ccache_name with "
-			"name '%s' failed (%s)\n",
-			ccname, error_message(min_stat));
-	}
-#else
-	/*
-	 * Set the KRB5CCNAME environment variable to tell the krb5 code
-	 * which credentials cache to use.  (Instead of using the private
-	 * function above for which there is no generic gssapi
-	 * equivalent.)
-	 */
-	printerr(3, "using environment variable to select krb5 ccache %s\n",
-		 ccname);
-	setenv("KRB5CCNAME", ccname, 1);
-#endif
-}
-
-/*
  * Given a principal, find a matching ple structure
  */
 static struct gssd_k5_kt_princ *
@@ -1094,6 +1063,7 @@ gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirpattern)
 	const char		*cctype;
 	struct dirent		*d;
 	int			err, i, j;
+	u_int			maj_stat, min_stat;
 
 	printerr(3, "looking for client creds with uid %u for "
 		    "server %s in %s\n", uid, servername, dirpattern);
@@ -1129,22 +1099,16 @@ gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirpattern)
 
 	printerr(2, "using %s as credentials cache for client with "
 		    "uid %u for server %s\n", buf, uid, servername);
-	gssd_set_krb5_ccache_name(buf);
-	return 0;
-}
 
-/*
- * Let the gss code know where to find the machine credentials ccache.
- *
- * Returns:
- *	void
- */
-void
-gssd_setup_krb5_machine_gss_ccache(char *ccname)
-{
-	printerr(2, "using %s as credentials cache for machine creds\n",
-		 ccname);
-	gssd_set_krb5_ccache_name(ccname);
+	printerr(3, "using gss_krb5_ccache_name to select krb5 ccache %s\n",
+		 buf);
+	maj_stat = gss_krb5_ccache_name(&min_stat, buf, NULL);
+	if (maj_stat != GSS_S_COMPLETE) {
+		printerr(0, "ERROR: unable to get user cred cache '%s' "
+			 "failed (%s)\n", buf, error_message(min_stat));
+		return maj_stat;
+	}
+	return 0;
 }
 
 /*
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index a319588..d3b0777 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -27,7 +27,6 @@ int gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername,
 				     char *dirname);
 int  gssd_get_krb5_machine_cred_list(char ***list);
 void gssd_free_krb5_machine_cred_list(char **list);
-void gssd_setup_krb5_machine_gss_ccache(char *servername);
 void gssd_destroy_krb5_machine_creds(void);
 int  gssd_refresh_krb5_machine_credential(char *hostname,
 					  struct gssd_k5_kt_princ *ple, 
-- 
1.8.3.1

