Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56754 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932991AbdCJVqN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 16:46:13 -0500
Received: from smtp.corp.redhat.com (int-mx16.intmail.prod.int.phx2.redhat.com [10.5.11.28])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4EEC285545
        for <linux-nfs@vger.kernel.org>; Fri, 10 Mar 2017 21:46:13 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (unknown [10.10.123.67])
        by smtp.corp.redhat.com (Postfix) with ESMTP id ED61B2D653
        for <linux-nfs@vger.kernel.org>; Fri, 10 Mar 2017 21:46:12 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC nfs-utils PATCH] nfsdcltrack: cluster mode
Date: Fri, 10 Mar 2017 16:46:12 -0500
Message-Id: <20170310214612.12583-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds a new config option called "cluster-mode" for sharing
client records from the cltrack database between nodes of an HA cluster
such as pacemaker.

When enabled:

1. We have a sqlite db in a hidden directory (".nfsdcltrack") on each
   export.
2. We store the inode number of the etab file in the parameters table
   of the local db, along with the path names for all the exports in a
   new table.
3. During nfsdcltrack's startup, we stat the etab file.  If the inode
   number is different than what we have in the db, then we know that
   the exportfs program has modified the file.  We read in the exported
   path names and compare them to what we have stored in the exports
   table.  If any new exports has been added, we merge the client
   records from db's on those exports into the clients table of the
   local db.  Then we update the exports table in the local db.
4. When client records are added (cltrack_create()), updated
   (cltrack_check()), or removed (cltrack_remove() and
   cltrace_gracedone()) from the local db, they're added/updated/removed
   from db on each of the exports as well.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/nfsdcltrack/Makefile.am   |   5 +-
 utils/nfsdcltrack/nfsdcltrack.c | 165 ++++++++
 utils/nfsdcltrack/sqlite.c      | 821 ++++++++++++++++++++++++++++++++++++++--
 utils/nfsdcltrack/sqlite.h      |   8 +
 4 files changed, 958 insertions(+), 41 deletions(-)

diff --git a/utils/nfsdcltrack/Makefile.am b/utils/nfsdcltrack/Makefile.am
index 0a2858f..ff804df 100644
--- a/utils/nfsdcltrack/Makefile.am
+++ b/utils/nfsdcltrack/Makefile.am
@@ -13,7 +13,10 @@ sbin_PROGRAMS	= nfsdcltrack
 noinst_HEADERS	= sqlite.h
 
 nfsdcltrack_SOURCES = nfsdcltrack.c sqlite.c
-nfsdcltrack_LDADD = ../../support/nfs/libnfs.a $(LIBSQLITE) $(LIBCAP)
+nfsdcltrack_LDADD = ../../support/export/libexport.a \
+		    ../../support/nfs/libnfs.a \
+		    ../../support/misc/libmisc.a \
+		    $(LIBSQLITE) $(LIBCAP)
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index 7af9efb..3ff6d02 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -46,6 +46,10 @@
 #include "conffile.h"
 #include "xlog.h"
 #include "sqlite.h"
+#include "exportfs.h"
+#include "misc.h"
+#include "nfslib.h"
+#include "xmalloc.h"
 
 #ifndef CLD_DEFAULT_STORAGEDIR
 #define CLD_DEFAULT_STORAGEDIR NFS_STATEDIR "/nfsdcltrack"
@@ -93,6 +97,8 @@ static struct cltrack_cmd commands[] =
 };
 
 static char *storagedir = CLD_DEFAULT_STORAGEDIR;
+int cluster_mode = 0;
+struct state_paths etab;
 
 /* common buffer for holding id4 blobs */
 static unsigned char blob[NFS4_OPAQUE_LIMIT];
@@ -262,6 +268,136 @@ cltrack_get_grace_start(void)
 	return grace_start;
 }
 
