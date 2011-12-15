Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759312Ab1LOSoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 13:44:03 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi3fn010883
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:03 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi17g010403
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:02 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/7] nfsdcld: add routines for a sqlite backend database
Date: Thu, 15 Dec 2011 13:43:58 -0500
Message-Id: <1323974641-16515-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
References: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than roll our own "storage engine", use sqlite instead. It fits
the bill nicely as it does:

- durable on-disk storage
- the ability to constrain record uniqueness
- a facility for collating and searching the host records

...it does add a build dependency to nfs-utils, but almost all modern
distros provide those packages.

The current incarnation of this code dynamically links against a
provided sqlite library, but we could also consider including their
single-file "amalgamation" to reduce dependencies (though with all
the caveats that that entails).

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/Makefile.am |    4 +-
 utils/nfsdcld/nfsdcld.c   |   16 ++-
 utils/nfsdcld/sqlite.c    |  256 +++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h    |   27 +++++
 4 files changed, 297 insertions(+), 6 deletions(-)
 create mode 100644 utils/nfsdcld/sqlite.c
 create mode 100644 utils/nfsdcld/sqlite.h

diff --git a/utils/nfsdcld/Makefile.am b/utils/nfsdcld/Makefile.am
index ed7ed42..8e4f2ab 100644
--- a/utils/nfsdcld/Makefile.am
+++ b/utils/nfsdcld/Makefile.am
@@ -6,9 +6,9 @@
 AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
 sbin_PROGRAMS	= nfsdcld
 
-nfsdcld_SOURCES = nfsdcld.c
+nfsdcld_SOURCES = nfsdcld.c sqlite.c
 
-nfsdcld_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT)
+nfsdcld_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT) $(LIBSQLITE)
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index d82908f..de2e932 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -36,6 +36,7 @@
 
 #include "xlog.h"
 #include "nfslib.h"
+#include "sqlite.h"
 
 #ifndef PIPEFS_DIR
 #define PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
