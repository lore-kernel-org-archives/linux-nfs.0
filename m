Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47262 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797Ab3ISU5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 16:57:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, root <root@pip4.fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] gssd: let tgtname override clp->servicename
Date: Thu, 19 Sep 2013 16:57:19 -0400
Message-Id: <1379624239-31199-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1379624239-31199-1-git-send-email-bfields@redhat.com>
References: <1379624239-31199-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: root <root@pip4.fieldses.org>

When the kernel provides an explicit "target=" name in the upcall, that
should override the name in clp->servicename.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/gssd/gssd_proc.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 7200a78..e58c341 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -822,6 +822,7 @@ set_port:
  */
 static int
 create_auth_rpc_client(struct clnt_info *clp,
+		       char *tgtname,
 		       CLIENT **clnt_return,
 		       AUTH **auth_return,
 		       uid_t uid,
@@ -926,14 +927,16 @@ create_auth_rpc_client(struct clnt_info *clp,
 			 clnt_spcreateerror(rpc_errmsg));
 		goto out_fail;
 	}
+	if (!tgtname)
+		tgtname = clp->servicename;
 
-	printerr(2, "creating context with server %s\n", clp->servicename);
-	auth = authgss_create_default(rpc_clnt, clp->servicename, &sec);
+	printerr(2, "creating context with server %s\n", tgtname);
+	auth = authgss_create_default(rpc_clnt, tgtname, &sec);
 	if (!auth) {
 		/* Our caller should print appropriate message */
 		printerr(2, "WARNING: Failed to create krb5 context for "
 			    "user with uid %d for server %s\n",
-			 uid, clp->servername);
+			 uid, tgtname);
 		goto out_fail;
 	}
 
@@ -1015,7 +1018,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		/* Try first to acquire credentials directly via GSSAPI */
 		err = gssd_acquire_user_cred(uid, &gss_cred);
 		if (!err)
-			create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
+			create_resp = create_auth_rpc_client(clp, tgtname, &rpc_clnt, &auth, uid,
 							     AUTHTYPE_KRB5, gss_cred);
 		/* if create_auth_rplc_client fails try the traditional method of
 		 * trolling for credentials */
@@ -1024,7 +1027,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 			if (err == -EKEYEXPIRED)
 				downcall_err = -EKEYEXPIRED;
 			else if (!err)
-				create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
+				create_resp = create_auth_rpc_client(clp, tgtname, &rpc_clnt, &auth, uid,
 							     AUTHTYPE_KRB5, GSS_C_NO_CREDENTIAL);
 		}
 	}
@@ -1048,7 +1051,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 				}
 				for (ccname = credlist; ccname && *ccname; ccname++) {
 					gssd_setup_krb5_machine_gss_ccache(*ccname);
-					if ((create_auth_rpc_client(clp, &rpc_clnt,
+					if ((create_auth_rpc_client(clp, tgtname, &rpc_clnt,
 								    &auth, uid,
 								    AUTHTYPE_KRB5,
 								    GSS_C_NO_CREDENTIAL)) == 0) {
-- 
1.8.3.1