+/* stolen from nfs-server-generator.c */
+struct list {
+	struct list *next;
+	char *name;
+};
+
+/* stolen from nfs-server-generator.c */
+static int is_unique(struct list **lp, char *path)
+{
+	struct list *l = *lp;
+
+	while (l) {
+		if (strcmp(l->name, path) == 0)
+			return 0;
+		l = l->next;
+	}
+	l = malloc(sizeof(*l));
+	if (l == NULL)
+		return 0;
+	l->name = path;
+	l->next = *lp;
+	*lp = l;
+	return 1;
+}
+
+static
+void dispose_list(struct list **lp)
+{
+	struct list *x;
+	struct list *l = *lp;
+
+	while (l) {
+		x = l;
+		l = l->next;
+		free(x);
+	}
+}
+
+/*
+ * Walk the export list, adding them to a temp table in the db.  For any new
+ * export we find, try to merge the client records from that export's db into
+ * the main db.
+ */
+static int
+cltrack_walk_exportlist(void)
+{
+	int ret = 0;
+	int i;
+	nfs_export *exp;
+	struct list *list = NULL;
+
+	for (i = 0; i < MCL_MAXTYPES; i++) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
+			if (!is_unique(&list, exp->m_export.e_path))
+				continue;
+			if (exp->m_export.e_flags & NFSEXP_V4ROOT)
+				continue;
+			xlog(D_GENERAL, "export path: %s", exp->m_export.e_path);
+			if (!sqlite_export_exists(exp->m_export.e_path)) {
+				xlog(D_GENERAL, "%s is a new export",
+						exp->m_export.e_path);
+				ret = sqlite_merge_client_records(exp->m_export.e_path);
+				if (ret)
+					xlog(L_WARNING, "failed to merge client records from %s",
+							exp->m_export.e_path);
+			}
+			ret = sqlite_insert_temp_export(exp->m_export.e_path);
+			if (ret) {
+				xlog(L_WARNING, "failed to insert temp export");
+				goto out_err;
+			}
+		}
+	}
+
+out_err:
+	dispose_list(&list);
+	return ret;
+}
+
+/*
+ * If the etab file's inode number has changed then it's an indication that the
+ * exports have changed.  When that happens, we need to re-read the etab file
+ * and update the exports in the db.
+ */
+static void
+cltrack_check_etab(void)
+{
+	int ret;
+	int fd;
+	struct stat stb;
+	ino_t etab_inode;
+
+	etab_inode = (ino_t)sqlite_query_etab_inode();
+	if ((fd = open(etab.statefn, O_RDONLY)) < 0) {
+		xlog(L_WARNING, "couldn't open %s", etab.statefn);
+		goto out_deactivate;
+	} else if (fstat(fd, &stb) < 0) {
+		xlog(L_WARNING, "couldn't stat %s", etab.statefn);
+		goto out_deactivate;
+	}
+	if (etab_inode != stb.st_ino) {
+		sqlite_create_temp_exports();
+		xlog(D_GENERAL, "re-reading %s", etab.statefn);
+		xtab_export_read();
+		ret = cltrack_walk_exportlist();
+		if (ret) {
+			xlog(L_WARNING, "failed to walk exportlist");
+			goto out_deactivate;
+		}
+		ret = sqlite_update_exports((long)stb.st_ino);
+		if (ret) {
+			xlog(L_WARNING, "failed to update exports");
+			goto out_deactivate;
+		}
+		sqlite_drop_temp_exports();
+		if (ret) {
+			xlog(L_WARNING, "failed to update etab inode in database");
+			goto out_deactivate;
+		}
+	}
+
+out:
+	return;
+
+out_deactivate:
+	xlog(D_GENERAL, "cluster mode deactivated");
+	cluster_mode = 0;
+	goto out;
+}
+
 static bool
 cltrack_reclaims_complete(void)
 {
@@ -315,6 +451,8 @@ cltrack_init(const char __attribute__((unused)) *unused)
 		 */
 		ret = -EACCES;
 	} else {
+		if (cluster_mode)
+			cltrack_check_etab();
 		if (cltrack_reclaims_complete())
 			cltrack_lift_grace_period();
 	}
@@ -552,6 +690,29 @@ find_cmd(char *cmdname)
 	return NULL;
 }
 
