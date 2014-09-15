Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:45495 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972AbaIOOBX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 10:01:23 -0400
Received: by mail-qg0-f53.google.com with SMTP id q108so3909350qgd.12
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 07:01:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH v4 6/7] nfsdcltrack: grab the NFSDCLTRACK_CLIENT_HAS_SESSION env var if it's present
Date: Mon, 15 Sep 2014 10:01:04 -0400
Message-Id: <1410789665-19745-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410789665-19745-1-git-send-email-jlayton@primarydata.com>
References: <1410789665-19745-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and set the has_session field in the DB based on whether it's
true or not. Since we no longer set the timestamp for v4.1+ clients on
a check operation, we must be careful to set the timestamp to zero
for v4.1+ clients found via the legacy tracker.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/nfsdcltrack.c | 31 ++++++++++++++++++++++++++-----
 utils/nfsdcltrack/sqlite.c      | 30 +++++++++++++++++++++++++-----
 utils/nfsdcltrack/sqlite.h      |  6 ++++--
 3 files changed, 55 insertions(+), 12 deletions(-)

diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index f2813610be73..80e7e456306e 100644
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
@@ -254,6 +255,22 @@ cltrack_init(const char __attribute__((unused)) *unused)
 	return ret;
 }
 
+/*
+ * Fetch the contents of the NFSDCLTRACK_CLIENT_HAS_SESSION env var. If
+ * it's set and the first character is 'Y' then return true. Otherwise
+ * return false.
+ */
+static bool
+cltrack_client_has_session(void)
+{
+	char *has_session = getenv("NFSDCLTRACK_CLIENT_HAS_SESSION");
+
+	if (has_session && *has_session == 'Y')
+		return true;
+
+	return false;
+}
+
 static int
 cltrack_create(const char *id)
 {
@@ -270,7 +287,7 @@ cltrack_create(const char *id)
 	if (len < 0)
 		return (int)len;
 
-	ret = sqlite_insert_client(blob, len);
+	ret = sqlite_insert_client(blob, len, cltrack_client_has_session(), false);
 
 	return ret ? -EREMOTEIO : ret;
 }
@@ -297,7 +314,8 @@ cltrack_remove(const char *id)
 }
 
 static int
-cltrack_check_legacy(const unsigned char *blob, const ssize_t len)
+cltrack_check_legacy(const unsigned char *blob, const ssize_t len,
+			bool has_session)
 {
 	int ret;
 	struct stat st;
@@ -323,7 +341,7 @@ cltrack_check_legacy(const unsigned char *blob, const ssize_t len)
 	}
 
 	/* Dir exists, try to insert record into db */
-	ret = sqlite_insert_client(blob, len);
+	ret = sqlite_insert_client(blob, len, has_session, has_session);
 	if (ret) {
 		xlog(D_GENERAL, "Failed to insert client: %d", ret);
 		return -EREMOTEIO;
@@ -343,6 +361,7 @@ cltrack_check(const char *id)
 {
 	int ret;
 	ssize_t len;
+	bool has_session;
 
 	xlog(D_GENERAL, "%s: check client record", __func__);
 
@@ -354,9 +373,11 @@ cltrack_check(const char *id)
 	if (len < 0)
 		return (int)len;
 
-	ret = sqlite_check_client(blob, len);
+	has_session = cltrack_client_has_session();
+
+	ret = sqlite_check_client(blob, len, has_session);
 	if (ret)
-		ret = cltrack_check_legacy(blob, len);
+		ret = cltrack_check_legacy(blob, len, has_session);
 
 	return ret ? -EPERM : ret;
 }
diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index 5d38ccb7c0fe..4ff0a37b30e9 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -368,14 +368,20 @@ out_close:
  * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0)
  */
 int
-sqlite_insert_client(const unsigned char *clname, const size_t namelen)
+sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+			const bool has_session, const bool zerotime)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
 
-	ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients VALUES "
-					"(?, strftime('%s', 'now'), 0);", -1,
-					&stmt, NULL);
+	if (zerotime)
+		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
+				"VALUES (?, 0, ?);", -1, &stmt, NULL);
+	else
+		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
+				"VALUES (?, strftime('%s', 'now'), ?);", -1,
+				&stmt, NULL);
+
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
 			__func__, sqlite3_errmsg(dbh));
@@ -390,6 +396,13 @@ sqlite_insert_client(const unsigned char *clname, const size_t namelen)
 		goto out_err;
 	}
 
+	ret = sqlite3_bind_int(stmt, 2, (int)has_session);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind int failed: %s", __func__,
+				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
 	ret = sqlite3_step(stmt);
 	if (ret == SQLITE_DONE)
 		ret = SQLITE_OK;
@@ -445,7 +458,8 @@ out_err:
  * return an error.
  */
 int
-sqlite_check_client(const unsigned char *clname, const size_t namelen)
+sqlite_check_client(const unsigned char *clname, const size_t namelen,
+			const bool has_session)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
@@ -480,6 +494,12 @@ sqlite_check_client(const unsigned char *clname, const size_t namelen)
 		goto out_err;
 	}
 
+	/* Only update timestamp for v4.0 clients */
+	if (has_session) {
+		ret = SQLITE_OK;
+		goto out_err;
+	}
+
 	sqlite3_finalize(stmt);
 	stmt = NULL;
 	ret = sqlite3_prepare_v2(dbh, "UPDATE OR FAIL clients SET "
diff --git a/utils/nfsdcltrack/sqlite.h b/utils/nfsdcltrack/sqlite.h
index 3713bfb66e2f..bf4ba352b99e 100644
--- a/utils/nfsdcltrack/sqlite.h
+++ b/utils/nfsdcltrack/sqlite.h
@@ -21,9 +21,11 @@
 #define _SQLITE_H_
 
 int sqlite_prepare_dbh(const char *topdir);
-int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
+int sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+				const bool has_session, const bool zerotime);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
-int sqlite_check_client(const unsigned char *clname, const size_t namelen);
+int sqlite_check_client(const unsigned char *clname, const size_t namelen,
+				const bool has_session);
 int sqlite_remove_unreclaimed(const time_t grace_start);
 
 #endif /* _SQLITE_H */
-- 
1.9.3

