Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22933 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759316Ab1LOSoE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 13:44:04 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi3Mg010889
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:04 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi17i010403
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:03 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/7] nfsdcld: add check/update functionality
Date: Thu, 15 Dec 2011 13:44:00 -0500
Message-Id: <1323974641-16515-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
References: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add functions to check whether a client is allowed to reclaim, and
update its timestamp in the DB if so. We do this with an UPDATE OR
FAIL SQL statement. If the update fails for any reason (like, say
the record doesn't exist), then the kernel can disallow the reclaim.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/nfsdcld.c |   30 +++++++++++++++++++-
 utils/nfsdcld/sqlite.c  |   69 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h  |    1 +
 3 files changed, 99 insertions(+), 1 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 0252e78..2322ab7 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -161,6 +161,32 @@ cld_remove(struct cld_client *clnt)
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
@@ -184,8 +210,10 @@ cldcb(int UNUSED(fd), short which, void *data)
 	case Cld_Expire:
 		cld_remove(clnt);
 		break;
-	case Cld_NrToReclaim:
 	case Cld_Allow:
+		cld_check(clnt);
+		break;
+	case Cld_NrToReclaim:
 	case Cld_GraceDone:
 		xlog_warn("%s: command %u is not yet implemented", __func__,
 			  cmsg->cm_cmd);
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index 5986dca..63d5363 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -289,3 +289,72 @@ out_err:
 	sqlite3_finalize(stmt);
 	return ret;
 }
+
+/*
+ * Update a client's timestamp. Return an error if the update fails. On error,
+ * the kernel can infer that reclaim should be denied.
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
index 157c127..613ae97 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -24,5 +24,6 @@ void sqlite_set_topdir(char *topdir);
 int sqlite_maindb_init(void);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
+int sqlite_check_client(const unsigned char *clname, const size_t namelen);
 
 #endif /* _SQLITE_H */
-- 
1.7.1

