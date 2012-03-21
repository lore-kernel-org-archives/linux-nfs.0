Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:46529 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750966Ab2CUVAR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 17:00:17 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1SASdi-0003nW-DY
	for linux-nfs@vger.kernel.org; Wed, 21 Mar 2012 17:00:15 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] gssd: Look for user creds in user defined directory
Date: Wed, 21 Mar 2012 17:00:13 -0400
Message-Id: <1332363613-9930-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The user credential cache currently is kept in /tmp.
In upcoming Kerberos release that will be moved to
/run/user/<username>/. This patch enables gssd to
look in both the old and new caches

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd.c      |    2 +-
 utils/gssd/gssd.h      |    1 +
 utils/gssd/gssd_proc.c |   36 ++++++++++++++++++++++++++++++++++--
 3 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index ccadb07..d53795e 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -57,7 +57,7 @@
 
 char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
 char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
-char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
+char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR ":" GSSD_USER_CRED_DIR;
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
 int  use_memcache = 0;
 int  root_uses_machine_creds = 1;
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 40f824c..28a8206 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -45,6 +45,7 @@
 #define DNOTIFY_SIGNAL		(SIGRTMIN + 3)
 
 #define GSSD_DEFAULT_CRED_DIR			"/tmp"
+#define GSSD_USER_CRED_DIR			"/run/user"
 #define GSSD_DEFAULT_CRED_PREFIX		"krb5cc_"
 #define GSSD_DEFAULT_MACHINE_CRED_SUFFIX	"machine"
 #define GSSD_DEFAULT_KEYTAB_FILE		"/etc/krb5.keytab"
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index a51dbae..aa39435 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -918,6 +918,23 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	goto out;
 }
 
+static char *
+user_cachedir(char *dirname, uid_t uid)
+{
+	struct passwd *pw;
+	char *ptr;
+
+	if ((pw = getpwuid(uid)) == NULL) {
+		printerr(0, "user_cachedir: Failed to find '%d' uid"
+			    " for cache directory\n");
+		return NULL;
+	}
+	ptr = malloc(strlen(dirname)+strlen(pw->pw_name)+2);
+	if (ptr)
+		sprintf(ptr, "%s/%s", dirname, pw->pw_name);
+
+	return ptr;
+}
 /*
  * this code uses the userland rpcsec gss library to create a krb5
  * context on behalf of the kernel
@@ -932,7 +949,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	gss_buffer_desc		token;
 	char			**credlist = NULL;
 	char			**ccname;
-	char			**dirname;
+	char			**dirname, *dir, *userdir;
 	int			create_resp = -1;
 	int			err, downcall_err = -EACCES;
 
@@ -975,7 +992,22 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 				service == NULL)) {
 		/* Tell krb5 gss which credentials cache to use */
 		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
-			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
+			/* See if the user name is needed */
+			if (strncmp(*dirname, GSSD_USER_CRED_DIR, 
+					strlen(GSSD_USER_CRED_DIR)) == 0) {
+				userdir = user_cachedir(*dirname, uid);
+				if (userdir == NULL) 
+					continue;
+				dir = userdir;
+			} else
+				dir = *dirname;
+
+			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, dir);
+
+			if (userdir) {
+				free(userdir);
+				userdir = NULL;
+			}
 			if (err == -EKEYEXPIRED)
 				downcall_err = -EKEYEXPIRED;
 			else if (!err)
-- 
1.7.7.5