+static void
+cluster_mode_activate(const char *progname)
+{
+	char *s;
+
+	xlog(D_GENERAL, "cluster mode activated");
+	/* NOTE: following uses "mountd" section of nfs.conf !!!! */
+	s = conf_get_str("mountd", "state-directory-path");
+	if (s && !state_setup_basedir(progname, s)) {
+		xlog(L_WARNING, "failed to get mountd's state directory path");
+		goto out_deactivate;
+	}
+	if (!setup_state_path_names(progname, ETAB, ETABTMP, ETABLCK, &etab)) {
+		xlog(L_WARNING, "failed to setup etab path");
+		goto out_deactivate;
+	}
+	return;
+
+out_deactivate:
+	xlog(D_GENERAL, "cluster mode deactivated");
+	cluster_mode = 0;
+}
+
 int
 main(int argc, char **argv)
 {
@@ -575,6 +736,8 @@ main(int argc, char **argv)
 	if (rc > 0)
 		xlog_config(D_ALL, 1);
 
+	cluster_mode = conf_get_bool("nfsdcltrack", "cluster-mode", cluster_mode);
+
 	/* process command-line options */
 	while ((arg = getopt_long(argc, argv, "hdfs:", longopts,
 				  NULL)) != EOF) {
@@ -630,6 +793,8 @@ main(int argc, char **argv)
 		}
 		cmdarg = argv[optind + 1];
 	}
+	if (cluster_mode)
+		cluster_mode_activate(progname);
 	rc = cmd->func(cmdarg);
 out:
 	return rc;
diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index 54cd748..759c1b6 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -49,17 +49,46 @@
 #include <unistd.h>
 #include <sqlite3.h>
 #include <linux/limits.h>
+#include <stdlib.h>
+#include <libgen.h>
 
 #include "xlog.h"
 
-#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 2
+#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 3
 
 /* in milliseconds */
 #define CLTRACK_SQLITE_BUSY_TIMEOUT 10000
 
 /* private data structures */
+struct insert_client_args {
+	const unsigned char	*clname;
+	const size_t		namelen;
+	const bool		has_session;
+	const bool		zerotime;
+};
+
+struct remove_client_args {
+	const unsigned char	*clname;
+	const size_t		namelen;
+};
+
+struct check_client_args {
+	const unsigned char	*clname;
+	const size_t		namelen;
+	const bool		has_session;
+};
+
+struct remove_unreclaimed_args {
+	const time_t		grace_start;
+};
+
+struct list {
+	struct list *next;
+	char *name;
+};
 
 /* global variables */
+extern int cluster_mode;
 
 /* reusable pathname and sql command buffer */
 static char buf[PATH_MAX];
@@ -123,7 +152,7 @@ out:
 }
 
 static int
-sqlite_maindb_update_v1_to_v2(void)
+sqlite_maindb_update_v1_to_v3(void)
 {
 	int ret, ret2;
 	char *err;
@@ -164,6 +193,90 @@ sqlite_maindb_update_v1_to_v2(void)
 		goto rollback;
 	}
 
