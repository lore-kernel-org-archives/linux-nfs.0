Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:50014 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbaHSSuG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 14:50:06 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so6836990qcz.28
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 11:50:05 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 7/7] nfsdcltrack: fetch NFSDCLTRACK_GRACE_START out of environment
Date: Tue, 19 Aug 2014 14:49:49 -0400
Message-Id: <1408474189-14491-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408474189-14491-1-git-send-email-jlayton@primarydata.com>
References: <1408474189-14491-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the fetching of NFSDCLTRACK_GRACE_START out of environment
variables. If it's present in the "create" or "init" upcalls, then we
can use that to query the database to see whether there are any clients
that have not issued a RECLAIM_COMPLETE since that time.

If there aren't any, then we know that all reclaim activity is now done
and we can then cue the kernel to lift the grace period.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/nfsdcltrack.c | 77 ++++++++++++++++++++++++++++++++++++++++-
 utils/nfsdcltrack/sqlite.c      | 40 +++++++++++++++++++++
 utils/nfsdcltrack/sqlite.h      |  1 +
 3 files changed, 117 insertions(+), 1 deletion(-)

diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index cbc98c7edc11..f500216e6021 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -50,6 +50,8 @@
 #define CLD_DEFAULT_STORAGEDIR NFS_STATEDIR "/nfsdcltrack"
 #endif
 
+#define NFSD_END_GRACE_FILE "/proc/fs/nfsd/v4_end_grace"
+
 /* defined by RFC 3530 */
 #define NFS4_OPAQUE_LIMIT	1024
 
@@ -211,6 +213,64 @@ cltrack_set_caps(void)
 	return ret;
 }
 
+/* Inform the kernel that it's OK to lift nfsd's grace period */
+static void
+cltrack_lift_grace_period(void)
+{
+	int fd;
+
+	fd = open(NFSD_END_GRACE_FILE, O_WRONLY);
+	if (fd < 0) {
+		/* Don't warn if file isn't present */
+		if (errno != ENOENT)
+			xlog(L_WARNING, "Unable to open %s: %m",
+				NFSD_END_GRACE_FILE);
+		return;
+	}
+
+	if (write(fd, "Y", 1) < 0)
+		xlog(L_WARNING, "Unable to write to %s: %m",
+				NFSD_END_GRACE_FILE);
+
+	close(fd);
+	return;
+}
+
+/*
+ * Fetch the contents of the NFSDCLTRACK_GRACE_START env var. If it's not set
+ * or there's an error converting it to time_t, then return LONG_MAX.
+ */
+static time_t
+cltrack_get_grace_start(void)
+{
+	time_t grace_start;
+	char *end;
+	char *grace_start_str = getenv("NFSDCLTRACK_GRACE_START");
+
+	if (!grace_start_str)
+		return LONG_MAX;
+
+	errno = 0;
+	grace_start = strtol(grace_start_str, &end, 0);
+	/* Problem converting or value is too large? */
+	if (errno)
+		return LONG_MAX;
+
+	return grace_start;
+}
+
+static bool
+cltrack_reclaims_complete(void)
+{
+	time_t grace_start = cltrack_get_grace_start();
+
+	/* Don't query DB if we didn't get a valid boot time */
+	if (grace_start == LONG_MAX)
+		return false;
+
+	return !sqlite_query_reclaiming(grace_start);
+}
+
 static int
 cltrack_init(const char __attribute__((unused)) *unused)
 {
@@ -251,7 +311,11 @@ cltrack_init(const char __attribute__((unused)) *unused)
 		 * stop upcalling until the problem is resolved.
 		 */
 		ret = -EACCES;
+	} else {
+		if (cltrack_reclaims_complete())
+			cltrack_lift_grace_period();
 	}
+
 	return ret;
 }
 
@@ -284,6 +348,7 @@ cltrack_create(const char *id)
 {
 	int ret;
 	ssize_t len;
+	unsigned int minorvers;
 
 	xlog(D_GENERAL, "%s: create client record.", __func__);
 
@@ -295,8 +360,18 @@ cltrack_create(const char *id)
 	if (len < 0)
 		return (int)len;
 
-	ret = sqlite_insert_client(blob, len, cltrack_get_minorvers());
+	minorvers = cltrack_get_minorvers();
+	ret = sqlite_insert_client(blob, len, minorvers);
+	if (ret)
+		goto out;
+
+	/* No point in querying the DB if this client was v4.0 */
+	if (minorvers == 0)
+		goto out;
 
+	if (cltrack_reclaims_complete())
+		cltrack_lift_grace_period();
+out:
 	return ret ? -EREMOTEIO : ret;
 }
 
diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index 01084bb6c4d8..17437e48ffaa 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -547,3 +547,43 @@ sqlite_remove_unreclaimed(time_t grace_start)
 	sqlite3_free(err);
 	return ret;
 }
+
+/*
+ * Are there any clients that are possibly still reclaiming? Return a positive
+ * integer (usually number of clients) if so. If not, then return 0. On any
+ * error, return non-zero.
+ */
+int
+sqlite_query_reclaiming(const time_t grace_start)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh, "SELECT count(*) FROM clients WHERE "
+				      "reclaim_complete < ?", -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: unable to prepare select statement: %s",
+				__func__, sqlite3_errstr(ret));
+		return ret;
+	}
+
+	ret = sqlite3_bind_int64(stmt, 1, (sqlite3_int64)grace_start);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind int64 failed: %s",
+				__func__, sqlite3_errstr(ret));
+		return ret;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(L_ERROR, "%s: unexpected return code from select: %s",
+				__func__, sqlite3_errstr(ret));
+		return ret;
+	}
+
+	ret = sqlite3_column_int(stmt, 0);
+	sqlite3_finalize(stmt);
+	xlog(D_GENERAL, "%s: there are %d clients that have not completed "
+			"reclaim", __func__, ret);
+	return ret;
+}
diff --git a/utils/nfsdcltrack/sqlite.h b/utils/nfsdcltrack/sqlite.h
index e9cc84cbb294..0e1939198367 100644
--- a/utils/nfsdcltrack/sqlite.h
+++ b/utils/nfsdcltrack/sqlite.h
@@ -26,5 +26,6 @@ int sqlite_insert_client(const unsigned char *clname, const size_t namelen,
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
 int sqlite_check_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_unreclaimed(const time_t grace_start);
+int sqlite_query_reclaiming(const time_t grace_start);
 
 #endif /* _SQLITE_H */
-- 
1.9.3

