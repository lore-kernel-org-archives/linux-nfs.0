Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12904C10F05
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:07:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CC57A2075D
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:07:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731644AbfCZWHf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 18:07:35 -0400
Received: from mx1.redhat.com ([209.132.183.28]:41704 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731859AbfCZWHc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 18:07:32 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0BC5330FE5D2;
        Tue, 26 Mar 2019 22:07:32 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-200.rdu2.redhat.com [10.10.122.200])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B8BF017DC5;
        Tue, 26 Mar 2019 22:07:31 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id E92CB2134A; Tue, 26 Mar 2019 18:07:30 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     bfields@fieldses.org, jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH RFC v3 8/8] nfsdcld: add a facility for migrating from older client tracking methods
Date:   Tue, 26 Mar 2019 18:07:30 -0400
Message-Id: <20190326220730.3763-9-smayhew@redhat.com>
In-Reply-To: <20190326220730.3763-1-smayhew@redhat.com>
References: <20190326220730.3763-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 26 Mar 2019 22:07:32 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patch adds a one-time "upgrade" when using nfsdcld for the first
time.  During initialization of the database, we try to copy records
from the old nfdscltrack database and from the legacy v4recovery
directory (although we don't expect to find records in both places).

nfsdcltrack stores the client name string so the handling of those
records is straightforward.  Legacy records are md5 hashes of the client
name string, so we prefix them with "hash:" as way to let knfsd know
that this is a legacy record.  knfsd will need a fallback check in the
event that it cannot find a reclaim record using the client name string.

Upon receipt of the first "GraceDone" upcall we clean out any records
from the old nfsdcltrack database and delete any subdirectories under
the v4recovery directory.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/nfsdcld/Makefile.am    |   4 +-
 utils/nfsdcld/cld-internal.h |   3 +
 utils/nfsdcld/legacy.c       | 180 +++++++++++++++++++++++
 utils/nfsdcld/legacy.h       |  24 ++++
 utils/nfsdcld/nfsdcld.c      |  13 ++
 utils/nfsdcld/sqlite.c       | 272 +++++++++++++++++++++++++++++++++++
 utils/nfsdcld/sqlite.h       |   2 +
 7 files changed, 496 insertions(+), 2 deletions(-)
 create mode 100644 utils/nfsdcld/legacy.c
 create mode 100644 utils/nfsdcld/legacy.h

diff --git a/utils/nfsdcld/Makefile.am b/utils/nfsdcld/Makefile.am
index d1da749..2c4e5a1 100644
--- a/utils/nfsdcld/Makefile.am
+++ b/utils/nfsdcld/Makefile.am
@@ -10,10 +10,10 @@ EXTRA_DIST	= $(man8_MANS)
 AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
 sbin_PROGRAMS	= nfsdcld
 
-nfsdcld_SOURCES = nfsdcld.c sqlite.c
+nfsdcld_SOURCES = nfsdcld.c sqlite.c legacy.c
 nfsdcld_LDADD = ../../support/nfs/libnfs.la $(LIBEVENT) $(LIBSQLITE) $(LIBCAP)
 
-noinst_HEADERS	= sqlite.h cld-internal.h
+noinst_HEADERS	= sqlite.h cld-internal.h legacy.h
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/nfsdcld/cld-internal.h b/utils/nfsdcld/cld-internal.h
index a90cced..76e97db 100644
--- a/utils/nfsdcld/cld-internal.h
+++ b/utils/nfsdcld/cld-internal.h
@@ -26,5 +26,8 @@ struct cld_client {
 
 uint64_t current_epoch;
 uint64_t recovery_epoch;
+int first_time;
+int num_cltrack_records;
+int num_legacy_records;
 
 #endif /* _CLD_INTERNAL_H_ */
diff --git a/utils/nfsdcld/legacy.c b/utils/nfsdcld/legacy.c
new file mode 100644
index 0000000..f0ca316
--- /dev/null
+++ b/utils/nfsdcld/legacy.c
@@ -0,0 +1,180 @@
+/*
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
+#include <stdio.h>
+#include <dirent.h>
+#include <string.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include "cld.h"
+#include "sqlite.h"
+#include "xlog.h"
+#include "legacy.h"
+
+#define NFSD_RECDIR_FILE "/proc/fs/nfsd/nfsv4recoverydir"
+
+/*
+ * Loads client records from the v4recovery directory into the database.
+ * Records are prefixed with the string "hash:" and include the '\0' byte.
+ *
+ * Called during database initialization as part of a one-time "upgrade".
+ */
+void
+legacy_load_clients_from_recdir(int *num_records)
+{
+	int fd;
+	DIR *v4recovery;
+	struct dirent *entry;
+	char recdirname[PATH_MAX];
+	char buf[NFS4_OPAQUE_LIMIT];
+	struct stat st;
+	char *nl;
+
+	fd = open(NFSD_RECDIR_FILE, O_RDONLY);
+	if (fd < 0) {
+		xlog(D_GENERAL, "Unable to open %s: %m", NFSD_RECDIR_FILE);
+		return;
+	}
+	if (read(fd, recdirname, PATH_MAX) < 0) {
+		xlog(D_GENERAL, "Unable to read from %s: %m", NFSD_RECDIR_FILE);
+		return;
+	}
+	close(fd);
+	/* the output from the proc file isn't null-terminated */
+	nl = strchr(recdirname, '\n');
+	if (!nl)
+		return;
+	*nl = '\0';
+	if (stat(recdirname, &st) < 0) {
+		xlog(D_GENERAL, "Unable to stat %s: %d", recdirname, errno);
+		return;
+	}
+	if (!S_ISDIR(st.st_mode)) {
+		xlog(D_GENERAL, "%s is not a directory: mode=0%o", recdirname
+				, st.st_mode);
+		return;
+	}
+	v4recovery = opendir(recdirname);
+	if (!v4recovery)
+		return;
+	while ((entry = readdir(v4recovery))) {
+		int ret;
+
+		/* skip "." and ".." */
+		if (entry->d_name[0] == '.') {
+			switch (entry->d_name[1]) {
+			case '\0':
+				continue;
+			case '.':
+				if (entry->d_name[2] == '\0')
+					continue;
+			}
+		}
+		/* prefix legacy records with the string "hash:" */
+		ret = snprintf(buf, sizeof(buf), "hash:%s", entry->d_name);
+		/* if there's a problem, then skip this entry */
+		if (ret < 0 || (size_t)ret >= sizeof(buf)) {
+			xlog(L_WARNING, "%s: unable to build client string for %s!",
+				__func__, entry->d_name);
+			continue;
+		}
+		/* legacy client records need to include the null terminator */
+		ret = sqlite_insert_client((unsigned char *)buf, strlen(buf) + 1);
+		if (ret)
+			xlog(L_WARNING, "%s: unable to insert %s: %d", __func__,
+				entry->d_name, ret);
+		else
+			(*num_records)++;
+	}
+	closedir(v4recovery);
+}
+
+/*
+ * Cleans out the v4recovery directory.
+ *
+ * Called upon receipt of the first "GraceDone" upcall only.
+ */
+void
+legacy_clear_recdir(void)
+{
+	int fd;
+	DIR *v4recovery;
+	struct dirent *entry;
+	char recdirname[PATH_MAX];
+	char dirname[PATH_MAX];
+	struct stat st;
+	char *nl;
+
+	fd = open(NFSD_RECDIR_FILE, O_RDONLY);
+	if (fd < 0) {
+		xlog(D_GENERAL, "Unable to open %s: %m", NFSD_RECDIR_FILE);
+		return;
+	}
+	if (read(fd, recdirname, PATH_MAX) < 0) {
+		xlog(D_GENERAL, "Unable to read from %s: %m", NFSD_RECDIR_FILE);
+		return;
+	}
+	close(fd);
+	/* the output from the proc file isn't null-terminated */
+	nl = strchr(recdirname, '\n');
+	if (!nl)
+		return;
+	*nl = '\0';
+	if (stat(recdirname, &st) < 0) {
+		xlog(D_GENERAL, "Unable to stat %s: %d", recdirname, errno);
+		return;
+	}
+	if (!S_ISDIR(st.st_mode)) {
+		xlog(D_GENERAL, "%s is not a directory: mode=0%o", recdirname
+				, st.st_mode);
+		return;
+	}
+	v4recovery = opendir(recdirname);
+	if (!v4recovery)
+		return;
+	while ((entry = readdir(v4recovery))) {
+		int len;
+
+		/* skip "." and ".." */
+		if (entry->d_name[0] == '.') {
+			switch (entry->d_name[1]) {
+			case '\0':
+				continue;
+			case '.':
+				if (entry->d_name[2] == '\0')
+					continue;
+			}
+		}
+		len = snprintf(dirname, sizeof(dirname), "%s/%s", recdirname,
+				entry->d_name);
+		/* if there's a problem, then skip this entry */
+		if (len < 0 || (size_t)len >= sizeof(dirname)) {
+			xlog(L_WARNING, "%s: unable to build filename for %s!",
+				__func__, entry->d_name);
+			continue;
+		}
+		len = rmdir(dirname);
+		if (len)
+			xlog(L_WARNING, "%s: unable to rmdir %s: %d", __func__,
+				dirname, len);
+	}
+	closedir(v4recovery);
+}
diff --git a/utils/nfsdcld/legacy.h b/utils/nfsdcld/legacy.h
new file mode 100644
index 0000000..8988f6e
--- /dev/null
+++ b/utils/nfsdcld/legacy.h
@@ -0,0 +1,24 @@
+/*
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
+#ifndef _LEGACY_H_
+#define _LEGACY_H_
+
+void legacy_load_clients_from_recdir(int *);
+void legacy_clear_recdir(void);
+
+#endif /* _LEGACY_H_ */
diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 313c68f..cbf71fc 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -46,6 +46,7 @@
 #include "sqlite.h"
 #include "../mount/version.h"
 #include "conffile.h"
+#include "legacy.h"
 
 #ifndef DEFAULT_PIPEFS_DIR
 #define DEFAULT_PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
@@ -510,6 +511,15 @@ cld_gracedone(struct cld_client *clnt)
 
 	ret = sqlite_grace_done();
 
+	if (first_time) {
+		if (num_cltrack_records > 0)
+			sqlite_delete_cltrack_records();
+		if (num_legacy_records > 0)
+			legacy_clear_recdir();
+		sqlite_first_time_done();
+		first_time = 0;
+	}
+
 reply:
 	/* set up reply: downcall with 0 status */
 	cmsg->cm_status = ret ? -EREMOTEIO : ret;
@@ -642,6 +652,9 @@ main(int argc, char **argv)
 	char *storagedir = CLD_DEFAULT_STORAGEDIR;
 	struct cld_client clnt;
 	char *s;
+	first_time = 0;
+	num_cltrack_records = 0;
+	num_legacy_records = 0;
 
 	memset(&clnt, 0, sizeof(clnt));
 
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index 6e4eb66..faa62f9 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -64,8 +64,11 @@
 #include "sqlite.h"
 #include "cld.h"
 #include "cld-internal.h"
+#include "conffile.h"
+#include "legacy.h"
 
 #define CLD_SQLITE_LATEST_SCHEMA_VERSION 3
+#define CLTRACK_DEFAULT_STORAGEDIR NFS_STATEDIR "/nfsdcltrack"
 
 /* in milliseconds */
 #define CLD_SQLITE_BUSY_TIMEOUT 10000
@@ -73,6 +76,7 @@
 /* private data structures */
 
 /* global variables */
+static char *cltrack_storagedir = CLTRACK_DEFAULT_STORAGEDIR;
 
 /* reusable pathname and sql command buffer */
 static char buf[PATH_MAX];
@@ -135,6 +139,37 @@ out:
 	return ret;
 }
 
+static int
+sqlite_query_first_time(int *first_time)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	/* prepare select query */
+	ret = sqlite3_prepare_v2(dbh,
+		"SELECT value FROM parameters WHERE key == \"first_time\";",
+		 -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to prepare select statement: %s",
+			sqlite3_errmsg(dbh));
+		goto out;
+	}
+
+	/* query first_time */
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(D_GENERAL, "Select statement execution failed: %s",
+				sqlite3_errmsg(dbh));
+		goto out;
+	}
+
+	*first_time = sqlite3_column_int(stmt, 0);
+	ret = 0;
+out:
+	sqlite3_finalize(stmt);
+	return ret;
+}
+
 static int
 sqlite_maindb_update_schema(int oldversion)
 {
@@ -229,6 +264,18 @@ sqlite_maindb_update_schema(int oldversion)
 		goto rollback;
 	}
 
