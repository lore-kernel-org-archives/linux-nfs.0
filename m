From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st part)
Date: Wed, 05 Aug 2009 10:45:40 -0400
Message-ID: <20090805144540.12866.22084.stgit@matisse.1015granger.net>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:43533 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934469AbZHEOqT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 10:46:19 -0400
In-Reply-To: <20090805143550.12866.8377.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a new implementation of statd that supports IPv6.  The new
statd implementation resides under

  utils/new-statd/

The contents of this directory are built if --enable-tirpc is set
on the ./configure command line, and sqlite3 is available on the
build system.  Otherwise, the legacy version of statd, which still
resides under utils/statd/, is built.

The goals of this re-write are:

 o Support IPv6 networking

   Support interoperation with TI-RPC-based NSM implementations.
   Transport Independent RPC, or TI-RPC, provides IPv6 network support
   for Linux's NSM implementation.

   To support TI-RPC, open code to construct RPC requests in socket
   buffers and then schedule them has been replaced with standard
   library calls.

 o Support notification via TCP

   As a secondary benefit of using TI-RPC library calls, reboot
   notifications and NLM callbacks can now be sent via connection-
   oriented transport protocols.

   Note that lockd does not (yet) tell statd what transport protocol
   to use when sending reboot notifications.  statd/sm-notify will
   continue to use UDP for the time being.

 o Use an embedded database for storing on-disk callback data

   This whole exercise is for the purpose of crash robustness.  There
   are well-known deficiencies with simple create/rename/unlink
   disk storage schemes during system crashes.  Replace the current
   flat-file monitor list mechanism which uses sync(2) with sqlite3,
   which uses fsync(3).

 o Share code between sm-notify and statd

   Statd and sm-notify access the same set of on-disk data.  These
   separate programs now share the same code and implementation, with
   access to on-disk data serialized by sqlite3.  The two remain
   separate executables to allow other system facilities to send
   reboot notifications without poking statd.

 o Reduce impact of DNS outages

   The heuristics used by SM_NOTIFY to figure out which remote peer
   has rebooted are heavily dependent on DNS.  If the DNS service is
   slow or hangs, that will make the NSM listener unresponsive.
   Incoming SM_NOTIFY requests are now handled in a sidecar process
   to reduce the impact of DNS outages on the NSM service listener.

 o Proper my_name support

   The current version of statd uses gethostname(3) to generate the
   mon_name argument of SM_NOTIFY.  This value can change across a
   reboot.  The new version of statd records lockd's my_name, passed
   by every SM_MON request, and uses that when sending SM_NOTIFY.

   This can be useful for multi-homed and DHCP configured hosts.

 o Send SM_NOTIFY more aggressively

   It has been recommended that statd/sm-notify send SM_NOTIFY
   more aggressively (for example, to the entire list returned by
   getaddrinfo(3)).  Since SM_NOTIFY's reply is NULL, there's no
   way to tell whether the remote peer recognized the mon_name we
   sent.  More study is required, but this implementation attempts
   to send an SM_NOTIFY request to each address returned by
   getaddrinfo(3).

This re-implementation paves the way for a number of future
improvements.  However, it does not immediately address:

 o lockd/statd start-up serialization issues

   Sending reboot notifications, starting statd and lockd, and opening
   the lockd grace period are still determined independently in user
   space and the kernel.

 o Binding mon_names to caller IP addresses

   By default, lockd continues to send IP addresses as the mon_name
   argument of the SM_MON procedure.  This provides a better guarantee
   of being able to contact remote peers during a reboot, but means
   statd must continue to use heuristics to match incoming SM_NOTIFY
   requests with peers on the monitor list.

 o Distinct logic for NFS client- and server-side

   Client-side and server-side monitoring requirements are different.
   Statd continues to use the same logic for both NFS client and
   server, as the NSMv1 protocol does not provide any indication
   that a mon_name is for a client or server peer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/new-statd/file.c     |  779 ++++++++++++++++++++++++++++++++++++++++++++
 utils/new-statd/hostname.c |  520 +++++++++++++++++++++++++++++
 utils/new-statd/nlmcall.c  |  525 ++++++++++++++++++++++++++++++
 3 files changed, 1824 insertions(+), 0 deletions(-)
 create mode 100644 utils/new-statd/file.c
 create mode 100644 utils/new-statd/hostname.c
 create mode 100644 utils/new-statd/nlmcall.c

