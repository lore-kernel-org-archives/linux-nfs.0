Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01D24C43612
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B685121871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727077AbeLROaU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:30:20 -0500
Received: from mx1.redhat.com ([209.132.183.28]:33418 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726751AbeLROaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:30:19 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3E0DEC0524E1;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E6E0317B57;
        Tue, 18 Dec 2018 14:30:18 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 899AD20D39; Tue, 18 Dec 2018 09:30:18 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 2/7] nfsdcld: move nfsdcld to its own directory
Date:   Tue, 18 Dec 2018 09:30:13 -0500
Message-Id: <20181218143018.28575-3-smayhew@redhat.com>
In-Reply-To: <20181218143018.28575-1-smayhew@redhat.com>
References: <20181218143018.28575-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The schema for the db used by nfsdcld is going to diverge quite a bit
from that used by nfsdcltrack.  It will be easier if the programs are
kept in separate directories.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 .gitignore                                 |   2 +-
 configure.ac                               |  23 +
 utils/Makefile.am                          |   4 +
 utils/nfsdcld/Makefile.am                  |  19 +
 utils/{nfsdcltrack => nfsdcld}/nfsdcld.c   |   0
 utils/{nfsdcltrack => nfsdcld}/nfsdcld.man |   0
 utils/nfsdcld/sqlite.c                     | 601 +++++++++++++++++++++
 utils/nfsdcld/sqlite.h                     |  32 ++
 utils/nfsdcltrack/Makefile.am              |   7 +-
 9 files changed, 682 insertions(+), 6 deletions(-)
 create mode 100644 utils/nfsdcld/Makefile.am
 rename utils/{nfsdcltrack => nfsdcld}/nfsdcld.c (100%)
 rename utils/{nfsdcltrack => nfsdcld}/nfsdcld.man (100%)
 create mode 100644 utils/nfsdcld/sqlite.c
 create mode 100644 utils/nfsdcld/sqlite.h

diff --git a/.gitignore b/.gitignore
index d4f4f34..e97b31f 100644
--- a/.gitignore
+++ b/.gitignore
@@ -54,7 +54,7 @@ utils/rquotad/rquotad
 utils/rquotad/rquota.h
 utils/rquotad/rquota_xdr.c
 utils/showmount/showmount
-utils/nfsdcltrack/nfsdcld
+utils/nfsdcld/nfsdcld
 utils/nfsdcltrack/nfsdcltrack
 utils/statd/statd
 tools/locktest/testlk
diff --git a/configure.ac b/configure.ac
index 4bf5aea..8598d50 100644
--- a/configure.ac
+++ b/configure.ac
@@ -242,6 +242,12 @@ else
 	AM_CONDITIONAL(MOUNT_CONFIG, [test "$enable_mount" = "yes"])
 fi
 
+AC_ARG_ENABLE(nfsdcld,
+	[AC_HELP_STRING([--disable-nfsdcld],
+			[disable NFSv4 clientid tracking daemon @<:@default=no@:>@])],
+	enable_nfsdcld=$enableval,
+	enable_nfsdcld="yes")
+
 AC_ARG_ENABLE(nfsdcltrack,
 	[AC_HELP_STRING([--disable-nfsdcltrack],
 			[disable NFSv4 clientid tracking programs @<:@default=no@:>@])],
@@ -321,6 +327,20 @@ if test "$enable_nfsv4" = yes; then
   dnl Check for sqlite3
   AC_SQLITE3_VERS
 
+  if test "$enable_nfsdcld" = "yes"; then
+	AC_CHECK_HEADERS([libgen.h sys/inotify.h], ,
+		AC_MSG_ERROR([Cannot find header needed for nfsdcld]))
+
+    case $libsqlite3_cv_is_recent in
+    yes) ;;
+    unknown)
+      dnl do not fail when cross-compiling
+      AC_MSG_WARN([assuming sqlite is at least v3.3]) ;;
+    *)
+      AC_MSG_ERROR([nfsdcld requires sqlite-devel]) ;;
+    esac
+  fi
+
   if test "$enable_nfsdcltrack" = "yes"; then
 	AC_CHECK_HEADERS([libgen.h sys/inotify.h], ,
 		AC_MSG_ERROR([Cannot find header needed for nfsdcltrack]))
@@ -336,6 +356,7 @@ if test "$enable_nfsv4" = yes; then
   fi
 
 else
