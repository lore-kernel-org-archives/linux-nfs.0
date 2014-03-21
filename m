Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hobo-dev.uvm.edu ([132.198.101.84]:58212 "EHLO hobo-dev.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbaCXMzj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Mar 2014 08:55:39 -0400
Received: from hobo-dev.uvm.edu (localhost [127.0.0.1])
	by hobo-dev.uvm.edu (8.14.4/8.14.4) with ESMTP id s2OBopd0010686
	for <linux-nfs@vger.kernel.org>; Mon, 24 Mar 2014 07:50:51 -0400
Message-Id: <201403241150.s2OBonLC010685@hobo-dev.uvm.edu>
From: Benjamin Coddington <bcodding@uvm.edu>
Date: Fri, 21 Mar 2014 17:08:12 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsidmap: use multiple child keyrings
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel keyring has a max of ~508 entries on 64-bit systems.
For installations with more distict users than this limit, create
a specified number of child keyrings and fill them evenly.
---
 utils/nfsidmap/nfsidmap.c   |   76 +++++++++++++++++++++++++++++++++---------
 utils/nfsidmap/nfsidmap.man |    5 ++-
 2 files changed, 63 insertions(+), 18 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 2518ed6..41abede 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -15,7 +15,7 @@
 #include "conffile.h"
 
 int verbose = 0;
-char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
+char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] [-n count] key desc]";
 
 #define MAX_ID_LEN   11
 #define IDMAP_NAMESZ 128
@@ -24,7 +24,7 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
 
 #define PROCKEYS "/proc/keys"
 #ifndef DEFAULT_KEYRING
-#define DEFAULT_KEYRING "id_resolver"
+#define DEFAULT_KEYRING ".id_resolver"
 #endif
 
 #ifndef PATH_IDMAPDCONF
@@ -39,7 +39,7 @@ static int keyring_clear(char *keyring);
 /*
  * Find either a user or group id based on the name@domain string
  */
