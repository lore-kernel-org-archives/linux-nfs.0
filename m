Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:41754 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754410Ab1KQU0G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2011 15:26:06 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RR8Uc-0003Ga-T6
	for linux-nfs@vger.kernel.org; Thu, 17 Nov 2011 15:23:31 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] nfsidmap: Allow a particular key to be revoked.
Date: Thu, 17 Nov 2011 15:26:03 -0500
Message-Id: <1321561563-5862-3-git-send-email-steved@redhat.com>
In-Reply-To: <1321561563-5862-1-git-send-email-steved@redhat.com>
References: <1321561563-5862-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introducing three new command line arguments
that allow particular keys to be revoke

  -u will remove a uid key
  -g will revoke a gid key
  -r will revoke both the uid and gid keys

The user name has also needs to be supply
with these new flags.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c   |   84 ++++++++++++++++++++++++++++++++++++++++--
 utils/nfsidmap/nfsidmap.man |   23 ++++++++++--
 2 files changed, 99 insertions(+), 8 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 2625dc1..7b64cd4 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -13,7 +13,7 @@
 #include "xlog.h"
 
 int verbose = 0;
-char *usage="Usage: %s [-v] [-c [keyring]] [-t timeout] key desc";
+char *usage="Usage: %s [-v] [[-u|-g|-r key]] | [-c [keyring]] | [[-t timeout] key desc]";
 
 #define MAX_ID_LEN   11
 #define IDMAP_NAMESZ 128
@@ -22,6 +22,9 @@ char *usage="Usage: %s [-v] [-c [keyring]] [-t timeout] key desc";
 #define DEFAULT_KEYRING "id_resolver"
 #define PROCKEYS "/proc/keys"
 
+#define UIDKEYS 0x1
+#define GIDKEYS 0x2
+
 /*
  * Find either a user or group id based on the name@domain string
  */
@@ -130,6 +133,63 @@ static int keyring_clear(char *keyring)
 	xlog_err("'%s' keyring was not found.", keyring);
 	return 1;
 }
+/*
+ * Revoke a key 
+ */
+static int key_revoke(char *keystr, int keymask)
+{
+	FILE *fp;
+	char buf[BUFSIZ], *ptr;
+	key_serial_t key;
+	int mask;
+
+	xlog_syslog(0);
+
+	if ((fp = fopen(PROCKEYS, "r")) == NULL) {
+		xlog_err("fopen(%s) failed: %m", PROCKEYS);
+		return 1;
+	}
+
+	while(fgets(buf, BUFSIZ, fp) != NULL) {
+		if (strstr(buf, "keyring") != NULL)
+			continue;
+
+		mask = 0;
+		if ((ptr = strstr(buf, "uid:")) != NULL)
+			mask = UIDKEYS;
+		else if ((ptr = strstr(buf, "gid:")) != NULL)
+			mask = GIDKEYS;
+		else 
+			continue;
+
+		if ((keymask & mask) == 0)
+			continue;
+
+		if (strncmp(ptr+4, keystr, strlen(keystr)) != NULL)
+			continue;
+
+		if (verbose) {
+			*(strchr(buf, '\n')) = '\0';
+			xlog_warn("revoking '%s'", buf);
+		}
+		/*
+		 * The key is the first arugment in the string
+		 */
+		*(strchr(buf, ' ')) = '\0';
+		sscanf(buf, "%x", &key);
+
+		if (keyctl_revoke(key) < 0) {
+			xlog_err("keyctl_revoke(0x%x) failed: %m", key);
+			return 1;
+		}
+
+		keymask &= ~mask;
+		if (keymask == 0)
+			return 0;
+	}
+	xlog_err("'%s' key was not found.", keystr);
+	return 1;
+}
 
 int main(int argc, char **argv)
 {
@@ -139,8 +199,8 @@ int main(int argc, char **argv)
 	int rc = 1, opt;
 	int timeout = 600;
 	key_serial_t key;
-	char *progname, *keyring = NULL;
-	int clearring;
+	char *progname, *keyring = NULL, *keystr = NULL;
+	int clearring, keymask = 0;
 
 	/* Set the basename */
 	if ((progname = strrchr(argv[0], '/')) != NULL)
@@ -150,8 +210,20 @@ int main(int argc, char **argv)
 
 	xlog_open(progname);
 
-	while ((opt = getopt(argc, argv, "ct:v")) != -1) {
+	while ((opt = getopt(argc, argv, "u:g:r:ct:v")) != -1) {
 		switch (opt) {
+		case 'u':
+			keymask = UIDKEYS;
+			keystr = strdup(optarg);
+			break;
+		case 'g':
+			keymask = GIDKEYS;
+			keystr = strdup(optarg);
+			break;
+		case 'r':
+			keymask = GIDKEYS|UIDKEYS;
+			keystr = strdup(optarg);
+			break;
 		case 'c':
 			clearring++;
 			break;
@@ -167,6 +239,10 @@ int main(int argc, char **argv)
 		}
 	}
 
+	if (keystr) {
+		rc = key_revoke(keystr, keymask);
+		return rc;		
+	}
 	if (clearring) {
 		keyring = ((argc - optind) ? argv[optind] : NULL);
 		rc = keyring_clear(keyring);
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index db65a1f..216afd1 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -6,7 +6,11 @@
 .SH NAME
 nfsidmap \- The NFS idmapper upcall program
 .SH SYNOPSIS
-.B "nfsidmap [-v] [-c [keyring]] [-t timeout] key desc"
+.B "nfsidmap [-v] [-t timeout] key desc"
+.br
+.B "nfsidmap [-v] [-c [keyring]]"
+.br
+.B "nfsidmap [-v] [-u|-g|-r user]"
 .SH DESCRIPTION
 The file
 .I /usr/sbin/nfsidmap
@@ -18,9 +22,11 @@ is called by /sbin/request-key, and will perform the translation and
 initialize a key with the resulting information.
 .PP
 .I nfsidmap
-can also used to clear the keyring of all the keys.  
-This is useful when all the mappings have failed to due to an DNS outage
-or some other error resulting in all the cached uid/gid to be invalid.
+can also used to clear the keyring of all the keys or 
+revoke one particular key.  
+This is useful when the id mappings have failed to due 
+to a lookup error resulting in all the cached uids/gids to be set 
+to the user id nobody.
 .SH OPTIONS
 .TP
 .B -c [keyring]
@@ -28,10 +34,19 @@ Clear the keyring of all the keys. If a
 keyring is not supplied the default 
 keyring 'id_resolver' will be used.
 .TP
+.B -g user
+Revoke the gid key of the given user.
+.TP
+.B -r user
+Revoke both the uid and gid key of the given user.
+.TP
 .B -t timeout
 Set the expiration timer, in seconds, on the key.
 The default is 600 seconds (10 mins).
 .TP
+.B -u user
+Revoke the uid key of the given user.
+.TP
 .B -v
 Increases the verbosity of the output to syslog 
 (can be specified multiple times).
-- 
1.7.7

