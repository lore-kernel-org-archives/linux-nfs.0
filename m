Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:36022 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbGaWNt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jul 2015 18:13:49 -0400
Received: by qgeh16 with SMTP id h16so55262054qge.3
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2015 15:13:48 -0700 (PDT)
Subject: [PATCH 2/6] nfsidmap: Use find_key_by_type_and_desc() if available
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: dhowells@redhat.com
Date: Fri, 31 Jul 2015 15:13:46 -0700
Message-ID: <20150731221346.50685.42127.stgit@seurat.1015granger.net>
In-Reply-To: <20150731220914.50685.32887.stgit@seurat.1015granger.net>
References: <20150731220914.50685.32887.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent versions of libkeyutils have find_key_by_type_and_desc()
which replaces the open-coded keyring search in keyring_clear().

I don't quite understand what's going on in key_invalidate(),
so I didn't touch it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/nfsidmap/nfsidmap.c |  106 +++++++++++++++++++++++++--------------------
 1 file changed, 60 insertions(+), 46 deletions(-)

diff --git a/aclocal/keyutils.m4 b/aclocal/keyutils.m4
index a392c0e..16b225d 100644
--- a/aclocal/keyutils.m4
+++ b/aclocal/keyutils.m4
@@ -8,4 +8,8 @@ AC_DEFUN([AC_KEYUTILS], [
 
   AC_CHECK_HEADERS([keyutils.h])
 
+  AC_CHECK_LIB([keyutils], [find_key_by_type_and_desc],
+		[AC_DEFINE([HAVE_FIND_KEY_BY_TYPE_AND_DESC], [1],
+			[Define to 1 if you have the `find_key_by_type_and_desc' function.])],)
+
 ])dnl
diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 85177bf..44b8b4b 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -1,3 +1,4 @@
+#include "config.h"
 
 #include <stdarg.h>
 #include <stdio.h>
@@ -32,11 +33,66 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
 #define PATH_IDMAPDCONF "/etc/idmapd.conf"
 #endif
 
-static int keyring_clear(char *keyring);
-
 #define UIDKEYS 0x1
 #define GIDKEYS 0x2
 
+#ifndef HAVE_FIND_KEY_BY_TYPE_AND_DESC
+static key_serial_t find_key_by_type_and_desc(const char *type,
+		const char *desc, key_serial_t destringid)
+{
+	char buf[BUFSIZ];
+	key_serial_t key;
+	FILE *fp;
+
+	if ((fp = fopen(PROCKEYS, "r")) == NULL) {
+		xlog_err("fopen(%s) failed: %m", PROCKEYS);
+		return -1;
+	}
+
+	key = -1;
+	while(fgets(buf, BUFSIZ, fp) != NULL) {
+		unsigned int id;
+
+		if (strstr(buf, type) == NULL)
+			continue;
+		if (strstr(buf, desc) == NULL)
+			continue;
+		if (sscanf(buf, "%x %*s", &id) != 1) {
+			xlog_err("Unparsable keyring entry in %s", PROCKEYS);
+			continue;
+		}
+
+		key = (key_serial_t)id;
+		break;
+	}
+
+	fclose(fp);
+	return key;
+}
+#endif
+
+/*
+ * Clear all the keys on the given keyring
+ */
+static int keyring_clear(const char *keyring)
+{
+	key_serial_t key;
+
+	key = find_key_by_type_and_desc("keyring", keyring, 0);
+	if (key == -1) {
+		xlog_err("'%s' keyring was not found.", keyring);
+		return EXIT_FAILURE;
+	}
+
+	if (keyctl_clear(key) < 0) {
+		xlog_err("keyctl_clear(0x%x) failed: %m",
+				(unsigned int)key);
+		return EXIT_FAILURE;
+	}
+
+	return EXIT_SUCCESS;
+}
+
 static int display_default_domain(void)
 {
 	char domain[NFS4_MAX_DOMAIN_LEN];
@@ -55,7 +111,7 @@ static int display_default_domain(void)
 /*
  * Find either a user or group id based on the name@domain string
  */
-int id_lookup(char *name_at_domain, key_serial_t key, int type)
+static int id_lookup(char *name_at_domain, key_serial_t key, int type)
 {
 	char id[MAX_ID_LEN];
 	uid_t uid = 0;
@@ -101,7 +157,7 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
 /*
  * Find the name@domain string from either a user or group id
  */
-int name_lookup(char *id, key_serial_t key, int type)
+static int name_lookup(char *id, key_serial_t key, int type)
 {
 	char name[IDMAP_NAMESZ];
 	char domain[NFS4_MAX_DOMAIN_LEN];
@@ -136,49 +192,7 @@ int name_lookup(char *id, key_serial_t key, int type)
 out:
 	return rc;
 }
-/*
- * Clear all the keys on the given keyring
- */
-static int keyring_clear(char *keyring)
-{
-	FILE *fp;
-	char buf[BUFSIZ];
-	key_serial_t key;
-
-	if (keyring == NULL)
-		keyring = DEFAULT_KEYRING;
-
-	if ((fp = fopen(PROCKEYS, "r")) == NULL) {
-		xlog_err("fopen(%s) failed: %m", PROCKEYS);
-		return 1;
-	}
 
-	while(fgets(buf, BUFSIZ, fp) != NULL) {
-		if (strstr(buf, "keyring") == NULL)
-			continue;
-		if (strstr(buf, keyring) == NULL)
-			continue;
-		if (verbose) {
-			*(strchr(buf, '\n')) = '\0';
-			xlog_warn("clearing '%s'", buf);
-		}
-		/*
-		 * The key is the first arugment in the string
-		 */
-		*(strchr(buf, ' ')) = '\0';
-		sscanf(buf, "%x", &key);
-		if (keyctl_clear(key) < 0) {
-			xlog_err("keyctl_clear(0x%x) failed: %m", key);
-			fclose(fp);
-			return 1;
-		}
-		fclose(fp);
-		return 0;
-	}
-	xlog_err("'%s' keyring was not found.", keyring);
-	fclose(fp);
-	return 1;
-}
 /*
  * Revoke a key 
  */

