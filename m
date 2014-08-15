Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:50529 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbaHOOp2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:45:28 -0400
Received: by mail-qa0-f52.google.com with SMTP id j15so2120433qaq.39
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:45:28 -0700 (PDT)
Received: from tlielax.poochiereds.net ([2001:470:8:d63:3a60:77ff:fe93:a95d])
        by mx.google.com with ESMTPSA id t107sm3989900qgt.28.2014.08.15.07.45.26
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 07:45:27 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 4/7] nfsdcltrack: overhaul database initializtion
Date: Fri, 15 Aug 2014 10:45:12 -0400
Message-Id: <1408113915-5573-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
References: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have some possibility for races with nfsdcltrack when the DB schema
is upgraded.

Suppose we update the nfs-utils package on a machine after the DB has
been initialized. With the current scheme of initializing the DB only
during the "init" phase, we could end up with a new program that expects
a new schema with an old database.

We could try to do a one-time update when the package is installed, but
that could be racy. We could get an upcall between when the program is
installed and when we run the update. Also, relying on packaging to get
that right is tricky at best. To fix this, change how the database
initialization and checking of the schema revision works.

On every upcall, attempt to open the db as we normally would. If that
fails, then try to create the directory if it doesn't exist and then
retry the open. If it fails again, then give up.

If we get a successful open, then query the DB for the schema version.
If it matches what we expect, then declare success and move on. If the
query fails then assume that the DB isn't set up yet. Start an exclusive
transaction, check the schema version again and then set up the DB if no
one raced in to create it in the meantime.

This should only add a tiny bit of overhead on most upcalls (just an
extra select of the parameters table), and should improve the
performance of the "init" upcall. It'll also make it possible to handle
DB schema changes sanely.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/nfsdcltrack.c |   2 +-
 utils/nfsdcltrack/sqlite.c      | 225 +++++++++++++++++++++++++---------------
 utils/nfsdcltrack/sqlite.h      |   1 -
 3 files changed, 142 insertions(+), 86 deletions(-)

diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index 4334340197b1..f2813610be73 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -241,7 +241,7 @@ cltrack_init(const char __attribute__((unused)) *unused)
 	}
 
 	/* set up storage db */
-	ret = sqlite_maindb_init(storagedir);
+	ret = sqlite_prepare_dbh(storagedir);
 	if (ret) {
 		xlog(L_ERROR, "Failed to init database: %d", ret);
 		/*
diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index 52fcaa4d7ca3..dde2f7ff8621 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -88,135 +88,192 @@ mkdir_if_not_exist(const char *dirname)
 	return ret;
 }
 
-/* Open the database and set up the database handle for it */
-int
-sqlite_prepare_dbh(const char *topdir)
+static int
+sqlite_query_schema_version(void)
 {
 	int ret;
+	sqlite3_stmt *stmt = NULL;
 
-	/* Do nothing if the database handle is already set up */
-	if (dbh)
-		return 0;
-
-	ret = snprintf(buf, PATH_MAX - 1, "%s/main.sqlite", topdir);
-	if (ret < 0)
-		return ret;
-
-	buf[PATH_MAX - 1] = '\0';
-
-	ret = sqlite3_open(buf, &dbh);
+	/* prepare select query */
+	ret = sqlite3_prepare_v2(dbh,
+		"SELECT value FROM parameters WHERE key == \"version\";",
+		 -1, &stmt, NULL);
 	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "Unable to open main database: %d", ret);
-		dbh = NULL;
-		return ret;
+		xlog(L_ERROR, "Unable to prepare select statement: %s",
+			sqlite3_errstr(ret));
+		ret = 0;
+		goto out;
 	}
 
-	ret = sqlite3_busy_timeout(dbh, CLTRACK_SQLITE_BUSY_TIMEOUT);
-	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "Unable to set sqlite busy timeout: %d", ret);
-		sqlite3_close(dbh);
-		dbh = NULL;
+	/* query schema version */
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(L_ERROR, "Select statement execution failed: %s",
+				sqlite3_errstr(ret));
+		ret = 0;
+		goto out;
 	}
 