@@ -111,18 +112,20 @@ cld_pipe_reopen(struct cld_client *clnt)
 static void
 cld_create(struct cld_client *clnt)
 {
+	int ret;
 	ssize_t bsize, wsize;
 	struct cld_msg *cmsg = &clnt->cl_msg;
 
-	xlog(D_GENERAL, "%s: create client record", __func__);
+	xlog(D_GENERAL, "%s: create client record.", __func__);
 
-	/* FIXME: create client record on storage here */
+	ret = sqlite_insert_client(cmsg->cm_u.cm_name.cn_id,
+				   cmsg->cm_u.cm_name.cn_len);
 
-	/* set up reply */
-	cmsg->cm_status = 0;
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
 
 	bsize = sizeof(*cmsg);
 
+	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
 	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
 	if (wsize != bsize) {
 		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
@@ -221,6 +224,11 @@ main(int argc, char **argv)
 	}
 
 	/* set up storage db */
+	rc = sqlite_maindb_init();
+	if (rc) {
+		xlog(L_ERROR, "Failed to open main database: %d", rc);
+		goto out;
+	}
 
 	/* set up event handler */
 	fd = cld_pipe_open(&clnt);
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
new file mode 100644
index 0000000..2534ba5
--- /dev/null
+++ b/utils/nfsdcld/sqlite.c
@@ -0,0 +1,256 @@
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
+ * clstated upcall daemon.
+ *
+ * The main database is called main.sqlite and contains the following tables:
+ *
+ * parameters: simple key/value pairs for storing database info
+ *
+ * clients: one column containing a BLOB with the as sent by the client
+ * 	    and a timestamp (in epoch seconds) of when the record was
+ * 	    established
+ *
+ * FIXME: should we also record the fsid being accessed?
+ */
+
+#ifdef HAVE_CONFIG_H
+#include "config.h"
+#endif /* HAVE_CONFIG_H */
+
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
+
+#define CLD_SQLITE_SCHEMA_VERSION 1
+
+#ifndef CLD_SQLITE_TOPDIR
+#define CLD_SQLITE_TOPDIR NFS_STATEDIR "/nfsdcld"
+#endif
+
+/* in milliseconds */
+#define CLD_SQLITE_BUSY_TIMEOUT 10000
+
+/* private data structures */
+
+/* global variables */
+
+/* top level DB directory */
+static char *sqlite_topdir = CLD_SQLITE_TOPDIR;
+
+/* reusable pathname and sql command buffer */
+static char buf[PATH_MAX];
+
+/* global database handle */
+static sqlite3 *dbh;
+
+/* forward declarations */
+
+void
+sqlite_set_topdir(char *topdir)
+{
+	sqlite_topdir = topdir;
+}
+
+/* make a directory, ignoring EEXIST errors unless it's not a directory */
+static int
+mkdir_if_not_exist(char *dirname)
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
+/*
+ * Open the "main" database, and attempt to initialize it by creating the
+ * parameters table and inserting the schema version into it. Ignore any errors
+ * from that, and then attempt to select the version out of it again. If the
+ * version appears wrong, then assume that the DB is corrupt or has been
+ * upgraded, and return an error. If all of that works, then attempt to create
+ * the "clients" table.
+ */
+int
+sqlite_maindb_init(void)
+{
+	int ret;
+	char *err = NULL;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = mkdir_if_not_exist(sqlite_topdir);
+	if (ret)
+		return ret;
+
+	ret = snprintf(buf, PATH_MAX - 1, "%s/main.sqlite", sqlite_topdir);
+	if (ret < 0)
+		return ret;
+
+	buf[PATH_MAX - 1] = '\0';
+
+	ret = sqlite3_open(buf, &dbh);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to open main database: %d", ret);
+		return ret;
+	}
+
+	ret = sqlite3_busy_timeout(dbh, CLD_SQLITE_BUSY_TIMEOUT);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to set sqlite busy timeout: %d", ret);
+		goto out_err;
+	}
+
+	/* Try to create table */
+	ret = sqlite3_exec(dbh, "CREATE TABLE IF NOT EXISTS parameters "
+				"(key TEXT PRIMARY KEY, value TEXT);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to create parameter table: %d", ret);
+		goto out_err;
+	}
+
+	/* insert version into table -- ignore error if it fails */
+	ret = snprintf(buf, sizeof(buf),
+		       "INSERT OR IGNORE INTO parameters values (\"version\", "
+		       "\"%d\");", CLD_SQLITE_SCHEMA_VERSION);
+	if (ret < 0) {
+		goto out_err;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		ret = -EINVAL;
+		goto out_err;
+	}
+
+	ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to insert into parameter table: %d",
+				ret);
+		goto out_err;
+	}
+
+	ret = sqlite3_prepare_v2(dbh,
+		"SELECT value FROM parameters WHERE key == \"version\";",
+		 -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to prepare select statement: %d", ret);
+		goto out_err;
+	}
+
+	/* check schema version */
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(D_GENERAL, "Select statement execution failed: %s",
+				sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	/* process SELECT result */
+	ret = sqlite3_column_int(stmt, 0);
+	if (ret != CLD_SQLITE_SCHEMA_VERSION) {
+		xlog(L_ERROR, "Unsupported database schema version! "
+			"Expected %d, got %d.",
+			CLD_SQLITE_SCHEMA_VERSION, ret);
+		ret = -EINVAL;
+		goto out_err;
+	}
+
+	/* now create the "clients" table */
+	ret = sqlite3_exec(dbh, "CREATE TABLE IF NOT EXISTS clients "
+				"(id BLOB PRIMARY KEY, time INTEGER);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create clients table: %s", err);
+		goto out_err;
+	}
+
+	sqlite3_free(err);
+	sqlite3_finalize(stmt);
+	return 0;
+
+out_err:
+	if (err) {
+		xlog(L_ERROR, "sqlite error: %s", err);
+		sqlite3_free(err);
+	}
+	sqlite3_finalize(stmt);
+	sqlite3_close(dbh);
+	return ret;
+}
+
+/*
+ * Create a client record
+ *
+ * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0)
+ */
+int
+sqlite_insert_client(const unsigned char *clname, const size_t namelen)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients VALUES "
+				      "(?, strftime('%s', 'now'));", -1,
+					&stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Insert statement prepare failed: %s",
+			sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
+				SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Bind blob failed: %d", sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret == SQLITE_DONE)
+		ret = SQLITE_OK;
+	else
+		xlog(D_GENERAL, "Unexpected return code from insert: %s",
+				sqlite3_errmsg(dbh));
+
+out_err:
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_finalize(stmt);
+	return ret;
+}
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
new file mode 100644
index 0000000..4b99729
--- /dev/null
+++ b/utils/nfsdcld/sqlite.h
@@ -0,0 +1,27 @@
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
+void sqlite_set_topdir(char *topdir);
+int sqlite_maindb_init(void);
+int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
+
+#endif /* _SQLITE_H */
-- 
1.7.1

