Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:62426 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934911Ab2JXP0M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 11:26:12 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so666919vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 08:26:11 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 03/10] nfsdcltrack: remove pointless sqlite_topdir variable
Date: Wed, 24 Oct 2012 11:25:52 -0400
Message-Id: <1351092359-25842-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351092359-25842-1-git-send-email-jlayton@redhat.com>
References: <1351092359-25842-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is holdover from an earlier version of the code and doesn't really
provide any benefit. Also, mark the topdir and dirname arguments const
since they should never be changed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcltrack/sqlite.c | 13 ++++---------
 utils/nfsdcltrack/sqlite.h |  2 +-
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index fc882c6..c19af7e 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -61,9 +61,6 @@
 
 /* global variables */
 
-/* top level DB directory */
-static char *sqlite_topdir;
-
 /* reusable pathname and sql command buffer */
 static char buf[PATH_MAX];
 
@@ -74,7 +71,7 @@ static sqlite3 *dbh;
 
 /* make a directory, ignoring EEXIST errors unless it's not a directory */
 static int
-mkdir_if_not_exist(char *dirname)
+mkdir_if_not_exist(const char *dirname)
 {
 	int ret;
 	struct stat statbuf;
@@ -102,19 +99,17 @@ mkdir_if_not_exist(char *dirname)
  * the "clients" table.
  */
 int
-sqlite_maindb_init(char *topdir)
+sqlite_maindb_init(const char *topdir)
 {
 	int ret;
 	char *err = NULL;
 	sqlite3_stmt *stmt = NULL;
 
-	sqlite_topdir = topdir;
-
-	ret = mkdir_if_not_exist(sqlite_topdir);
+	ret = mkdir_if_not_exist(topdir);
 	if (ret)
 		return ret;
 
-	ret = snprintf(buf, PATH_MAX - 1, "%s/main.sqlite", sqlite_topdir);
+	ret = snprintf(buf, PATH_MAX - 1, "%s/main.sqlite", topdir);
 	if (ret < 0)
 		return ret;
 
diff --git a/utils/nfsdcltrack/sqlite.h b/utils/nfsdcltrack/sqlite.h
index c85e7d6..8748948 100644
--- a/utils/nfsdcltrack/sqlite.h
+++ b/utils/nfsdcltrack/sqlite.h
@@ -20,7 +20,7 @@
 #ifndef _SQLITE_H_
 #define _SQLITE_H_
 
-int sqlite_maindb_init(char *topdir);
+int sqlite_maindb_init(const char *topdir);
 int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
 int sqlite_check_client(const unsigned char *clname, const size_t namelen);
-- 
1.7.11.7

