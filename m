Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:47122 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756334Ab1KWPYG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Nov 2011 10:24:06 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RTEda-0003qX-HP
	for linux-nfs@vger.kernel.org; Wed, 23 Nov 2011 10:21:26 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] nfsidmap: Allow keys to be cleared from the keyring
Date: Wed, 23 Nov 2011 10:24:01 -0500
Message-Id: <1322061842-1806-2-git-send-email-steved@redhat.com>
In-Reply-To: <1322061842-1806-1-git-send-email-steved@redhat.com>
References: <1322061842-1806-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added the '-c' command line argument that will
clear all the keys from the keyring.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c   |   66 ++++++++++++++++++++++++++++++++++++++++--
 utils/nfsidmap/nfsidmap.man |   12 +++++++-
 2 files changed, 73 insertions(+), 5 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 6a09f38..cec2cb3 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -13,13 +13,19 @@
 #include "xlog.h"
 
 int verbose = 0;
-char *usage="Usage: %s [-v] [-t timeout] key desc";
+char *usage="Usage: %s [-v] [-c || [-t timeout] key desc]";
 
 #define MAX_ID_LEN   11
 #define IDMAP_NAMESZ 128
 #define USER  1
 #define GROUP 0
 
+#define PROCKEYS "/proc/keys"
+#ifndef DEFAULT_KEYRING
+#define DEFAULT_KEYRING "id_resolver"
+#endif
+
+
 /*
  * Find either a user or group id based on the name@domain string
  */
@@ -87,6 +93,50 @@ int name_lookup(char *id, key_serial_t key, int type)
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
@@ -97,6 +147,7 @@ int main(int argc, char **argv)
 	int timeout = 600;
 	key_serial_t key;
 	char *progname;
+	int clearring;
 
 	/* Set the basename */
 	if ((progname = strrchr(argv[0], '/')) != NULL)
@@ -105,11 +156,12 @@ int main(int argc, char **argv)
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
@@ -122,6 +174,12 @@ int main(int argc, char **argv)
 		}
 	}
 
+	if (clearring) {
+		rc = keyring_clear(DEFAULT_KEYRING);
+		return rc;		
+	}
+
+	xlog_stderr(0);
 	if ((argc - optind) != 2) {
 		xlog_err("Bad arg count. Check /etc/request-key.conf");
 		xlog_warn(usage, progname);
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index c67aab6..9badb3f 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -7,6 +7,8 @@
 nfsidmap \- The NFS idmapper upcall program
 .SH SYNOPSIS
 .B "nfsidmap [-v] [-t timeout] key desc"
+.br
+.B "nfsidmap [-v] [-c]"
 .SH DESCRIPTION
 The file
 .I /usr/sbin/nfsidmap
@@ -14,10 +16,18 @@ is used by the NFS idmapper to translate user and group ids into names, and to
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
+.B -c 
+Clear the keyring of all the keys.
+.TP
 .B -t timeout
 Set the expiration timer, in seconds, on the key.
 The default is 600 seconds (10 mins).
-- 
1.7.7

