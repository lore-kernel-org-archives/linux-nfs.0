Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hobo-dev.uvm.edu ([132.198.101.84]:58582 "EHLO hobo-dev.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbaCYBZe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Mar 2014 21:25:34 -0400
Received: from hobo-dev.uvm.edu (localhost [127.0.0.1])
	by hobo-dev.uvm.edu (8.14.4/8.14.4) with ESMTP id s2P1PX1Z051487
	for <linux-nfs@vger.kernel.org>; Mon, 24 Mar 2014 21:25:33 -0400
Message-Id: <0460776cb199d3af99a86cf2f4e37900cb984698.1395710586.git.root@hobo-dev.uvm.edu>
In-Reply-To: <cover.1395710586.git.root@hobo-dev.uvm.edu>
References: <cover.1395710586.git.root@hobo-dev.uvm.edu>
From: Benjamin Coddington <bcodding@uvm.edu>
To: linux-nfs@vger.kernel.org
Date: Mon, 24 Mar 2014 21:06:12 -0400
Subject: [PATCH 2/2] nfsidmap: Create id_resolver child keyrings
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create and fill child keyrings of MAX_KEYS number of keys with
id_resolver keys to expand the idmapper's key capacity.

Signed-off-by: Benjamin Coddington <bcodding@uvm.edu>
---
 utils/nfsidmap/nfsidmap.c |   74 ++++++++++++++++++++++++++++++++++++--------
 1 files changed, 60 insertions(+), 14 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index ae84633..c66c19f 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -27,6 +27,10 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
 #define DEFAULT_KEYRING ".id_resolver"
 #endif
 
+#ifndef MAX_KEYS
+#define MAX_KEYS 500
+#endif
+
 #ifndef PATH_IDMAPDCONF
 #define PATH_IDMAPDCONF "/etc/idmapd.conf"
 #endif
@@ -39,7 +43,7 @@ static int keyring_clear(char *keyring);
 /*
  * Find either a user or group id based on the name@domain string
  */
-int id_lookup(char *name_at_domain, key_serial_t key, int type)
+int id_lookup(char *name_at_domain, key_serial_t key, int type, key_serial_t dest_keyring)
 {
 	char id[MAX_ID_LEN];
 	uid_t uid = 0;
@@ -58,7 +62,7 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 			(type == USER ? "nfs4_owner_to_uid" : "nfs4_group_owner_to_gid"));
 
 	if (rc == 0) {
-		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
+		rc = keyctl_instantiate(key, id, strlen(id) + 1, dest_keyring);
 		if (rc < 0) {
 			switch(rc) {
 			case -EDQUOT:
@@ -67,9 +71,9 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
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
@@ -85,7 +89,7 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 /*
  * Find the name@domain string from either a user or group id
  */
-int name_lookup(char *id, key_serial_t key, int type)
+int name_lookup(char *id, key_serial_t key, int type, key_serial_t dest_keyring)
 {
 	char name[IDMAP_NAMESZ];
 	char domain[NFS4_MAX_DOMAIN_LEN];
@@ -113,7 +117,7 @@ int name_lookup(char *id, key_serial_t key, int type)
 			(type == USER ? "nfs4_uid_to_name" : "nfs4_gid_to_name"));
 
 	if (rc == 0) {
-		rc = keyctl_instantiate(key, &name, strlen(name), 0);
+		rc = keyctl_instantiate(key, &name, strlen(name), dest_keyring);
 		if (rc < 0)
 			xlog_err("name_lookup: keyctl_instantiate failed: %m");
 	}
@@ -142,6 +146,8 @@ static int keyring_clear(char *keyring)
 			continue;
 		if (strstr(buf, keyring) == NULL)
 			continue;
+		if (strstr(buf, "perm") == NULL)
+			continue;
 		if (verbose) {
 			*(strchr(buf, '\n')) = '\0';
 			xlog_warn("clearing '%s'", buf);
@@ -157,9 +163,13 @@ static int keyring_clear(char *keyring)
 			return 1;
 		}
 		fclose(fp);
+		// if this is a child, revoke it so it gets cleaned up
+		if (!strstr(keyring, DEFAULT_KEYRING":"))
+			keyctl_revoke(key);
 		return 0;
 	}
-	xlog_err("'%s' keyring was not found.", keyring);
+	if (strstr(keyring, DEFAULT_KEYRING":"))
+		xlog_err("'%s' keyring was not found.", keyring);
 	fclose(fp);
 	return 1;
 }
@@ -232,9 +242,12 @@ int main(int argc, char **argv)
 	char *type;
 	int rc = 1, opt;
 	int timeout = 600;
-	key_serial_t key;
+	int childrings = 0;
+	key_serial_t key, parent_keyring, child_keyring;
 	char *progname, *keystr = NULL;
-	int clearing = 0, keymask = 0;
+	char child_name[BUFSIZ];
+	int clearing = 0, keymask = 0, i;
+	long child_size;
 
 	/* Set the basename */
 	if ((progname = strrchr(argv[0], '/')) != NULL)
@@ -284,9 +297,16 @@ int main(int argc, char **argv)
 		rc = key_revoke(keystr, keymask);
 		return rc;		
 	}
+
 	if (clearing) {
 		xlog_syslog(0);
-		rc = keyring_clear(DEFAULT_KEYRING);
+		i = 1;
+		for(i = 1; i < MAX_KEYS; i++) {
+			snprintf(child_name, sizeof(child_name), DEFAULT_KEYRING "_child_%d", i);
+			keyring_clear(child_name);
+		}
+
+		rc = keyring_clear(DEFAULT_KEYRING ":");
 		return rc;		
 	}
 
@@ -315,14 +335,40 @@ int main(int argc, char **argv)
 			key, type, value, timeout);
 	}
 
+	parent_keyring = request_key("keyring", DEFAULT_KEYRING, NULL, KEY_SPEC_THREAD_KEYRING);
+
+	for (i = 1; i < MAX_KEYS; i++) {
+		snprintf(child_name, sizeof(child_name), DEFAULT_KEYRING "_child_%d", i);
+
+		child_keyring = keyctl_search(parent_keyring, "keyring", child_name, 0);
+		if (child_keyring < 0) {
+			child_keyring = add_key("keyring", child_name, NULL, 0, parent_keyring);
+			xlog_warn("adding new child %s: %m", child_name);
+
+			if (child_keyring < 0)
+				xlog_err("Failed to add child keyring: %m");
+
+			keyctl_setperm(child_keyring, KEY_POS_ALL|KEY_USR_ALL);
+			break;
+		}
+
+		child_size = keyctl_read(child_keyring, NULL, 0);
+		if (child_size <= MAX_KEYS * 4)
+			break;
+	}
+
 	if (strcmp(type, "uid") == 0)
-		rc = id_lookup(value, key, USER);
+		rc = id_lookup(value, key, USER, child_keyring);
 	else if (strcmp(type, "gid") == 0)
-		rc = id_lookup(value, key, GROUP);
+		rc = id_lookup(value, key, GROUP, child_keyring);
 	else if (strcmp(type, "user") == 0)
-		rc = name_lookup(value, key, USER);
+		rc = name_lookup(value, key, USER, child_keyring);
 	else if (strcmp(type, "group") == 0)
-		rc = name_lookup(value, key, GROUP);
+		rc = name_lookup(value, key, GROUP, child_keyring);
+
+	/* if we hung this off a child, unlink from the parent */
+	if (child_keyring)
+		keyctl_unlink(key, parent_keyring);
 
 	/* Set timeout to 10 (600 seconds) minutes */
 	if (rc == 0)
-- 
1.7.1

