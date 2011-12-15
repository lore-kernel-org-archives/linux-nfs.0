Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759315Ab1LOSoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 13:44:03 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi3o8032274
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:03 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi17h010403
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:03 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/7] nfsdcld: add remove functionality
Date: Thu, 15 Dec 2011 13:43:59 -0500
Message-Id: <1323974641-16515-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
References: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the kernel to ask for removal of a client record.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/nfsdcld.c |   28 ++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.c  |   35 +++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h  |    1 +
 3 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index de2e932..0252e78 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -135,6 +135,32 @@ cld_create(struct cld_client *clnt)
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
+	/* set up reply */
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
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
@@ -156,6 +182,8 @@ cldcb(int UNUSED(fd), short which, void *data)
 		cld_create(clnt);
 		break;
 	case Cld_Expire:
+		cld_remove(clnt);
+		break;
 	case Cld_NrToReclaim:
 	case Cld_Allow:
 	case Cld_GraceDone:
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index 2534ba5..5986dca 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -254,3 +254,38 @@ out_err:
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
+		xlog(D_GENERAL, "Statement prepare failed: %s",
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
+		xlog(D_GENERAL, "Unexpected return code from delete: %s",
+				sqlite3_errmsg(dbh));
+
+out_err:
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_finalize(stmt);
+	return ret;
+}
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
index 4b99729..157c127 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -23,5 +23,6 @@
 void sqlite_set_topdir(char *topdir);
 int sqlite_maindb_init(void);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
+int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
 
 #endif /* _SQLITE_H */
-- 
1.7.1

