Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:59368 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbaHSSuE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 14:50:04 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so6446443qgf.34
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 11:50:04 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/7] nfsdcltrack: grab the client minorversion from the env var if it's present
Date: Tue, 19 Aug 2014 14:49:48 -0400
Message-Id: <1408474189-14491-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408474189-14491-1-git-send-email-jlayton@primarydata.com>
References: <1408474189-14491-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And set the reclaim_complete field in the DB based on whether it's zero
or not. We have no way to know for certain when a v4.0 client has
completed reclaim, so we always set that field in the DB to zero for
v4.0 clients.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/nfsdcltrack.c | 29 +++++++++++++++++++++++++++--
 utils/nfsdcltrack/sqlite.c      | 16 ++++++++++++----
 utils/nfsdcltrack/sqlite.h      |  3 ++-
 3 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index f2813610be73..cbc98c7edc11 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -37,6 +37,7 @@
 #include <libgen.h>
 #include <sys/inotify.h>
 #include <dirent.h>
+#include <limits.h>
 #ifdef HAVE_SYS_CAPABILITY_H
 #include <sys/prctl.h>
 #include <sys/capability.h>
@@ -254,6 +255,30 @@ cltrack_init(const char __attribute__((unused)) *unused)
 	return ret;
 }
 
+/*
+ * Fetch the contents of the NFSDCLTRACK_CLIENT_MINORVERSION env var. If
+ * it's not set or there is an error converting it to an unsigned int
+ * then return 0 (since the minorversion isn't reliable at that point).
+ */
+static unsigned int
+cltrack_get_minorvers(void)
+{
+	unsigned long minorvers;
+	char *end;
+	char *minorvers_str = getenv("NFSDCLTRACK_CLIENT_MINORVERSION");
+
+	if (!minorvers_str)
+		return 0;
+
+	errno = 0;
+	minorvers = strtoul(minorvers_str, &end, 0);
+	/* Problem converting or value is too large? */
+	if (errno || minorvers > UINT_MAX)
+		return 0;
+
+	return (unsigned int)minorvers;
+}
+
 static int
 cltrack_create(const char *id)
 {
@@ -270,7 +295,7 @@ cltrack_create(const char *id)
 	if (len < 0)
 		return (int)len;
 
-	ret = sqlite_insert_client(blob, len);
+	ret = sqlite_insert_client(blob, len, cltrack_get_minorvers());
 
 	return ret ? -EREMOTEIO : ret;
 }
@@ -323,7 +348,7 @@ cltrack_check_legacy(const unsigned char *blob, const ssize_t len)
 	}
 
 	/* Dir exists, try to insert record into db */
-	ret = sqlite_insert_client(blob, len);
+	ret = sqlite_insert_client(blob, len, 0);
 	if (ret) {
 		xlog(D_GENERAL, "Failed to insert client: %d", ret);
 		return -EREMOTEIO;
diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index e260e81b1722..01084bb6c4d8 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -369,14 +369,22 @@ out_close:
  * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0)
  */
 int
-sqlite_insert_client(const unsigned char *clname, const size_t namelen)
+sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+			const unsigned int minorvers)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
 
-	ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients VALUES "
-					"(?, strftime('%s', 'now'), 0);", -1,
-					&stmt, NULL);
+	if (minorvers == 0)
+		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
+				"VALUES (?, strftime('%s', 'now'), 0);", -1,
+				&stmt, NULL);
+	else
+		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
+				"VALUES (?, strftime('%s', 'now'), "
+				"strftime('%s', 'now'));", -1,
+				&stmt, NULL);
+
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
 			__func__, sqlite3_errmsg(dbh));
diff --git a/utils/nfsdcltrack/sqlite.h b/utils/nfsdcltrack/sqlite.h
index 3713bfb66e2f..e9cc84cbb294 100644
--- a/utils/nfsdcltrack/sqlite.h
+++ b/utils/nfsdcltrack/sqlite.h
@@ -21,7 +21,8 @@
 #define _SQLITE_H_
 
 int sqlite_prepare_dbh(const char *topdir);
-int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
+int sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+				const unsigned int minorvers);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
 int sqlite_check_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_unreclaimed(const time_t grace_start);
-- 
1.9.3

