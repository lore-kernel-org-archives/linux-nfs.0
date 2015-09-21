Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:51454 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbbIUUuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2015 16:50:44 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/4] GSSD: move process_krb5_updcall non machine cred case to helper function
Date: Mon, 21 Sep 2015 16:50:07 -0400
Message-ID: <1442868609-1812-3-git-send-email-andros@netapp.com>
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
 utils/gssd/gssd_proc.c | 74 ++++++++++++++++++++++++++++++++------------------
 1 file changed, 47 insertions(+), 27 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index f5a9ce1..0e04570 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -483,6 +483,49 @@ change_identity(uid_t uid)
 }
 
 AUTH *
+krb5_not_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
+			int *downcall_err, int *chg_err, CLIENT **rpc_clnt)
+{
+	AUTH		*auth = NULL;
+	gss_cred_id_t	gss_cred;
+	char		**dname;
+	int		err, resp = -1;
+
+	*chg_err = change_identity(uid);
+	if (*chg_err) {
+		printerr(0, "WARNING: failed to change identity: %s",
+			strerror(*chg_err));
+		goto out;
+	}
+
+	/** Tell krb5 gss which credentials cache to use.
+	 * Try first to acquire credentials directly via GSSAPI
+	 */
+	err = gssd_acquire_user_cred(&gss_cred);
+	if (err == 0)
+		resp = create_auth_rpc_client(clp, tgtname, rpc_clnt,
+						&auth, uid,
+						AUTHTYPE_KRB5, gss_cred);
+
+	/** if create_auth_rplc_client fails try the traditional
+	 * method of trolling for credentials
+	 */
+	for (dname = ccachesearch; resp != 0 && *dname != NULL; dname++) {
+		err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername,
+						*dname);
+		if (err == -EKEYEXPIRED)
+			*downcall_err = -EKEYEXPIRED;
+		else if (err == 0)
+			resp = create_auth_rpc_client(clp, tgtname, rpc_clnt,
+						&auth, uid,AUTHTYPE_KRB5,
+						GSS_C_NO_CREDENTIAL);
+	}
+
+out:
+	return auth;
+}
+
+AUTH *
 krb5_use_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
 		    char *service, CLIENT **rpc_clnt)
 {
@@ -552,10 +595,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	AUTH			*auth = NULL;
 	struct authgss_private_data pd;
 	gss_buffer_desc		token;
-	char			**dirname;
-	int			create_resp = -1;
 	int			err, downcall_err = -EACCES;
-	gss_cred_id_t		gss_cred;
 	OM_uint32		maj_stat, min_stat, lifetime_rec;
 	pid_t			pid;
 	gss_name_t		gacceptor = GSS_C_NO_NAME;
@@ -615,32 +655,12 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		 service ? service : "<null>");
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
 				service == NULL)) {
-
-		err = change_identity(uid);
-		if (err) {
-			printerr(0, "WARNING: failed to change identity: %s",
-				 strerror(err));
+		auth = krb5_not_machine_creds(clp, uid, tgtname, &downcall_err,
+						&err, &rpc_clnt);
+		if (err)
 			goto out_return_error;
-		}
-
-		/* Tell krb5 gss which credentials cache to use */
-		/* Try first to acquire credentials directly via GSSAPI */
-		err = gssd_acquire_user_cred(&gss_cred);
-		if (!err)
-			create_resp = create_auth_rpc_client(clp, tgtname, &rpc_clnt, &auth, uid,
-							     AUTHTYPE_KRB5, gss_cred);
-		/* if create_auth_rplc_client fails try the traditional method of
-		 * trolling for credentials */
-		for (dirname = ccachesearch; create_resp != 0 && *dirname != NULL; dirname++) {
-			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
-			if (err == -EKEYEXPIRED)
-				downcall_err = -EKEYEXPIRED;
-			else if (!err)
-				create_resp = create_auth_rpc_client(clp, tgtname, &rpc_clnt, &auth, uid,
-							     AUTHTYPE_KRB5, GSS_C_NO_CREDENTIAL);
-		}
 	}
-	if (create_resp != 0) {
+	if (auth == NULL) {
 		if (uid == 0 && (root_uses_machine_creds == 1 ||
 				service != NULL)) {
 			auth =	krb5_use_machine_creds(clp, uid, tgtname,
-- 
1.9.3 (Apple Git-50)

