Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60023 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab2AWUCZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:02:25 -0500
Received: by mail-qw0-f46.google.com with SMTP id c10so2031574qad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:02:25 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 06/11] nfsdcld: have daemon pass client row index back to kernel
Date: Mon, 23 Jan 2012 15:02:06 -0500
Message-Id: <1327348931-785-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327348931-785-1-git-send-email-jlayton@redhat.com>
References: <1327348931-785-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to deal with some potential problems with lock recovery, we'll
need a way to tag clustered locks in such a way that we know what client
owns them. In order to do that, we need a way to uniquely the client.

We could use the nfs_client_id4 value that the client sends, but it's
too long to be reasonable for this purpose. We could also hash that
down, but there's always the potential for hash collisions. What would
be best is a value that's unique for a particular clientid at a
particular time.

Add an autoincrement index field to the clients table, and have the
check and insert routines grab that and pass it back to the kernel.

For now, the kernel ignores this value, but eventually the locking code
can use this to designate ownership of a lock.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/nfsdcld.c |    8 +++++-
 utils/nfsdcld/sqlite.c  |   53 ++++++++++++++++++++++++++++++++++------------
 utils/nfsdcld/sqlite.h  |    6 +++-
 3 files changed, 49 insertions(+), 18 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 151dd16..bd643b0 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -117,15 +117,17 @@ static void
 cld_create(struct cld_client *clnt)
 {
 	int ret;
+	int64_t index;
 	ssize_t bsize, wsize;
 	struct cld_msg *cmsg = &clnt->cl_msg;
 
 	xlog(D_GENERAL, "%s: create client record.", __func__);
 
 	ret = sqlite_insert_client(cmsg->cm_u.cm_name.cn_id,
-				   cmsg->cm_u.cm_name.cn_len);
+				   cmsg->cm_u.cm_name.cn_len, &index);
 
 	cmsg->cm_status = ret ? -EREMOTEIO : ret;
+	cmsg->cm_u.cm_index = index;
 
 	bsize = sizeof(*cmsg);
 
@@ -164,16 +166,18 @@ static void
 cld_check(struct cld_client *clnt)
 {
 	int ret;
+	int64_t index;
 	ssize_t bsize, wsize;
 	struct cld_msg *cmsg = &clnt->cl_msg;
 
 	xlog(D_GENERAL, "%s: check client record", __func__);
 
 	ret = sqlite_check_client(cmsg->cm_u.cm_name.cn_id,
-				  cmsg->cm_u.cm_name.cn_len);
+				  cmsg->cm_u.cm_name.cn_len, &index);
 
 	/* set up reply */
 	cmsg->cm_status = ret ? -EACCES : ret;
+	cmsg->cm_u.cm_index = index;
 
 	bsize = sizeof(*cmsg);
 
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index a0bcf2f..85e76a1 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -191,7 +191,8 @@ sqlite_maindb_init(char *topdir)
 
 	/* now create the "clients" table */
 	ret = sqlite3_exec(dbh, "CREATE TABLE IF NOT EXISTS clients "
-				"(id BLOB PRIMARY KEY, time INTEGER);",
+				"(idx INTEGER PRIMARY KEY AUTOINCREMENT, "
+				"id BLOB UNIQUE, time INTEGER);",
 				NULL, NULL, &err);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to create clients table: %s", err);
@@ -218,12 +219,14 @@ out_err:
  * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0)
  */
 int
-sqlite_insert_client(const unsigned char *clname, const size_t namelen)
+sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+		     int64_t *index)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
 
-	ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients VALUES "
+	ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
+				      "(id, time) VALUES "
 				      "(?, strftime('%s', 'now'));", -1,
 					&stmt, NULL);
 	if (ret != SQLITE_OK) {
@@ -240,12 +243,38 @@ sqlite_insert_client(const unsigned char *clname, const size_t namelen)
 	}
 
 	ret = sqlite3_step(stmt);
-	if (ret == SQLITE_DONE)
-		ret = SQLITE_OK;
-	else
+	if (ret != SQLITE_DONE) {
 		xlog(D_GENERAL, "Unexpected return code from insert: %s",
 				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	sqlite3_finalize(stmt);
+	stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh, "SELECT index FROM clients WHERE "
+				      "id==?", -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to prepare update statement: %s",
+				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
 
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
+				SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Bind blob failed: %s", sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(D_GENERAL, "Unexpected return code from select: %d", ret);
+		goto out_err;
+	}
+
+	ret = SQLITE_OK;
+	*index = (int64_t)sqlite3_column_int64(stmt, 0);
 out_err:
 	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
 	sqlite3_finalize(stmt);
@@ -258,12 +287,13 @@ out_err:
  * return an error.
  */
 int
-sqlite_check_client(const unsigned char *clname, const size_t namelen)
+sqlite_check_client(const unsigned char *clname, const size_t namelen,
+		    int64_t *index)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
 
-	ret = sqlite3_prepare_v2(dbh, "SELECT count(*) FROM clients WHERE "
+	ret = sqlite3_prepare_v2(dbh, "SELECT index FROM clients WHERE "
 				      "id==?", -1, &stmt, NULL);
 	if (ret != SQLITE_OK) {
 		xlog(D_GENERAL, "Unable to prepare update statement: %s",
@@ -284,12 +314,7 @@ sqlite_check_client(const unsigned char *clname, const size_t namelen)
 		goto out_err;
 	}
 
-	ret = sqlite3_column_int(stmt, 0);
-	xlog(D_GENERAL, "Select returned %d rows", ret);
-	if (ret != 1) {
-		ret = -EACCES;
-		goto out_err;
-	}
+	*index = (int64_t)sqlite3_column_int64(stmt, 0);
 
 	sqlite3_finalize(stmt);
 	stmt = NULL;
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
index f6ed348..0476bef 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -21,8 +21,10 @@
 #define _SQLITE_H_
 
 int sqlite_maindb_init(char *topdir);
-int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
-int sqlite_check_client(const unsigned char *clname, const size_t namelen);
+int sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+			 int64_t *index);
+int sqlite_check_client(const unsigned char *clname, const size_t namelen,
+			int64_t *index);
 int sqlite_remove_unreclaimed(const time_t grace_start);
 
 #endif /* _SQLITE_H */
-- 
1.7.7.5

