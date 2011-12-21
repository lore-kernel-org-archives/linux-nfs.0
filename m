Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754029Ab1LUUfb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 15:35:31 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 06/10] nfsdcld: add check/update functionality
Date: Wed, 21 Dec 2011 15:35:18 -0500
Message-Id: <1324499722-10363-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1324499722-10363-1-git-send-email-jlayton@redhat.com>
References: <1324499722-10363-1-git-send-email-jlayton@redhat.com>
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
index 885d79e..29c514c 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -186,6 +186,32 @@ cld_remove(struct cld_client *clnt)
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
@@ -215,6 +241,9 @@ cldcb(int UNUSED(fd), short which, void *data)
 	case Cld_Expire:
 		cld_remove(clnt);
 		break;
+	case Cld_Allow:
+		cld_check(clnt);
+		break;
 	default:
 		xlog_warn("%s: command %u is not yet implemented", __func__,
 			  cmsg->cm_cmd);
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index a90e112..6d3c022 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -285,3 +285,73 @@ out_err:
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
index 425f5ba..59ebd72 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -23,5 +23,6 @@
 int sqlite_maindb_init(char *topdir);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
+int sqlite_check_client(const unsigned char *clname, const size_t namelen);
 
 #endif /* _SQLITE_H */
-- 
1.7.1

