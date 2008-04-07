From: Vince Busam <vbusam@google.com>
Subject: [PATCH] gssd: search multiple directories for credentials
Date: Mon, 7 Apr 2008 14:42:28 -0700
Message-ID: <20080407214228.GA11350@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:53667 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbYDGVm0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2008 17:42:26 -0400
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m37Lg6uZ032595
	for <linux-nfs@vger.kernel.org>; Mon, 7 Apr 2008 22:42:06 +0100
Received: from localhost (dig.smo.corp.google.com [172.29.60.89])
	by zps19.corp.google.com with ESMTP id m37Lg4pl025292
	for <linux-nfs@vger.kernel.org>; Mon, 7 Apr 2008 14:42:05 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We store kerberos credentials in multiple places, and it would be nice to
search them for a valid credential when making NFS requests.  This patch
allows that.

diff -up --recursive nfs-utils-1.1.1.orig/utils/gssd/gssd.c nfs-utils-1.1.1/utils/gssd/gssd.c
--- nfs-utils-1.1.1.orig/utils/gssd/gssd.c	2007-10-18 20:07:28.000000000 -0700
+++ nfs-utils-1.1.1/utils/gssd/gssd.c	2008-03-17 13:35:39.000000000 -0700
@@ -57,6 +57,7 @@ char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_
 char pipefs_nfsdir[PATH_MAX] = GSSD_PIPEFS_DIR;
 char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
 char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
+char *ccachesearch[GSSD_MAX_CCACHE_SEARCH];
 int  use_memcache = 0;
 int  root_uses_machine_creds = 1;
 
@@ -93,9 +94,11 @@ main(int argc, char *argv[])
 	int verbosity = 0;
 	int rpc_verbosity = 0;
 	int opt;
+	int i;
 	extern char *optarg;
 	char *progname;
 