+	/* create the "exports" table */
+	ret = sqlite3_exec(dbh, "CREATE TABLE exports "
+				"(path TEXT PRIMARY KEY); ",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create exports table: %s", err);
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
+static int
+sqlite_maindb_update_v2_to_v3(void)
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
+	case 2:
+		/* Still at v2 -- do conversion */
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
+	/* create the "exports" table */
+	ret = sqlite3_exec(dbh, "CREATE TABLE exports "
+				"(path TEXT PRIMARY KEY); ",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create exports table: %s", err);
+		goto rollback;
+	}
+
 	ret = snprintf(buf, sizeof(buf), "UPDATE parameters SET value = %d "
 			"WHERE key = \"version\";",
 			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION);
@@ -204,7 +317,7 @@ rollback:
  * transaction. On any error, rollback the transaction.
  */
 int
-sqlite_maindb_init_v2(void)
+sqlite_maindb_init_v3(void)
 {
 	int ret, ret2;
 	char *err = NULL;
@@ -253,6 +366,14 @@ sqlite_maindb_init_v2(void)
 		goto rollback;
 	}
 
+	/* create the "exports" table */
+	ret = sqlite3_exec(dbh, "CREATE TABLE exports "
+				"(path TEXT PRIMARY KEY); ",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create exports table: %s", err);
+		goto rollback;
+	}
 
 	/* insert version into parameters table */
 	ret = snprintf(buf, sizeof(buf), "INSERT OR FAIL INTO parameters "
@@ -334,15 +455,21 @@ sqlite_prepare_dbh(const char *topdir)
 		/* DB is already set up. Do nothing */
 		ret = 0;
 		break;
+	case 2:
+		/* Old DB -- update to new schema */
+		ret = sqlite_maindb_update_v2_to_v3();
+		if (ret)
+			goto out_close;
+		break;
 	case 1:
 		/* Old DB -- update to new schema */
-		ret = sqlite_maindb_update_v1_to_v2();
+		ret = sqlite_maindb_update_v1_to_v3();
 		if (ret)
 			goto out_close;
 		break;
 	case 0:
 		/* Query failed -- try to set up new DB */
-		ret = sqlite_maindb_init_v2();
+		ret = sqlite_maindb_init_v3();
 		if (ret)
 			goto out_close;
 		break;
@@ -362,25 +489,252 @@ out_close:
 	return ret;
 }
 
+static int
+sqlite_create_export_db(const char *path)
+{
+	int ret, ret2;
+	sqlite3 *dbh;
+	char *err = NULL;
+	char *dbpath = strdup(path);
+
+	ret = mkdir_if_not_exist(dirname(dbpath));
+	if (ret)
+		goto out;
+
+	ret = sqlite3_open(path, &dbh);
+	if (ret != SQLITE_OK)
+		goto out;
+
+	ret = sqlite3_exec(dbh, "BEGIN EXCLUSIVE TRANSACTION;", NULL, NULL,
+				&err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to begin transaction: %s", err);
+		goto out_dbh;
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
+	ret = sqlite3_exec(dbh, "CREATE TABLE clients (id BLOB PRIMARY KEY, "
+				"time INTEGER, has_session INTEGER);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create clients table: %s", err);
+		goto rollback;
+	}
+
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
+
+out_dbh:
+	sqlite3_free(err);
+	sqlite3_close(dbh);
+	dbh = NULL;
+out:
+	free(dbpath);
+	return ret;
+
+rollback:
+	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	if (ret2 != SQLITE_OK)
+		xlog(L_ERROR, "Unable to rollback transaction: %s", err);
+	goto out_dbh;
+}
+
+static int
+sqlite_attach_db(const char *path)
+{
+	int ret;
+	char dbpath[PATH_MAX];
+	struct stat stb;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = snprintf(dbpath, PATH_MAX - 1, "%s/.nfsdcltrack/main.sqlite", path);
+	if (ret < 0)
+		return ret;
+
+	dbpath[PATH_MAX - 1] = '\0';
+	if (stat(dbpath, &stb) < 0) {
+		if (errno == ENOENT) {
+			xlog(L_WARNING, "%s does not exist, create it!", dbpath);
+			ret = sqlite_create_export_db(dbpath);
+			if (ret) {
+				xlog(L_ERROR, "failed to create %s", dbpath);
+				return ret;
+			}
+		} else {
+			xlog(L_ERROR, "stat of %s failed", buf);
+			return ret;
+		}
+	}
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
+static int
+sqlite_cluster_do(int (*func)(void *, const char *), void *data)
+{
+	int ret;
+	char *err = NULL;
+	sqlite3_stmt *stmt = NULL;
+	struct list *lp = NULL;
+	struct list *l;
+
+	xlog(D_GENERAL, "%s", __func__);
+
+	ret = sqlite3_prepare_v2(dbh, "SELECT * FROM exports;",
+			-1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
+			__func__, sqlite3_errmsg(dbh));
+		goto out_err;
+	}
+
+	ret = sqlite3_step(stmt);
+	while (ret == SQLITE_ROW) {
+		l = malloc(sizeof(*l));
+		memset(l, 0, sizeof(*l));
+		if (l == NULL)
+			return 0;
+		l->name = strdup((char *)sqlite3_column_text(stmt, 0));
+		l->next = lp;
+		lp = l;
+		ret = sqlite3_step(stmt);
+	}
+	if (ret == SQLITE_DONE)
+		ret = SQLITE_OK;
+	else
+		xlog(L_ERROR, "%s: unexpected return code from insert: %s",
+				__func__, sqlite3_errmsg(dbh));
+
+	sqlite3_finalize(stmt);
+	stmt = NULL;
+
+	while (lp) {
+		ret = func(data, lp->name);
+		if (ret != SQLITE_OK)
+			xlog(L_ERROR, "%s: func failed for db %s",
+					__func__, lp->name);
+		l = lp;
+		lp = lp->next;
+		free(l->name);
+		free(l);
+	}
+
+out_err:
+	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
+	sqlite3_free(err);
+	return ret;
+}
+
 /*
  * Create a client record
  *
  * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0)
  */
-int
-sqlite_insert_client(const unsigned char *clname, const size_t namelen,
-			const bool has_session, const bool zerotime)
+static int
+__sqlite_insert_client(void *data, const char *path)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
+	struct insert_client_args *args = data;
+
+	if (path) {
+		ret = sqlite_attach_db(path);
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "%s: failed to attach db for %s",
+					__func__ , path);
+			return ret;
+		}
+	}
 