+	ret = sqlite_query_first_time(&first_time);
+	if (ret != SQLITE_OK) {
+		/* insert first_time into parameters table */
+		ret = sqlite3_exec(dbh, "INSERT OR FAIL INTO parameters "
+					"values (\"first_time\", \"1\");",
+					NULL, NULL, &err);
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "Unable to insert into parameter table: %s", err);
+			goto rollback;
+		}
+	}
+
 	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to commit transaction: %s", err);
@@ -338,6 +385,15 @@ sqlite_maindb_init_v3(void)
 		goto rollback;
 	}
 
+	/* insert first_time into parameters table */
+	ret = sqlite3_exec(dbh, "INSERT OR FAIL INTO parameters "
+				"values (\"first_time\", \"1\");",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to insert into parameter table: %s", err);
+		goto rollback;
+	}
+
 	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to commit transaction: %s", err);
@@ -391,6 +447,153 @@ out:
 	return ret;
 }
 
+static int
+sqlite_attach_db(const char *path)
+{
+	int ret;
+	char dbpath[PATH_MAX];
+	struct stat stb;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = snprintf(dbpath, PATH_MAX - 1, "%s/main.sqlite", path);
+	if (ret < 0)
+		return ret;
+
+	dbpath[PATH_MAX - 1] = '\0';
+	ret = stat(dbpath, &stb);
+	if (ret < 0)
+		return ret;
+
+	xlog(D_GENERAL, "attaching %s", dbpath);
+	ret = sqlite3_prepare_v2(dbh, "ATTACH DATABASE ? AS attached;",
+			-1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: unable to prepare attach statement: %s",
+				__func__, sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	ret = sqlite3_bind_text(stmt, 1, dbpath, strlen(dbpath), SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind text failed: %s",
+				__func__, sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret == SQLITE_DONE)
+		ret = SQLITE_OK;
+	else
+		xlog(L_ERROR, "%s: unexpected return code from attach: %s",
+				__func__, sqlite3_errmsg(dbh));
+
+	sqlite3_finalize(stmt);
+	stmt = NULL;
+	return ret;
+}
+
+static int
+sqlite_detach_db(void)
+{
+	int ret;
+	char *err = NULL;
+
+	xlog(D_GENERAL, "detaching database");
+	ret = sqlite3_exec(dbh, "DETACH DATABASE attached;", NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to detach attached db: %s", err);
+	}
+
+	sqlite3_free(err);
+	return ret;
+}
+
+/*
+ * Copies client records from the nfsdcltrack database as part of a one-time
+ * "upgrade".
+ *
+ * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0).
+ * Returns the number of records copied via "num_rec".
+ */
+static int
+sqlite_copy_cltrack_records(int *num_rec)
+{
+	int ret, ret2;
+	char *s;
+	char *err = NULL;
+	sqlite3_stmt *stmt = NULL;
+
+	s = conf_get_str("nfsdcltrack", "storagedir");
+	if (s)
+		cltrack_storagedir = s;
+	ret = sqlite_attach_db(cltrack_storagedir);
+	if (ret)
+		goto out;
+	ret = sqlite3_exec(dbh, "BEGIN EXCLUSIVE TRANSACTION;", NULL, NULL,
+				&err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to begin transaction: %s", err);
+		goto rollback;
+	}
+	ret = snprintf(buf, sizeof(buf), "DELETE FROM \"rec-%016lx\";",
+			current_epoch);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		goto rollback;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+		ret = -EINVAL;
+		goto rollback;
+	}
+	ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to clear records from current epoch: %s", err);
+		goto rollback;
+	}
+	ret = snprintf(buf, sizeof(buf), "INSERT INTO \"rec-%016lx\" "
+				"SELECT id FROM attached.clients;",
+				current_epoch);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		goto rollback;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+		ret = -EINVAL;
+		goto rollback;
+	}
+	ret = sqlite3_prepare_v2(dbh, buf, -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
+			__func__, sqlite3_errmsg(dbh));
+		goto rollback;
+	}
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_DONE) {
+		xlog(L_ERROR, "%s: unexpected return code from insert: %s",
+				__func__, sqlite3_errmsg(dbh));
+		goto rollback;
+	}
+	*num_rec = sqlite3_changes(dbh);
+	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to commit transaction: %s", err);
+		goto rollback;
+	}
+cleanup:
+	sqlite3_finalize(stmt);
+	sqlite3_free(err);
+	sqlite_detach_db();
+out:
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	return ret;
+rollback:
+	*num_rec = 0;
+	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	if (ret2 != SQLITE_OK)
+		xlog(L_ERROR, "Unable to rollback transaction: %s", err);
+	goto cleanup;
+}
+
 /* Open the database and set up the database handle for it */
 int
 sqlite_prepare_dbh(const char *topdir)
