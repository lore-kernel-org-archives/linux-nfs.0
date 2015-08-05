Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33539 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbHEOpr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 10:45:47 -0400
Received: by qged69 with SMTP id d69so31319676qge.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 07:45:46 -0700 (PDT)
Subject: [PATCH v2 2/6] nfsidmap: Use find_key_by_type_and_desc() if
 available
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2015 10:45:43 -0400
Message-ID: <20150805144543.13266.72102.stgit@manet.1015granger.net>
In-Reply-To: <20150805143258.13266.92369.stgit@manet.1015granger.net>
References: <20150805143258.13266.92369.stgit@manet.1015granger.net>
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
 utils/nfsidmap/nfsidmap.c |  102 ++++++++++++++++++++++++++-------------------
 1 file changed, 58 insertions(+), 44 deletions(-)

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
index dd490aa..6005125 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -1,3 +1,4 @@
+#include "config.h"
 
 #include <stdarg.h>
 #include <stdio.h>
@@ -32,11 +33,66 @@ char *usage = "Usage: %s [-v] [-c || [-u|-g|-r key] || -d || [-t timeout] key de
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