+	memset(ccachesearch, 0, sizeof(ccachesearch));
 	while ((opt = getopt(argc, argv, "fvrmnMp:k:d:")) != -1) {
 		switch (opt) {
 			case 'f':
@@ -130,6 +133,12 @@ main(int argc, char *argv[])
 				strncpy(ccachedir, optarg, sizeof(ccachedir));
 				if (ccachedir[sizeof(ccachedir)-1] != '\0')
 					errx(1, "ccachedir path name too long");
+				i = 0;
+				strtok(ccachedir,":");
+				do {
+					ccachesearch[i] = strtok(NULL,":");
+					i++;
+				} while (ccachesearch[i-1] && (i<(GSSD_MAX_CCACHE_SEARCH-1)));
 				break;
 			default:
 				usage(argv[0]);
diff -up --recursive nfs-utils-1.1.1.orig/utils/gssd/gssd.h nfs-utils-1.1.1/utils/gssd/gssd.h
--- nfs-utils-1.1.1.orig/utils/gssd/gssd.h	2007-10-18 20:07:28.000000000 -0700
+++ nfs-utils-1.1.1/utils/gssd/gssd.h	2008-03-12 13:10:19.000000000 -0700
@@ -50,6 +50,7 @@
 #define GSSD_DEFAULT_KEYTAB_FILE		"/etc/krb5.keytab"
 #define GSSD_SERVICE_NAME			"nfs"
 #define GSSD_SERVICE_NAME_LEN			3
+#define GSSD_MAX_CCACHE_SEARCH			16
 
 /*
  * The gss mechanisms that we can handle
@@ -62,6 +63,7 @@ extern char			pipefs_dir[PATH_MAX];
 extern char			pipefs_nfsdir[PATH_MAX];
 extern char			keytabfile[PATH_MAX];
 extern char			ccachedir[PATH_MAX];
+extern char			*ccachesearch[GSSD_MAX_CCACHE_SEARCH];
 extern int			use_memcache;
 extern int			root_uses_machine_creds;
 
diff -up --recursive nfs-utils-1.1.1.orig/utils/gssd/gssd.man nfs-utils-1.1.1/utils/gssd/gssd.man
--- nfs-utils-1.1.1.orig/utils/gssd/gssd.man	2007-10-18 20:07:28.000000000 -0700
+++ nfs-utils-1.1.1/utils/gssd/gssd.man	2008-03-12 13:10:19.000000000 -0700
@@ -75,6 +75,8 @@ where to look for the rpc_pipefs filesys
 Tells
 .B rpc.gssd
 where to look for kerberos credential files.  The default value is "/tmp".
+This can also be a colon separated list of directories to search through
+for a kerberos credential file.
 .TP
 .B -v
 Increases the verbosity of the output (can be specified multiple times).
diff -up --recursive nfs-utils-1.1.1.orig/utils/gssd/gssd_proc.c nfs-utils-1.1.1/utils/gssd/gssd_proc.c
--- nfs-utils-1.1.1.orig/utils/gssd/gssd_proc.c	2007-10-18 20:07:28.000000000 -0700
+++ nfs-utils-1.1.1/utils/gssd/gssd_proc.c	2008-03-12 14:44:26.000000000 -0700
@@ -691,10 +691,18 @@ handle_krb5_upcall(struct clnt_info *clp
 
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0)) {
 		/* Tell krb5 gss which credentials cache to use */
-		gssd_setup_krb5_user_gss_ccache(uid, clp->servername);
+		gssd_setup_krb5_user_gss_ccache(uid, clp->servername, ccachedir);
 
 		create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
 						     AUTHTYPE_KRB5);
+		for (ccname = ccachesearch; *ccname; ccname++) {
+			gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *ccname);
+
+			create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
+							     AUTHTYPE_KRB5);
+			if (create_resp == 0)
+				break;
+		}
 	}
 	if (create_resp != 0) {
 		if (uid == 0 && root_uses_machine_creds == 1) {
diff -up --recursive nfs-utils-1.1.1.orig/utils/gssd/krb5_util.c nfs-utils-1.1.1/utils/gssd/krb5_util.c
--- nfs-utils-1.1.1.orig/utils/gssd/krb5_util.c	2007-10-18 20:07:28.000000000 -0700
+++ nfs-utils-1.1.1/utils/gssd/krb5_util.c	2008-03-12 13:10:19.000000000 -0700
@@ -131,7 +131,8 @@ struct gssd_k5_kt_princ *gssd_k5_kt_prin
 /*==========================*/
 
 static int select_krb5_ccache(const struct dirent *d);
-static int gssd_find_existing_krb5_ccache(uid_t uid, struct dirent **d);
+static int gssd_find_existing_krb5_ccache(uid_t uid, struct dirent **d,
+		char *directory);
 static int gssd_get_single_krb5_cred(krb5_context context,
 		krb5_keytab kt, struct gssd_k5_kt_princ *ple);
 
@@ -170,7 +171,7 @@ select_krb5_ccache(const struct dirent *
  *	1 => found an existing entry
  */
 static int
-gssd_find_existing_krb5_ccache(uid_t uid, struct dirent **d)
+gssd_find_existing_krb5_ccache(uid_t uid, struct dirent **d, char *directory)
 {
 	struct dirent **namelist;
 	int n;
@@ -181,7 +182,7 @@ gssd_find_existing_krb5_ccache(uid_t uid
 
 	memset(&best_match_stat, 0, sizeof(best_match_stat));
 	*d = NULL;
-	n = scandir(ccachedir, &namelist, select_krb5_ccache, 0);
+	n = scandir(directory, &namelist, select_krb5_ccache, 0);
 	if (n < 0) {
 		perror("scandir looking for krb5 credentials caches");
 	}
@@ -191,7 +192,7 @@ gssd_find_existing_krb5_ccache(uid_t uid
 			printerr(3, "CC file '%s' being considered\n",
 				 namelist[i]->d_name);
 			snprintf(statname, sizeof(statname),
-				 "%s/%s", ccachedir, namelist[i]->d_name);
+				 "%s/%s", directory, namelist[i]->d_name);
 			if (lstat(statname, &tmp_stat)) {
 				printerr(0, "Error doing stat on file '%s'\n",
 					 statname);
@@ -892,7 +893,7 @@ out:
  *	void
  */
 void
-gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername)
+gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *directory)
 {
 	char			buf[MAX_NETOBJ_SZ];
 	struct dirent		*d;
@@ -900,14 +901,14 @@ gssd_setup_krb5_user_gss_ccache(uid_t ui
 	printerr(2, "getting credentials for client with uid %u for "
 		    "server %s\n", uid, servername);
 	memset(buf, 0, sizeof(buf));
-	if (gssd_find_existing_krb5_ccache(uid, &d)) {
+	if (gssd_find_existing_krb5_ccache(uid, &d, directory)) {
 		snprintf(buf, sizeof(buf), "FILE:%s/%s",
-			ccachedir, d->d_name);
+			directory, d->d_name);
 		free(d);
 	}
 	else
 		snprintf(buf, sizeof(buf), "FILE:%s/%s%u",
-			ccachedir, GSSD_DEFAULT_CRED_PREFIX, uid);
+			directory, GSSD_DEFAULT_CRED_PREFIX, uid);
 	printerr(2, "using %s as credentials cache for client with "
 		    "uid %u for server %s\n", buf, uid, servername);
 	gssd_set_krb5_ccache_name(buf);
diff -up --recursive nfs-utils-1.1.1.orig/utils/gssd/krb5_util.h nfs-utils-1.1.1/utils/gssd/krb5_util.h
--- nfs-utils-1.1.1.orig/utils/gssd/krb5_util.h	2007-10-18 20:07:28.000000000 -0700
+++ nfs-utils-1.1.1/utils/gssd/krb5_util.h	2008-03-12 13:10:19.000000000 -0700
@@ -17,7 +17,8 @@ struct gssd_k5_kt_princ {
 };
 
 
-void gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername);
+void gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername,
+                                     char *directory);
 int  gssd_get_krb5_machine_cred_list(char ***list);
 void gssd_free_krb5_machine_cred_list(char **list);
 void gssd_setup_krb5_machine_gss_ccache(char *servername);
