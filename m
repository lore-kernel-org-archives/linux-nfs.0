Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:25922 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266AbaLLWh6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2014 17:37:58 -0500
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] GSSD add rpc_gss_svc_t to the gssd upcall
Date: Fri, 12 Dec 2014 17:37:54 -0500
Message-ID: <1418423874-1370-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Otherwise rpc.gssd will send a V4 NULL RPCSEC_GSS_INIT call with an RPCSEC_GSS
service of rpc_gss_svc_none for rpc_sec_gss_svc_integrity/privacy requests
from the kernel.

Companion patch to kernel patch SUNRPC add rpc_gss_svc_t to gssd upcall

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd_proc.c | 35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 121feb1..022cac3 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -841,7 +841,8 @@ create_auth_rpc_client(struct clnt_info *clp,
 		       AUTH **auth_return,
 		       uid_t uid,
 		       int authtype,
-		       gss_cred_id_t cred)
+		       gss_cred_id_t cred,
+		       int svc /* rpc_gss_svc_t */ )
 {
 	CLIENT			*rpc_clnt = NULL;
 	struct rpc_gss_sec	sec;
@@ -855,7 +856,7 @@ create_auth_rpc_client(struct clnt_info *clp,
 	socklen_t		salen;
 
 	sec.qop = GSS_C_QOP_DEFAULT;
-	sec.svc = RPCSEC_GSS_SVC_NONE;
+	sec.svc = svc;
 	sec.cred = cred;
 	sec.req_flags = 0;
 	if (authtype == AUTHTYPE_KRB5) {
@@ -1029,7 +1030,7 @@ change_identity(uid_t uid)
  */
 static void
 process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
-		    char *service)
+		    char *service, int svc)
 {
 	CLIENT			*rpc_clnt = NULL;
 	AUTH			*auth = NULL;
@@ -1113,7 +1114,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		err = gssd_acquire_user_cred(&gss_cred);
 		if (!err)
 			create_resp = create_auth_rpc_client(clp, tgtname, &rpc_clnt, &auth, uid,
-							     AUTHTYPE_KRB5, gss_cred);
+							     AUTHTYPE_KRB5, gss_cred, svc);
 		/* if create_auth_rplc_client fails try the traditional method of
 		 * trolling for credentials */
 		for (dirname = ccachesearch; create_resp != 0 && *dirname != NULL; dirname++) {
@@ -1122,7 +1123,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 				downcall_err = -EKEYEXPIRED;
 			else if (!err)
 				create_resp = create_auth_rpc_client(clp, tgtname, &rpc_clnt, &auth, uid,
-							     AUTHTYPE_KRB5, GSS_C_NO_CREDENTIAL);
+							     AUTHTYPE_KRB5, GSS_C_NO_CREDENTIAL, svc);
 		}
 	}
 	if (create_resp != 0) {
@@ -1148,7 +1149,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 					if ((create_auth_rpc_client(clp, tgtname, &rpc_clnt,
 								    &auth, uid,
 								    AUTHTYPE_KRB5,
-								    GSS_C_NO_CREDENTIAL)) == 0) {
+								    GSS_C_NO_CREDENTIAL, svc)) == 0) {
 						/* Success! */
 						success++;
 						break;
@@ -1243,7 +1244,8 @@ handle_krb5_upcall(struct clnt_info *clp)
 		return;
 	}
 
-	process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL);
+	process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL,
+			    RPCSEC_GSS_SVC_NONE);
 }
 
 void
@@ -1251,6 +1253,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 {
 	uid_t			uid;
 	char			*lbuf = NULL;
+	int			svc = 0; /* rpc_gss_service_t */
 	int			lbuflen = 0;
 	char			*p;
 	char			*mech = NULL;
@@ -1300,6 +1303,21 @@ handle_gssd_upcall(struct clnt_info *clp)
 		goto out;
 	}
 
+	/* read rpc_gss_service_t */
+	if ((p = strstr(lbuf, "svc=")) != NULL) {
+		if (sscanf(p, "svc=%d", &svc) != 1) {
+			printerr(0, "WARNING: handle_gssd_upcall: "
+				    "failed to parse svc "
+				    "in upcall string '%s'\n", lbuf);
+			goto out;
+		}
+	} else {
+		printerr(0, "WARNING: handle_gssd_upcall: "
+			    "failed to find svc "
+			    "in upcall string '%s'\n", lbuf);
+		goto out;
+	}
+
 	/* read supported encryption types if supplied */
 	if ((p = strstr(lbuf, "enctypes=")) != NULL) {
 		enctypes = malloc(lbuflen);
@@ -1353,7 +1371,8 @@ handle_gssd_upcall(struct clnt_info *clp)
 	}
 
 	if (strcmp(mech, "krb5") == 0 && clp->servername)
-		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service);
+		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service,
+				    svc);
 	else {
 		if (clp->servername)
 			printerr(0, "WARNING: handle_gssd_upcall: "
-- 
1.9.3 (Apple Git-50)