@@ -465,6 +668,23 @@ sqlite_prepare_dbh(const char *topdir)
 
 	ret = sqlite_startup_query_grace();
 
+	ret = sqlite_query_first_time(&first_time);
+	if (ret)
+		goto out_close;
+
+	/* one-time "upgrade" from older client tracking methods */
+	if (first_time) {
+		sqlite_copy_cltrack_records(&num_cltrack_records);
+		xlog(D_GENERAL, "%s: num_cltrack_records = %d\n",
+			__func__, num_cltrack_records);
+		legacy_load_clients_from_recdir(&num_legacy_records);
+		xlog(D_GENERAL, "%s: num_legacy_records = %d\n",
+			__func__, num_legacy_records);
+		if (num_cltrack_records > 0 && num_legacy_records > 0)
+			xlog(L_WARNING, "%s: first-time upgrade detected "
+				"both cltrack and legacy records!\n", __func__);
+	}
+
 	return ret;
 out_close:
 	sqlite3_close(dbh);
@@ -835,3 +1055,55 @@ sqlite_iterate_recovery(int (*cb)(struct cld_client *clnt), struct cld_client *c
 	sqlite3_finalize(stmt);
 	return ret;
 }
+
+/*
+ * Cleans out the old nfsdcltrack database.
+ *
+ * Called upon receipt of the first "GraceDone" upcall only.
+ */
+int
+sqlite_delete_cltrack_records(void)
+{
+	int ret;
+	char *s;
+	char *err = NULL;
+
+	s = conf_get_str("nfsdcltrack", "storagedir");
+	if (s)
+		cltrack_storagedir = s;
+	ret = sqlite_attach_db(cltrack_storagedir);
+	if (ret)
+		goto out;
+	ret = sqlite3_exec(dbh, "DELETE FROM attached.clients;",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to clear records from cltrack db: %s",
+				err);
+	}
+	sqlite_detach_db();
+out:
+	sqlite3_free(err);
+	return ret;
+}
+
+/*
+ * Sets first_time to 0 in the parameters table to ensure we only
+ * copy old client tracking records into the database one time.
+ *
+ * Called upon receipt of the first "GraceDone" upcall only.
+ */
+int
+sqlite_first_time_done(void)
+{
+	int ret;
+	char *err = NULL;
+
+	ret = sqlite3_exec(dbh, "UPDATE parameters SET value = \"0\" "
+				"WHERE key = \"first_time\";",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK)
+		xlog(L_ERROR, "Unable to clear first_time: %s", err);
+
+	sqlite3_free(err);
+	return ret;
+}
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
index 757e5cc..7741382 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -29,5 +29,7 @@ int sqlite_check_client(const unsigned char *clname, const size_t namelen);
 int sqlite_grace_start(void);
 int sqlite_grace_done(void);
 int sqlite_iterate_recovery(int (*cb)(struct cld_client *clnt), struct cld_client *clnt);
+int sqlite_delete_cltrack_records(void);
+int sqlite_first_time_done(void);
 
 #endif /* _SQLITE_H */
-- 
2.17.2

