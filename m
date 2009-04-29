From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 7/7] gssd: process service= attribute in new upcall
Date: Wed, 29 Apr 2009 17:56:47 -0400
Message-ID: <20090429215647.25811.27317.stgit@jazz.citi.umich.edu>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47730 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759175AbZD2V4r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2009 17:56:47 -0400
In-Reply-To: <20090429214300.25811.81332.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

Add processing of the "service=" attribute in the new gssd upcall.

If "service" is specified, then the kernel is indicating that
we must use machine credentials for this request.  (Regardless
of the uid value or the setting of root_uses_machine_creds.)
If the service value is "*", then any service name can be used.
Otherwise, it specifies the service name that should be used.
(For now, the values of service will only be "*" or "nfs".)

Restricting gssd to use "nfs" service name is needed for when
the NFS server is doing a callback to the NFS client.  In this
case, the NFS server has to authenticate itself as "nfs" --
even if there are other service keys such as "host" or "root"
in the keytab.

Another case when the kernel may specify the service attribute
is when gssd is being asked to create the context for a
SETCLIENT_ID operation.  In this case, machine credentials
must be used for the authentication.  However, the service name
used for this case is not important.

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd_proc.c |   63 +++++++++++++++++++++++++++++++++++++++++++-----
 utils/gssd/krb5_util.c |   21 ++++++++++++----
 utils/gssd/krb5_util.h |    3 ++
 3 files changed, 75 insertions(+), 12 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 12eb5b3..b48fd38 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -885,7 +885,8 @@ int create_auth_rpc_client(struct clnt_info *clp,
  * context on behalf of the kernel
  */
 static void
-process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname)
+process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
+		    char *service)
 {
 	CLIENT			*rpc_clnt = NULL;
 	AUTH			*auth = NULL;
@@ -908,7 +909,31 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname)
 	token.value = NULL;
 	memset(&pd, 0, sizeof(struct authgss_private_data));
 
-	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0)) {
+	/*
+	 * If "service" is specified, then the kernel is indicating that
+	 * we must use machine credentials for this request.  (Regardless
+	 * of the uid value or the setting of root_uses_machine_creds.)
+	 * If the service value is "*", then any service name can be used.
+	 * Otherwise, it specifies the service name that should be used.
+	 * (For now, the values of service will only be "*" or "nfs".)
+	 *
+	 * Restricting gssd to use "nfs" service name is needed for when
+	 * the NFS server is doing a callback to the NFS client.  In this
+	 * case, the NFS server has to authenticate itself as "nfs" --
+	 * even if there are other service keys such as "host" or "root"
+	 * in the keytab.
+	 *
+	 * Another case when the kernel may specify the service attribute
+	 * is when gssd is being asked to create the context for a
+	 * SETCLIENT_ID operation.  In this case, machine credentials
+	 * must be used for the authentication.  However, the service name
+	 * used for this case is not important.
+	 *
+	 */
+	printerr(2, "%s: service is '%s'\n", __func__,
+		 service ? service : "<null>");
+	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
+				service == NULL)) {
 		/* Tell krb5 gss which credentials cache to use */
 		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
 			if (gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname) == 0)