-	if (zerotime)
-		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
-				"VALUES (?, 0, ?);", -1, &stmt, NULL);
-	else
-		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
-				"VALUES (?, strftime('%s', 'now'), ?);", -1,
-				&stmt, NULL);
+	if (args->zerotime) {
+		if (path)
+			ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE "
+					"INTO attached.clients "
+					"VALUES (?, 0, ?);", -1, &stmt, NULL);
+		else
+			ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE "
+					"INTO clients "
+					"VALUES (?, 0, ?);", -1, &stmt, NULL);
+	} else {
+		if (path)
+			ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE "
+					"INTO attached.clients "
+					"VALUES (?, strftime('%s', 'now'), ?);",
+					-1, &stmt, NULL);
+		else
+			ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE "
+					"INTO clients "
+					"VALUES (?, strftime('%s', 'now'), ?);",
+					-1, &stmt, NULL);
+	}
 
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
@@ -388,15 +742,15 @@ sqlite_insert_client(const unsigned char *clname, const size_t namelen,
 		return ret;
 	}
 
-	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
-				SQLITE_STATIC);
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)args->clname,
+				args->namelen, SQLITE_STATIC);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: bind blob failed: %s", __func__,
 				sqlite3_errmsg(dbh));
 		goto out_err;
 	}
 
-	ret = sqlite3_bind_int(stmt, 2, (int)has_session);
+	ret = sqlite3_bind_int(stmt, 2, (int)args->has_session);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: bind int failed: %s", __func__,
 				sqlite3_errmsg(dbh));
@@ -409,30 +763,75 @@ sqlite_insert_client(const unsigned char *clname, const size_t namelen,
 	else
 		xlog(L_ERROR, "%s: unexpected return code from insert: %s",
 				__func__, sqlite3_errmsg(dbh));
-
 out_err:
+	if (path) {
+		ret = sqlite_detach_db();
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "%s: failed to detach db for %s",
+					__func__ , path);
+		}
+	}
 	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
 	sqlite3_finalize(stmt);
 	return ret;
 }
 
-/* Remove a client record */
+/*
+ * Create a client record
+ *
+ * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0)
+ */
 int
-sqlite_remove_client(const unsigned char *clname, const size_t namelen)
+sqlite_insert_client(const unsigned char *clname, const size_t namelen,
+			const bool has_session, const bool zerotime)
+{
+	int ret;
+	struct insert_client_args args = {
+		.clname = clname,
+		.namelen = namelen,
+		.has_session = has_session,
+		.zerotime = zerotime,
+	};
+
+	ret = __sqlite_insert_client(&args, NULL);
+	if (ret == SQLITE_OK && cluster_mode)
+		sqlite_cluster_do(&__sqlite_insert_client, &args);
+
+	return ret;
+}
+
+/* Remove a client record */
+static int
+__sqlite_remove_client(void *data, const char *path)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
+	struct remove_client_args *args = data;
+
+	if (path) {
+		ret = sqlite_attach_db(path);
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "%s: failed to attach db for %s",
+					__func__ , path);
+			return ret;
+		}
+	}
+
+	if (path)
+		ret = sqlite3_prepare_v2(dbh, "DELETE FROM attached.clients "
+					"WHERE id==?", -1, &stmt, NULL);
+	else
+		ret = sqlite3_prepare_v2(dbh, "DELETE FROM clients "
+					"WHERE id==?", -1, &stmt, NULL);
 
