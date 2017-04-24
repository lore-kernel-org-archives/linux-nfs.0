Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44876 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S974818AbdDXQla (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Apr 2017 12:41:30 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 72F554AE9E
        for <linux-nfs@vger.kernel.org>; Mon, 24 Apr 2017 16:41:19 +0000 (UTC)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, chunwang@redhat.com
Subject: [PATCH] nfsdcltrack: silence some expected errors
Date: Mon, 24 Apr 2017 12:41:17 -0400
Message-Id: <20170424164117.13119-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On a new install, we're unable to select from the parameters table, as
it doesn't exist yet. The code is set up to log that fact at L_ERROR
now, but it's an expected situation. Change it to log that at D_GENERAL
instead.

Reported-and-Tested-by: ChunYu Wang <chunwang@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcltrack/sqlite.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index 54cd7487920b..1552eba4e35c 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -101,7 +101,7 @@ sqlite_query_schema_version(void)
 		"SELECT value FROM parameters WHERE key == \"version\";",
 		 -1, &stmt, NULL);
 	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "Unable to prepare select statement: %s",
+		xlog(D_GENERAL, "Unable to prepare select statement: %s",
 			sqlite3_errmsg(dbh));
 		ret = 0;
 		goto out;
@@ -110,7 +110,7 @@ sqlite_query_schema_version(void)
 	/* query schema version */
 	ret = sqlite3_step(stmt);
 	if (ret != SQLITE_ROW) {
-		xlog(L_ERROR, "Select statement execution failed: %s",
+		xlog(D_GENERAL, "Select statement execution failed: %s",
 				sqlite3_errmsg(dbh));
 		ret = 0;
 		goto out;
-- 
2.9.3

