Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:58848 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754616AbaIHQag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 12:30:36 -0400
Received: by mail-qg0-f45.google.com with SMTP id j107so2578767qga.32
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 09:30:36 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v3 6/7] nfsdcltrack: grab the NFSDCLTRACK_RECLAIM_COMPLETE env var if it's present
Date: Mon,  8 Sep 2014 12:30:20 -0400
Message-Id: <1410193821-25109-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410193821-25109-1-git-send-email-jlayton@primarydata.com>
References: <1410193821-25109-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and set the reclaim_complete field in the DB based on whether it's
true or not. If it's true, set it to the current time. If it's not, then
set it to zero.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/nfsdcltrack.c | 21 +++++++++++++++++++--
 utils/nfsdcltrack/sqlite.c      | 16 ++++++++++++----
 utils/nfsdcltrack/sqlite.h      |  3 ++-
 3 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index f2813610be73..873b1fae056d 100644
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
+ * Fetch the contents of the NFSDCLTRACK_RECLAIM_COMPLETE env var. If
+ * it's set and the first character is 'Y' then return true. Otherwise
+ * return false.
+ */
+static bool
+cltrack_get_reclaim_complete(void)
+{
+	char *reclaim_complete = getenv("NFSDCLTRACK_RECLAIM_COMPLETE");
+
+	if (reclaim_complete && *reclaim_complete == 'Y')
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
+	ret = sqlite_insert_client(blob, len, cltrack_get_reclaim_complete());
 
 	return ret ? -EREMOTEIO : ret;
 }
@@ -323,7 +340,7 @@ cltrack_check_legacy(const unsigned char *blob, const ssize_t len)
 	}
 
 	/* Dir exists, try to insert record into db */
-	ret = sqlite_insert_client(blob, len);
+	ret = sqlite_insert_client(blob, len, 0);
 	if (ret) {
 		xlog(D_GENERAL, "Failed to insert client: %d", ret);
 		return -EREMOTEIO;
diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index e260e81b1722..e2a860f4b924 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -369,14 +369,22 @@ out_close:
  * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0)
  */
 int
-sqlite_insert_client(const unsigned char *clname, const size_t namelen)
+sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+			const bool reclaim_complete)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
 
-	ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients VALUES "
-					"(?, strftime('%s', 'now'), 0);", -1,
-					&stmt, NULL);
+	if (reclaim_complete)
+		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
+				"VALUES (?, strftime('%s', 'now'), "
+				"strftime('%s', 'now'));", -1,
+				&stmt, NULL);
+	else
+		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
+				"VALUES (?, strftime('%s', 'now'), 0);", -1,
+				&stmt, NULL);
+
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
 			__func__, sqlite3_errmsg(dbh));
diff --git a/utils/nfsdcltrack/sqlite.h b/utils/nfsdcltrack/sqlite.h
index 3713bfb66e2f..9d7357bcf832 100644
--- a/utils/nfsdcltrack/sqlite.h
+++ b/utils/nfsdcltrack/sqlite.h
@@ -21,7 +21,8 @@
 #define _SQLITE_H_
 
 int sqlite_prepare_dbh(const char *topdir);
-int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
+int sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+				const bool reclaim_complete);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
 int sqlite_check_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_unreclaimed(const time_t grace_start);
-- 
1.9.3

