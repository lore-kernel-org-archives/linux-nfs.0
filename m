Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:34567 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbaHSSuD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 14:50:03 -0400
Received: by mail-qa0-f54.google.com with SMTP id k15so6161112qaq.27
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 11:50:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/7] nfsdcltrack: update schema to v2
Date: Tue, 19 Aug 2014 14:49:47 -0400
Message-Id: <1408474189-14491-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408474189-14491-1-git-send-email-jlayton@primarydata.com>
References: <1408474189-14491-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@poochiereds.net>

In order to allow knfsd's lock manager to lift its grace period early,
we need to figure out whether all clients have finished reclaiming
their state not. Unfortunately, the current code doesn't allow us to
ascertain this. All we track for each client is a timestamp that tells
us when the last "check" or "create" operation came in.

We need to track the two timestamps separately. Add a new
"reclaim_complete" column to the database that tells us when the last
"create" operation came in. For now, we just insert "0" in that column
but a later patch will make it so that we insert a real timestamp for
v4.1+ client records.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/sqlite.c | 102 +++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 94 insertions(+), 8 deletions(-)

diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index dde2f7ff8621..e260e81b1722 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -29,7 +29,10 @@
  *
  * clients: an "id" column containing a BLOB with the long-form clientid as
  * 	    sent by the client, a "time" column containing a timestamp (in
- * 	    epoch seconds) of when the record was last updated.
+ * 	    epoch seconds) of when the record was last updated, and a
+ * 	    "reclaim_complete" column containing a timestamp (in epoch seconds)
+ * 	    of when the last "create" operation came in for v4.1+ clients.
+ * 	    v4.0 clients should always have this set to 0.
  */
 
 #ifdef HAVE_CONFIG_H
@@ -50,7 +53,7 @@
 
 #include "xlog.h"
 
-#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 1
+#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 2
 
 /* in milliseconds */
 #define CLTRACK_SQLITE_BUSY_TIMEOUT 10000
@@ -120,6 +123,81 @@ out:
 	return ret;
 }
 
+static int
+sqlite_maindb_update_v1_to_v2(void)
+{
+	int ret, ret2;
+	char *err;
+
+	/* begin transaction */
+	ret = sqlite3_exec(dbh, "BEGIN EXCLUSIVE TRANSACTION;", NULL, NULL,
+				&err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to begin transaction: %s", err);
+		goto rollback;
+	}
+
+	/*
+	 * Check schema version again. This time, under an exclusive
+	 * transaction to guard against racing DB setup attempts
+	 */
+	ret = sqlite_query_schema_version();
+	switch (ret) {
+	case 1:
+		/* Still at v1 -- do conversion */
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
+
+	/* create v2 clients table */
+	ret = sqlite3_exec(dbh, "ALTER TABLE clients ADD COLUMN "
+				"reclaim_complete INTEGER;",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to update clients table: %s", err);
+		goto rollback;
+	}
+
+	ret = snprintf(buf, sizeof(buf), "UPDATE parameters SET value = %d "
+			"WHERE key = \"version\";",
+			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		goto rollback;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+		ret = -EINVAL;
+		goto rollback;
+	}
+
+	ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to update schema version: %s", err);
+		goto rollback;
+	}
+
+	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to commit transaction: %s", err);
+		goto rollback;
+	}
+out:
+	sqlite3_free(err);
+	return ret;
+rollback:
+	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	if (ret2 != SQLITE_OK)
+		xlog(L_ERROR, "Unable to rollback transaction: %s", err);
+	goto out;
+}
+
 /*
  * Start an exclusive transaction and recheck the DB schema version. If it's
  * still zero (indicating a new database) then set it up. If that all works,
@@ -127,9 +205,9 @@ out:
  * transaction. On any error, rollback the transaction.
  */
 int
-sqlite_maindb_init_v1(void)
+sqlite_maindb_init_v2(void)
 {
-	int ret;
+	int ret, ret2;
 	char *err = NULL;
 
 	/* Start a transaction */
@@ -169,7 +247,7 @@ sqlite_maindb_init_v1(void)
 
 	/* create the "clients" table */
 	ret = sqlite3_exec(dbh, "CREATE TABLE clients (id BLOB PRIMARY KEY, "
-				"time INTEGER);",
+				"time INTEGER, reclaim_complete INTEGER);",
 				NULL, NULL, &err);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to create clients table: %s", err);
@@ -207,7 +285,9 @@ out:
 
 rollback:
 	/* Attempt to rollback the transaction */
-	sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	if (ret2 != SQLITE_OK)
+		xlog(L_ERROR, "Unable to rollback transaction: %s", err);
 	goto out;
 }
 
@@ -255,9 +335,15 @@ sqlite_prepare_dbh(const char *topdir)
 		/* DB is already set up. Do nothing */
 		ret = 0;
 		break;
+	case 1:
+		/* Old DB -- update to new schema */
+		ret = sqlite_maindb_update_v1_to_v2();
+		if (ret)
+			goto out_close;
+		break;
 	case 0:
 		/* Query failed -- try to set up new DB */
-		ret = sqlite_maindb_init_v1();
+		ret = sqlite_maindb_init_v2();
 		if (ret)
 			goto out_close;
 		break;
@@ -289,7 +375,7 @@ sqlite_insert_client(const unsigned char *clname, const size_t namelen)
 	sqlite3_stmt *stmt = NULL;
 
 	ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients VALUES "
-				      "(?, strftime('%s', 'now'));", -1,
+					"(?, strftime('%s', 'now'), 0);", -1,
 					&stmt, NULL);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
-- 
1.9.3