+  enable_nfsdcld="no"
   enable_nfsdcltrack="no"
 fi
 
@@ -346,6 +367,7 @@ if test "$enable_nfsv41" = yes; then
 fi
 
 dnl enable nfsidmap when its support by libnfsidmap
+AM_CONDITIONAL(CONFIG_NFSDCLD, [test "$enable_nfsdcld" = "yes" ])
 AM_CONDITIONAL(CONFIG_NFSDCLTRACK, [test "$enable_nfsdcltrack" = "yes" ])
 
 
@@ -623,6 +645,7 @@ AC_CONFIG_FILES([
 	tools/nfsconf/Makefile
 	utils/Makefile
 	utils/blkmapd/Makefile
+	utils/nfsdcld/Makefile
 	utils/nfsdcltrack/Makefile
 	utils/exportfs/Makefile
 	utils/gssd/Makefile
diff --git a/utils/Makefile.am b/utils/Makefile.am
index 0a5b062..4c930a4 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -19,6 +19,10 @@ if CONFIG_MOUNT
 OPTDIRS += mount
 endif
 
+if CONFIG_NFSDCLD
+OPTDIRS += nfsdcld
+endif
+
 if CONFIG_NFSDCLTRACK
 OPTDIRS += nfsdcltrack
 endif
diff --git a/utils/nfsdcld/Makefile.am b/utils/nfsdcld/Makefile.am
new file mode 100644
index 0000000..8239be8
--- /dev/null
+++ b/utils/nfsdcld/Makefile.am
@@ -0,0 +1,19 @@
+## Process this file with automake to produce Makefile.in
+
+# These binaries go in /sbin (not /usr/sbin), and that cannot be
+# overridden at config time. The kernel "knows" the /sbin name.
+sbindir = /sbin
+
+man8_MANS	= nfsdcld.man
+EXTRA_DIST	= $(man8_MANS)
+
+AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
+sbin_PROGRAMS	= nfsdcld
+
+nfsdcld_SOURCES = nfsdcld.c sqlite.c
+nfsdcld_LDADD = ../../support/nfs/libnfs.la $(LIBEVENT) $(LIBSQLITE) $(LIBCAP)
+
+noinst_HEADERS	= sqlite.h
+
+MAINTAINERCLEANFILES = Makefile.in
+
diff --git a/utils/nfsdcltrack/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
similarity index 100%
rename from utils/nfsdcltrack/nfsdcld.c
rename to utils/nfsdcld/nfsdcld.c
diff --git a/utils/nfsdcltrack/nfsdcld.man b/utils/nfsdcld/nfsdcld.man
similarity index 100%
rename from utils/nfsdcltrack/nfsdcld.man
rename to utils/nfsdcld/nfsdcld.man
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
new file mode 100644
index 0000000..c59f777
--- /dev/null
+++ b/utils/nfsdcld/sqlite.c
@@ -0,0 +1,601 @@
+/*
+ * Copyright (C) 2011  Red Hat, Jeff Layton <jlayton@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor,
+ * Boston, MA 02110-1301, USA.
+ */
+
+/*
+ * Explanation:
+ *
+ * This file contains the code to manage the sqlite backend database for the
+ * nfsdcltrack usermodehelper upcall program.
+ *
+ * The main database is called main.sqlite and contains the following tables:
+ *
+ * parameters: simple key/value pairs for storing database info
+ *
+ * clients: an "id" column containing a BLOB with the long-form clientid as
+ * 	    sent by the client, a "time" column containing a timestamp (in
+ * 	    epoch seconds) of when the record was last updated, and a
+ * 	    "has_session" column containing a boolean value indicating
+ * 	    whether the client has sessions (v4.1+) or not (v4.0).
+ */
+
+#ifdef HAVE_CONFIG_H
+#include "config.h"
+#endif /* HAVE_CONFIG_H */
+
+#include <dirent.h>
+#include <errno.h>
+#include <event.h>
+#include <stdbool.h>
+#include <string.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <sqlite3.h>
+#include <linux/limits.h>
+
+#include "xlog.h"
+#include "sqlite.h"
+
+#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 2
+
+/* in milliseconds */
+#define CLTRACK_SQLITE_BUSY_TIMEOUT 10000
+
+/* private data structures */
+
+/* global variables */
+
+/* reusable pathname and sql command buffer */
+static char buf[PATH_MAX];
+
+/* global database handle */
+static sqlite3 *dbh;
+
+/* forward declarations */
+
+/* make a directory, ignoring EEXIST errors unless it's not a directory */
+static int
+mkdir_if_not_exist(const char *dirname)
+{
+	int ret;
+	struct stat statbuf;
+
+	ret = mkdir(dirname, S_IRWXU);
+	if (ret && errno != EEXIST)
+		return -errno;
+
+	ret = stat(dirname, &statbuf);
+	if (ret)
+		return -errno;
+
+	if (!S_ISDIR(statbuf.st_mode))
+		ret = -ENOTDIR;
+
+	return ret;
+}
+
+static int
+sqlite_query_schema_version(void)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	/* prepare select query */
+	ret = sqlite3_prepare_v2(dbh,
+		"SELECT value FROM parameters WHERE key == \"version\";",
+		 -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to prepare select statement: %s",
+			sqlite3_errmsg(dbh));
+		ret = 0;
+		goto out;
+	}
+
+	/* query schema version */
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(D_GENERAL, "Select statement execution failed: %s",
+				sqlite3_errmsg(dbh));
+		ret = 0;
+		goto out;
+	}
+
+	ret = sqlite3_column_int(stmt, 0);
+out:
+	sqlite3_finalize(stmt);
+	return ret;
+}
+
+static int
+sqlite_maindb_update_v1_to_v2(void)
+{
+	int ret, ret2;
+	char *err;
+
+	/* begin transaction */
+	ret = sqlite3_exec(dbh, "BEGIN EXCLUSIVE TRANSACTION;", NULL, NULL,
+				&err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to begin transaction: %s", err);
+		goto rollback;
+	}
+
+	/*
+	 * Check schema version again. This time, under an exclusive
+	 * transaction to guard against racing DB setup attempts
+	 */
+	ret = sqlite_query_schema_version();
+	switch (ret) {
+	case 1:
+		/* Still at v1 -- do conversion */
+		break;
+	case CLTRACK_SQLITE_LATEST_SCHEMA_VERSION:
+		/* Someone else raced in and set it up */
+		ret = 0;
+		goto rollback;
+	default:
+		/* Something went wrong -- fail! */
+		ret = -EINVAL;
+		goto rollback;
+	}
+
+	/* create v2 clients table */
+	ret = sqlite3_exec(dbh, "ALTER TABLE clients ADD COLUMN "
+				"has_session INTEGER;",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to update clients table: %s", err);
+		goto rollback;
+	}
+
+	ret = snprintf(buf, sizeof(buf), "UPDATE parameters SET value = %d "
+			"WHERE key = \"version\";",
+			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		goto rollback;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+		ret = -EINVAL;
+		goto rollback;
+	}
+
+	ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to update schema version: %s", err);
+		goto rollback;
+	}
+
+	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to commit transaction: %s", err);
+		goto rollback;
+	}
+out:
+	sqlite3_free(err);
+	return ret;
+rollback:
+	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	if (ret2 != SQLITE_OK)
+		xlog(L_ERROR, "Unable to rollback transaction: %s", err);
+	goto out;
+}
+
+/*
+ * Start an exclusive transaction and recheck the DB schema version. If it's
+ * still zero (indicating a new database) then set it up. If that all works,
+ * then insert schema version into the parameters table and commit the
+ * transaction. On any error, rollback the transaction.
+ */
+static int
+sqlite_maindb_init_v2(void)
+{
+	int ret, ret2;
+	char *err = NULL;
+
+	/* Start a transaction */
+	ret = sqlite3_exec(dbh, "BEGIN EXCLUSIVE TRANSACTION;", NULL, NULL,
+				&err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to begin transaction: %s", err);
+		return ret;
+	}
+
+	/*
+	 * Check schema version again. This time, under an exclusive
+	 * transaction to guard against racing DB setup attempts
+	 */
+	ret = sqlite_query_schema_version();
+	switch (ret) {
+	case 0:
+		/* Query failed again -- set up DB */
+		break;
+	case CLTRACK_SQLITE_LATEST_SCHEMA_VERSION:
+		/* Someone else raced in and set it up */
+		ret = 0;
+		goto rollback;
+	default:
+		/* Something went wrong -- fail! */
+		ret = -EINVAL;
+		goto rollback;
+	}
+
+	ret = sqlite3_exec(dbh, "CREATE TABLE parameters "
+				"(key TEXT PRIMARY KEY, value TEXT);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create parameter table: %s", err);
+		goto rollback;
+	}
+
+	/* create the "clients" table */
+	ret = sqlite3_exec(dbh, "CREATE TABLE clients (id BLOB PRIMARY KEY, "
+				"time INTEGER, has_session INTEGER);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create clients table: %s", err);
+		goto rollback;
+	}
+
+
+	/* insert version into parameters table */
+	ret = snprintf(buf, sizeof(buf), "INSERT OR FAIL INTO parameters "
+			"values (\"version\", \"%d\");",
+			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		goto rollback;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+		ret = -EINVAL;
+		goto rollback;
+	}
+
+	ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to insert into parameter table: %s", err);
+		goto rollback;
+	}
+
+	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to commit transaction: %s", err);
+		goto rollback;
+	}
+out:
+	sqlite3_free(err);
+	return ret;
+
+rollback:
+	/* Attempt to rollback the transaction */
+	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	if (ret2 != SQLITE_OK)
+		xlog(L_ERROR, "Unable to rollback transaction: %s", err);
+	goto out;
+}
+
+/* Open the database and set up the database handle for it */
+int
+sqlite_prepare_dbh(const char *topdir)
+{
+	int ret;
+
+	/* Do nothing if the database handle is already set up */
+	if (dbh)
+		return 0;
+
+	ret = snprintf(buf, PATH_MAX - 1, "%s/main.sqlite", topdir);
+	if (ret < 0)
+		return ret;
+
+	buf[PATH_MAX - 1] = '\0';
+
+	/* open a new DB handle */
+	ret = sqlite3_open(buf, &dbh);
+	if (ret != SQLITE_OK) {
+		/* try to create the dir */
+		ret = mkdir_if_not_exist(topdir);
+		if (ret)
+			goto out_close;
+
+		/* retry open */
+		ret = sqlite3_open(buf, &dbh);
+		if (ret != SQLITE_OK)
+			goto out_close;
+	}
+
+	/* set busy timeout */
+	ret = sqlite3_busy_timeout(dbh, CLTRACK_SQLITE_BUSY_TIMEOUT);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to set sqlite busy timeout: %s",
+				sqlite3_errmsg(dbh));
+		goto out_close;
+	}
+
+	ret = sqlite_query_schema_version();
+	switch (ret) {
+	case CLTRACK_SQLITE_LATEST_SCHEMA_VERSION:
+		/* DB is already set up. Do nothing */
+		ret = 0;
+		break;
+	case 1:
+		/* Old DB -- update to new schema */
+		ret = sqlite_maindb_update_v1_to_v2();
+		if (ret)
+			goto out_close;
+		break;
+	case 0:
+		/* Query failed -- try to set up new DB */
+		ret = sqlite_maindb_init_v2();
+		if (ret)
+			goto out_close;
+		break;
+	default:
+		/* Unknown DB version -- downgrade? Fail */
+		xlog(L_ERROR, "Unsupported database schema version! "
+			"Expected %d, got %d.",
+			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION, ret);
+		ret = -EINVAL;
+		goto out_close;
+	}
+
+	return ret;
+out_close:
+	sqlite3_close(dbh);
+	dbh = NULL;
+	return ret;
+}
+
+/*
+ * Create a client record
+ *
+ * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0)
+ */
+int
+sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+			const bool has_session, const bool zerotime)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	if (zerotime)
+		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
+				"VALUES (?, 0, ?);", -1, &stmt, NULL);
+	else
+		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
+				"VALUES (?, strftime('%s', 'now'), ?);", -1,
+				&stmt, NULL);
+
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
+			__func__, sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
+				SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind blob failed: %s", __func__,
+				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_bind_int(stmt, 2, (int)has_session);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind int failed: %s", __func__,
+				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret == SQLITE_DONE)
+		ret = SQLITE_OK;
+	else
+		xlog(L_ERROR, "%s: unexpected return code from insert: %s",
+				__func__, sqlite3_errmsg(dbh));
+
+out_err:
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_finalize(stmt);
+	return ret;
+}
+
+/* Remove a client record */
+int
+sqlite_remove_client(const unsigned char *clname, const size_t namelen)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh, "DELETE FROM clients WHERE id==?", -1,
+				 &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: statement prepare failed: %s",
+				__func__, sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
+				SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind blob failed: %s", __func__,
+				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret == SQLITE_DONE)
+		ret = SQLITE_OK;
+	else
+		xlog(L_ERROR, "%s: unexpected return code from delete: %d",
+				__func__, ret);
+
+out_err:
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_finalize(stmt);
+	return ret;
+}
+
+/*
+ * Is the given clname in the clients table? If so, then update its timestamp
+ * and return success. If the record isn't present, or the update fails, then
+ * return an error.
+ */
+int
+sqlite_check_client(const unsigned char *clname, const size_t namelen,
+			const bool has_session)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh, "SELECT count(*) FROM clients WHERE "
+				      "id==?", -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: unable to prepare update statement: %s",
+				__func__, sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
+				SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind blob failed: %s",
+				__func__, sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(L_ERROR, "%s: unexpected return code from select: %d",
+				__func__, ret);
+		goto out_err;
+	}
+
+	ret = sqlite3_column_int(stmt, 0);
+	xlog(D_GENERAL, "%s: select returned %d rows", __func__, ret);
+	if (ret != 1) {
+		ret = -EACCES;
+		goto out_err;
+	}
+
+	/* Only update timestamp for v4.0 clients */
+	if (has_session) {
+		ret = SQLITE_OK;
+		goto out_err;
+	}
+
+	sqlite3_finalize(stmt);
+	stmt = NULL;
+	ret = sqlite3_prepare_v2(dbh, "UPDATE OR FAIL clients SET "
+				      "time=strftime('%s', 'now') WHERE id==?",
+				 -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: unable to prepare update statement: %s",
+				__func__, sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
+				SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind blob failed: %s",
+				__func__, sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret == SQLITE_DONE)
+		ret = SQLITE_OK;
+	else
+		xlog(L_ERROR, "%s: unexpected return code from update: %s",
+				__func__, sqlite3_errmsg(dbh));
+
+out_err:
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_finalize(stmt);
+	return ret;
+}
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
+		xlog(L_ERROR, "%s: delete failed: %s", __func__, err);
+
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_free(err);
+	return ret;
+}
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
+				      "time < ? OR has_session != 1", -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: unable to prepare select statement: %s",
+				__func__, sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	ret = sqlite3_bind_int64(stmt, 1, (sqlite3_int64)grace_start);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind int64 failed: %s",
+				__func__, sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(L_ERROR, "%s: unexpected return code from select: %s",
+				__func__, sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	ret = sqlite3_column_int(stmt, 0);
+	sqlite3_finalize(stmt);
+	xlog(D_GENERAL, "%s: there are %d clients that have not completed "
+			"reclaim", __func__, ret);
+	return ret;
+}
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
new file mode 100644
index 0000000..06e7c04
--- /dev/null
+++ b/utils/nfsdcld/sqlite.h
@@ -0,0 +1,32 @@
+/*
+ * Copyright (C) 2011  Red Hat, Jeff Layton <jlayton@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor,
+ * Boston, MA 02110-1301, USA.
+ */
+
+#ifndef _SQLITE_H_
+#define _SQLITE_H_
+
+int sqlite_prepare_dbh(const char *topdir);
+int sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+				const bool has_session, const bool zerotime);
+int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
+int sqlite_check_client(const unsigned char *clname, const size_t namelen,
+				const bool has_session);
+int sqlite_remove_unreclaimed(const time_t grace_start);
+int sqlite_query_reclaiming(const time_t grace_start);
+
+#endif /* _SQLITE_H */
diff --git a/utils/nfsdcltrack/Makefile.am b/utils/nfsdcltrack/Makefile.am
index 0f599c0..2f7fe3d 100644
--- a/utils/nfsdcltrack/Makefile.am
+++ b/utils/nfsdcltrack/Makefile.am
@@ -4,14 +4,11 @@
 # overridden at config time. The kernel "knows" the /sbin name.
 sbindir = /sbin
 
-man8_MANS	= nfsdcld.man nfsdcltrack.man
+man8_MANS	= nfsdcltrack.man
 EXTRA_DIST	= $(man8_MANS)
 
 AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
-sbin_PROGRAMS	= nfsdcld nfsdcltrack
-
-nfsdcld_SOURCES = nfsdcld.c sqlite.c
-nfsdcld_LDADD = ../../support/nfs/libnfs.la $(LIBEVENT) $(LIBSQLITE) $(LIBCAP)
+sbin_PROGRAMS	= nfsdcltrack
 
 noinst_HEADERS	= sqlite.h
 
-- 
2.17.1