+	ret = sqlite3_column_int(stmt, 0);
+out:
+	sqlite3_finalize(stmt);
 	return ret;
 }
 
 /*
- * Open the "main" database, and attempt to initialize it by creating the
- * parameters table and inserting the schema version into it. Ignore any errors
- * from that, and then attempt to select the version out of it again. If the
- * version appears wrong, then assume that the DB is corrupt or has been
- * upgraded, and return an error. If all of that works, then attempt to create
- * the "clients" table.
+ * Start an exclusive transaction and recheck the DB schema version. If it's
+ * still zero (indicating a new database) then set it up. If that all works,
+ * then insert schema version into the parameters table and commit the
+ * transaction. On any error, rollback the transaction.
  */
 int
-sqlite_maindb_init(const char *topdir)
+sqlite_maindb_init_v1(void)
 {
 	int ret;
 	char *err = NULL;
-	sqlite3_stmt *stmt = NULL;
 
-	ret = mkdir_if_not_exist(topdir);
-	if (ret)
+	/* Start a transaction */
+	ret = sqlite3_exec(dbh, "BEGIN EXCLUSIVE TRANSACTION;", NULL, NULL,
+				&err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to begin transaction: %s", err);
 		return ret;
+	}
 
-	ret = sqlite_prepare_dbh(topdir);
-	if (ret)
-		return ret;
+	/*
+	 * Check schema version again. This time, under an exclusive
+	 * transaction to guard against racing DB setup attempts
+	 */
+	ret = sqlite_query_schema_version();
+	switch (ret) {
+	case 0:
+		/* Query failed again -- set up DB */
+		break;
+	case CLTRACK_SQLITE_LATEST_SCHEMA_VERSION:
+		/* Someone else raced in and set it up */
+		ret = 0;
+		goto rollback;
+	default:
+		/* Something went wrong -- fail! */
+		ret = -EINVAL;
+		goto rollback;
+	}
 
-	/* Try to create table */
-	ret = sqlite3_exec(dbh, "CREATE TABLE IF NOT EXISTS parameters "
+	ret = sqlite3_exec(dbh, "CREATE TABLE parameters "
 				"(key TEXT PRIMARY KEY, value TEXT);",
 				NULL, NULL, &err);
 	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "Unable to create parameter table: %d", ret);
-		goto out_err;
+		xlog(L_ERROR, "Unable to create parameter table: %s", err);
+		goto rollback;
 	}
 
-	/* insert version into table -- ignore error if it fails */
-	ret = snprintf(buf, sizeof(buf),
-		       "INSERT OR IGNORE INTO parameters values (\"version\", "
-		       "\"%d\");", CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION);
+	/* create the "clients" table */
+	ret = sqlite3_exec(dbh, "CREATE TABLE clients (id BLOB PRIMARY KEY, "
+				"time INTEGER);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create clients table: %s", err);
+		goto rollback;
+	}
+
+
+	/* insert version into parameters table */
+	ret = snprintf(buf, sizeof(buf), "INSERT OR FAIL INTO parameters "
+			"values (\"version\", \"%d\");",
+			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION);
 	if (ret < 0) {
-		goto out_err;
+		xlog(L_ERROR, "sprintf failed!");
+		goto rollback;
 	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
 		ret = -EINVAL;
-		goto out_err;
+		goto rollback;
 	}
 
 	ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
 	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "Unable to insert into parameter table: %d",
-				ret);
-		goto out_err;
+		xlog(L_ERROR, "Unable to insert into parameter table: %s", err);
+		goto rollback;
 	}
 
-	ret = sqlite3_prepare_v2(dbh,
-		"SELECT value FROM parameters WHERE key == \"version\";",
-		 -1, &stmt, NULL);
+	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
 	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "Unable to prepare select statement: %d", ret);
