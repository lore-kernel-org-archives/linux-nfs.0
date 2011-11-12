Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:37421 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754101Ab1KLPzs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 10:55:48 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RPFtM-0003Ia-9G
	for linux-nfs@vger.kernel.org; Sat, 12 Nov 2011 10:53:16 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] nfsidmap: Added -v and -t flags
Date: Sat, 12 Nov 2011 10:55:46 -0500
Message-Id: <1321113346-10106-3-git-send-email-steved@redhat.com>
In-Reply-To: <1321113346-10106-1-git-send-email-steved@redhat.com>
References: <1321113346-10106-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To aid in debugging, the -v flag can now be specified,
multiple time, on the command line to enable verbose
logging in both the nfsidmap command and libnfsidmap
library routines.

Also converted the timeout argument to use a -t flag.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsidmap/nfsidmap.c   |   45 +++++++++++++++++++++++++++++-------------
 utils/nfsidmap/nfsidmap.man |   26 +++++++++++++++++-------
 2 files changed, 49 insertions(+), 22 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 134d9bc..6f85c5f 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -9,17 +9,17 @@
 #include <keyutils.h>
 #include <nfsidmap.h>
 
-#include <syslog.h>
+#include <unistd.h>
 #include "xlog.h"
 
-/* gcc nfsidmap.c -o nfsidmap -l nfsidmap -l keyutils */
+int verbose = 0;
+char *usage="Usage: %s [-v] [-t timeout] key desc";
 
 #define MAX_ID_LEN   11
 #define IDMAP_NAMESZ 128
 #define USER  1
 #define GROUP 0
 
-
 /*
  * Find either a user or group id based on the name@domain string
  */
@@ -93,7 +93,7 @@ int main(int argc, char **argv)
 	char *arg;
 	char *value;
 	char *type;
-	int rc = 1;
+	int rc = 1, opt;
 	int timeout = 600;
 	key_serial_t key;
 	char *progname;
@@ -108,24 +108,41 @@ int main(int argc, char **argv)
 	xlog_syslog(1);
 	xlog_stderr(0);
 
-	if (argc < 3) {
+	while ((opt = getopt(argc, argv, "t:v")) != -1) {
+		switch (opt) {
+		case 'v':
+			verbose++;
+			break;
+		case 't':
+			timeout = atoi(optarg);
+			break;
+		default:
+			xlog_warn(usage, progname);
+			break;
+		}
+	}
+
+	if ((argc - optind) != 2) {
 		xlog_err("Bad arg count. Check /etc/request-key.conf");
+		xlog_warn(usage, progname);
 		return 1;
 	}
 
-	arg = malloc(sizeof(char) * strlen(argv[2]) + 1);
-	strcpy(arg, argv[2]);
+	if (verbose)
+		nfs4_set_debug(verbose, NULL);
+
+	key = strtol(argv[optind++], NULL, 10);
+
+	arg = malloc(sizeof(char) * strlen(argv[optind]) + 1);
+	strcpy(arg, argv[optind]);
 	type = strtok(arg, ":");
 	value = strtok(NULL, ":");
 
-	if (argc == 4) {
-		timeout = atoi(argv[3]);
-		if (timeout < 0)
-			timeout = 0;
+	if (verbose) {
+		xlog_warn("key: %ld type: %s value: %s timeout %ld",
+			key, type, value, timeout);
 	}
 
-	key = strtol(argv[1], NULL, 10);
-
 	if (strcmp(type, "uid") == 0)
 		rc = id_lookup(value, key, USER);
 	else if (strcmp(type, "gid") == 0)
@@ -135,7 +152,7 @@ int main(int argc, char **argv)
 	else if (strcmp(type, "group") == 0)
 		rc = name_lookup(value, key, GROUP);
 
-	/* Set timeout to 5 (600 seconds) minutes */
+	/* Set timeout to 10 (600 seconds) minutes */
 	if (rc == 0)
 		keyctl_set_timeout(key, timeout);
 
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index 2381908..c67aab6 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -5,6 +5,8 @@
 .TH nfsidmap 5 "1 October 2010"
 .SH NAME
 nfsidmap \- The NFS idmapper upcall program
+.SH SYNOPSIS
+.B "nfsidmap [-v] [-t timeout] key desc"
 .SH DESCRIPTION
 The file
 .I /usr/sbin/nfsidmap
@@ -14,9 +16,15 @@ the upcall and cache the result.
 .I /usr/sbin/nfsidmap
 should only be called by request-key, and will perform the translation and
 initialize a key with the resulting information.
-.PP
-NFS_USE_NEW_IDMAPPER must be selected when configuring the kernel to use this
-feature.
+.SH OPTIONS
+.TP
+.B -t timeout
+Set the expiration timer, in seconds, on the key.
+The default is 600 seconds (10 mins).
+.TP
+.B -v
+Increases the verbosity of the output to syslog 
+(can be specified multiple times).
 .SH CONFIGURING
 The file
 .I /etc/request-key.conf
@@ -25,11 +33,13 @@ will need to be modified so
 can properly direct the upcall. The following line should be added before a call
 to keyctl negate:
 .PP
-create	id_resolver	*	*	/usr/sbin/nfsidmap %k %d 600
+create	id_resolver	*	*	/usr/sbin/nfsidmap -t 600 %k %d 
 .PP
 This will direct all id_resolver requests to the program
-.I /usr/sbin/nfsidmap
-The last parameter, 600, defines how many seconds into the future the key will
+.I /usr/sbin/nfsidmap.
+The 
+.B -t 600 
+defines how many seconds into the future the key will
 expire.  This is an optional parameter for
 .I /usr/sbin/nfsidmap
 and will default to 600 seconds when not specified.
@@ -48,9 +58,9 @@ You can choose to handle any of these individually, rather than using the
 generic upcall program.  If you would like to use your own program for a uid
 lookup then you would edit your request-key.conf so it looks similar to this:
 .PP
-create	id_resolver	uid:*	*	/some/other/program %k %d 600
+create	id_resolver	uid:*	*	/some/other/program %k %d
 .br
-create	id_resolver	*		*	/usr/sbin/nfsidmap %k %d 600
+create	id_resolver	*		*	/usr/sbin/nfsidmap %k %d
 .PP
 Notice that the new line was added above the line for the generic program.
 request-key will find the first matching line and run the corresponding program.
-- 
1.7.7

