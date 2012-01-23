Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60023 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab2AWUCY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:02:24 -0500
Received: by mail-qw0-f46.google.com with SMTP id c10so2031574qad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:02:24 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 05/11] nfsdcld: add function to remove unreclaimed client records
Date: Mon, 23 Jan 2012 15:02:05 -0500
Message-Id: <1327348931-785-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327348931-785-1-git-send-email-jlayton@redhat.com>
References: <1327348931-785-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should remove any client record that has a timestamp prior to
the given time.

Eventually, this call will need to be made cluster aware when this is
run in a clustered configuration. For now, this is only suitable for
single-host configurations.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/nfsdcld.c |   29 +++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.c  |   28 ++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h  |    1 +
 3 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 2930de4..151dd16 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -187,6 +187,32 @@ cld_check(struct cld_client *clnt)
 }
 
 static void
+cld_gracedone(struct cld_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: grace done. cm_gracetime=%ld", __func__,
+			cmsg->cm_u.cm_gracetime);
+
+	ret = sqlite_remove_unreclaimed(cmsg->cm_u.cm_gracetime);
+
+	/* set up reply: downcall with 0 status */
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
@@ -216,6 +242,9 @@ cldcb(int UNUSED(fd), short which, void *data)
 	case Cld_Allow:
 		cld_check(clnt);
 		break;
+	case Cld_GraceDone:
+		cld_gracedone(clnt);
+		break;
 	default:
 		xlog_warn("%s: command %u is not yet implemented", __func__,
 			  cmsg->cm_cmd);
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index 814e421..a0bcf2f 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -38,6 +38,7 @@
 #include "config.h"
 #endif /* HAVE_CONFIG_H */
 
+#include <dirent.h>
 #include <errno.h>
 #include <event.h>
 #include <stdbool.h>
@@ -320,3 +321,30 @@ out_err:
 	sqlite3_finalize(stmt);
 	return ret;
 }
+
+/*
+ * remove any client records that were not reclaimed since grace_start.
+ */
+int
+sqlite_remove_unreclaimed(time_t grace_start)
+{
+	int ret;
+	char *err = NULL;
+
+	ret = snprintf(buf, sizeof(buf), "DELETE FROM clients WHERE time < %ld",
+			grace_start);
+	if (ret < 0) {
+		return ret;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		ret = -EINVAL;
+		return ret;
+	}
+
+	ret = sqlite3_exec(dbh, buf, NULL, NULL, &err);
+	if (ret != SQLITE_OK)
+		xlog(D_GENERAL, "Delete failed: %s", err);
+
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_free(err);
+	return ret;
+}
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
index 7fc5ea4..f6ed348 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -23,5 +23,6 @@
 int sqlite_maindb_init(char *topdir);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
 int sqlite_check_client(const unsigned char *clname, const size_t namelen);
+int sqlite_remove_unreclaimed(const time_t grace_start);
 
 #endif /* _SQLITE_H */
-- 
1.7.7.5

