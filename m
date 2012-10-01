Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:38295 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab2JALwy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 07:52:54 -0400
Received: by mail-gh0-f174.google.com with SMTP id g15so1356084ghb.19
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2012 04:52:54 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] nfsdcltrack: break out a function to open the database handle
Date: Mon,  1 Oct 2012 07:52:42 -0400
Message-Id: <1349092365-23920-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
References: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we add a new usermodehelper upcall program to do the database
access, the existing "init" function will be overkill every time
we start up the program.

Break out the database handle establishment routine into a separate
function that we can call from each upcall command in the one-shot
program.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcltrack/sqlite.c | 49 ++++++++++++++++++++++++++++++++--------------
 utils/nfsdcltrack/sqlite.h |  1 +
 2 files changed, 35 insertions(+), 15 deletions(-)

diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index c19af7e..bac6789 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -90,24 +90,15 @@ mkdir_if_not_exist(const char *dirname)
 	return ret;
 }
 
-/*
- * Open the "main" database, and attempt to initialize it by creating the
- * parameters table and inserting the schema version into it. Ignore any errors
- * from that, and then attempt to select the version out of it again. If the
- * version appears wrong, then assume that the DB is corrupt or has been
- * upgraded, and return an error. If all of that works, then attempt to create
- * the "clients" table.
- */
+/* Open the database and set up the database handle for it */
 int
-sqlite_maindb_init(const char *topdir)
+sqlite_prepare_dbh(const char *topdir)
 {
 	int ret;
-	char *err = NULL;
-	sqlite3_stmt *stmt = NULL;
 
-	ret = mkdir_if_not_exist(topdir);
-	if (ret)
-		return ret;
+	/* Do nothing if the database handle is already set up */
+	if (dbh)
+		return 0;
 
 	ret = snprintf(buf, PATH_MAX - 1, "%s/main.sqlite", topdir);
 	if (ret < 0)
@@ -118,15 +109,43 @@ sqlite_maindb_init(const char *topdir)
 	ret = sqlite3_open(buf, &dbh);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to open main database: %d", ret);
+		dbh = NULL;
 		return ret;
 	}
 
 	ret = sqlite3_busy_timeout(dbh, CLD_SQLITE_BUSY_TIMEOUT);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to set sqlite busy timeout: %d", ret);
-		goto out_err;
+		sqlite3_close(dbh);
+		dbh = NULL;
 	}
 
+	return ret;
+}
+
+/*
+ * Open the "main" database, and attempt to initialize it by creating the
+ * parameters table and inserting the schema version into it. Ignore any errors
+ * from that, and then attempt to select the version out of it again. If the
+ * version appears wrong, then assume that the DB is corrupt or has been
+ * upgraded, and return an error. If all of that works, then attempt to create
+ * the "clients" table.
+ */
+int
+sqlite_maindb_init(const char *topdir)
+{
+	int ret;
+	char *err = NULL;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = mkdir_if_not_exist(topdir);
+	if (ret)
+		return ret;
+
+	ret = sqlite_prepare_dbh(topdir);
+	if (ret)
+		return ret;
+
 	/* Try to create table */
 	ret = sqlite3_exec(dbh, "CREATE TABLE IF NOT EXISTS parameters "
 				"(key TEXT PRIMARY KEY, value TEXT);",
diff --git a/utils/nfsdcltrack/sqlite.h b/utils/nfsdcltrack/sqlite.h
index 8748948..ebf04c3 100644
--- a/utils/nfsdcltrack/sqlite.h
+++ b/utils/nfsdcltrack/sqlite.h
@@ -20,6 +20,7 @@
 #ifndef _SQLITE_H_
 #define _SQLITE_H_
 
+int sqlite_prepare_dbh(const char *topdir);
 int sqlite_maindb_init(const char *topdir);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
-- 
1.7.11.4

