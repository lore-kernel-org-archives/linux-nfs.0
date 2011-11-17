Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:57476 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752538Ab1KQVvk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2011 16:51:40 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RR9pR-0003K1-Rp
	for linux-nfs@vger.kernel.org; Thu, 17 Nov 2011 16:49:06 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] nfsidmap: Allow all keys to clear on the keyring
Date: Thu, 17 Nov 2011 16:51:35 -0500
Message-Id: <1321566696-7298-2-git-send-email-steved@redhat.com>
In-Reply-To: <1321566696-7298-1-git-send-email-steved@redhat.com>
References: <1321566696-7298-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce the '-c [keyring]' command line argument
which will clear the giving keyring of the keys.
If a keyring not supplied the default 'id_resolver'
keyring will be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c   |   65 +++++++++++++++++++++++++++++++++++++++---
 utils/nfsidmap/nfsidmap.man |   14 ++++++++-
 2 files changed, 72 insertions(+), 7 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 6a09f38..84a57fe 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -13,12 +13,14 @@
 #include "xlog.h"
 
 int verbose = 0;
-char *usage="Usage: %s [-v] [-t timeout] key desc";
+char *usage="Usage: %s [-v] [-c [keyring]] [-t timeout] key desc";
 
 #define MAX_ID_LEN   11
 #define IDMAP_NAMESZ 128
 #define USER  1
 #define GROUP 0
+#define DEFAULT_KEYRING "id_resolver"
+#define PROCKEYS "/proc/keys"
 
 /*
  * Find either a user or group id based on the name@domain string
@@ -87,6 +89,50 @@ int name_lookup(char *id, key_serial_t key, int type)
 out:
 	return rc;
 }
+/*
+ * Clear all the keys on the given keyring
+ */
+static int keyring_clear(char *keyring)
+{
+	FILE *fp;
+	char buf[BUFSIZ];
+	key_serial_t key;
+
+	xlog_syslog(0);
+	if (keyring == NULL)
+		keyring = DEFAULT_KEYRING;
+
+	if ((fp = fopen(PROCKEYS, "r")) == NULL) {
+		xlog_err("fopen(%s) failed: %m", PROCKEYS);
+		return 1;
+	}
+
+	while(fgets(buf, BUFSIZ, fp) != NULL) {
+		if (strstr(buf, "keyring") == NULL)
+			continue;
+		if (strstr(buf, keyring) == NULL)
+			continue;
+		if (verbose) {
+			*(strchr(buf, '\n')) = '\0';
+			xlog_warn("clearing '%s'", buf);
+		}
+		/*
+		 * The key is the first arugment in the string
+		 */
+		*(strchr(buf, ' ')) = '\0';
+		sscanf(buf, "%x", &key);
+		if (keyctl_clear(key) < 0) {
+			xlog_err("keyctl_clear(0x%x) failed: %m", key);
+			fclose(fp);
+			return 1;
+		}
+		fclose(fp);
+		return 0;
+	}
+	xlog_err("'%s' keyring was not found.", keyring);
+	fclose(fp);
+	return 1;
+}
 
 int main(int argc, char **argv)
 {
@@ -96,7 +142,8 @@ int main(int argc, char **argv)
 	int rc = 1, opt;
 	int timeout = 600;
 	key_serial_t key;
-	char *progname;
+	char *progname, *keyring = NULL;
+	int clearring;
 
 	/* Set the basename */
 	if ((progname = strrchr(argv[0], '/')) != NULL)
@@ -105,11 +152,12 @@ int main(int argc, char **argv)
 		progname = argv[0];
 
 	xlog_open(progname);
-	xlog_syslog(1);
-	xlog_stderr(0);
 
-	while ((opt = getopt(argc, argv, "t:v")) != -1) {
+	while ((opt = getopt(argc, argv, "ct:v")) != -1) {
 		switch (opt) {
+		case 'c':
+			clearring++;
+			break;
 		case 'v':
 			verbose++;
 			break;
@@ -122,6 +170,13 @@ int main(int argc, char **argv)
 		}
 	}
 
+	if (clearring) {
+		keyring = ((argc - optind) ? argv[optind] : NULL);
+		rc = keyring_clear(keyring);
+		return rc;		
+	}
+
+	xlog_stderr(0);
 	if ((argc - optind) != 2) {
 		xlog_err("Bad arg count. Check /etc/request-key.conf");
 		xlog_warn(usage, progname);
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index c67aab6..db65a1f 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -6,7 +6,7 @@
 .SH NAME
 nfsidmap \- The NFS idmapper upcall program
 .SH SYNOPSIS
-.B "nfsidmap [-v] [-t timeout] key desc"
+.B "nfsidmap [-v] [-c [keyring]] [-t timeout] key desc"
 .SH DESCRIPTION
 The file
 .I /usr/sbin/nfsidmap
@@ -14,10 +14,20 @@ is used by the NFS idmapper to translate user and group ids into names, and to
 translate user and group names into ids. Idmapper uses request-key to perform
 the upcall and cache the result.
 .I /usr/sbin/nfsidmap
-should only be called by request-key, and will perform the translation and
+is called by /sbin/request-key, and will perform the translation and
 initialize a key with the resulting information.
+.PP
+.I nfsidmap
+can also used to clear the keyring of all the keys.  
+This is useful when all the mappings have failed to due to an DNS outage
+or some other error resulting in all the cached uid/gid to be invalid.
 .SH OPTIONS
 .TP
+.B -c [keyring]
+Clear the keyring of all the keys. If a
+keyring is not supplied the default 
+keyring 'id_resolver' will be used.
+.TP
 .B -t timeout
 Set the expiration timer, in seconds, on the key.
 The default is 600 seconds (10 mins).
-- 
1.7.7

