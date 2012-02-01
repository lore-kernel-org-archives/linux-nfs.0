Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:46265 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641Ab2BAPpH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 10:45:07 -0500
Received: by mail-qy0-f174.google.com with SMTP id w6so740319qcq.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Feb 2012 07:45:07 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 4/9] nfsdcld: add remove functionality
Date: Wed,  1 Feb 2012 10:44:51 -0500
Message-Id: <1328111096-28430-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
References: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the kernel to ask for removal of a client record.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/nfsdcld.c |   34 ++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.c  |   36 ++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h  |    1 +
 3 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 15746e6..ce8355a 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -171,6 +171,37 @@ cld_create(struct cld_client *clnt)
 }
 
 static void
+cld_remove(struct cld_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: remove client record.", __func__);
+
+	ret = sqlite_remove_client(cmsg->cm_u.cm_name.cn_id,
+				   cmsg->cm_u.cm_name.cn_len);
+
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
+
+	bsize = sizeof(*cmsg);
+
+	xlog(D_GENERAL, "%s: downcall with status %d", __func__,
+			cmsg->cm_status);
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize) {
+		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
+			 __func__, wsize);
+		ret = cld_pipe_open(clnt);
+		if (ret) {
+			xlog(L_FATAL, "%s: unable to reopen pipe: %d",
+					__func__, ret);
+			exit(ret);
+		}
+	}
+}
+
+static void
 cldcb(int UNUSED(fd), short which, void *data)
 {
 	ssize_t len;
@@ -198,6 +229,9 @@ cldcb(int UNUSED(fd), short which, void *data)
 	case Cld_Create:
 		cld_create(clnt);
 		break;
+	case Cld_Remove:
+		cld_remove(clnt);
+		break;
 	default:
 		xlog(L_WARNING, "%s: command %u is not yet implemented",
 				__func__, cmsg->cm_cmd);
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index f70568e..a198c34 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -251,3 +251,39 @@ out_err:
 	sqlite3_finalize(stmt);
 	return ret;
 }
+
+/* Remove a client record */
+int
+sqlite_remove_client(const unsigned char *clname, const size_t namelen)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh, "DELETE FROM clients WHERE id==?", -1,
+				 &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: statement prepare failed: %s",
+				__func__, sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
+				SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind blob failed: %s", __func__,
+				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret == SQLITE_DONE)
+		ret = SQLITE_OK;
+	else
+		xlog(L_ERROR, "%s: unexpected return code from delete: %d",
+				__func__, ret);
+
+out_err:
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_finalize(stmt);
+	return ret;
+}
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
index ba4c213..425f5ba 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -22,5 +22,6 @@
 
 int sqlite_maindb_init(char *topdir);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
+int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
 
 #endif /* _SQLITE_H */
-- 
1.7.7.6