@@ -919,11 +944,13 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname)
 		}
 	}
 	if (create_resp != 0) {
-		if (uid == 0 && root_uses_machine_creds == 1) {
+
+		if (uid == 0 && (root_uses_machine_creds == 1 ||
+				service != NULL)) {
 			int success = 0;
 
 			gssd_refresh_krb5_machine_credential(clp->servername,
-							     NULL);
+							     NULL, service);
 			/*
 			 * Get a list of credential cache names and try each
 			 * of them until one works or we've tried them all
@@ -1062,7 +1089,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 		return;
 	}
 
-	return process_krb5_upcall(clp, uid, clp->krb5_fd, NULL);
+	return process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL);
 }
 
 void
@@ -1088,6 +1115,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 	char			*p;
 	char			*mech = NULL;
 	char			*target = NULL;
+	char			*service = NULL;
 
 	printerr(1, "handling gssd upcall (%s)\n", clp->dirname);
 
@@ -1144,8 +1172,30 @@ handle_gssd_upcall(struct clnt_info *clp)
 		}
 	}
 
+	/*
+	 * read the service name
+	 *
+	 * The presence of attribute "service=" indicates that machine
+	 * credentials should be used for this request.  If the value
+	 * is "*", then any machine credentials available can be used.
+	 * If the value is anything else, then machine credentials for
+	 * the specified service name (always "nfs" for now) should be
+	 * used.
+	 */
+	if ((p = strstr(lbuf, "service=")) != NULL) {
+		service = malloc(lbuflen);
+		if (!service)
+			goto out;
+		if (sscanf(p, "service=%s", service) != 1) {
+			printerr(0, "WARNING: handle_gssd_upcall: "
+				    "failed to parse service type "
+				    "in upcall string '%s'\n", lbuf);
+			goto out;
+		}
+	}
+
 	if (strcmp(mech, "krb5") == 0)
-		process_krb5_upcall(clp, uid, clp->gssd_fd, target);
+		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service);
 	else if (strcmp(mech, "spkm3") == 0)
 		process_spkm3_upcall(clp, uid, clp->gssd_fd);
 	else
@@ -1156,6 +1206,7 @@ out:
 	free(lbuf);
 	free(mech);
 	free(target);
+	free(service);
 	return;	
 }
 
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 3009cc5..ef12ec5 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -796,10 +796,9 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
  */
 static int
 find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
-		  krb5_keytab_entry *kte)
+		  krb5_keytab_entry *kte, const char **svcnames)
 {
 	krb5_error_code code;
-	const char *svcnames[] = { "root", "nfs", "host", NULL };
 	char **realmnames = NULL;
 	char myhostname[NI_MAXHOST], targethostname[NI_MAXHOST];
 	int i, j, retval;
@@ -1095,7 +1094,8 @@ gssd_get_krb5_machine_cred_list(char ***list)
 	for (ple = gssd_k5_kt_princ_list; ple; ple = ple->next) {
 		if (ple->ccname) {
 			/* Make sure cred is up-to-date before returning it */
-			retval = gssd_refresh_krb5_machine_credential(NULL, ple);
+			retval = gssd_refresh_krb5_machine_credential(NULL, ple,
+					NULL);
 			if (retval)
 				continue;
 			if (i + 1 > listsize) {
@@ -1185,13 +1185,24 @@ gssd_destroy_krb5_machine_creds(void)
  */
 int
 gssd_refresh_krb5_machine_credential(char *hostname,
-				     struct gssd_k5_kt_princ *ple)
+				     struct gssd_k5_kt_princ *ple,
+				     char *service)
 {
 	krb5_error_code code = 0;
 	krb5_context context;
 	krb5_keytab kt = NULL;;
 	int retval = 0;
 	char *k5err = NULL;
+	const char *svcnames[4] = { "root", "nfs", "host", NULL };
+
+	/*
+	 * If a specific service name was specified, use it.
+	 * Otherwise, use the default list.
+	 */
+	if (service != NULL && strcmp(service, "*") != 0) {
+		svcnames[0] = service;
+		svcnames[1] = NULL;
+	}
 
 	if (hostname == NULL && ple == NULL)
 		return EINVAL;
@@ -1215,7 +1226,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
 	if (ple == NULL) {
 		krb5_keytab_entry kte;
 
-		code = find_keytab_entry(context, kt, hostname, &kte);
+		code = find_keytab_entry(context, kt, hostname, &kte, svcnames);
 		if (code) {
 			printerr(0, "ERROR: %s: no usable keytab entry found "
 				 "in keytab %s for connection with host %s\n",
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index 3d39300..b696ea4 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -30,7 +30,8 @@ void gssd_free_krb5_machine_cred_list(char **list);
 void gssd_setup_krb5_machine_gss_ccache(char *servername);
 void gssd_destroy_krb5_machine_creds(void);
 int  gssd_refresh_krb5_machine_credential(char *hostname,
-					  struct gssd_k5_kt_princ *ple);
+					  struct gssd_k5_kt_princ *ple,
+					  char *service);
 char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
 void gssd_k5_get_default_realm(char **def_realm);
 

