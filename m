Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757211Ab1LNN5P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 08:57:15 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvFid026826
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:15 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvC3g005913
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:15 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] clstated: add function to remove unreclaimed client records
Date: Wed, 14 Dec 2011 08:57:12 -0500
Message-Id: <1323871032-3191-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should remove any client record from any server address DB that
has a timestamp prior to the given time.

Eventually, this call will need to be made cluster aware when this is
run in a clustered configuration. For now, this is only suitable for
single-host configurations.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/clstated/clstated.c |   33 +++++++++++++-
 utils/clstated/sqlite.c   |  109 +++++++++++++++++++++++++++++++++++++++++++++
 utils/clstated/sqlite.h   |    1 +
 3 files changed, 142 insertions(+), 1 deletions(-)

diff --git a/utils/clstated/clstated.c b/utils/clstated/clstated.c
index 885e302..a19d269 100644
--- a/utils/clstated/clstated.c
+++ b/utils/clstated/clstated.c
@@ -207,6 +207,35 @@ clstate_check(struct clstate_client *clnt)
 }
 
 static void
+clstate_gracedone(struct clstate_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct clstate_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: grace done. cm_gracetime=%ld", __func__,
+			cmsg->cm_u.cm_gracetime);
+
+	ret = clstate_remove_unreclaimed(cmsg->cm_u.cm_gracetime);
+
+	/* set up reply: downcall with 0 status */
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
+	cmsg->cm_len = 0;
+	memset(cmsg->cm_addr, 0, sizeof(cmsg->cm_addr) +
+			sizeof(cmsg->cm_u));
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
@@ -233,8 +262,10 @@ clstatecb(int UNUSED(fd), short which, void *data)
 	case Cl_Allow:
 		clstate_check(clnt);
 		break;
-	case Cl_NrToReclaim:
 	case Cl_GraceDone:
+		clstate_gracedone(clnt);
+		break;
+	case Cl_NrToReclaim:
 		xlog_warn("%s: command %u is not yet implemented", __func__,
 			  cmsg->cm_cmd);
 		break;
diff --git a/utils/clstated/sqlite.c b/utils/clstated/sqlite.c
index d6f6a90..c8e15e5 100644
--- a/utils/clstated/sqlite.c
+++ b/utils/clstated/sqlite.c
@@ -44,6 +44,7 @@
 #include "config.h"
 #endif /* HAVE_CONFIG_H */
 
+#include <dirent.h>
 #include <errno.h>
 #include <event.h>
 #include <stdbool.h>
@@ -97,6 +98,30 @@ addr_to_dbname(const char *src, char *dst)
 	*dst = '\0';
 }
 
+/*
+ * strip the '.sqlite' from the end of the filename. If there is no postfix,
+ * then return NULL and don't do anything.
+ */
+static char *
+filename_to_dbname(const char *src, char *dst)
+{
+	char *postfix;
+	size_t len;
+
+	/* no .sqlite prefix? Then we're not interested */
+	postfix = strstr(src, ".sqlite");
+	if (!postfix)
+		return postfix;
+
+	len = postfix - src;
+	if (len > CLSTATE_MAX_ADDRESS_LEN)
+		return NULL;
+
+	strncpy(dst, src, len);
+	dst[len] = '\0';
+	return dst;
+}
+
 void
 clstate_set_topdir(char *topdir)
 {
@@ -461,3 +486,87 @@ out_detach:
 	clstate_db_detach(dbname);
 	return ret;
 }
+
+/*
+ * Attempt to attach to a database with the given filename. If the DB appears
+ * to be usable, then remove any client records with a timestamp before
+ * grace_start.
+ */
+static int
+clstate_remove_unreclaimed_db(const char *filename, time_t grace_start)
+{
+	int ret;
+	char *err = NULL;
+	char dbname[CLSTATE_MAX_ADDRESS_LEN];
+
+	/* get the dbname for the given filename */
+	if (!filename_to_dbname(filename, dbname))
+		return 0;
+
+	/* skip main.sqlite */
+	if (!strcmp(dbname, "main"))
+		return 0;
+
+	ret = clstate_db_attach(dbname);
+	if (ret != SQLITE_OK)
+		return ret;
+
+	ret = snprintf(buf, sizeof(buf),
+			"DELETE FROM '%s'.clients WHERE time < %ld",
+			dbname, grace_start);
+	if (ret < 0) {
+		goto out_detach;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		ret = -EINVAL;
+		goto out_detach;
+	}
+
+	ret = sqlite3_exec(dbh, buf, NULL, NULL, &err);
+	if (ret != SQLITE_OK)
+		xlog(D_GENERAL, "delete failed: %s", err);
+
+	xlog(D_GENERAL, "%s returning %d", __func__, ret);
+	sqlite3_free(err);
+
+out_detach:
+	clstate_db_detach(dbname);
+	return ret;
+}
+
+/*
+ * remove any client records that were not reclaimed since grace_start. We
+ * do this by attempting to attach to any database in the clstatedir and
+ * removing any records that have timestamps that are too old.
+ */
+int
+clstate_remove_unreclaimed(const time_t grace_start)
+{
+	int ret;
+	DIR *dir;
+	struct dirent *de;
+
+	dir = opendir(clstate_topdir);
+	if (!dir) {
+		xlog(L_ERROR, "Unable to opendir %s: %m", clstate_topdir);
+		return errno;
+	}
+
+	for (;;) {
+		errno = 0;
+		de = readdir(dir);
+		if (!de) {
+			ret = errno;
+			if (errno != 0)
+				xlog(L_ERROR, "readdir failed: %m");
+			break;
+		}
+
+		ret = clstate_remove_unreclaimed_db(de->d_name, grace_start);
+		if (ret)
+			xlog(L_ERROR, "Unable to clear old client records from "
+				      "%s: %d", de->d_name, ret);
+	}
+
+	closedir(dir);
+	return ret;
+}
diff --git a/utils/clstated/sqlite.h b/utils/clstated/sqlite.h
index 46d2f24..3fecf96 100644
--- a/utils/clstated/sqlite.h
+++ b/utils/clstated/sqlite.h
@@ -25,5 +25,6 @@ int clstate_maindb_init(void);
 int clstate_insert_client(const unsigned char *addr, const unsigned char *clname, const size_t namelen);
 int clstate_remove_client(const unsigned char *addr, const unsigned char *clname, const size_t namelen);
 int clstate_check_client(const unsigned char *addr, const unsigned char *clname, const size_t namelen);
+int clstate_remove_unreclaimed(const time_t grace_start);
 
 #endif /* _SQLITE_H */
-- 
1.7.1