diff --git a/utils/new-statd/file.c b/utils/new-statd/file.c
new file mode 100644
index 0000000..db54bf7
--- /dev/null
+++ b/utils/new-statd/file.c
@@ -0,0 +1,779 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ *
+ * Callback information is stored in an sqlite database that provides
+ * transactional semantics, to preserve state in the event of a system
+ * crash, and can easily be updated to store additional data elements
+ * without need for versioning
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/types.h>
+#include <sys/capability.h>
+#include <sys/prctl.h>
+#include <sys/stat.h>
+#include <sys/ipc.h>
+#include <sys/sem.h>
+
+#include <stdint.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <dirent.h>
+#include <grp.h>
+#include <arpa/inet.h>
+
+#include "statd.h"
+
+#ifdef NFS_STATEDIR
+#define STATD_DEFAULT_STATEDIR		NFS_STATEDIR "/statd"
+#else	/* !defined(NFS_STATEDIR) */
+#define STATD_DEFAULT_STATEDIR		"/var/lib/nfs/statd"
+#endif	/* !defined(NFS_STATEDIR) */
+
+#define STATD_DATABASE_FILE		"statdb"
+
+static char statd_db_dirname[PATH_MAX];
+static char statd_db_filename[PATH_MAX];
+
+/**
+ * statd_open_db - open a database connection to statd's sqlite3 database
+ * @flags: flags passed to sqlite3_open_v2
+ *
+ * Returns an open database connection; otherwise NULL is returned if
+ * an error occurred.
+ */
+sqlite3 *
+statd_open_db(int flags)
+{
+	sqlite3 *db;
+	int rc;
+
+	rc = sqlite3_open_v2(statd_db_filename, &db, flags, NULL);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to open database in %s: %s",
+				statd_db_filename, sqlite3_errmsg(db));
+		xlog(L_ERROR, "Check that the state directory pathname "
+				"is correct and has proper permissions");
+		(void)sqlite3_close(db);
+		return NULL;
+	}
+
+	/*
+	 * Retry SQLITE_BUSY for 100 msec before returning an error.
+	 */
+	(void)sqlite3_busy_timeout(db, 100);
+
+	return db;
+}
+
+/**
+ * statd_close_db - close an open sqlite3 database connection
+ * @db: open sqlite3 database connection descriptor
+ *
+ */
+void
+statd_close_db(sqlite3 *db)
+{
+	if (sqlite3_close(db) != SQLITE_OK)
+		xlog(L_ERROR, "Failed to close database: %s",
+				sqlite3_errmsg(db));
+}
+
+/**
+ * statd_prepare_stmt - prepare a C string SQL statement
+ * @db: open database connection
+ * @stmt: OUT: pointer to prepared SQL statement object
+ * @sql: C string containing SQL statement to prepare
+ *
+ * Returns TRUE if the statement was prepared successfully; otherwise
+ * FALSE is returned and an error is logged.
+ */
+bool_t
+statd_prepare_stmt(sqlite3 *db, sqlite3_stmt **stmt, const char *sql)
+{
+	int rc;
+
+	rc = sqlite3_prepare_v2(db, sql, -1, stmt, NULL);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to compile SQL: %s",
+				sqlite3_errmsg(db));
+		xlog(L_ERROR, "SQL: %s", sql);
+		return FALSE;
+	}
+	return TRUE;
+}
+
+/**
+ * statd_finalize_stmt - release a prepared SQL statement
+ * @stmt: sqlite3_stmt to release
+ *
+ */
+void
+statd_finalize_stmt(sqlite3_stmt *stmt)
+{
+	sqlite3 *db = sqlite3_db_handle(stmt);
+	int rc;
+
+	rc = sqlite3_finalize(stmt);
+	switch(rc) {
+	case SQLITE_OK:
+	case SQLITE_ABORT:
+	case SQLITE_CONSTRAINT:
+		break;
+	default:
+		xlog(L_ERROR, "Failed to finalize SQL statement: %s",
+				sqlite3_errmsg(db));
+	}
+}
+
+/**
+ * statd_begin_transaction - start a sqlite3 transaction
+ * @db: open database connection
+ *
+ * Returns TRUE if the transaction was started; otherwise FALSE is
+ * returned if sqlite3 reported an error.
+ */
+bool_t
+statd_begin_transaction(sqlite3 *db)
+{
+	char *err_msg;
+	int rc;
+
+	err_msg = NULL;
+	rc = sqlite3_exec(db, "BEGIN IMMEDIATE TRANSACTION;", NULL, 0, &err_msg);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to start transaction: %s", err_msg);
+		sqlite3_free(err_msg);
+		return FALSE;
+	}
+
+	xlog(D_CALL, "Transaction started");
+	return TRUE;
+}
+
+/**
+ * statd_end_transaction - commit a sqlite3 transaction
+ * @db: open database connection
+ *
+ */
+void
+statd_end_transaction(sqlite3 *db)
+{
+	char *err_msg;
+	int rc;
+
+	err_msg = NULL;
+	rc = sqlite3_exec(db, "COMMIT TRANSACTION;", NULL, 0, &err_msg);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to commit transaction: %s", err_msg);
+		sqlite3_free(err_msg);
+		return;
+	}
+
+	xlog(D_CALL, "Transaction committed");
+}
+
+/**
+ * statd_rollback_transaction - rollback an active sqlite3 transaction
+ * @db: open database connection
+ *
+ */
+void
+statd_rollback_transaction(sqlite3 *db)
+{
+	char *err_msg;
+	int rc;
+
+	err_msg = NULL;
+	rc = sqlite3_exec(db, "ROLLBACK TRANSACTION;", NULL, 0, &err_msg);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to roll back transaction: %s", err_msg);
+		sqlite3_free(err_msg);
+		return;
+	}
+
+	xlog(D_CALL, "Transaction rolled back");
+}
+
+/**
+ * statd_check_pathname - set up pathname
+ * @parentdir: C string containing pathname to on-disk state
+ *
+ * Returns TRUE if pathname was valid; otherwise FALSE is returned.
+ */
+bool_t
+statd_check_pathname(const char *parentdir)
+{
+	struct stat st;
+	int len;
+
+	if (parentdir != NULL) {
+		if (strlen(parentdir) >= PATH_MAX) {
+			xlog(L_ERROR, "Invalid directory name");
+			return FALSE;
+		}
+	} else
+		parentdir = STATD_DEFAULT_STATEDIR;
+
+	if (lstat(parentdir, &st) == -1) {
+		xlog(L_ERROR, "Failed to stat %s: %m", parentdir);
+		return FALSE;
+	}
+
+	if (chdir(parentdir) == -1) {
+		xlog(L_ERROR, "Failed to change working directory to %s: %m",
+				parentdir);
+		return FALSE;
+	}
+
+	strncpy(statd_db_dirname, parentdir, sizeof(statd_db_dirname));
+
+	len = snprintf(statd_db_filename, sizeof(statd_db_filename),
+			"%s/%s", parentdir, STATD_DATABASE_FILE);
+	if (__error_check(len, sizeof(statd_db_filename))) {
+		xlog(L_ERROR, "Illegal directory name");
+		return FALSE;
+	}
+
+	return TRUE;
+}
+
+/*
+ * Returns TRUE if info table creation was successful, or if
+ * info table already exists; otherwise FALSE is returned if
+ * any error occurs.
+ */
+static bool_t
+statd_create_info_table(sqlite3 *db)
+{
+	sqlite3_stmt *stmt;
+	bool_t result;
+	int rc;
+
+	result = FALSE;
+
+	rc = sqlite3_prepare_v2(db, "CREATE TABLE " STATD_INFO_TABLENAME
+					" (name TEXT PRIMARY KEY,"
+					" value INTEGER);",
+						-1, &stmt, NULL);
+	switch (rc) {
+	case SQLITE_OK:
+		rc = sqlite3_step(stmt);
+		if (rc != SQLITE_DONE) {
+			xlog(L_ERROR, "Failed to create table '"
+					STATD_INFO_TABLENAME "': %s",
+					sqlite3_errmsg(db));
+			break;
+		}
+
+		result = TRUE;
+		xlog(D_GENERAL, "Table '" STATD_INFO_TABLENAME
+				"' created successfully");
+		break;
+	case SQLITE_ERROR:
+		result = TRUE;
+		xlog(D_GENERAL, "Table '" STATD_INFO_TABLENAME "' already exists");
+		goto out;
+	default:
+		xlog(L_ERROR, "Failed to compile SQL: %s",
+				sqlite3_errmsg(db));
+		xlog(L_ERROR, "SQL: %s");
+		goto out;
+	}
+
+	statd_finalize_stmt(stmt);
+
+out:
+	return result;
+}
+
+/*
+ * Returns TRUE if the monitor table exists, or was created; otherwise
+ * FALSE is returned if an error occurs.
+ *
+ * This could be done in svc.c.  Since sm-notify links file.o, that
+ * would mean it would have to link svc.c as well.
+ */
+static bool_t
+statd_create_monitor_table(sqlite3 *db)
+{
+	sqlite3_stmt *stmt;
+	bool_t result;
+	int rc;
+
+	result = FALSE;
+
+	rc = sqlite3_prepare_v2(db, "CREATE TABLE " STATD_MONITOR_TABLENAME
+					" (priv BLOB,"
+					" mon_name TEXT NOT NULL,"
+					" my_name TEXT NOT NULL,"
+					" program INTEGER,"
+					" version INTEGER,"
+					" procedure INTEGER,"
+					" protocol TEXT NOT NULL,"
+					" state INTEGER,"
+					" UNIQUE(mon_name,my_name));",
+						-1, &stmt, NULL);
+	switch (rc) {
+	case SQLITE_OK:
+		rc = sqlite3_step(stmt);
+		if (rc != SQLITE_DONE) {
+			xlog(L_ERROR, "Failed to create table '"
+					STATD_MONITOR_TABLENAME "': %s",
+					sqlite3_errmsg(db));
+			break;
+		}
+
+		result = 1;
+		xlog(D_GENERAL, "Table '" STATD_MONITOR_TABLENAME
+				"' created successfully");
+		break;
+	case SQLITE_ERROR:
+		result = TRUE;
+		xlog(D_GENERAL, "Table '" STATD_MONITOR_TABLENAME
+				"' already exists");
+		goto out;
+	default:
+		xlog(L_ERROR, "Failed to compile SQL: %s",
+				sqlite3_errmsg(db));
+		xlog(L_ERROR, "SQL: %s");
+		goto out;
+	}
+
+	statd_finalize_stmt(stmt);
+
+out:
+	return result;
+}
+
+/*
+ * Ensure database file exists.  This should create the file
+ * with the proper ownership.  Also ensure tables are created.
+ *
+ * XXX: Is it enough to set journal_mode and synchronous just once?
+ */
+static bool_t
+statd_init_database(void)
+{
+	bool_t result;
+	char *err_msg;
+	sqlite3 *db;
+	int rc;
+
+	xlog(D_CALL, "Initializing database");
+
+	result = FALSE;
+	db = statd_open_db(SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE);
+	if (db == NULL)
+		goto out;
+
+	/*
+	 * Don't delete the journal file after each transaction.
+	 * This provides better performance and crash robustness.
+	 */
+	err_msg = NULL;
+	rc = sqlite3_exec(db, "PRAGMA journal_mode=TRUNCATE;", NULL, 0, &err_msg);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to enable persistent journaling: %s",
+				err_msg);
+		sqlite3_free(err_msg);
+		goto out_close;
+	}
+
+	/*
+	 * Protect against db corruption during crashes.
+	 */
+	err_msg = NULL;
+	rc = sqlite3_exec(db, "PRAGMA synchronous=FULL;", NULL, 0, &err_msg);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to enable full synchronous mode: %s",
+				err_msg);
+		sqlite3_free(err_msg);
+		goto out_close;
+	}
+
+	if (!statd_create_info_table(db))
+		goto out_close;
+
+	if (!statd_create_monitor_table(db))
+		goto out_close;
+
+	result = TRUE;
+
+out_close:
+	statd_close_db(db);
+
+out:
+	return result;
+}
+
+/*
+ * Clear all capabilities but CAP_NET_BIND_SERVICE.  This permits
+ * statd to acquire privileged source ports, but all other
+ * capabilities are disallowed.
+ */
+static bool_t
+statd_clear_capabilities(void)
+{
+	bool_t result;
+	cap_t caps;
+
+	result = FALSE;
+
+	caps = cap_from_text("cap_net_bind_service=ep");
+	if (caps == NULL) {
+		xlog(L_ERROR, "Failed to allocate working storage: %m");
+		return result;
+	}
+
+	if (cap_set_proc(caps) == -1) {
+		xlog(L_ERROR, "Failed to set capability flags: %m");
+		goto out_free;
+	}
+
+	result = TRUE;
+
+out_free:
+	(void)cap_free(caps);
+	return result;
+}
+
+/**
+ * statd_drop_privileges - drop root privileges
+ * @keep_bind: caller sets this to keep CAP_NET_BIND_SERVICE
+ *
+ * Returns TRUE if successful, or FALSE if some error occurred.
+ *
+ * Set our effective UID and GID to that of our on-disk database.
+ */
+bool_t
+statd_drop_privileges(const int keep_bind)
+{
+	struct stat st;
+
+	/*
+	 * XXX: If we can't stat dirname, or if dirname is owned by
+	 *      root, we should use "statduser" instead, which is set up
+	 *      by configure.ac
+	 *
+	 *      Nothing in nfs-utils seems to use statduser, though.
+	 */
+	if (lstat(statd_db_dirname, &st) == -1) {
+		xlog(L_ERROR, "Failed to stat %s: %m", statd_db_dirname);
+		return FALSE;
+	}
+
+	if (st.st_uid == 0) {
+		xlog(L_WARNING,
+			"Running as root. chown %s to choose different user",
+				statd_db_dirname);
+		return TRUE;
+	}
+
+        /*
+	 * Don't clear capabilities when dropping root.
+	 */
+        if (keep_bind && prctl(PR_SET_KEEPCAPS, 1, 0, 0, 0) == -1) {
+                xlog(L_ERROR, "prctl(PR_SET_KEEPCAPS) failed: %m");
+		return FALSE;
+	}
+
+	if (setgroups(0, NULL) == -1) {
+		xlog(L_ERROR, "Failed to drop supplementary groups: %m");
+		return FALSE;
+	}
+
+	/*
+	 * ORDER
+	 *
+	 * setgid(2) first, as setuid(2) may remove privileges needed
+	 * to set the group id.
+	 */
+	if (setgid(st.st_gid) == -1 || setuid(st.st_uid) == -1) {
+		xlog(L_ERROR, "Failed to drop privileges: %m");
+		return FALSE;
+	}
+	xlog(D_GENERAL, "Effective UID, GID: %u, %u", st.st_uid, st.st_gid);
+
+	if (keep_bind && !statd_clear_capabilities())
+		return FALSE;
+
+	/*
+	 * ORDER
+	 *
+	 * If the on-disk database doesn't exist yet, it is created
+	 * here, after lowering our privileges.  This ensures that
+	 * statd can continue to access the database after privileges
+	 * are dropped.
+	 */
+	return statd_init_database();
+}
+
+/**
+ * statd_system_rebooted - check if we've run since the last reboot
+ *
+ * Returns TRUE if the system has rebooted since we last ran, or if
+ * we can't tell if we rebooted.  Otherwise FALSE is returned.
+ */
+bool_t
+statd_system_rebooted(void)
+{
+	key_t key;
+
+	key = ftok(statd_db_filename, 'r');	/* 'r' as in aRbitrary */
+
+	if (semget(key, 1, IPC_CREAT | IPC_EXCL | S_IRUSR | S_IWUSR) == -1) {
+		if (errno == EEXIST) {
+			xlog(D_GENERAL, "Already ran since last reboot");
+			return FALSE;
+		} else
+		xlog(D_GENERAL, "Failed to find shared semaphor: %m");
+	}
+
+	xlog(D_GENERAL, "First run since last reboot");
+	return TRUE;
+}
+
+/*
+ * Returns TRUE if successful, or FALSE if an error occurred.
+ */
+static bool_t
+statd_insert_info(sqlite3 *db, const char *name, const int64_t value)
+{
+	sqlite3_stmt *stmt;
+	bool_t result;
+	int rc;
+
+	result = FALSE;
+
+	if (!statd_prepare_stmt(db, &stmt, "INSERT OR REPLACE INTO "
+			STATD_INFO_TABLENAME " (name,value) VALUES(?,?);"))
+		goto out;
+
+	rc = sqlite3_bind_text(stmt, 1, name, -1, SQLITE_STATIC);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to bind name %s: %s",
+				name, sqlite3_errmsg(db));
+		goto out_finalize;
+	}
+
+	rc = sqlite3_bind_int64(stmt, 2, (sqlite3_int64)value);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to bind value: %s",
+				sqlite3_errmsg(db));
+		goto out_finalize;
+	}
+
+	rc = sqlite3_step(stmt);
+	if (rc != SQLITE_DONE) {
+		xlog(L_ERROR, "Failed to write NSM state number: %s",
+				sqlite3_errmsg(db));
+		goto out_finalize;
+	}
+
+	result = TRUE;
+
+out_finalize:
+	statd_finalize_stmt(stmt);
+
+out:
+	return result;
+}
+
+/*
+ * Returns TRUE if successful, or FALSE if an error occurred.
+ */
+static bool_t
+statd_get_info(sqlite3 *db, const char *name, int64_t *value)
+{
+	sqlite3_stmt *stmt;
+	bool_t result;
+	int rc;
+
+	result = FALSE;
+
+	if (!statd_prepare_stmt(db, &stmt,
+			"SELECT * FROM " STATD_INFO_TABLENAME " WHERE name=?;"))
+		goto out;
+
+	rc = sqlite3_bind_text(stmt, 1, name, -1, SQLITE_STATIC);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to bind name %s: %s",
+				name, sqlite3_errmsg(db));
+		goto out_finalize;
+	}
+
+	rc = sqlite3_step(stmt);
+	switch (rc) {
+	case SQLITE_ROW:
+		*value = (int64_t)sqlite3_column_int64(stmt, 1);
+		result = TRUE;
+		break;
+	case SQLITE_DONE:
+		xlog(D_GENERAL, "Table '" STATD_INFO_TABLENAME
+				"' did not contain a row for '%s'", name);
+		break;
+	default:
+		xlog(L_ERROR, "Failed to read value of '%s': %s",
+				name, sqlite3_errmsg(db));
+	}
+
+out_finalize:
+	statd_finalize_stmt(stmt);
+
+out:
+	return result;
+}
+
+/**
+ * statd_get_nsm_state - retrieve on-disk NSM state number
+ *
+ * Returns an odd NSM state number, or a starting NSM state number
+ * of 1 if some error occurred.
+ */
+int
+statd_get_nsm_state(void)
+{
+	int64_t state;
+	sqlite3 *db;
+
+	state = 1;
+	db = statd_open_db(SQLITE_OPEN_READONLY);
+	if (db == NULL)
+		goto out;
+
+	if (!statd_get_info(db, "state", &state))
+		goto out_close;
+
+	if (!(state & 1)) {
+		xlog(L_WARNING, "Database contained an even state number");
+		state++;
+	}
+
+out_close:
+	statd_close_db(db);
+
+out:
+	return (int)state;
+}
+
+/**
+ * statd_update_nsm_state - unconditionally update NSM state number
+ * @db: open database connection
+ *
+ * Returns TRUE if the on-disk NSM state number was updated successfully;
+ * otherwise FALSE.
+ */
+bool_t
+statd_update_nsm_state(sqlite3 *db)
+{
+	int64_t state;
+
+	if (!statd_get_info(db, "state", &state))
+		state = 1;
+	else
+		state += 2;
+
+	if (!statd_insert_info(db, "state", state))
+		return FALSE;
+
+	xlog(D_GENERAL, "Bumped NSM state, new value: %d", state);
+	return TRUE;
+}
+
+/**
+ * statd_dump_monitor_list - Display the monitor list
+ *
+ * For debugging.
+ */
+void
+statd_dump_monitor_list(void)
+{
+	int result, err, i, nrow, ncolumn;
+	char **resultp;
+	char *err_msg;
+	sqlite3 *db;
+
+	result = 0;
+
+	db = statd_open_db(SQLITE_OPEN_READONLY);
+	if (db == NULL)
+		return;
+
+	err_msg = NULL;
+	err = sqlite3_get_table(db, "SELECT"
+		" mon_name,my_name,state  FROM " STATD_MONITOR_TABLENAME ";",
+			&resultp, &nrow, &ncolumn, &err_msg);
+	if (err != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to get table '"
+				STATD_MONITOR_TABLENAME "': %s", err_msg);
+		sqlite3_free(err_msg);
+		goto out_close;
+	}
+	if (ncolumn == 0) {
+		xlog(D_GENERAL, "The monitor list currently is empty");
+		goto out_free_table;
+	}
+	if (ncolumn != 3) {
+		xlog(L_ERROR, "Incorrect column count %d in SELECT result",
+				ncolumn);
+		goto out_free_table;
+	}
+
+	xlog(D_GENERAL, "Monitor list (mon_name, my_name, state)");
+	for (i = ncolumn; i < (nrow + 1) * ncolumn ; i += ncolumn)
+		xlog(D_GENERAL, "%s, %s, %d",
+			resultp[i], resultp[i + 1], resultp[i + 2]);
+
+out_free_table:
+	sqlite3_free_table(resultp);
+
+out_close:
+	statd_close_db(db);
+}
+
+/**
+ * statd_print_capabilities - dump process capability set to log
+ *
+ * For debugging.
+ */
+void
+statd_print_capabilities(void)
+{
+	cap_t caps;
+
+	caps = cap_get_proc();
+	if (caps == NULL) {
+		xlog(L_ERROR, "Failed to get process capaabilities: %m");
+		return;
+	}
+
+	xlog(L_NOTICE, "Capabilities: %s", cap_to_text(caps, NULL));
+
+	(void)cap_free(caps);
+}
diff --git a/utils/new-statd/hostname.c b/utils/new-statd/hostname.c
new file mode 100644
index 0000000..a9f1557
--- /dev/null
+++ b/utils/new-statd/hostname.c
@@ -0,0 +1,520 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ *
+ * mon_name matching and verification functions.
+ *
+ * Multi-homed remotes usually send only a single SM_NOTIFY when they
+ * reboot, even though the local system may be accessing the remote
+ * by different names.
+ *
+ * statd maps such remotes to the same callback database entry by
+ * performing a series of steps to generate a canonical hostname
+ * from the mon_name passed to it by lockd, which it then uses as
+ * a key to index its database of NLM callback information.  The
+ * main assumption is that the names of the remotes are not volatile
+ * across local host reboots.
+ *
+ * There are some risks to this strategy:
+ *
+ *   1.  The external DNS database can change over time so that
+ *       this canonicalization process generates a different string,
+ *       preventing a clean match
+ *
+ *   2.  Local DNS resolution can produce different results than the
+ *       hostname the remote used to contact us, preventing a clean
+ *       match.
+ *
+ *   3.  Inconsistent forward and reverse DNS maps may prevent a clean
+ *       match.
+ *
+ *   4.  When DNS is slow or unavailable, statd, and thus mounting
+ *       and reboot recovery, hangs.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <ctype.h>
+#include <string.h>
+#include <stdlib.h>
+#include <netdb.h>
+#include <errno.h>
+
+#include <netinet/in.h>
+#include <arpa/inet.h>
+
+#include <rpc/rpc.h>
+#include <rpc/svc.h>
+
+#include "statd.h"
+
+#define IN_LOOPBACK(a)	((((long int)(a)) & 0xff000000) == 0x7f000000)
+
+static bool_t
+statd_report_nonlocal(const struct sockaddr *sap)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
+	char buf[INET6_ADDRSTRLEN];
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		if (inet_ntop(AF_INET, &sin->sin_addr.s_addr,
+						buf, sizeof(buf)) == NULL)
+			break;
+		xlog(L_WARNING, "Dropping non-local call from %s:%u",
+				buf, ntohs(sin->sin_port));
+		goto out;
+	case AF_INET6:
+		if (inet_ntop(AF_INET6, &sin6->sin6_addr,
+						buf, sizeof(buf)) == NULL)
+			break;
+		xlog(L_WARNING, "Dropping non-local call from %s:%u",
+				buf, ntohs(sin6->sin6_port));
+		goto out;
+	}
+
+	xlog(L_WARNING, "Received call from unrecognized address");
+
+out:
+	return FALSE;
+}
+
+static bool_t
+statd_is_loopback4(const struct sockaddr_in *sin)
+{
+	return IN_LOOPBACK(ntohl(sin->sin_addr.s_addr)) ? TRUE : FALSE;
+}
+
+static bool_t
+statd_is_loopback6(const struct sockaddr_in6 *sin6)
+{
+	return IN6_IS_ADDR_LOOPBACK(&sin6->sin6_addr) ? TRUE : FALSE;
+}
+
+static bool_t
+statd_is_loopback46(const struct sockaddr_in6 *sin6)
+{
+	if (IN6_IS_ADDR_V4MAPPED(&sin6->sin6_addr))
+		return IN_LOOPBACK(ntohl(sin6->sin6_addr.s6_addr32[3])) ?
+				TRUE : FALSE;
+	return statd_is_loopback6(sin6);
+}
+
+static bool_t
+statd_localhost4_caller_check(const struct sockaddr *sap)
+{
+	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+
+	if (statd_is_loopback4(sin) && ntohs(sin->sin_port) < IPPORT_RESERVED)
+		return TRUE;
+	return statd_report_nonlocal(sap);
+}
+
+static bool_t
+statd_localhost6_caller_check(const struct sockaddr *sap)
+{
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+
+	if (statd_is_loopback6(sin6) && ntohs(sin6->sin6_port) < IPPORT_RESERVED)
+		return TRUE;
+	return statd_report_nonlocal(sap);
+}
+
+/**
+ * statd_localhost_caller - ensure RPC caller is from loopback
+ * @rqstp: RPC request metadata
+ *
+ * Return TRUE if caller is localhost; otherwise return FALSE.
+ *
+ * Reject requests from non-loopback addresses in order
+ * to prevent attack described in CERT CA-99.05.  Also ensure
+ * that these calls are from a privileged port.
+ */
+bool_t
+statd_localhost_caller(const struct svc_req *rqstp)
+{
+	const struct netbuf *nbuf = svc_getrpccaller(rqstp->rq_xprt);
+	const struct sockaddr *sap = (struct sockaddr *)nbuf->buf;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		return statd_localhost4_caller_check(sap);
+	case AF_INET6:
+		return statd_localhost6_caller_check(sap);
+	}
+	return statd_report_nonlocal(sap);
+}
+
+/*
+ * Look up the hostname; report exceptional errors.  Caller must
+ * call freeaddrinfo(3) if a valid addrinfo is returned.
+ */
+static struct addrinfo *
+statd_get_addrinfo(const char *hostname, const struct addrinfo* gai_hint)
+{
+	struct addrinfo *gai_results;
+	int error;
+
+	error = getaddrinfo(hostname, NULL, gai_hint, &gai_results);
+	switch (error) {
+	case 0:
+		xlog(D_CALL, "%s: getaddrinfo('%s') successful",
+				__func__, hostname);
+		return gai_results;
+	case EAI_NONAME:
+		xlog(D_CALL, "%s: No hostname '%s' was found",
+				__func__, hostname);
+		break;
+	case EAI_SYSTEM:
+		xlog(L_ERROR, "Unexpected system error %m while "
+			"resolving host %s", hostname);
+		break;
+	default:
+		xlog(L_ERROR, "Unexpected getaddrinfo error %s while "
+			"resolving host %s", gai_strerror(error), hostname);
+	}
+
+	return NULL;
+}
+
+/**
+ * statd_forward_lookup - hostname or presentation address to sockaddr list
+ * @hostname: C string containing hostname or presentation address
+ * @protocol: IPPROTO_ number hint
+ *
+ * Returns addrinfo list, or NULL if an error occurs.  Caller must free
+ * addrinfo list via freeaddrinfo(3).
+ *
+ * We must be able to send an SM_NOTIFY later, so ensure that the
+ * provided mon_name either is an IP address, or can be resolved by DNS.
+ * Verify that the name does not contain illegal characters.  See CERT
+ * CA-96.09 for details.
+ *
+ * AI_ADDRCONFIG should prevent us from monitoring a host that we can't
+ * reach.  If IPv6 is not enabled on this system, then we don't want to
+ * monitor remote hosts that have only IPv6 addresses.
+ */
+struct addrinfo *
+statd_forward_lookup(const char *hostname, const int protocol)
+{
+	struct addrinfo gai_hint = {
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_UNSPEC,
+		.ai_flags	= AI_CANONNAME | AI_ADDRCONFIG,
+#else	/* !IPV6_SUPPORTED */
+		.ai_family	= AF_INET,
+		.ai_flags	= AI_CANONNAME,
+#endif	/* !IPV6_SUPPORTED */
+	};
+
+	gai_hint.ai_protocol = protocol;
+	return statd_get_addrinfo(hostname, &gai_hint);
+}
+
+/*
+ * This module is built only if the local system has TI-RPC
+ * and sqlite3, so we are fairly sure it has a recent enough
+ * glibc that getnameinfo(3) is available.
+ *
+ * Returns a pointer to a C string containing a hostname (never
+ * a presentation address), or NULL if the resolution failed.
+ * Caller must free the string.
+ */
+static char *
+statd_reverse_lookup(const struct sockaddr *sap, const socklen_t salen,
+			const char *hostname)
+{
+	char buf[NI_MAXHOST];
+	int error;
+
+	error = getnameinfo(sap, salen, buf, sizeof(buf), NULL, 0, NI_NAMEREQD);
+	switch (error) {
+	case 0:
+		xlog(D_CALL, "Reverse lookup found hostname '%s'", buf);
+		return strdup(buf);
+	case EAI_NONAME:
+		xlog(D_CALL, "Reverse lookup found no name");
+		break;
+	case EAI_SYSTEM:
+		xlog(L_ERROR, "Unexpected system error %m while "
+			"resolving host %s", hostname);
+		break;
+	default:
+		xlog(L_ERROR, "Unexpected getnameinfo(3) error %s while "
+			"resolving host %s", gai_strerror(error), hostname);
+		break;
+	}
+
+	return NULL;
+}
+
+/**
+ * statd_get_address_list - Generate list of addresses for @hostname
+ * @hostname: C string containing hostname or presentation address
+ * @gai_hint: hint passed to getaddrinfo(3)
+ *
+ * If @hostname is a presentation address, first try to reverse map it
+ * to a canonical hostname.  This allows us to generate a list of
+ * equivalent addresses to try.  If the address in @hostname doesn't
+ * have a reverse map, just convert the address to an addrinfo.
+ *
+ * Returns addrinfo list, or NULL if an error occurs.  Caller must free
+ * addrinfo list via freeaddrinfo(3).
+ */
+struct addrinfo *
+statd_get_address_list(const char *hostname, const struct addrinfo *gai_hint)
+{
+	struct addrinfo reverse_hint, *gai_results;
+	char *name;
+	int error;
+
+	/* AI_NUMERICHOST means this one doesn't go on the wire */
+	reverse_hint = *gai_hint;
+	reverse_hint.ai_flags |= AI_NUMERICHOST;
+
+	error = getaddrinfo(hostname, NULL, &reverse_hint, &gai_results);
+	switch (error) {
+	case 0:
+		xlog(D_CALL, "Hostname '%s' is a presentation format address",
+				hostname);
+		name = statd_reverse_lookup(gai_results->ai_addr,
+						gai_results->ai_addrlen,
+						hostname);
+		if (name == NULL)
+			return gai_results;
+
+		freeaddrinfo(gai_results);
+		gai_results = statd_get_addrinfo(name, gai_hint);
+		free(name);
+		return gai_results;
+	case EAI_NONAME:
+		xlog(D_CALL, "Hostname '%s' is not a presentation format address",
+				hostname);
+		return statd_get_addrinfo(hostname, gai_hint);
+	case EAI_SYSTEM:
+		xlog(L_ERROR, "unexpected system error %m while "
+			"resolving hostname '%s'", hostname);
+		break;
+	default:
+		xlog(L_ERROR, "unexpected getaddrinfo(3) error %s while "
+			"resolving hostname '%s'", gai_strerror(error), hostname);
+	}
+
+	return NULL;
+}
+
+#ifdef IPV6_SUPPORTED
+static bool_t
+statd_compare_sockaddrs(const struct sockaddr *sa1,
+				const struct sockaddr *sa2)
+{
+	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
+	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
+
+	if (statd_is_loopback46(sin1) && statd_is_loopback46(sin2))
+		return TRUE;
+
+	if ((IN6_IS_ADDR_LINKLOCAL(&sin1->sin6_addr) &&
+	     IN6_IS_ADDR_LINKLOCAL(&sin2->sin6_addr)) ||
+	    (IN6_IS_ADDR_SITELOCAL(&sin1->sin6_addr) &&
+	     IN6_IS_ADDR_SITELOCAL(&sin2->sin6_addr)))
+		if (sin1->sin6_scope_id != sin2->sin6_scope_id)
+			return FALSE;
+
+	return IN6_ARE_ADDR_EQUAL(&sin1->sin6_addr, &sin2->sin6_addr) ?
+			TRUE : FALSE;
+}
+
+#else	/* !IPV6_SUPPORTED */
+static bool_t
+statd_compare_sockaddrs(const struct sockaddr *sa1,
+				const struct sockaddr *sa2)
+{
+	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
+	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
+
+	if (statd_is_loopback4(sin1) && statd_is_loopback4(sin2))
+		return TRUE;
+	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr ?
+			TRUE : FALSE;
+}
+#endif	/* !IPV6_SUPPORTED */
+
+static bool_t
+statd_compare_addrlists(struct addrinfo *ai1, struct addrinfo *ai2)
+{
+	xlog(D_CALL, "%s", __func__);
+
+	for (; ai1 != NULL; ai1 = ai1->ai_next) {
+		struct addrinfo *ai;
+		for (ai = ai2; ai != NULL; ai = ai->ai_next)
+			if (statd_compare_sockaddrs(ai1->ai_addr, ai->ai_addr))
+				return TRUE;
+	}
+	return FALSE;
+}
+
+/*
+ * If IPV6 is enabled, we always get back a list of only AF_INET6
+ * addresses (including mapped v4 addresses) from getaddrinfo(3).
+ * Thus we can always use IP6_ARE_ADDR_EQUAL to compare these addresses.
+ */
+static bool_t
+statd_matchhostname_dns(const char *hostname1, const char *hostname2)
+{
+	static const struct addrinfo gai_hint = {
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_INET6,
+		.ai_flags	= AI_CANONNAME | AI_V4MAPPED,
+#else	/* !IPV6_SUPPORTED */
+		.ai_family	= AF_INET,
+		.ai_flags	= AI_CANONNAME,
+#endif	/* !IPV6_SUPPORTED */
+		.ai_protocol	= IPPROTO_UDP,
+	};
+	struct addrinfo *gai_results1, *gai_results2;
+	bool_t result;
+
+	result = FALSE;
+
+	/*
+	 * Acquire a list of associated IP addresses for each hostname.
+	 */
+	gai_results1 = statd_get_address_list(hostname1, &gai_hint);
+	if (gai_results1 == NULL)
+		return result;
+	gai_results2 = statd_get_address_list(hostname2, &gai_hint);
+	if (gai_results2 == NULL) {
+		freeaddrinfo(gai_results1);
+		return result;
+	}
+
+	/*
+	 * If the canonical hostnames match, or one address in each
+	 * list matches, then we have a positive result.
+	 */
+	if ((strcasecmp(gai_results1->ai_canonname,
+				gai_results2->ai_canonname) != 0) ||
+	    !statd_compare_addrlists(gai_results1, gai_results2))
+		goto out;
+
+	result = TRUE;
+
+out:
+	freeaddrinfo(gai_results2);
+	freeaddrinfo(gai_results1);
+	return result;
+}
+
+/**
+ * statd_match_hostname - check if two hostnames are equivalent
+ * @hostname1: C string containing hostname
+ * @hostname2: C string containing hostname
+ *
+ * Returns TRUE if the hostnames are the same, the hostnames resolve
+ * to the same canonical name, or the hostnames resolve to at least
+ * one address that is the same.  FALSE is returned if the hostnames
+ * do not match in any of these ways, if either hostname contains
+ * illegal characters, or if an error occurs.
+ */
+bool_t
+statd_match_hostname(const char *hostname1, const char *hostname2)
+{
+	bool_t result;
+
+	xlog(D_CALL, "Comparing '%s' and '%s'", hostname1, hostname2);
+
+	if (strcasecmp(hostname1, hostname2) == 0) {
+		xlog(D_GENERAL, "Exact match between '%s' and '%s'",
+				hostname1, hostname2);
+		return TRUE;
+	}
+
+	result = statd_matchhostname_dns(hostname1, hostname2);
+	if (result == TRUE)
+		xlog(D_GENERAL, "DNS match between '%s' and '%s'",
+				hostname1, hostname2);
+	else
+		xlog(D_GENERAL, "Failed to match '%s' and '%s':",
+				hostname1, hostname2);
+	return result;
+}
+
+/**
+ * statd_match_address - check if hostname and IP address are equivalent
+ * @hostname: C string containing hostname
+ * @sap: pointer to socket address
+ *
+ * Returns TRUE if the hostname resolves to @sap.  FALSE is returned if
+ * the hostname does not resolve to address, if @hostname contains
+ * illegal characters, or if an error occurs.
+ */
+bool_t
+statd_match_address(const char *hostname, const struct sockaddr *sap)
+{
+	struct addrinfo gai_hint = {
+		.ai_protocol	= IPPROTO_UDP,
+	};
+	struct addrinfo *gai_results, *ai;
+	char buf[INET6_ADDRSTRLEN];
+
+	if (opt_debug) {
+		const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+		const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
+
+		switch (sap->sa_family) {
+		case AF_INET:
+			(void)inet_ntop(AF_INET, &sin->sin_addr.s_addr,
+						buf, sizeof(buf));
+			break;
+		case AF_INET6:
+			(void)inet_ntop(AF_INET6, &sin6->sin6_addr,
+						buf, sizeof(buf));
+			break;
+		default:
+			xlog(L_NOTICE, "%s: Invalid address family", __func__);
+			return FALSE;
+		}
+
+		xlog(D_CALL, "Comparing '%s' and %s", hostname, buf);
+	}
+
+	gai_hint.ai_family = sap->sa_family;
+	gai_results = statd_get_address_list(hostname, &gai_hint);
+	if (gai_results == NULL)
+		goto out_fail;
+
+	for (ai = gai_results; ai != NULL; ai = ai->ai_next)
+		if (statd_compare_sockaddrs(ai->ai_addr, sap)) {
+			xlog(D_GENERAL, "DNS match between '%s' and %s",
+					hostname, buf);
+			return TRUE;
+		}
+
+	freeaddrinfo(gai_results);
+
+out_fail:
+	xlog(D_GENERAL, "Failed to match '%s' and %s", hostname, buf);
+	return FALSE;
+}
diff --git a/utils/new-statd/nlmcall.c b/utils/new-statd/nlmcall.c
new file mode 100644
index 0000000..3a7b3b0
--- /dev/null
+++ b/utils/new-statd/nlmcall.c
@@ -0,0 +1,525 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ *
+ * Manage NLM callbacks.
+ *
+ * There are some complications.
+ *
+ * 1. Standard RPC library client calls that expect a reply are always
+ *    synchronous with the remote server, and use system calls that
+ *    cause the RPC caller process to block.
+ *
+ *    However, statd cannot block, because its NSM service is
+ *    implemented as a single thread.  Blocking would cause statd to
+ *    become unresponsive.
+ *
+ *    To allow the use of standard RPC client library calls to
+ *    implement our NLM callback, callbacks are done in a separate
+ *    process.  The statd service process hands NLM callback requests
+ *    to this process via a packet socket.
+ *
+ * 2. Statd drops its root privileges before creating listener
+ *    sockets to minimize exposure to network attacks.  Linux lockd
+ *    requires, however, that NLM callbacks are sent from a
+ *    privileged port, in order to prevent users from sending local
+ *    reboot notification spoofs.
+ *
+ *    After starting up, then, the statd process forks the NLM
+ *    callback child process before dropping its root privileges.  The
+ *    child NLM callback process retains its root privileges so it can
+ *    create sockets with privileged source ports as needed.
+ *
+ *    Each transport socket used for NLM callbacks is destroyed after
+ *    the callback finishes to minimize exposure to RPC reply spoofing.
+ *
+ * 3. A UDP socket is used to send an NLM callback.  This prevents
+ *    the callback process from leaving privileged ports in TIME_WAIT
+ *    after each callback request is finished.
+ *
+ * 4. The callback mechanism must tolerate the temporary absence of
+ *    lockd and/or rpcbind.  The NLM callback implementation uses
+ *    a long timeout and a large number of retries to improve the
+ *    chances that the local lockd will see the request.
+ *
+ */
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/resource.h>
+#include <sys/time.h>
+
+#include <time.h>
+#include <string.h>
+#include <stdint.h>
+#include <unistd.h>
+#include <signal.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <netdb.h>
+
+#include "statd.h"
+#include "nfsrpc.h"
+
+#if SIZEOF_SOCKLEN_T - 0 == 0
+#define socklen_t int
+#endif
+
+struct statd_callback {
+	int			state;
+	struct sockaddr_storage	address;
+	char			mon_name[SM_MAXSTRLEN];
+};
+
+static int statd_sv[2];
+
+/*
+ * Show the priv in hexadecimal.  For debugging only.
+ */
+#define STATD_SIZEOF_HEXBYTE	sizeof("ff")
+#define STATD_PRIVBUF_LEN	(SM_PRIV_SIZE * STATD_SIZEOF_HEXBYTE)
+static const char *
+statd_show_priv(const char *priv)
+{
+	static char buf[STATD_PRIVBUF_LEN];
+	unsigned int i;
+	char *p;
+
+	memset(buf, 0, sizeof(buf));
+	p = &buf[0];
+	for (i = 0; i < SM_PRIV_SIZE; i++)
+		p += sprintf(p, "%02x", 0xff & priv[i]);
+
+	return (const char *)buf;
+}
+
+/*
+ * Synchronously create a socket and RPC client, perform an rpcbind,
+ * send the callback, then shutdown the client and destroy the socket.
+ *
+ * Lockd requires a privileged port for these calls, as a simple form
+ * of authentication.  A UDP transport is used to prevent tying up a
+ * pair of privileged ports for 120 seconds in TIME_WAIT (one for the
+ * rpcbind and one for the call itself).
+ *
+ * Note that some recent kernels do not create a UDP listener for
+ * lockd.  In that case we try the client creation with TCP.
+ *
+ * Even though the reply is void, we leave our RPC client available
+ * to receive it.  The reply tells us the kernel actually saw and
+ * executed the request, thus we don't need to retransmit it.
+ *
+ * Returns TRUE if the call succeeded, or FALSE if caller should try again.
+ */
+static bool_t
+statd_send_one_nlm_callback(const struct mon *monp, const int state)
+{
+	const struct my_id *my_idp = &monp->mon_id.my_id;
+	const rpcprog_t program = (rpcprog_t)my_idp->my_prog;
+	const rpcvers_t version = (rpcvers_t)my_idp->my_vers;
+	const rpcproc_t procedure = (rpcproc_t)my_idp->my_proc;
+	struct timeval timeout = { STATD_NLM_CALLBACK_TIMEOUT, 0 };
+	struct nlm_reboot new_status = {
+		.mon_name	= monp->mon_id.mon_name,
+		.state		= (int)state,
+	};
+	enum clnt_stat status;
+	CLIENT *clnt;
+
+	rpc_createerr.cf_stat = 0;
+	clnt = clnt_create_timed("localhost", program, version,
+						"udp", &timeout);
+	/* Sometimes lockd starts only a TCP listener */
+	if (clnt == NULL && rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED) {
+		rpc_createerr.cf_stat = 0;
+		clnt = clnt_create_timed("localhost", program,
+					version, "tcp", &timeout);
+	}
+	if (clnt == NULL) {
+		xlog(L_ERROR, "Failed to create RPC client for NLM callback: %s",
+				clnt_sperrno(rpc_createerr.cf_stat));
+		return FALSE;
+	}
+
+	memcpy(new_status.priv, monp->priv, sizeof(new_status.priv));
+	xlog(D_GENERAL, "Arguments for callback: %s, %u",
+			new_status.mon_name, new_status.state);
+
+	status = clnt_call(clnt, procedure,
+				(xdrproc_t)xdr_nlm_reboot, (caddr_t)&new_status,
+				(xdrproc_t)xdr_void, NULL, timeout);
+	switch (status) {
+	case RPC_SUCCESS:
+		xlog(D_GENERAL, "NLM callback succeeded");
+		break;
+	default:
+		xlog(D_GENERAL, "NLM callback failed: %s", clnt_sperrno(status));
+		break;
+	}
+
+	clnt_destroy(clnt);
+	return status == RPC_SUCCESS ? TRUE : FALSE;
+}
+
+static bool_t
+statd_send_nlm_callback(const struct mon *monp, const int state)
+{
+	unsigned int retries;
+
+	xlog(D_CALL, "Sending callback for %s/%s (%u, %u, %u) priv: %s",
+			monp->mon_id.mon_name, monp->mon_id.my_id.my_name,
+			monp->mon_id.my_id.my_prog,
+			monp->mon_id.my_id.my_vers,
+			monp->mon_id.my_id.my_proc,
+			statd_show_priv(monp->priv));
+
+	retries = STATD_NLM_CALLBACK_RETRIES;
+	while (retries--) {
+		if (statd_send_one_nlm_callback(monp, state))
+			return TRUE;
+		sleep(2);
+	}
+
+	return FALSE;
+}
+
+/*
+ * Extract the NLM callback arguments from our database,
+ * and send the the RPC.
+ *
+ * Returns TRUE if all went to plan, or FALSE if some error
+ * occurred.
+ */
+static bool_t
+statd_post_nlm_callback(sqlite3 *db, char *mon_name,
+		char *my_name, const int state)
+{
+	sqlite3_stmt *stmt;
+	struct mon mon;
+	bool_t result;
+	int rc, tmp;
+	char *sql;
+
+	memset(&mon, 0, sizeof(mon));
+	result = FALSE;
+
+	sql = sqlite3_mprintf("SELECT priv,program,version,procedure FROM "
+				STATD_MONITOR_TABLENAME
+				" WHERE mon_name='%q' and my_name='%q';",
+					mon_name, my_name);
+	if (sql == NULL) {
+		xlog(L_ERROR, "Failed to generate SQL command in %s", __func__);
+		return result;
+	}
+
+	rc = statd_prepare_stmt(db, &stmt, sql);
+	sqlite3_free(sql);
+	if (!rc)
+		goto out;
+
+	rc = sqlite3_step(stmt);
+	switch (rc) {
+	case SQLITE_ROW:
+		tmp = sqlite3_column_count(stmt);
+		if (tmp != 4) {
+			xlog(L_ERROR, "Incorrect column count %d "
+					"in SELECT result", tmp);
+			break;
+		}
+
+		tmp = sqlite3_column_bytes(stmt, 0);
+		if (tmp != SM_PRIV_SIZE) {
+			xlog(L_ERROR, "Incorrect priv cookie size %d "
+					"in SELECT result", tmp);
+			//break;
+		}
+		memcpy(mon.priv, sqlite3_column_blob(stmt, 0), sizeof(mon.priv));
+
+		mon.mon_id.mon_name = mon_name;
+		mon.mon_id.my_id.my_name = my_name;
+		mon.mon_id.my_id.my_prog = sqlite3_column_int(stmt, 1);
+		mon.mon_id.my_id.my_vers = sqlite3_column_int(stmt, 2);
+		mon.mon_id.my_id.my_proc = sqlite3_column_int(stmt, 3);
+
+		result = statd_send_nlm_callback(&mon, state);
+		break;
+	case SQLITE_DONE:
+		xlog(L_ERROR, "The monitor list does not contain an entry "
+				"for '%s'", mon_name);
+		break;
+	default:
+		xlog(L_ERROR, "Failed to find row for '%s' in table '"
+				STATD_MONITOR_TABLENAME "': %s",
+				mon_name, sqlite3_errmsg(db));
+	}
+
+	statd_finalize_stmt(stmt);
+
+out:
+	return result;
+}
+
+/*
+ * Remember the new NSM state for this mon_name/my_name.
+ */
+static bool_t
+statd_set_mon_state(sqlite3 *db, const char *mon_name,
+		const char *my_name, const int state)
+{
+	char *sql, *err_msg;
+	bool_t result;
+
+	result = FALSE;
+
+	sql = sqlite3_mprintf("UPDATE " STATD_MONITOR_TABLENAME " SET state=%d"
+				" WHERE mon_name='%q' and my_name='%q';",
+					state, mon_name, my_name);
+	if (sql == NULL) {
+		xlog(L_ERROR, "Failed to generate SQL command in %s", __func__);
+		return result;
+	}
+
+	err_msg = NULL;
+	if (sqlite3_exec(db, sql, NULL, 0, &err_msg) != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to update state for mon_name '%s': %s",
+				mon_name, err_msg);
+		xlog(L_ERROR, "SQL: %s", sql);
+		sqlite3_free(err_msg);
+		goto out_free;
+	}
+
+	result = TRUE;
+	xlog(D_CALL, "Set state to %d for mon_name '%s'", state, mon_name);
+
+out_free:
+	sqlite3_free(sql);
+	return result;
+}
+
+/*
+ * Since it's not likely we will get an exact match on the mon_name
+ * (if the kernel sends us IP addresses to monitor instead of real
+ * hostnames, or the NFS server's actual hostname does not match
+ * the name sent to us by the local NFS client), we must use a
+ * heuristic to match incoming SM_NOTIFY arguments to rows in our
+ * monitor list.
+ */
+static void
+statd_match_monitored_host(const char *mon_name, const int state,
+		const struct sockaddr *sap)
+{
+	int err, i, nrow, ncolumn;
+	char **resultp;
+	char *err_msg;
+	bool_t result;
+	sqlite3 *db;
+
+	result = FALSE;
+
+	db = statd_open_db(SQLITE_OPEN_READWRITE);
+	if (db == NULL)
+		goto out;
+
+	err_msg = NULL;
+	err = sqlite3_get_table(db, "SELECT"
+		" mon_name,my_name,state"
+		" FROM " STATD_MONITOR_TABLENAME ";",
+			&resultp, &nrow, &ncolumn, &err_msg);
+	if (err != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to get table '"
+				STATD_MONITOR_TABLENAME "': %s", err_msg);
+		sqlite3_free(err_msg);
+		goto out_close;
+	}
+	if (ncolumn == 0) {
+		xlog(D_GENERAL, "The monitor list is empty");
+		goto out_free_table;
+	}
+	if (ncolumn != 3) {
+		xlog(L_ERROR, "Incorrect column count %d in SELECT result",
+				ncolumn);
+		goto out_free_table;
+	}
+
+	for (i = ncolumn; i < (nrow + 1) * ncolumn ; i += ncolumn) {
+		/*
+		 * Does the row's mon_name or hostname "match" the incoming
+		 * mon_name?  Does the row's hostname "match" the caller's
+		 * IP address?
+		 */
+		if (!statd_match_hostname(resultp[i], mon_name) &&
+		    !statd_match_address(resultp[i], sap))
+			continue;
+
+		/*
+		 * If we've been sent this state number update
+		 * already, don't send callback.
+		 */
+		if (state == atoi(resultp[i + 2])) {
+			xlog(D_GENERAL, "Already seen state %d from %s",
+					state, mon_name);
+			continue;
+		}
+
+		if (statd_post_nlm_callback(db, resultp[i], resultp[i + 1], state)) {
+			statd_set_mon_state(db, resultp[i], resultp[i + 1],
+						state);
+			result = TRUE;
+		}
+	}
+
+out_free_table:
+	sqlite3_free_table(resultp);
+
+out_close:
+	statd_close_db(db);
+
+out:
+	if (result == FALSE)
+		xlog(D_GENERAL, "SM_NOTIFY for %s call ignored", mon_name);
+}
+
+/*
+ * The statd child process that manages NLM callbacks.
+ *
+ * Read NLM callback requests from our socket, match them against
+ * our monitor list, and execute them.
+ */
+static void
+statd_nlm_callback_process(void)
+{
+	(void)setpriority(PRIO_PROCESS, 0, 19);
+
+	xlog(D_CALL, "NLM callback process %u running", getpid());
+
+	if (!statd_drop_privileges(1))
+		return;
+
+	for (;;) {
+		static struct statd_callback buf;
+
+		if (read(statd_sv[1], &buf, sizeof(buf)) < 1)
+			break;
+
+		xlog(D_CALL, "Received queued NLM callback request");
+
+		statd_match_monitored_host(buf.mon_name, buf.state,
+					(struct sockaddr *)&buf.address);
+	}
+
+	xlog(D_CALL, "Shutting down NLM callback process");
+}
+
+/**
+ * statd_queue_nlm_callback - queue an NLM callback
+ * @mon_name: C string containing mon_name argument of SM_NOTIFY request
+ * @state: NSM state number argument of SM_NOTIFY request
+ * @sap: pointer to IP address of caller
+ *
+ * Called by the statd RPC listener process when a remote has sent
+ * us an SM_NOTIFY for a host we're monitoring.
+ *
+ * Tests show a packet socket can queue over 3000 packets, independent
+ * of packet size.
+ */
+void
+statd_queue_nlm_callback(const char *mon_name, const int state,
+		const struct sockaddr *sap)
+{
+	static struct statd_callback args;
+	ssize_t len;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		memcpy(&args.address, sap, sizeof(struct sockaddr_in));
+		break;
+	case AF_INET6:
+		memcpy(&args.address, sap, sizeof(struct sockaddr_in6));
+		break;
+	default:
+		xlog(L_ERROR, "Unrecognized SM_NOTIFY caller address");
+		return;
+	}
+	args.state = state;
+	strncpy(args.mon_name, mon_name, sizeof(args.mon_name));
+
+	len = write(statd_sv[0], &args, sizeof(args));
+	if (__exact_error_check(len, sizeof(args))) {
+		if (errno == EAGAIN)
+			xlog(L_ERROR, "NLM callback process not responding");
+		else
+			xlog(L_ERROR, "NLM callback socket write failed: %m");
+		return;
+	}
+
+	xlog(D_CALL, "Queued callback request for %s", mon_name);
+}
+
+/**
+ * statd_init_nlm_callback - set up callback process
+ *
+ * Returns TRUE if all went to plan; otherwise returns FALSE.
+ */
+bool_t
+statd_init_nlm_callback(void)
+{
+	const struct sigaction statd_sigchld_action = {
+		.sa_handler	= SIG_DFL,
+		.sa_flags	= SA_NOCLDSTOP | SA_NOCLDWAIT,
+	};
+	bool_t result;
+
+	result = FALSE;
+
+	if (socketpair(AF_UNIX, SOCK_SEQPACKET, 0, statd_sv) < 0) {
+		xlog(L_ERROR, "Failed to create NLM callback sockets: %m");
+		return result;
+	}
+
+	/*
+	 * Make the write end non-blocking so the NSM service doesn't
+	 * stall if the child end stops responding.
+	 */
+	if (fcntl(statd_sv[0], F_SETFL, O_NONBLOCK) == -1)
+		xlog(L_ERROR, "Failed to make NLM callback socket nonblocking: %m");
+	else {
+		switch (fork()) {
+		case -1:
+			xlog(L_ERROR, "Failed to fork NLM callback process: %m");
+			close(statd_sv[0]);
+			break;
+		case 0:
+			/* Child. */
+			close(statd_sv[0]);
+			statd_nlm_callback_process();
+			break;
+		default:
+			/* Parent. */
+			(void)sigaction(SIGCHLD, &statd_sigchld_action, NULL);
+			usleep(10000);	/* Let child run */
+			result = TRUE;
+		}
+	}
+
+	close(statd_sv[1]);
+	return result;
+}

