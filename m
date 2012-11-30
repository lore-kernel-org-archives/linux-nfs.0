Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:63405 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755085Ab2K3SaL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Nov 2012 13:30:11 -0500
From: andros@netapp.com
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/3] GSSD: cleanup process_krb5_upcall indentation
Date: Fri, 30 Nov 2012 13:30:04 -0500
Message-Id: <1354300204-2509-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd_proc.c |  107 +++++++++++++++++++++++++-----------------------
 1 files changed, 56 insertions(+), 51 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index d01ba2f..97e8f99 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -996,58 +996,63 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 				break;
 		}
 	}
-	if (create_resp != 0) {
-		if (uid == 0 && (root_uses_machine_creds == 1 ||
-				service != NULL)) {
-			int nocache = 0;
-			int success = 0;
-			do {
-				gssd_refresh_krb5_machine_credential(clp->servername,
-								     NULL, service,
-								     tgtname);
-				/*
-				 * Get a list of credential cache names and try each
-				 * of them until one works or we've tried them all
-				 */
-				if (gssd_get_krb5_machine_cred_list(&credlist)) {
-					printerr(0, "ERROR: No credentials found "
-						 "for connection to server %s\n",
-						 clp->servername);
-						goto out_return_error;
-				}
-				for (ccname = credlist; ccname && *ccname; ccname++) {
-					gssd_setup_krb5_machine_gss_ccache(*ccname);
-					if ((create_auth_rpc_client(clp, &rpc_clnt,
-								    &auth, uid,
-								    AUTHTYPE_KRB5)) == 0) {
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
+	if (create_resp == 0)
+		goto resp_found;
+	if (uid == 0 && (root_uses_machine_creds == 1 || service != NULL)) {
+		int nocache = 0;
+		int success = 0;
+		do {
+			gssd_refresh_krb5_machine_credential(clp->servername,
+							     NULL, service,
+							     tgtname);
+			/*
+			 * Get a list of credential cache names and try each
+			 * of them until one works or we've tried them all
+			 */
+			if (gssd_get_krb5_machine_cred_list(&credlist)) {
+				printerr(0, "ERROR: No credentials found "
+					"for connection to server %s\n",
+					clp->servername);
+				goto out_return_error;
+			}
+			for (ccname = credlist; ccname && *ccname; ccname++) {
+				gssd_setup_krb5_machine_gss_ccache(*ccname);
+				if ((create_auth_rpc_client(clp, &rpc_clnt,
+							&auth, uid,
+							AUTHTYPE_KRB5)) == 0) {
+					/* Success! */
+					success++;
+					break;
+				} 
+				printerr(2, "WARNING: Failed to create machine "
+					"krb5 context with credentials cache "
+					"%s for server %s\n",
+					*ccname, clp->servername);
+			}
+			gssd_free_krb5_machine_cred_list(credlist);			
+			if (!success) {
+				if(nocache == 0) {
+					nocache++;
+					printerr(2, "WARNING: Machine cache is "
+						"prematurely expired or "
+						"corrupted trying to recreate "
+						"cache for server %s\n",
+						clp->servername);
+				} else {
+					printerr(1, "WARNING: Failed to create "
+						"machine krb5 context "
+						"with any credentials cache "
+						"for server %s\n",
+						clp->servername);
+					goto out_return_error;
 				}
-			} while(!success);
-		} else {
-			printerr(1, "WARNING: Failed to create krb5 context "
-				 "for user with uid %d for server %s\n",
-				 uid, clp->servername);
-			goto out_return_error;
-		}
+			}
+		} while(!success);
+	} else {
+		printerr(1, "WARNING: Failed to create krb5 context "
+			"for user with uid %d for server %s\n",
+			uid, clp->servername);
+		goto out_return_error;
 	}
 
 	if (!authgss_get_private_data(auth, &pd)) {
-- 
1.7.7.6

