Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:34010 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaKQScZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 13:32:25 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so3194066qcr.28
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 10:32:24 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 2/2] nfsdcltrack: use sqlite3_errmsg instead of sqlite3_errstr
Date: Mon, 17 Nov 2014 13:32:15 -0500
Message-Id: <1416249135-18736-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416249135-18736-1-git-send-email-jlayton@primarydata.com>
References: <1416249135-18736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sqlite3_errstr was only added in v3.7.15 of libsqlite3, which makes it
difficult to build against earlier releases. Switch the code over to
use sqlite3_errmsg instead.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/sqlite.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index 7cac89ef459f..54cd7487920b 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -102,7 +102,7 @@ sqlite_query_schema_version(void)
 		 -1, &stmt, NULL);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to prepare select statement: %s",
-			sqlite3_errstr(ret));
+			sqlite3_errmsg(dbh));
 		ret = 0;
 		goto out;
 	}
@@ -111,7 +111,7 @@ sqlite_query_schema_version(void)
 	ret = sqlite3_step(stmt);
 	if (ret != SQLITE_ROW) {
 		xlog(L_ERROR, "Select statement execution failed: %s",
-				sqlite3_errstr(ret));
+				sqlite3_errmsg(dbh));
 		ret = 0;
 		goto out;
 	}
@@ -324,7 +324,7 @@ sqlite_prepare_dbh(const char *topdir)
 	ret = sqlite3_busy_timeout(dbh, CLTRACK_SQLITE_BUSY_TIMEOUT);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to set sqlite busy timeout: %s",
-				sqlite3_errstr(ret));
+				sqlite3_errmsg(dbh));
 		goto out_close;
 	}
 
@@ -574,21 +574,21 @@ sqlite_query_reclaiming(const time_t grace_start)
 				      "time < ? OR has_session != 1", -1, &stmt, NULL);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: unable to prepare select statement: %s",
-				__func__, sqlite3_errstr(ret));
+				__func__, sqlite3_errmsg(dbh));
 		return ret;
 	}
 
 	ret = sqlite3_bind_int64(stmt, 1, (sqlite3_int64)grace_start);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: bind int64 failed: %s",
-				__func__, sqlite3_errstr(ret));
+				__func__, sqlite3_errmsg(dbh));
 		return ret;
 	}
 
 	ret = sqlite3_step(stmt);
 	if (ret != SQLITE_ROW) {
 		xlog(L_ERROR, "%s: unexpected return code from select: %s",
-				__func__, sqlite3_errstr(ret));
+				__func__, sqlite3_errmsg(dbh));
 		return ret;
 	}
 
-- 
2.1.0

