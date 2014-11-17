Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:55416 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaKQScY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 13:32:24 -0500
Received: by mail-qc0-f181.google.com with SMTP id m20so4075240qcx.12
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 10:32:23 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 1/2] nfsdcltrack: use sqlite3_close instead of sqlite3_close_v2
Date: Mon, 17 Nov 2014 13:32:14 -0500
Message-Id: <1416249135-18736-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416249135-18736-1-git-send-email-jlayton@primarydata.com>
References: <1416249135-18736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sqlite3_close_v2 wasn't added until v3.7.14 of libsqlite3 so this causes
the build to fail vs. very old sqlite3 libs. Also, Chuck points out that
the documentation says that sqlite3_close_v2 is intended for use with
host languages that are garbage collected, and C isn't.

In practice, we shouldn't ever see sqlite3_close return SQLITE_BUSY here
anyway since the program is single-threaded, so sqlite3_close should be
fine.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/sqlite.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index fb45c4af5edb..7cac89ef459f 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -357,7 +357,7 @@ sqlite_prepare_dbh(const char *topdir)
 
 	return ret;
 out_close:
-	sqlite3_close_v2(dbh);
+	sqlite3_close(dbh);
 	dbh = NULL;
 	return ret;
 }
-- 
2.1.0