-	ret = sqlite3_prepare_v2(dbh, "DELETE FROM clients WHERE id==?", -1,
-				 &stmt, NULL);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: statement prepare failed: %s",
 				__func__, sqlite3_errmsg(dbh));
 		goto out_err;
 	}
 
-	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
-				SQLITE_STATIC);
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)args->clname,
+				args->namelen, SQLITE_STATIC);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: bind blob failed: %s", __func__,
 				sqlite3_errmsg(dbh));
@@ -447,22 +846,56 @@ sqlite_remove_client(const unsigned char *clname, const size_t namelen)
 				__func__, ret);
 
 out_err:
+	if (path) {
+		ret = sqlite_detach_db();
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "%s: failed to detach db for %s",
+					__func__ , path);
+		}
+	}
 	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
 	sqlite3_finalize(stmt);
 	return ret;
 }
 
+/* Remove a client record */
+int
+sqlite_remove_client(const unsigned char *clname, const size_t namelen)
+{
+	int ret;
+	struct remove_client_args args = {
+		.clname = clname,
+		.namelen = namelen,
+	};
+
+	ret = __sqlite_remove_client(&args, NULL);
+	if (ret == SQLITE_OK && cluster_mode)
+		sqlite_cluster_do(&__sqlite_remove_client, &args);
+
+	return ret;
+}
+
 /*
  * Is the given clname in the clients table? If so, then update its timestamp
  * and return success. If the record isn't present, or the update fails, then
  * return an error.
  */
-int
-sqlite_check_client(const unsigned char *clname, const size_t namelen,
-			const bool has_session)
+static int
+__sqlite_check_client(void *data, const char *path)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
+	struct check_client_args *args = data;
+
+	if (path) {
+		ret = sqlite_attach_db(path);
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "%s: failed to attach db for %s",
+					__func__ , path);
+			return ret;
+		}
+		goto do_update;
+	}
 
 	ret = sqlite3_prepare_v2(dbh, "SELECT count(*) FROM clients WHERE "
 				      "id==?", -1, &stmt, NULL);
@@ -472,8 +905,8 @@ sqlite_check_client(const unsigned char *clname, const size_t namelen,
 		goto out_err;
 	}
 
-	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
-				SQLITE_STATIC);
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)args->clname,
+				args->namelen, SQLITE_STATIC);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: bind blob failed: %s",
 				__func__, sqlite3_errmsg(dbh));
@@ -494,25 +927,32 @@ sqlite_check_client(const unsigned char *clname, const size_t namelen,
 		goto out_err;
 	}
 
+do_update:
 	/* Only update timestamp for v4.0 clients */
-	if (has_session) {
+	if (args->has_session) {
 		ret = SQLITE_OK;
 		goto out_err;
 	}
 
 	sqlite3_finalize(stmt);
 	stmt = NULL;
-	ret = sqlite3_prepare_v2(dbh, "UPDATE OR FAIL clients SET "
-				      "time=strftime('%s', 'now') WHERE id==?",
-				 -1, &stmt, NULL);
+	if (path)
+		ret = sqlite3_prepare_v2(dbh, "UPDATE OR FAIL attached.clients "
+					"SET time=strftime('%s', 'now') "
+					"WHERE id==?", -1, &stmt, NULL);
+	else
+		ret = sqlite3_prepare_v2(dbh, "UPDATE OR FAIL clients "
+					"SET time=strftime('%s', 'now') "
+					"WHERE id==?", -1, &stmt, NULL);
+
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: unable to prepare update statement: %s",
 				__func__, sqlite3_errmsg(dbh));
 		goto out_err;
 	}
 
-	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
-				SQLITE_STATIC);
+	ret = sqlite3_bind_blob(stmt, 1, (const void *)args->clname,
+				args->namelen, SQLITE_STATIC);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: bind blob failed: %s",
 				__func__, sqlite3_errmsg(dbh));
@@ -527,22 +967,67 @@ sqlite_check_client(const unsigned char *clname, const size_t namelen,
 				__func__, sqlite3_errmsg(dbh));
 
 out_err:
