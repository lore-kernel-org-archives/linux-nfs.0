Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758429Ab2HUUvo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:51:44 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7LKpiQi029076
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2012 16:51:44 -0400
Received: from blade.bos.redhat.com (blade.bos.redhat.com [10.16.184.36])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q7LKph0U023342
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2012 16:51:44 -0400
Received: from blade.bos.redhat.com (localhost.localdomain [127.0.0.1])
	by blade.bos.redhat.com (8.14.5/8.14.5) with ESMTP id q7LKphuh015938
	for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2012 16:51:43 -0400
Received: (from nalin@localhost)
	by blade.bos.redhat.com (8.14.5/8.14.5/Submit) id q7LKpgiv015931
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 16:51:42 -0400
Date: Tue, 21 Aug 2012 16:51:37 -0400
From: Nalin Dahyabhai <nalin@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] scan for DIR: ccaches, too
Message-ID: <20120821205137.GD9511@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In addition to matching "FILE:krb5cc_*" in the specified directory or
directories, also match "DIR:krb5cc*", if we find subdirectories with
names that match the search pattern.

Signed-off-by: Nalin Dahyabhai <nalin@redhat.com>
---
 utils/gssd/gssd.h      |  2 +-
 utils/gssd/krb5_util.c | 50 ++++++++++++++++++++++++++++++++------------------
 2 files changed, 33 insertions(+), 19 deletions(-)

diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 71a140b..1d923d7 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -46,7 +46,7 @@
 
 #define GSSD_DEFAULT_CRED_DIR			"/tmp"
 #define GSSD_USER_CRED_DIR			"/run/user"
-#define GSSD_DEFAULT_CRED_PREFIX		"krb5cc_"
+#define GSSD_DEFAULT_CRED_PREFIX		"krb5cc"
 #define GSSD_DEFAULT_MACHINE_CRED_SUFFIX	"machine"
 #define GSSD_DEFAULT_KEYTAB_FILE		"/etc/krb5.keytab"
 #define GSSD_SERVICE_NAME			"nfs"
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 887d118..2389276 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -139,7 +139,7 @@ int limit_to_legacy_enctypes = 0;
 
 static int select_krb5_ccache(const struct dirent *d);
 static int gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
-		struct dirent **d);
+		const char **cctype, struct dirent **d);
 static int gssd_get_single_krb5_cred(krb5_context context,
 		krb5_keytab kt, struct gssd_k5_kt_princ *ple, int nocache);
 static int query_krb5_ccache(const char* cred_cache, char **ret_princname,
@@ -178,7 +178,8 @@ select_krb5_ccache(const struct dirent *d)
  * code otherwise.
  */
 static int
-gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
+gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
+			       const char **cctype, struct dirent **d)
 {
 	struct dirent **namelist;
 	int n;
@@ -192,6 +193,7 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 	int score, best_match_score = 0, err = -EACCES;
 
 	memset(&best_match_stat, 0, sizeof(best_match_stat));
+	*cctype = NULL;
 	*d = NULL;
 	n = scandir(dirname, &namelist, select_krb5_ccache, 0);
 	if (n < 0) {
@@ -203,41 +205,51 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 		for (i = 0; i < n; i++) {
 			snprintf(statname, sizeof(statname),
 				 "%s/%s", dirname, namelist[i]->d_name);
-			printerr(3, "CC file '%s' being considered, "
+			printerr(3, "CC '%s' being considered, "
 				 "with preferred realm '%s'\n",
 				 statname, preferred_realm ?
 					preferred_realm : "<none selected>");
-			snprintf(buf, sizeof(buf), "FILE:%s/%s", dirname, 
-					namelist[i]->d_name);
 			if (lstat(statname, &tmp_stat)) {
-				printerr(0, "Error doing stat on file '%s'\n",
+				printerr(0, "Error doing stat on '%s'\n",
 					 statname);
 				free(namelist[i]);
 				continue;
 			}
 			/* Only pick caches owned by the user (uid) */
 			if (tmp_stat.st_uid != uid) {
-				printerr(3, "CC file '%s' owned by %u, not %u\n",
+				printerr(3, "CC '%s' owned by %u, not %u\n",
 					 statname, tmp_stat.st_uid, uid);
 				free(namelist[i]);
 				continue;
 			}
-			if (!S_ISREG(tmp_stat.st_mode)) {
-				printerr(3, "CC file '%s' is not a regular file\n",
+			if (!S_ISREG(tmp_stat.st_mode) &&
+			    !S_ISDIR(tmp_stat.st_mode)) {
+				printerr(3, "CC '%s' is not a regular "
+					 "file or directory\n",
 					 statname);
 				free(namelist[i]);
 				continue;
 			}
 			if (uid == 0 && !root_uses_machine_creds && 
 				strstr(namelist[i]->d_name, "_machine_")) {
-				printerr(3, "CC file '%s' not available to root\n",
+				printerr(3, "CC '%s' not available to root\n",
 					 statname);
 				free(namelist[i]);
 				continue;
 			}
+			if (S_ISDIR(tmp_stat.st_mode)) {
+				*cctype = "DIR";
+			} else
+			if (S_ISREG(tmp_stat.st_mode)) {
+				*cctype = "FILE";
+			} else {
+				continue;
+			}
+			snprintf(buf, sizeof(buf), "%s:%s/%s", *cctype,
+				 dirname, namelist[i]->d_name);
 			if (!query_krb5_ccache(buf, &princname, &realm)) {
-				printerr(3, "CC file '%s' is expired or corrupt\n",
-					 statname);
+				printerr(3, "CC '%s' is expired or corrupt\n",
+					 buf);
 				free(namelist[i]);
 				err = -EKEYEXPIRED;
 				continue;
@@ -248,9 +260,9 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 					strcmp(realm, preferred_realm) == 0) 
 				score++;
 
-			printerr(3, "CC file '%s'(%s@%s) passed all checks and"
+			printerr(3, "CC '%s'(%s@%s) passed all checks and"
 				    " has mtime of %u\n",
-				 statname, princname, realm, 
+				 buf, princname, realm, 
 				 tmp_stat.st_mtime);
 			/*
 			 * if more than one match is found, return the most
@@ -284,10 +296,11 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 				else {
 					free(namelist[i]);
 				}
-				printerr(3, "CC file '%s/%s' is our "
+				printerr(3, "CC '%s:%s/%s' is our "
 					    "current best match "
 					    "with mtime of %u\n",
-					 dirname, best_match_dir->d_name,
+					 cctype, dirname,
+					 best_match_dir->d_name,
 					 best_match_stat.st_mtime);
 			}
 			free(princname);
@@ -1026,17 +1039,18 @@ int
 gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirname)
 {
 	char			buf[MAX_NETOBJ_SZ];
+	const char		*cctype;
 	struct dirent		*d;
 	int			err;
 
 	printerr(2, "getting credentials for client with uid %u for "
 		    "server %s\n", uid, servername);
 	memset(buf, 0, sizeof(buf));
-	err = gssd_find_existing_krb5_ccache(uid, dirname, &d);
+	err = gssd_find_existing_krb5_ccache(uid, dirname, &cctype, &d);
 	if (err)
 		return err;
 
-	snprintf(buf, sizeof(buf), "FILE:%s/%s", dirname, d->d_name);
+	snprintf(buf, sizeof(buf), "%s:%s/%s", cctype, dirname, d->d_name);
 	free(d);
 
 	printerr(2, "using %s as credentials cache for client with "
-- 
1.7.11.5

