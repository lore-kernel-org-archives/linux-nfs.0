Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:33708 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbbHEOp4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 10:45:56 -0400
Received: by qged69 with SMTP id d69so31323513qge.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 07:45:56 -0700 (PDT)
Subject: [PATCH v2 3/6] nfsidmap: List cached ID mapping results
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2015 10:45:53 -0400
Message-ID: <20150805144553.13266.47361.stgit@manet.1015granger.net>
In-Reply-To: <20150805143258.13266.92369.stgit@manet.1015granger.net>
References: <20150805143258.13266.92369.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

User space can see the keys, but not their contents.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/nfsidmap/nfsidmap.c   |   86 ++++++++++++++++++++++++++++++++++++++++++-
 utils/nfsidmap/nfsidmap.man |   15 ++++++++
 2 files changed, 98 insertions(+), 3 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 6005125..65b5511 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -17,7 +17,7 @@
 #include "conffile.h"
 
 int verbose = 0;
-char *usage = "Usage: %s [-v] [-c || [-u|-g|-r key] || -d || [-t timeout] key desc]";
+char *usage = "Usage: %s [-v] [-c || [-u|-g|-r key] || -d || -l || [-t timeout] key desc]";
 
 #define MAX_ID_LEN   11
 #define IDMAP_NAMESZ 128
@@ -108,6 +108,81 @@ static int display_default_domain(void)
 	return EXIT_SUCCESS;
 }
 
+static void list_key(key_serial_t key)
+{
+	char *buffer, *c;
+	int rc;
+
+	rc = keyctl_describe_alloc(key, &buffer);
+	if (rc < 0) {
+		switch (errno) {
+		case EKEYEXPIRED:
+			printf("Expired key not displayed\n");
+			break;
+		default:
+			xlog_err("Failed to describe key: %m");
+		}
+		return;
+	}
+
+	c = strrchr(buffer, ';');
+	if (!c) {
+		xlog_err("Unparsable key not displayed\n");
+		goto out_free;
+	}
+	printf("  %s\n", ++c);
+
+out_free:
+	free(buffer);
+}
+
+static void list_keys(const char *ring_name, key_serial_t ring_id)
+{
+	key_serial_t *key;
+	void *keylist;
+	int count;
+
+	count = keyctl_read_alloc(ring_id, &keylist);
+	if (count < 0) {
+		xlog_err("Failed to read keyring %s: %m", ring_name);
+		return;
+	}
+	count /= (int)sizeof(*key);
+
+	switch (count) {
+	case 0:
+		printf("No %s keys found.\n", ring_name);
+		break;
+	case 1:
+		printf("1 %s key found:\n", ring_name);
+		break;
+	default:
+		printf("%u %s keys found:\n", count, ring_name);
+	}
+
+	for (key = keylist; count--; key++)
+		list_key(*key);
+
+	free(keylist);
+}
+
+/*
+ * List all keys on a keyring
+ */
+static int list_keyring(const char *keyring)
+{
+	key_serial_t key;
+
+	key = find_key_by_type_and_desc("keyring", keyring, 0);
+	if (key == -1) {
+		xlog_err("'%s' keyring was not found.", keyring);
+		return EXIT_FAILURE;
+	}
+
+	list_keys(keyring, key);
+	return EXIT_SUCCESS;
+}
+
 /*
  * Find either a user or group id based on the name@domain string
  */
@@ -277,7 +352,7 @@ int main(int argc, char **argv)
 	int timeout = 600;
 	key_serial_t key;
 	char *progname, *keystr = NULL;
-	int clearing = 0, keymask = 0, display = 0;
+	int clearing = 0, keymask = 0, display = 0, list = 0;
 
 	/* Set the basename */
 	if ((progname = strrchr(argv[0], '/')) != NULL)
@@ -287,11 +362,14 @@ int main(int argc, char **argv)
 
 	xlog_open(progname);
 
-	while ((opt = getopt(argc, argv, "du:g:r:ct:v")) != -1) {
+	while ((opt = getopt(argc, argv, "du:g:r:ct:vl")) != -1) {
 		switch (opt) {
 		case 'd':
 			display++;
 			break;
+		case 'l':
+			list++;
+			break;
 		case 'u':
 			keymask = UIDKEYS;
 			keystr = strdup(optarg);
@@ -328,6 +406,8 @@ int main(int argc, char **argv)
 
 	if (display)
 		return display_default_domain();
+	if (list)
+		return list_keyring(DEFAULT_KEYRING);
 	if (keystr) {
 		rc = key_invalidate(keystr, keymask);
 		return rc;		
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index 04ddff6..0275bdf 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -13,6 +13,8 @@ nfsidmap \- The NFS idmapper upcall program
 .B "nfsidmap [-v] [-u|-g|-r user]"
 .br
 .B "nfsidmap -d"
+.br
+.B "nfsidmap -l"
 .SH DESCRIPTION
 The NFSv4 protocol represents the local system's UID and GID values
 on the wire as strings of the form
@@ -50,6 +52,13 @@ can also clear cached ID map results in the kernel,
 or revoke one particular key.
 An incorrect cached key can result in file and directory ownership
 reverting to "nobody" on NFSv4 mount points.
+.PP
+In addition, the
+.B -d
+and
+.B -l
+options are available to help diagnose misconfigurations.
+They have no effect on the keyring containing ID mapping results.
 .SH OPTIONS
 .TP
 .B -c 
@@ -62,6 +71,12 @@ Display the system's effective NFSv4 domain name on
 .B -g user
 Revoke the gid key of the given user.
 .TP
+.B -l
+Display on
+.I stdout
+all keys currently in the keyring used to cache ID mapping results.
+These keys are visible only to the superuser.
+.TP
 .B -r user
 Revoke both the uid and gid key of the given user.
 .TP

