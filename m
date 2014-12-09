Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51265 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753576AbaLIFlK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:10 -0500
Subject: [PATCH 04/19] nfs-utils: gssd - remove arbitrary
 GSSD_MAX_CCACHE_SEARCH limitation
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:00 +0100
Message-ID: <20141209054100.24756.28340.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get rid of another arbitrary limitation and PATH_MAX array.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |   45 ++++++++++++++++++++++++++++++++++-----------
 utils/gssd/gssd.h |    3 +--
 2 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 6147d30..60e753c 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -69,8 +69,7 @@
 
 static char *pipefs_dir = GSSD_PIPEFS_DIR;
 char *keytabfile = GSSD_DEFAULT_KEYTAB_FILE;
-char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR ":" GSSD_USER_CRED_DIR;
-char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
+char **ccachesearch;
 int  use_memcache = 0;
 int  root_uses_machine_creds = 1;
 unsigned int  context_timeout = 0;
@@ -318,8 +317,8 @@ main(int argc, char *argv[])
 	int i;
 	extern char *optarg;
 	char *progname;
+	char *ccachedir = NULL;
 
-	memset(ccachesearch, 0, sizeof(ccachesearch));
 	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:T:R:")) != -1) {
 		switch (opt) {
 			case 'f':
@@ -347,9 +346,7 @@ main(int argc, char *argv[])
 				keytabfile = optarg;
 				break;
 			case 'd':
-				strncpy(ccachedir, optarg, sizeof(ccachedir));
-				if (ccachedir[sizeof(ccachedir)-1] != '\0')
-					errx(1, "ccachedir path name too long");
+				ccachedir = optarg;
 				break;
 			case 't':
 				context_timeout = atoi(optarg);
@@ -388,11 +385,37 @@ main(int argc, char *argv[])
 		exit(1);
 	}
 
-	i = 0;
-	ccachesearch[i++] = strtok(ccachedir, ":");
-	do {
-		ccachesearch[i++] = strtok(NULL, ":");
-	} while (ccachesearch[i-1] != NULL && i < GSSD_MAX_CCACHE_SEARCH);
+	if (ccachedir) {
+		char *ccachedir_copy;
+		char *ptr;
+
+		for (ptr = ccachedir, i = 2; *ptr; ptr++)
+			if (*ptr == ':')
+				i++;
+
+		ccachesearch = malloc(i * sizeof(char *));
+	       	ccachedir_copy = strdup(ccachedir);
+		if (!ccachedir_copy || !ccachesearch) {
+			printerr(0, "malloc failure\n");
+			exit(EXIT_FAILURE);
+		}
+
+		i = 0;
+		ccachesearch[i++] = strtok(ccachedir, ":");
+		while(ccachesearch[i - 1])
+			ccachesearch[i++] = strtok(NULL, ":");
+
+	} else {
+		ccachesearch = malloc(3 * sizeof(char *));
+		if (!ccachesearch) {
+			printerr(0, "malloc failure\n");
+			exit(EXIT_FAILURE);
+		}
+
+		ccachesearch[0] = GSSD_DEFAULT_CRED_DIR;
+		ccachesearch[1] = GSSD_USER_CRED_DIR;
+		ccachesearch[2] = NULL;
+	}
 
 	if (preferred_realm == NULL)
 		gssd_k5_get_default_realm(&preferred_realm);
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 4059544..3320d5e 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -51,7 +51,6 @@
 #define GSSD_DEFAULT_KEYTAB_FILE		"/etc/krb5.keytab"
 #define GSSD_SERVICE_NAME			"nfs"
 #define GSSD_SERVICE_NAME_LEN			3
-#define GSSD_MAX_CCACHE_SEARCH			16
 
 /*
  * The gss mechanisms that we can handle
@@ -59,7 +58,7 @@
 enum {AUTHTYPE_KRB5, AUTHTYPE_LIPKEY};
 
 extern char		       *keytabfile;
-extern char		       *ccachesearch[];
+extern char		      **ccachesearch;
 extern int			use_memcache;
 extern int			root_uses_machine_creds;
 extern unsigned int 		context_timeout;