+	if (path) {
+		ret = sqlite_detach_db();
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "%s: failed to detach db for %s",
+					__func__ , path);
+		}
+	}
 	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
 	sqlite3_finalize(stmt);
 	return ret;
 }
 
 /*
- * remove any client records that were not reclaimed since grace_start.
+ * Is the given clname in the clients table? If so, then update its timestamp
+ * and return success. If the record isn't present, or the update fails, then
+ * return an error.
  */
 int
-sqlite_remove_unreclaimed(time_t grace_start)
+sqlite_check_client(const unsigned char *clname, const size_t namelen,
+			const bool has_session)
+{
+	int ret;
+	struct check_client_args args = {
+		.clname = clname,
+		.namelen = namelen,
+		.has_session = has_session,
+	};
+
+	ret = __sqlite_check_client(&args, NULL);
+	if (ret == SQLITE_OK && cluster_mode)
+		sqlite_cluster_do(&__sqlite_check_client, &args);
+
+	return ret;
+}
+
+/*
+ * remove any client records that were not reclaimed since grace_start.
+ */
+static int
+__sqlite_remove_unreclaimed(void *data, const char *path)
 {
 	int ret;
 	char *err = NULL;
+	struct remove_unreclaimed_args *args = data;
+
+	if (path) {
+		ret = sqlite_attach_db(path);
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "%s: failed to attach db for %s",
+					__func__ , path);
+			return ret;
+		}
+	}
+
+	if (path)
+		ret = snprintf(buf, sizeof(buf), "DELETE FROM attached.clients "
+				"WHERE time < %ld", args->grace_start);
+	else
+		ret = snprintf(buf, sizeof(buf), "DELETE FROM clients "
+				"WHERE time < %ld", args->grace_start);
 
