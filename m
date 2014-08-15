Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:64601 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbaHOOp1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:45:27 -0400
Received: by mail-qc0-f174.google.com with SMTP id l6so2390524qcy.33
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:45:26 -0700 (PDT)
Received: from tlielax.poochiereds.net ([2001:470:8:d63:3a60:77ff:fe93:a95d])
        by mx.google.com with ESMTPSA id t107sm3989900qgt.28.2014.08.15.07.45.25
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 07:45:25 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 3/7] nfsdcltrack: rename CLD_* constants with CLTRACK_* prefixes
Date: Fri, 15 Aug 2014 10:45:11 -0400
Message-Id: <1408113915-5573-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
References: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@poochiereds.net>

Since nfsdcld has been dead for a few years now, clean up the prefixes
on the constants.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/sqlite.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index 352f029d55c0..52fcaa4d7ca3 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -50,10 +50,10 @@
 
 #include "xlog.h"
 
-#define CLD_SQLITE_SCHEMA_VERSION 1
+#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 1
 
 /* in milliseconds */
-#define CLD_SQLITE_BUSY_TIMEOUT 10000
+#define CLTRACK_SQLITE_BUSY_TIMEOUT 10000
 
 /* private data structures */
 
@@ -111,7 +111,7 @@ sqlite_prepare_dbh(const char *topdir)
 		return ret;
 	}
 
-	ret = sqlite3_busy_timeout(dbh, CLD_SQLITE_BUSY_TIMEOUT);
+	ret = sqlite3_busy_timeout(dbh, CLTRACK_SQLITE_BUSY_TIMEOUT);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to set sqlite busy timeout: %d", ret);
 		sqlite3_close(dbh);
@@ -156,7 +156,7 @@ sqlite_maindb_init(const char *topdir)
 	/* insert version into table -- ignore error if it fails */
 	ret = snprintf(buf, sizeof(buf),
 		       "INSERT OR IGNORE INTO parameters values (\"version\", "
-		       "\"%d\");", CLD_SQLITE_SCHEMA_VERSION);
+		       "\"%d\");", CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION);
 	if (ret < 0) {
 		goto out_err;
 	} else if ((size_t)ret >= sizeof(buf)) {
@@ -189,10 +189,10 @@ sqlite_maindb_init(const char *topdir)
 
 	/* process SELECT result */
 	ret = sqlite3_column_int(stmt, 0);
-	if (ret != CLD_SQLITE_SCHEMA_VERSION) {
+	if (ret != CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION) {
 		xlog(L_ERROR, "Unsupported database schema version! "
 			"Expected %d, got %d.",
-			CLD_SQLITE_SCHEMA_VERSION, ret);
+			CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION, ret);
 		ret = -EINVAL;
 		goto out_err;
 	}
-- 
1.9.3

