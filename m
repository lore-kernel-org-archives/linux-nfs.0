Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:51454 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306AbbIUUuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 16:50:44 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/4] GSSD: move process_krb5_upcall machine cred case to helper function
Date: Mon, 21 Sep 2015 16:50:06 -0400
Message-ID: <1442868609-1812-2-git-send-email-andros@netapp.com>
In-Reply-To: <1442868609-1812-1-git-send-email-andros@netapp.com>
References: <1442868609-1812-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
---
 utils/gssd/gssd_proc.c | 107 ++++++++++++++++++++++++++++---------------------
 1 file changed, 62 insertions(+), 45 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 03afc8b..f5a9ce1 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -482,6 +482,64 @@ change_identity(uid_t uid)
 	return 0;
 }
 
+AUTH *
+krb5_use_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
+		    char *service, CLIENT **rpc_clnt)
+{
+	AUTH	*auth = NULL;
+	char	**credlist = NULL;
+	char	**ccname;
+	int	nocache = 0;
+	int	success = 0;
+
+	do {
+		gssd_refresh_krb5_machine_credential(clp->servername, NULL,
+						service);
+	/*
+	 * Get a list of credential cache names and try each
+	 * of them until one works or we've tried them all
+	 */
+		if (gssd_get_krb5_machine_cred_list(&credlist)) {
+			printerr(0, "ERROR: No credentials found "
+				"for connection to server %s\n",
+				clp->servername);
+			goto out;
+		}
+		for (ccname = credlist; ccname && *ccname; ccname++) {
+			gssd_setup_krb5_machine_gss_ccache(*ccname);
+			if ((create_auth_rpc_client(clp, tgtname, rpc_clnt,
+						&auth, uid,
+						AUTHTYPE_KRB5,
+						GSS_C_NO_CREDENTIAL)) == 0) {
+				/* Success! */
+				success++;
+				break;
+			}
+			printerr(2, "WARNING: Failed to create machine krb5"
+				"context with cred cache %s for server %s\n",
+				*ccname, clp->servername);
+		}
+		gssd_free_krb5_machine_cred_list(credlist);
+		if (!success) {
+			if(nocache == 0) {
+				nocache++;
+				printerr(2, "WARNING: Machine cache prematurely"					 "expired or corrupted trying to"
+					 "recreate cache for server %s\n",
+					clp->servername);
+			} else {
+				printerr(1, "WARNING: Failed to create machine"
+					 "krb5 context with any credentials"
+					 "cache for server %s\n",
+					clp->servername);
+				goto out;
+			}
+		}
+	} while(!success);
+
+out:
+	return auth;
+}
+
 /*
  * this code uses the userland rpcsec gss library to create a krb5
  * context on behalf of the kernel
@@ -494,8 +552,6 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	AUTH			*auth = NULL;
 	struct authgss_private_data pd;
 	gss_buffer_desc		token;
-	char			**credlist = NULL;
-	char			**ccname;
 	char			**dirname;
 	int			create_resp = -1;
 	int			err, downcall_err = -EACCES;
@@ -587,49 +643,10 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	if (create_resp != 0) {
 		if (uid == 0 && (root_uses_machine_creds == 1 ||
 				service != NULL)) {
-			int nocache = 0;
-			int success = 0;
-			do {
-				gssd_refresh_krb5_machine_credential(clp->servername,
-								     NULL, service);
-				/*
-				 * Get a list of credential cache names and try each
-				 * of them until one works or we've tried them all
-				 */
-				if (gssd_get_krb5_machine_cred_list(&credlist)) {
-					printerr(0, "ERROR: No credentials found "
-						 "for connection to server %s\n",
-						 clp->servername);
-					goto out_return_error;
-				}
-				for (ccname = credlist; ccname && *ccname; ccname++) {
-					gssd_setup_krb5_machine_gss_ccache(*ccname);
-					if ((create_auth_rpc_client(clp, tgtname, &rpc_clnt,
-								    &auth, uid,
-								    AUTHTYPE_KRB5,
-								    GSS_C_NO_CREDENTIAL)) == 0) {
-						/* Success! */
-						success++;
-						break;
-					}
-					printerr(2, "WARNING: Failed to create machine krb5 context "
-						 "with credentials cache %s for server %s\n",
-						 *ccname, clp->servername);
-				}
-				gssd_free_krb5_machine_cred_list(credlist);
-				if (!success) {
-					if(nocache == 0) {
-						nocache++;
-						printerr(2, "WARNING: Machine cache is prematurely expired or corrupted "
-						            "trying to recreate cache for server %s\n", clp->servername);
-					} else {
-						printerr(1, "WARNING: Failed to create machine krb5 context "
-						 "with any credentials cache for server %s\n",
-						 clp->servername);
-						goto out_return_error;
-					}
-				}
-			} while(!success);
+			auth =	krb5_use_machine_creds(clp, uid, tgtname,
+							service, &rpc_clnt);
+			if (auth == NULL)
+				goto out_return_error;
 		} else {
 			printerr(1, "WARNING: Failed to create krb5 context "
 				 "for user with uid %d for server %s\n",
-- 
1.9.3 (Apple Git-50)