-int id_lookup(char *name_at_domain, key_serial_t key, int type)
+int id_lookup(char *name_at_domain, key_serial_t key, int type, key_serial_t dest_keyring)
 {
 	char id[MAX_ID_LEN];
 	uid_t uid = 0;
@@ -58,7 +58,7 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 			(type == USER ? "nfs4_owner_to_uid" : "nfs4_group_owner_to_gid"));
 
 	if (rc == 0) {
-		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
+		rc = keyctl_instantiate(key, id, strlen(id) + 1, dest_keyring);
 		if (rc < 0) {
 			switch(rc) {
 			case -EDQUOT:
@@ -67,9 +67,9 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 				/*
 			 	 * The keyring is full. Clear the keyring and try again
 			 	 */
-				rc = keyring_clear(DEFAULT_KEYRING);
+				rc = keyctl_clear(dest_keyring);
 				if (rc == 0)
-					rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
+					rc = keyctl_instantiate(key, id, strlen(id) + 1, dest_keyring);
 				break;
 			default:
 				break;
@@ -85,7 +85,7 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 /*
  * Find the name@domain string from either a user or group id
  */
-int name_lookup(char *id, key_serial_t key, int type)
+int name_lookup(char *id, key_serial_t key, int type, key_serial_t dest_keyring)
 {
 	char name[IDMAP_NAMESZ];
 	char domain[NFS4_MAX_DOMAIN_LEN];
@@ -113,7 +113,7 @@ int name_lookup(char *id, key_serial_t key, int type)
 			(type == USER ? "nfs4_uid_to_name" : "nfs4_gid_to_name"));
 
 	if (rc == 0) {
-		rc = keyctl_instantiate(key, &name, strlen(name), 0);
+		rc = keyctl_instantiate(key, &name, strlen(name), dest_keyring);
 		if (rc < 0)
 			xlog_err("name_lookup: keyctl_instantiate failed: %m");
 	}
@@ -127,7 +127,7 @@ static int keyring_clear(char *keyring)
 {
 	FILE *fp;
 	char buf[BUFSIZ];
-	key_serial_t key;
+	key_serial_t key, child_key;
 
 	if (keyring == NULL)
 		keyring = DEFAULT_KEYRING;
@@ -151,6 +151,7 @@ static int keyring_clear(char *keyring)
 		 */
 		*(strchr(buf, ' ')) = '\0';
 		sscanf(buf, "%x", &key);
+
 		if (keyctl_clear(key) < 0) {
 			xlog_err("keyctl_clear(0x%x) failed: %m", key);
 			fclose(fp);
@@ -159,7 +160,8 @@ static int keyring_clear(char *keyring)
 		fclose(fp);
 		return 0;
 	}
-	xlog_err("'%s' keyring was not found.", keyring);
+	if (strstr(keyring, DEFAULT_KEYRING":"))
+		xlog_err("'%s' keyring was not found.", keyring);
 	fclose(fp);
 	return 1;
 }
@@ -232,8 +234,10 @@ int main(int argc, char **argv)
 	char *type;
 	int rc = 1, opt;
 	int timeout = 600;
-	key_serial_t key;
+	int childrings = 0;
+	key_serial_t key, parent_keyring, dest_keyring;
 	char *progname, *keystr = NULL;
+	char child_name[BUFSIZ];
 	int clearing = 0, keymask = 0;
 
 	/* Set the basename */
@@ -244,7 +248,7 @@ int main(int argc, char **argv)
 
 	xlog_open(progname);
 
-	while ((opt = getopt(argc, argv, "u:g:r:ct:v")) != -1) {
+	while ((opt = getopt(argc, argv, "u:g:r:ct:vn:d:")) != -1) {
 		switch (opt) {
 		case 'u':
 			keymask = UIDKEYS;
@@ -267,6 +271,9 @@ int main(int argc, char **argv)
 		case 't':
 			timeout = atoi(optarg);
 			break;
+		case 'n':
+			childrings = atoi(optarg);
+			break;
 		default:
 			xlog_warn(usage, progname);
 			break;
@@ -284,9 +291,16 @@ int main(int argc, char **argv)
 		rc = key_revoke(keystr, keymask);
 		return rc;		
 	}
+
 	if (clearing) {
 		xlog_syslog(0);
-		rc = keyring_clear(DEFAULT_KEYRING);
+		int i = 1;
+		for(rc = 0; rc == 0; i++) {
+			snprintf(child_name, sizeof(child_name), DEFAULT_KEYRING "_child_%d", i);
+			rc = keyring_clear(child_name);
+		}
+
+		rc = keyring_clear(DEFAULT_KEYRING ":");
 		return rc;		
 	}
 
@@ -315,14 +329,42 @@ int main(int argc, char **argv)
 			key, type, value, timeout);
 	}
 
+	if (childrings) {
+		int i;
+		long child_size, smallest_size = 2032;
+		parent_keyring = request_key("keyring", DEFAULT_KEYRING, NULL, KEY_SPEC_THREAD_KEYRING);
+
+		for (i = 1; i <= childrings; i++) {
+			key_serial_t child_keyring;
+
+			snprintf(child_name, sizeof(child_name), DEFAULT_KEYRING "_child_%d", i);
+
+			child_keyring = keyctl_search(parent_keyring, "keyring", child_name, 0);
+			if (child_keyring < 0) {
+				child_keyring = add_key("keyring", child_name, NULL, 0, parent_keyring);
+				xlog_warn("added new child %s: %m", child_name);
+			}
+
+			child_size = keyctl_read(child_keyring, NULL, 0);
+			if (child_size < smallest_size) {
+				dest_keyring = child_keyring;
+				smallest_size = child_size;
+			}
+		}
+	}
+
 	if (strcmp(type, "uid") == 0)
-		rc = id_lookup(value, key, USER);
+		rc = id_lookup(value, key, USER, dest_keyring);
 	else if (strcmp(type, "gid") == 0)
-		rc = id_lookup(value, key, GROUP);
+		rc = id_lookup(value, key, GROUP, dest_keyring);
 	else if (strcmp(type, "user") == 0)
-		rc = name_lookup(value, key, USER);
+		rc = name_lookup(value, key, USER, dest_keyring);
 	else if (strcmp(type, "group") == 0)
-		rc = name_lookup(value, key, GROUP);
+		rc = name_lookup(value, key, GROUP, dest_keyring);
+
+	/* if we hung this off a child, unlink from the parent */
+	if (dest_keyring)
+		keyctl_unlink(key, parent_keyring);
 
 	/* Set timeout to 10 (600 seconds) minutes */
 	if (rc == 0)
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index 3a3a523..04f0014 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -6,7 +6,7 @@
 .SH NAME
 nfsidmap \- The NFS idmapper upcall program
 .SH SYNOPSIS
-.B "nfsidmap [-v] [-t timeout] key desc"
+.B "nfsidmap [-v] [-t timeout] [-n count] key desc"
 .br
 .B "nfsidmap [-v] [-c]"
 .br
@@ -42,6 +42,9 @@ Revoke both the uid and gid key of the given user.
 Set the expiration timer, in seconds, on the key.
 The default is 600 seconds (10 mins).
 .TP
+.B -n count
+Set the the number of child keyrings to create.
+.TP
 .B -u user
 Revoke the uid key of the given user.
 .TP
-- 
1.7.1

