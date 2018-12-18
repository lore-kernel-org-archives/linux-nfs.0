Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B151DC43613
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8E04521871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726971AbeLROaU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:30:20 -0500
Received: from mx1.redhat.com ([209.132.183.28]:53860 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727055AbeLROaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:30:19 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 83CD9DC8E0;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id F06306012C;
        Tue, 18 Dec 2018 14:30:18 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 92F012293D; Tue, 18 Dec 2018 09:30:18 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 4/7] nfsdcld: remove some unused functions
Date:   Tue, 18 Dec 2018 09:30:15 -0500
Message-Id: <20181218143018.28575-5-smayhew@redhat.com>
In-Reply-To: <20181218143018.28575-1-smayhew@redhat.com>
References: <20181218143018.28575-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Get rid of sqlite_query_reclaiming() and sqlite_remove_unreclaimed(),
which are not used.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/nfsdcld/sqlite.c | 67 ------------------------------------------
 utils/nfsdcld/sqlite.h |  2 --
 2 files changed, 69 deletions(-)

diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index 82140ea..6e4eb66 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -628,73 +628,6 @@ out_err:
 	return ret;
 }
 
-/*
- * remove any client records that were not reclaimed since grace_start.
- */
-int
-sqlite_remove_unreclaimed(time_t grace_start)
-{
-	int ret;
-	char *err = NULL;
-
-	ret = snprintf(buf, sizeof(buf), "DELETE FROM clients WHERE time < %ld",
-			grace_start);
-	if (ret < 0) {
-		return ret;
-	} else if ((size_t)ret >= sizeof(buf)) {
-		ret = -EINVAL;
-		return ret;
-	}
-
-	ret = sqlite3_exec(dbh, buf, NULL, NULL, &err);
-	if (ret != SQLITE_OK)
-		xlog(L_ERROR, "%s: delete failed: %s", __func__, err);
-
-	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
-	sqlite3_free(err);
-	return ret;
-}
-
-/*
- * Are there any clients that are possibly still reclaiming? Return a positive
- * integer (usually number of clients) if so. If not, then return 0. On any
- * error, return non-zero.
- */
-int
-sqlite_query_reclaiming(const time_t grace_start)
-{
-	int ret;
-	sqlite3_stmt *stmt = NULL;
-
-	ret = sqlite3_prepare_v2(dbh, "SELECT count(*) FROM clients WHERE "
-				      "time < ? OR has_session != 1", -1, &stmt, NULL);
-	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "%s: unable to prepare select statement: %s",
-				__func__, sqlite3_errmsg(dbh));
-		return ret;
-	}
-
-	ret = sqlite3_bind_int64(stmt, 1, (sqlite3_int64)grace_start);
-	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "%s: bind int64 failed: %s",
-				__func__, sqlite3_errmsg(dbh));
-		return ret;
-	}
-
-	ret = sqlite3_step(stmt);
-	if (ret != SQLITE_ROW) {
-		xlog(L_ERROR, "%s: unexpected return code from select: %s",
-				__func__, sqlite3_errmsg(dbh));
-		return ret;
-	}
-
-	ret = sqlite3_column_int(stmt, 0);
-	sqlite3_finalize(stmt);
-	xlog(D_GENERAL, "%s: there are %d clients that have not completed "
-			"reclaim", __func__, ret);
-	return ret;
-}
-
 int
 sqlite_grace_start(void)
 {
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
index 5c56f75..757e5cc 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -26,8 +26,6 @@ int sqlite_prepare_dbh(const char *topdir);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
 int sqlite_check_client(const unsigned char *clname, const size_t namelen);
-int sqlite_remove_unreclaimed(const time_t grace_start);
-int sqlite_query_reclaiming(const time_t grace_start);
 int sqlite_grace_start(void);
 int sqlite_grace_done(void);
 int sqlite_iterate_recovery(int (*cb)(struct cld_client *clnt), struct cld_client *clnt);
-- 
2.17.1

