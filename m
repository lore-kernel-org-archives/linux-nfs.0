Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12385 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486Ab2LCSqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2012 13:46:21 -0500
From: andros@netapp.com
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/2] GSSD: gssd_setup_krb5_user_keyring_ccache
Date: Mon,  3 Dec 2012 13:46:09 -0500
Message-Id: <1354560369-2427-3-git-send-email-andros@netapp.com>
In-Reply-To: <1354560369-2427-1-git-send-email-andros@netapp.com>
References: <1354560369-2427-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd_proc.c |   15 +++++++++++++++
 utils/gssd/krb5_util.c |   31 +++++++++++++++++++++++++++++++
 utils/gssd/krb5_util.h |    1 +
 3 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 97e8f99..e24dbcb 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -984,6 +984,20 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		 service ? service : "<null>");
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
 				service == NULL)) {
+		if (use_keyring) {
+			err = gssd_setup_krb5_user_keyring_ccache(uid,
+							clp->servername);
+			if (err == -EKEYEXPIRED)
+				downcall_err = -EKEYEXPIRED;
+			else if (!err)
+				create_resp = create_auth_rpc_client(clp,
+							&rpc_clnt, &auth, uid,
+							AUTHTYPE_KRB5);
+			if (create_resp == 0)
+				goto resp_found;
+
+		}
+
 		/* Tell krb5 gss which credentials cache to use */
 		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
 			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
@@ -1055,6 +1069,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		goto out_return_error;
 	}
 
+resp_found:
 	if (!authgss_get_private_data(auth, &pd)) {
 		printerr(1, "WARNING: Failed to obtain authentication "
 			    "data for user with uid %d for server %s\n",
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 8d42e8f..ae701a5 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -1039,6 +1039,37 @@ err_cache:
 /*==========================*/
 
 /*
+ * Attempt to find a KEYRING cache of the form KEYRING:krb5cc_<UID>.
+ *
+ * Returns 0 if a ccache was found, and a non-zero error code otherwise.
+ */
+int
+gssd_setup_krb5_user_keyring_ccache(uid_t uid, char *servername)
+{
+	char	buf[MAX_NETOBJ_SZ];
+	char	*princ = NULL, *realm = NULL;
+	int	err = -EKEYEXPIRED;
+
+	snprintf(buf, sizeof(buf), "%s:%s_%u", "KEYRING",
+		GSSD_DEFAULT_CRED_PREFIX, uid);
+
+	if (!query_krb5_ccache(buf, &princ, &realm)) {
+		printerr(3, "CC '%s' is expired or corrupt\n", buf);
+		goto out;
+	}
+	err = 0;
+	printerr(2, "Using CC '%s' as credentials cache for %s@%s with "
+		"uid %u for server %s\n", buf, princ, realm, uid, servername);
+
+	free(princ);
+	free(realm);
+
+	gssd_set_krb5_ccache_name(buf);
+out:
+	return err;
+}
+
+/*
  * Attempt to find the best match for a credentials cache file
  * given only a UID.  We really need more information, but we
  * do the best we can.
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index 9f41625..472b65e 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -25,6 +25,7 @@ struct gssd_k5_kt_princ {
 
 int gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername,
 				     char *dirname);
+int gssd_setup_krb5_user_keyring_ccache(uid_t uid, char *servername);
 int  gssd_get_krb5_machine_cred_list(char ***list);
 void gssd_free_krb5_machine_cred_list(char **list);
 void gssd_setup_krb5_machine_gss_ccache(char *servername);
-- 
1.7.7.6

