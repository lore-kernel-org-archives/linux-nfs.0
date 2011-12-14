Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756915Ab1LNN5P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 08:57:15 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvEXn010890
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:14 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvC3e005913
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:14 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] clstated: add remove functionality
Date: Wed, 14 Dec 2011 08:57:10 -0500
Message-Id: <1323871032-3191-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the kernel to ask for removal of a client record.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/clstated/clstated.c |   34 +++++++++++++++++++++++++++-
 utils/clstated/sqlite.c   |   54 +++++++++++++++++++++++++++++++++++++++++++++
 utils/clstated/sqlite.h   |    1 +
 3 files changed, 88 insertions(+), 1 deletions(-)

diff --git a/utils/clstated/clstated.c b/utils/clstated/clstated.c
index 95ac696..54214cb 100644
--- a/utils/clstated/clstated.c
+++ b/utils/clstated/clstated.c
@@ -147,6 +147,36 @@ clstate_create(struct clstate_client *clnt)
 }
 
 static void
+clstate_remove(struct clstate_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct clstate_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: expire client record. cm_addr=%s", __func__,
+			cmsg->cm_addr);
+
+	ret = clstate_remove_client(cmsg->cm_addr, cmsg->cm_u.cm_id,
+					cmsg->cm_len);
+
+	/* set up reply */
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
+	cmsg->cm_len = 0;
+	memset(cmsg->cm_addr, 0, sizeof(cmsg->cm_addr) +
+			sizeof(cmsg->cm_u.cm_id));
+
+	bsize = sizeof(*cmsg);
+
+	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize) {
+		xlog(L_ERROR, "%s: problem writing to clstate pipe (%ld): %m",
+			 __func__, wsize);
+		clstate_pipe_reopen(clnt);
+	}
+}
+
+static void
 clstatecb(int UNUSED(fd), short which, void *data)
 {
 	ssize_t len;
@@ -168,8 +198,10 @@ clstatecb(int UNUSED(fd), short which, void *data)
 		clstate_create(clnt);
 		break;
 	case Cl_Expire:
-	case Cl_NrToReclaim:
+		clstate_remove(clnt);
+		break;
 	case Cl_Allow:
+	case Cl_NrToReclaim:
 	case Cl_GraceDone:
 		xlog_warn("%s: command %u is not yet implemented", __func__,
 			  cmsg->cm_cmd);
diff --git a/utils/clstated/sqlite.c b/utils/clstated/sqlite.c
index ae83634..78ce6b4 100644
--- a/utils/clstated/sqlite.c
+++ b/utils/clstated/sqlite.c
@@ -349,3 +349,57 @@ out_detach:
 	clstate_db_detach(dbname);
 	return ret;
 }
+
+/* Remove a client record */
+int
+clstate_remove_client(const unsigned char *addr, const unsigned char *clname,
+			const size_t namelen)
+{
+	int ret;
+	char *err = NULL;
+	char dbname[CLSTATE_MAX_ADDRESS_LEN];
+	sqlite3_stmt *stmt = NULL;
+
+	addr_to_dbname((const char *)addr, dbname);
+
+	ret = clstate_db_attach(dbname);
+	if (ret != SQLITE_OK)
+		return ret;
+
+	ret = snprintf(buf, sizeof(buf),
+			"DELETE FROM '%s'.clients WHERE id==?", dbname);
+	if (ret < 0) {
+		goto out_detach;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		ret = -EINVAL;
+		goto out_detach;
+	}
+
+	ret = sqlite3_prepare_v2(dbh, buf, ret + 1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Statement prepare failed: %d", ret);
+		goto out_err;
+	}
+
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
+				SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Bind blob failed: %d", ret);
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret == SQLITE_DONE)
+		ret = SQLITE_OK;
+	else
+		xlog(D_GENERAL, "Unexpected return code from insert: %s",
+				sqlite3_errmsg(dbh));
+
+out_err:
+	xlog(D_GENERAL, "%s returning %d", __func__, ret);
+	sqlite3_finalize(stmt);
+	sqlite3_free(err);
+out_detach:
+	clstate_db_detach(dbname);
+	return ret;
+}
diff --git a/utils/clstated/sqlite.h b/utils/clstated/sqlite.h
index 4f81745..6f5637f 100644
--- a/utils/clstated/sqlite.h
+++ b/utils/clstated/sqlite.h
@@ -23,5 +23,6 @@
 void clstate_set_topdir(char *topdir);
 int clstate_maindb_init(void);
 int clstate_insert_client(const unsigned char *addr, const unsigned char *clname, const size_t namelen);
+int clstate_remove_client(const unsigned char *addr, const unsigned char *clname, const size_t namelen);
 
 #endif /* _SQLITE_H */
-- 
1.7.1

