Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12385 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170Ab2LCSqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2012 13:46:21 -0500
From: andros@netapp.com
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/2] GSSD: Add keyring ccache for machine credential
Date: Mon,  3 Dec 2012 13:46:08 -0500
Message-Id: <1354560369-2427-2-git-send-email-andros@netapp.com>
In-Reply-To: <1354560369-2427-1-git-send-email-andros@netapp.com>
References: <1354560369-2427-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd.c      |   10 ++++++++--
 utils/gssd/gssd.h      |    1 +
 utils/gssd/krb5_util.c |   18 ++++++++++++------
 3 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index a3292c9..1250e34 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -60,6 +60,7 @@ char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
 char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR ":" GSSD_USER_CRED_DIR;
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
 int  use_memcache = 0;
+int  use_keyring = 0;
 int  root_uses_machine_creds = 1;
 unsigned int  context_timeout = 0;
 char *preferred_realm = NULL;
@@ -85,7 +86,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
+	fprintf(stderr, "usage: %s [-f] [-l] [-K | -M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
 		progname);
 	exit(1);
 }
@@ -102,16 +103,21 @@ main(int argc, char *argv[])
 	char *progname;
 
 	memset(ccachesearch, 0, sizeof(ccachesearch));
-	while ((opt = getopt(argc, argv, "fvrlmnMp:k:d:t:R")) != -1) {
+	while ((opt = getopt(argc, argv, "fvrlKmnMp:k:d:t:R")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
 				break;
+			case 'K':
+				use_keyring = 1;
+				use_memcache = 0;
+				break;
 			case 'm':
 				/* Accept but ignore this. Now the default. */
 				break;
 			case 'M':
 				use_memcache = 1;
+				use_keyring = 0;
 				break;
 			case 'n':
 				root_uses_machine_creds = 0;
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 86472a1..168f99c 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -64,6 +64,7 @@ extern char			pipefs_dir[PATH_MAX];
 extern char			keytabfile[PATH_MAX];
 extern char			*ccachesearch[];
 extern int			use_memcache;
+extern int			use_keyring;
 extern int			root_uses_machine_creds;
 extern unsigned int 		context_timeout;
 extern char			*preferred_realm;
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index aeb8f70..8d42e8f 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -407,15 +407,21 @@ gssd_get_single_krb5_cred(krb5_context context,
 	/*
 	 * Initialize cache file which we're going to be using
 	 */
-
-	if (use_memcache)
-	    cache_type = "MEMORY";
-	else
-	    cache_type = "FILE";
-	snprintf(cc_name, sizeof(cc_name), "%s:%s/%s%s_%s",
+	if (use_keyring) {
+	    snprintf(cc_name, sizeof(cc_name), "%s:%s%s_%s",
+		"KEYRING",
+		GSSD_DEFAULT_CRED_PREFIX,
+		GSSD_DEFAULT_MACHINE_CRED_SUFFIX, ple->realm);
+	} else {
+	    if (use_memcache)
+	        cache_type = "MEMORY";
+	    else
+	        cache_type = "FILE";
+	    snprintf(cc_name, sizeof(cc_name), "%s:%s/%s%s_%s",
 		cache_type,
 		ccachesearch[0], GSSD_DEFAULT_CRED_PREFIX,
 		GSSD_DEFAULT_MACHINE_CRED_SUFFIX, ple->realm);
+	}
 	ple->endtime = my_creds.times.endtime;
 	if (ple->ccname != NULL)
 		free(ple->ccname);
-- 
1.7.7.6

