Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:38359 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab2AWUCX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:02:23 -0500
Received: by mail-qy0-f174.google.com with SMTP id f13so1753533qcs.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:02:23 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 04/11] nfsdcld: add check/update functionality
Date: Mon, 23 Jan 2012 15:02:04 -0500
Message-Id: <1327348931-785-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327348931-785-1-git-send-email-jlayton@redhat.com>
References: <1327348931-785-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add functions to check whether a client is allowed to reclaim, and
update its timestamp in the DB if so. If either the query or update
fails, then the host is not allowed to reclaim state.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/nfsdcld.c |   29 +++++++++++++++++++
 utils/nfsdcld/sqlite.c  |   70 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h  |    1 +
 3 files changed, 100 insertions(+), 0 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index d6bd041..2930de4 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -161,6 +161,32 @@ cld_not_implemented(struct cld_client *clnt)
 }
 
 static void
+cld_check(struct cld_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: check client record", __func__);
+
+	ret = sqlite_check_client(cmsg->cm_u.cm_name.cn_id,
+				  cmsg->cm_u.cm_name.cn_len);
+
+	/* set up reply */
+	cmsg->cm_status = ret ? -EACCES : ret;
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
 cldcb(int UNUSED(fd), short which, void *data)
 {
 	ssize_t len;
@@ -187,6 +213,9 @@ cldcb(int UNUSED(fd), short which, void *data)
 	case Cld_Create:
 		cld_create(clnt);
 		break;
+	case Cld_Allow:
+		cld_check(clnt);
+		break;
 	default:
 		xlog_warn("%s: command %u is not yet implemented", __func__,
 			  cmsg->cm_cmd);
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index 606d714..814e421 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -250,3 +250,73 @@ out_err:
 	sqlite3_finalize(stmt);
 	return ret;
 }
+
+/*
+ * Is the given clname in the clients table? If so, then update its timestamp
+ * and return success. If the record isn't present, or the update fails, then
+ * return an error.
+ */
+int
+sqlite_check_client(const unsigned char *clname, const size_t namelen)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh, "SELECT count(*) FROM clients WHERE "
+				      "id==?", -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to prepare update statement: %s",
+				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
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
+	ret = sqlite3_column_int(stmt, 0);
+	xlog(D_GENERAL, "Select returned %d rows", ret);
+	if (ret != 1) {
+		ret = -EACCES;
+		goto out_err;
+	}
+
+	sqlite3_finalize(stmt);
+	stmt = NULL;
+	ret = sqlite3_prepare_v2(dbh, "UPDATE OR FAIL clients SET "
+				      "time=strftime('%s', 'now') WHERE id==?",
+				 -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to prepare update statement: %s",
+				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
+				SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Bind blob failed: %s", sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret == SQLITE_DONE)
+		ret = SQLITE_OK;
+	else
+		xlog(D_GENERAL, "Unexpected return code from update: %s",
+				sqlite3_errmsg(dbh));
+
+out_err:
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_finalize(stmt);
+	return ret;
+}
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
index ba4c213..7fc5ea4 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -22,5 +22,6 @@
 
 int sqlite_maindb_init(char *topdir);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
+int sqlite_check_client(const unsigned char *clname, const size_t namelen);
 
 #endif /* _SQLITE_H */
-- 
1.7.7.5