-		goto out_err;
+		xlog(L_ERROR, "Unable to commit transaction: %s", err);
+		goto rollback;
 	}
+out:
+	sqlite3_free(err);
+	return ret;
 
-	/* check schema version */
-	ret = sqlite3_step(stmt);
-	if (ret != SQLITE_ROW) {
-		xlog(L_ERROR, "Select statement execution failed: %s",
-				sqlite3_errmsg(dbh));
-		goto out_err;
-	}
+rollback:
+	/* Attempt to rollback the transaction */
+	sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	goto out;
+}
 
-	/* process SELECT result */
-	ret = sqlite3_column_int(stmt, 0);
-	if (ret != CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION) {
-		xlog(L_ERROR, "Unsupported database schema version! "
-			"Expected %d, got %d.",
-			CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION, ret);
-		ret = -EINVAL;
-		goto out_err;
-	}
+/* Open the database and set up the database handle for it */
+int
+sqlite_prepare_dbh(const char *topdir)
+{
+	int ret;
 
-	/* now create the "clients" table */
-	ret = sqlite3_exec(dbh, "CREATE TABLE IF NOT EXISTS clients "
-				"(id BLOB PRIMARY KEY, time INTEGER);",
-				NULL, NULL, &err);
+	/* Do nothing if the database handle is already set up */
+	if (dbh)
+		return 0;
+
+	ret = snprintf(buf, PATH_MAX - 1, "%s/main.sqlite", topdir);
+	if (ret < 0)
+		return ret;
+
+	buf[PATH_MAX - 1] = '\0';
+
+	/* open a new DB handle */
+	ret = sqlite3_open(buf, &dbh);
 	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "Unable to create clients table: %s", err);
-		goto out_err;
+		/* try to create the dir */
+		ret = mkdir_if_not_exist(topdir);
+		if (ret)
+			goto out_close;
+
+		/* retry open */
+		ret = sqlite3_open(buf, &dbh);
+		if (ret != SQLITE_OK)
+			goto out_close;
 	}
 
-	sqlite3_free(err);
-	sqlite3_finalize(stmt);
-	return 0;
+	/* set busy timeout */
+	ret = sqlite3_busy_timeout(dbh, CLTRACK_SQLITE_BUSY_TIMEOUT);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to set sqlite busy timeout: %s",
+				sqlite3_errstr(ret));
+		goto out_close;
+	}
 
-out_err:
-	if (err) {
-		xlog(L_ERROR, "sqlite error: %s", err);
-		sqlite3_free(err);
+	ret = sqlite_query_schema_version();
+	switch (ret) {
+	case CLTRACK_SQLITE_LATEST_SCHEMA_VERSION:
+		/* DB is already set up. Do nothing */
+		ret = 0;
+		break;
+	case 0:
+		/* Query failed -- try to set up new DB */
+		ret = sqlite_maindb_init_v1();
+		if (ret)
+			goto out_close;
+		break;
+	default:
+		/* Unknown DB version -- downgrade? Fail */
+		xlog(L_ERROR, "Unsupported database schema version! "
+			"Expected %d, got %d.",
+			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION, ret);
+		ret = -EINVAL;
+		goto out_close;
 	}
-	sqlite3_finalize(stmt);
-	sqlite3_close(dbh);
+
+	return ret;
+out_close:
+	sqlite3_close_v2(dbh);
+	dbh = NULL;
 	return ret;
 }
 
diff --git a/utils/nfsdcltrack/sqlite.h b/utils/nfsdcltrack/sqlite.h
index ebf04c3cdbaa..3713bfb66e2f 100644
--- a/utils/nfsdcltrack/sqlite.h
+++ b/utils/nfsdcltrack/sqlite.h
@@ -21,7 +21,6 @@
 #define _SQLITE_H_
 
 int sqlite_prepare_dbh(const char *topdir);
-int sqlite_maindb_init(const char *topdir);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
 int sqlite_check_client(const unsigned char *clname, const size_t namelen);
-- 
1.9.3