-	ret = snprintf(buf, sizeof(buf), "DELETE FROM clients WHERE time < %ld",
-			grace_start);
 	if (ret < 0) {
 		return ret;
 	} else if ((size_t)ret >= sizeof(buf)) {
@@ -554,12 +1039,38 @@ sqlite_remove_unreclaimed(time_t grace_start)
 	if (ret != SQLITE_OK)
 		xlog(L_ERROR, "%s: delete failed: %s", __func__, err);
 
+	if (path) {
+		ret = sqlite_detach_db();
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "%s: failed to detach db for %s",
+					__func__ , path);
+		}
+	}
+
 	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
 	sqlite3_free(err);
 	return ret;
 }
 
 /*
+ * remove any client records that were not reclaimed since grace_start.
+ */
+int
+sqlite_remove_unreclaimed(time_t grace_start)
+{
+	int ret;
+	struct remove_unreclaimed_args args = {
+		.grace_start = grace_start,
+	};
+
+	ret = __sqlite_remove_unreclaimed(&args, NULL);
+	if (ret == SQLITE_OK && cluster_mode)
+		sqlite_cluster_do(&__sqlite_remove_unreclaimed, &args);
+
+	return ret;
+}
+
+/*
  * Are there any clients that are possibly still reclaiming? Return a positive
  * integer (usually number of clients) if so. If not, then return 0. On any
  * error, return non-zero.
@@ -598,3 +1109,233 @@ sqlite_query_reclaiming(const time_t grace_start)
 			"reclaim", __func__, ret);
 	return ret;
 }
+
+long
+sqlite_query_etab_inode(void)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh,
+		"SELECT value FROM parameters WHERE key == \"etab_inode\";",
+		 -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to prepare select statement: %s",
+			sqlite3_errmsg(dbh));
+		ret = 0;
+		goto out;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(L_ERROR, "Select statement execution failed: %s",
+				sqlite3_errmsg(dbh));
+		ret = 0;
+		goto out;
+	}
+
+	ret = sqlite3_column_int64(stmt, 0);
+out:
+	sqlite3_finalize(stmt);
+	return ret;
+}
+
+int
+sqlite_create_temp_exports(void)
+{
+	int ret;
+	char *err;
+
+	ret = sqlite3_exec(dbh, "CREATE TEMPORARY TABLE exports "
+				"(path TEXT PRIMARY KEY); ",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create temp exports table: %s", err);
+	}
+
+	sqlite3_free(err);
+	return ret;
+}
+
+void
+sqlite_drop_temp_exports(void)
+{
+	char *err;
+
+	sqlite3_exec(dbh, "DROP TABLE IF EXISTS temp.exports;",
+				NULL, NULL, &err);
+
+	sqlite3_free(err);
+}
+
+int sqlite_insert_temp_export(const char *path)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh, "INSERT OR IGNORE INTO temp.exports "
+			"VALUES (?);", -1, &stmt, NULL);
+
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
+			__func__, sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	ret = sqlite3_bind_text(stmt, 1, path, strlen(path), SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind text failed: %s", __func__,
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
+int
+sqlite_update_exports(const long ino)
+{
+	int ret, ret2;
+	char *err = NULL;
+
+	ret = sqlite3_exec(dbh, "BEGIN EXCLUSIVE TRANSACTION;", NULL, NULL,
+				&err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to begin transaction: %s", err);
+		return ret;
+	}
+
+	ret = sqlite3_exec(dbh, "DELETE FROM main.exports;",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to delete current exports: %s", err);
+		goto rollback;
+	}
+
+	ret = sqlite3_exec(dbh, "INSERT INTO main.exports "
+				"SELECT * from temp.exports;",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to copy from temp exports: %s", err);
+		goto rollback;
+	}
+
+	ret = snprintf(buf, sizeof(buf), "INSERT OR REPLACE INTO parameters "
+			"values (\"etab_inode\", \"%ld\");", ino);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		ret = -EINVAL;
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
+
+out:
+	sqlite3_free(err);
+	return ret;
+
+rollback:
+	ret2 = sqlite3_exec(dbh, "ROLLBACK TRANSACTION;", NULL, NULL, &err);
+	if (ret2 != SQLITE_OK)
+		xlog(L_ERROR, "Unable to rollback transaction: %s", err);
+	goto out;
+}
+
+int
+sqlite_export_exists(const char *path)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+
+	ret = sqlite3_prepare_v2(dbh, "SELECT count(*) FROM main.exports WHERE "
+				      "path = ?;", -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: unable to prepare select statement: %s",
+				__func__, sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	ret = sqlite3_bind_text(stmt, 1, path, strlen(path), SQLITE_STATIC);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: bind text failed: %s",
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
+	xlog(D_GENERAL, "%s: export %s %s", __func__, path,
+			ret ? "exists" : "does not exist");
+	return ret;
+}
+
+int
+sqlite_merge_client_records(const char *path)
+{
+	int ret;
+	char *err = NULL;
+
+	ret = sqlite_attach_db(path);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: failed to attach db for %s",
+				__func__ , path);
+		return ret;
+	}
+
+	ret = sqlite3_exec(dbh, "INSERT OR IGNORE INTO main.clients "
+				"SELECT * from attached.clients;",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to merge client records "
+				"from attached db: %s", err);
+		goto out;
+	}
+
+	ret = sqlite3_exec(dbh, "DELETE FROM attached.clients;",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to delete client records "
+				"from attached db: %s", err);
+		goto out;
+	}
+
+out:
+	ret = sqlite_detach_db();
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: failed to detach db for %s",
+				__func__ , path);
+	}
+	sqlite3_free(err);
+	return ret;
+}
diff --git a/utils/nfsdcltrack/sqlite.h b/utils/nfsdcltrack/sqlite.h
index 06e7c04..e21a568 100644
--- a/utils/nfsdcltrack/sqlite.h
+++ b/utils/nfsdcltrack/sqlite.h
@@ -29,4 +29,12 @@ int sqlite_check_client(const unsigned char *clname, const size_t namelen,
 int sqlite_remove_unreclaimed(const time_t grace_start);
 int sqlite_query_reclaiming(const time_t grace_start);
 
+long sqlite_query_etab_inode(void);
+int sqlite_create_temp_exports(void);
+void sqlite_drop_temp_exports(void);
+int sqlite_insert_temp_export(const char *path);
+int sqlite_update_exports(const long ino);
+int sqlite_export_exists(const char *path);
+int sqlite_merge_client_records(const char *path);
+
 #endif /* _SQLITE_H */
-- 
2.9.3

