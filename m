Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:38359 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab2AWUC1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:02:27 -0500
Received: by mail-qy0-f174.google.com with SMTP id f13so1753533qcs.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:02:26 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 07/11] nfsdcld: implement an init upcall
Date: Mon, 23 Jan 2012 15:02:07 -0500
Message-Id: <1327348931-785-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327348931-785-1-git-send-email-jlayton@redhat.com>
References: <1327348931-785-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The init upcall gets and increments the generation number in the
parameters table atomically with respect to other clients. We do this by
starting an immediate transaction, selecting the current value and then
incrementing it on stable storage before ending the transaction. That
ensures that accesses to the generation counter are serialized.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/nfsdcld.c |   29 +++++++++++++++
 utils/nfsdcld/sqlite.c  |   90 +++++++++++++++++++++++++++++++++++++++++++++-
 utils/nfsdcld/sqlite.h  |    1 +
 3 files changed, 118 insertions(+), 2 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index bd643b0..afc53d2 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -114,6 +114,32 @@ cld_pipe_reopen(struct cld_client *clnt)
 }
 
 static void
+cld_init(struct cld_client *clnt)
+{
+	int ret;
+	uint32_t generation;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: server initialization", __func__);
+
+	ret = sqlite_get_generation(&generation);
+
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
+	cmsg->cm_u.cm_generation = generation;
+
+	bsize = sizeof(*cmsg);
+
+	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize) {
+		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
+			 __func__, wsize);
+		cld_pipe_reopen(clnt);
+	}
+}
+
+static void
 cld_create(struct cld_client *clnt)
 {
 	int ret;
@@ -240,6 +266,9 @@ cldcb(int UNUSED(fd), short which, void *data)
 	}
 
 	switch(cmsg->cm_cmd) {
+	case Cld_Init:
+		cld_init(clnt);
+		break;
 	case Cld_Create:
 		cld_create(clnt);
 		break;
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index 85e76a1..47a3a19 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -189,6 +189,13 @@ sqlite_maindb_init(char *topdir)
 		goto out_err;
 	}
 
+	ret = sqlite3_exec(dbh, "INSERT OR IGNORE INTO parameters VALUES "
+				"(\"generation\", 0);", NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to initialize generation.");
+		goto out_err;
+	}
+
 	/* now create the "clients" table */
 	ret = sqlite3_exec(dbh, "CREATE TABLE IF NOT EXISTS clients "
 				"(idx INTEGER PRIMARY KEY AUTOINCREMENT, "
@@ -213,6 +220,85 @@ out_err:
 	return ret;
 }
 
+int
+sqlite_get_generation(uint32_t *generation)
+{
+	int ret, ret2;
+	char *err = NULL;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_exec(dbh, "BEGIN IMMEDIATE TRANSACTION;",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to start transaction: %s", err);
+		goto out_err;
+	}
+
+	ret = sqlite3_prepare_v2(dbh,
+		"SELECT value FROM parameters WHERE key==\"generation\";",
+		-1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to prepare select statement: %d", ret);
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(D_GENERAL, "Select statement execution failed (%d): %s",
+				ret, sqlite3_errmsg(dbh));
+		goto out_rollback;
+	}
+
+	/* pass the generation number back to caller */
+	*generation = (uint32_t)sqlite3_column_int(stmt, 0);
+
+	ret = snprintf(buf, sizeof(buf),
+		       "UPDATE parameters set value=%d where key=="
+		       "\"generation\";", *generation + 1);
+	if (ret < 0) {
+		goto out_rollback;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		ret = -EINVAL;
+		goto out_rollback;
+	}
+
+	ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to update generation number(%d): %s",
+				ret, err);
+		goto out_rollback;
+	}
+
+	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to commit transaction(%d): %s",
+				ret, err);
+		goto out_rollback;
+	}
+
+out_err:
+	if (err) {
+		xlog(L_ERROR, "sqlite error: %s", err);
+		sqlite3_free(err);
+	}
+	sqlite3_finalize(stmt);
+	return ret;
+
+out_rollback:
+	/* attempt to rollback on any error once the transaction is started */
+	sqlite3_free(err);
+	err = NULL;
+	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	if (ret2 != SQLITE_OK) {
+		/*
+		 * FIXME: is transaction still active? Should we re-init the
+		 * dbh here or have the daemon exit?
+		 */
+		xlog(L_ERROR, "Transaction rollback failed.");
+	}
+	goto out_err;
+}
+
 /*
  * Create a client record
  *
@@ -252,7 +338,7 @@ sqlite_insert_client(const unsigned char *clname, const size_t namelen,
 	sqlite3_finalize(stmt);
 	stmt = NULL;
 
-	ret = sqlite3_prepare_v2(dbh, "SELECT index FROM clients WHERE "
+	ret = sqlite3_prepare_v2(dbh, "SELECT idx FROM clients WHERE "
 				      "id==?", -1, &stmt, NULL);
 	if (ret != SQLITE_OK) {
 		xlog(D_GENERAL, "Unable to prepare update statement: %s",
@@ -293,7 +379,7 @@ sqlite_check_client(const unsigned char *clname, const size_t namelen,
 	int ret;
 	sqlite3_stmt *stmt = NULL;
 
-	ret = sqlite3_prepare_v2(dbh, "SELECT index FROM clients WHERE "
+	ret = sqlite3_prepare_v2(dbh, "SELECT idx FROM clients WHERE "
 				      "id==?", -1, &stmt, NULL);
 	if (ret != SQLITE_OK) {
 		xlog(D_GENERAL, "Unable to prepare update statement: %s",
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
index 0476bef..6a77b80 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -21,6 +21,7 @@
 #define _SQLITE_H_
 
 int sqlite_maindb_init(char *topdir);
+int sqlite_get_generation(uint32_t *generation);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen,
 			 int64_t *index);
 int sqlite_check_client(const unsigned char *clname, const size_t namelen,
-- 
1.7.7.5

