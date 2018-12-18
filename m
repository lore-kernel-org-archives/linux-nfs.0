Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6932C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 66BA821871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727055AbeLROaU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:30:20 -0500
Received: from mx1.redhat.com ([209.132.183.28]:53854 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726852AbeLROaU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:30:20 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5DE82BCD29;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E38925D6A6;
        Tue, 18 Dec 2018 14:30:18 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 8E96420DC6; Tue, 18 Dec 2018 09:30:18 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 3/7] nfsdcld: a few enhancements
Date:   Tue, 18 Dec 2018 09:30:14 -0500
Message-Id: <20181218143018.28575-4-smayhew@redhat.com>
In-Reply-To: <20181218143018.28575-1-smayhew@redhat.com>
References: <20181218143018.28575-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

1) Adopt the concept of "reboot epochs" (but not coordinated grace
periods via the "need" and "enforcing" flags) from Jeff Layton's
"Active/Active NFS Server Recovery" presentation from the Fall 2018 NFS
Bakeathon.  See
http://nfsv4bat.org/Documents/BakeAThon/2018/Active_Active%20NFS%20Server%20Recovery.pdf

- add a new table "grace" which contains two integer columns
  representing the "current" epoch (where new client records are stored)
  and the "recovery" epoch (which has the records for clients that are
  allowed to recover)
- replace the "clients" table with table(s) named "rec-CCCCCCCCCCCCCCCC"
  (where C is the hex value of the epoch), containing a single column
  "id" which stores the client id string
- when going from normal operation into grace, the current epoch becomes
  the recovery epoch, the current epoch is incremented, and a new table
  is created for the current epoch.  Clients are allowed to reclaim if
  they have a record in the table corresponding to the recovery epoch
  and new records are added to the table corresponding to the current
  epoch.
- when moving from grace back to normal operation, the table associated
  with the recovery epoch is deleted and the recovery epoch becomes
  zero.
- if the server restarts before exiting the previous grace period, then
  the epochs are not changed, and all records in the table associated
  with the "current" epoch are cleared out.

2) Allow knfsd to "slurp" the client records during startup.

During client tracking initialization, knfsd will do an upcall to get a
list of clients from the database.  nfsdcld will do one downcall with a
status of -EINPROGRESS for each client record in the database, followed
by a final downcall with a status of 0.  This will allow 2 things

- knfsd can check whether a client is allowed to reclaim without
  performing an upcall to nfsdcld
- knfsd can decide to end the grace period early by tracking the number
  of RECLAIM_COMPLETE operations it receives from "known" clients, or
  it can skip the grace period altogether if no clients are allowed
  to reclaim.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/include/cld.h        |   1 +
 utils/nfsdcld/Makefile.am    |   2 +-
 utils/nfsdcld/cld-internal.h |  30 +++
 utils/nfsdcld/nfsdcld.c      | 160 +++++++++++-
 utils/nfsdcld/sqlite.c       | 483 ++++++++++++++++++++++++++++-------
 utils/nfsdcld/sqlite.h       |  11 +-
 6 files changed, 579 insertions(+), 108 deletions(-)
 create mode 100644 utils/nfsdcld/cld-internal.h

diff --git a/support/include/cld.h b/support/include/cld.h
index f14a9ab..c1f5b70 100644
--- a/support/include/cld.h
+++ b/support/include/cld.h
@@ -33,6 +33,7 @@ enum cld_command {
 	Cld_Remove,		/* remove record of this cm_id */
 	Cld_Check,		/* is this cm_id allowed? */
 	Cld_GraceDone,		/* grace period is complete */
+	Cld_GraceStart,
 };
 
 /* representation of long-form NFSv4 client ID */
diff --git a/utils/nfsdcld/Makefile.am b/utils/nfsdcld/Makefile.am
index 8239be8..d1da749 100644
--- a/utils/nfsdcld/Makefile.am
+++ b/utils/nfsdcld/Makefile.am
@@ -13,7 +13,7 @@ sbin_PROGRAMS	= nfsdcld
 nfsdcld_SOURCES = nfsdcld.c sqlite.c
 nfsdcld_LDADD = ../../support/nfs/libnfs.la $(LIBEVENT) $(LIBSQLITE) $(LIBCAP)
 
-noinst_HEADERS	= sqlite.h
+noinst_HEADERS	= sqlite.h cld-internal.h
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/nfsdcld/cld-internal.h b/utils/nfsdcld/cld-internal.h
new file mode 100644
index 0000000..a90cced
--- /dev/null
+++ b/utils/nfsdcld/cld-internal.h
@@ -0,0 +1,30 @@
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
+#ifndef _CLD_INTERNAL_H_
+#define _CLD_INTERNAL_H_
+
+struct cld_client {
+	int			cl_fd;
+	struct event		cl_event;
+	struct cld_msg	cl_msg;
+};
+
+uint64_t current_epoch;
+uint64_t recovery_epoch;
+
+#endif /* _CLD_INTERNAL_H_ */
diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 082f3ab..9b1ad98 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -42,7 +42,9 @@
 #include "xlog.h"
 #include "nfslib.h"
 #include "cld.h"
+#include "cld-internal.h"
 #include "sqlite.h"
+#include "../mount/version.h"
 
 #ifndef PIPEFS_DIR
 #define PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
@@ -54,19 +56,17 @@
 #define CLD_DEFAULT_STORAGEDIR NFS_STATEDIR "/nfsdcld"
 #endif
 
+#define NFSD_END_GRACE_FILE "/proc/fs/nfsd/v4_end_grace"
+
 #define UPCALL_VERSION		1
 
 /* private data structures */
-struct cld_client {
-	int			cl_fd;
-	struct event		cl_event;
-	struct cld_msg	cl_msg;
-};
 
 /* global variables */
 static char *pipepath = DEFAULT_CLD_PATH;
 static int 		inotify_fd = -1;
 static struct event	pipedir_event;
+static bool old_kernel = false;
 
 static struct option longopts[] =
 {
@@ -298,6 +298,43 @@ out:
 	return ret;
 }
 
+/*
+ * Older kernels will not tell nfsdcld when a grace period has started.
+ * Therefore we have to peek at the /proc/fs/nfsd/v4_end_grace file to
+ * see if nfsd is in grace.  We have to do this for create and remove
+ * upcalls to ensure that the correct table is being updated - otherwise
+ * we could lose client records when the grace period is lifted.
+ */
+static int
+cld_check_grace_period(void)
+{
+	int fd, ret = 0;
+	char c;
+
+	if (!old_kernel)
+		return 0;
+	if (recovery_epoch != 0)
+		return 0;
+	fd = open(NFSD_END_GRACE_FILE, O_RDONLY);
+	if (fd < 0) {
+		xlog(L_WARNING, "Unable to open %s: %m",
+			NFSD_END_GRACE_FILE);
+		return 1;
+	}
+	if (read(fd, &c, 1) < 0) {
+		xlog(L_WARNING, "Unable to read from %s: %m",
+			NFSD_END_GRACE_FILE);
+		return 1;
+	}
+	close(fd);
+	if (c == 'N') {
+		xlog(L_WARNING, "nfsd is in grace but didn't send a gracestart upcall, "
+			"please update the kernel");
+		ret = sqlite_grace_start();
+	}
+	return ret;
+}
+
 static void
 cld_not_implemented(struct cld_client *clnt)
 {
@@ -332,14 +369,17 @@ cld_create(struct cld_client *clnt)
 	ssize_t bsize, wsize;
 	struct cld_msg *cmsg = &clnt->cl_msg;
 
+	ret = cld_check_grace_period();
+	if (ret)
+		goto reply;
+
 	xlog(D_GENERAL, "%s: create client record.", __func__);
 
 
 	ret = sqlite_insert_client(cmsg->cm_u.cm_name.cn_id,
-				   cmsg->cm_u.cm_name.cn_len,
-				   false,
-				   false);
+				   cmsg->cm_u.cm_name.cn_len);
 
+reply:
 	cmsg->cm_status = ret ? -EREMOTEIO : ret;
 
 	bsize = sizeof(*cmsg);
@@ -365,11 +405,16 @@ cld_remove(struct cld_client *clnt)
 	ssize_t bsize, wsize;
 	struct cld_msg *cmsg = &clnt->cl_msg;
 
+	ret = cld_check_grace_period();
+	if (ret)
+		goto reply;
+
 	xlog(D_GENERAL, "%s: remove client record.", __func__);
 
 	ret = sqlite_remove_client(cmsg->cm_u.cm_name.cn_id,
 				   cmsg->cm_u.cm_name.cn_len);
 
+reply:
 	cmsg->cm_status = ret ? -EREMOTEIO : ret;
 
 	bsize = sizeof(*cmsg);
@@ -396,12 +441,26 @@ cld_check(struct cld_client *clnt)
 	ssize_t bsize, wsize;
 	struct cld_msg *cmsg = &clnt->cl_msg;
 
+	/*
+	 * If we get a check upcall at all, it means we're talking to an old
+	 * kernel.  Furthermore, if we're not in grace it means this is the
+	 * first client to do a reclaim.  Log a message and use
+	 * sqlite_grace_start() to advance the epoch numbers.
+	 */
+	if (recovery_epoch == 0) {
+		xlog(D_GENERAL, "%s: received a check upcall, please update the kernel",
+			__func__);
+		ret = sqlite_grace_start();
+		if (ret)
+			goto reply;
+	}
+
 	xlog(D_GENERAL, "%s: check client record", __func__);
 
 	ret = sqlite_check_client(cmsg->cm_u.cm_name.cn_id,
-				  cmsg->cm_u.cm_name.cn_len,
-				  false);
+				  cmsg->cm_u.cm_name.cn_len);
 
+reply:
 	/* set up reply */
 	cmsg->cm_status = ret ? -EACCES : ret;
 
@@ -429,11 +488,27 @@ cld_gracedone(struct cld_client *clnt)
 	ssize_t bsize, wsize;
 	struct cld_msg *cmsg = &clnt->cl_msg;
 
-	xlog(D_GENERAL, "%s: grace done. cm_gracetime=%ld", __func__,
-			cmsg->cm_u.cm_gracetime);
+	/*
+	 * If we got a "gracedone" upcall while we're not in grace, then
+	 * 1) we must be talking to an old kernel
+	 * 2) no clients attempted to reclaim
+	 * In that case, log a message and use sqlite_grace_start() to
+	 * advance the epoch numbers, and then proceed as normal.
+	 */
+	if (recovery_epoch == 0) {
+		xlog(D_GENERAL, "%s: received gracedone upcall "
+			"while not in grace, please update the kernel",
+			__func__);
+		ret = sqlite_grace_start();
+		if (ret)
+			goto reply;
+	}
+
+	xlog(D_GENERAL, "%s: grace done.", __func__);
 
-	ret = sqlite_remove_unreclaimed(cmsg->cm_u.cm_gracetime);
+	ret = sqlite_grace_done();
 
+reply:
 	/* set up reply: downcall with 0 status */
 	cmsg->cm_status = ret ? -EREMOTEIO : ret;
 
@@ -453,6 +528,59 @@ cld_gracedone(struct cld_client *clnt)
 	}
 }
 
+static int
+gracestart_callback(struct cld_client *clnt) {
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	cmsg->cm_status = -EINPROGRESS;
+
+	bsize = sizeof(struct cld_msg);
+
+	xlog(D_GENERAL, "Sending client %.*s",
+			cmsg->cm_u.cm_name.cn_len, cmsg->cm_u.cm_name.cn_id);
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize)
+		return -EIO;
+	return 0;
+}
+
+static void
+cld_gracestart(struct cld_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: updating grace epochs", __func__);
+
+	ret = sqlite_grace_start();
+	if (ret)
+		goto reply;
+
+	xlog(D_GENERAL, "%s: sending client records to the kernel", __func__);
+
+	ret = sqlite_iterate_recovery(&gracestart_callback, clnt);
+
+reply:
+	/* set up reply: downcall with 0 status */
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
+
+	bsize = sizeof(struct cld_msg);
+	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize) {
+		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
+			 __func__, wsize);
+		ret = cld_pipe_open(clnt);
+		if (ret) {
+			xlog(L_FATAL, "%s: unable to reopen pipe: %d",
+					__func__, ret);
+			exit(ret);
+		}
+	}
+}
+
 static void
 cldcb(int UNUSED(fd), short which, void *data)
 {
@@ -490,6 +618,9 @@ cldcb(int UNUSED(fd), short which, void *data)
 	case Cld_GraceDone:
 		cld_gracedone(clnt);
 		break;
+	case Cld_GraceStart:
+		cld_gracestart(clnt);
+		break;
 	default:
 		xlog(L_WARNING, "%s: command %u is not yet implemented",
 				__func__, cmsg->cm_cmd);
@@ -586,6 +717,9 @@ main(int argc, char **argv)
 		}
 	}
 
+	if (linux_version_code() < MAKE_VERSION(4, 20, 0))
+		old_kernel = true;
+
 	/* set up storage db */
 	rc = sqlite_prepare_dbh(storagedir);
 	if (rc) {
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
index c59f777..82140ea 100644
--- a/utils/nfsdcld/sqlite.c
+++ b/utils/nfsdcld/sqlite.c
@@ -21,17 +21,24 @@
  * Explanation:
  *
  * This file contains the code to manage the sqlite backend database for the
- * nfsdcltrack usermodehelper upcall program.
+ * nfsdcld client tracking daemon.
  *
  * The main database is called main.sqlite and contains the following tables:
  *
  * parameters: simple key/value pairs for storing database info
  *
- * clients: an "id" column containing a BLOB with the long-form clientid as
- * 	    sent by the client, a "time" column containing a timestamp (in
- * 	    epoch seconds) of when the record was last updated, and a
- * 	    "has_session" column containing a boolean value indicating
- * 	    whether the client has sessions (v4.1+) or not (v4.0).
+ * grace: a "current" column containing an INTEGER representing the current
+ *        epoch (where should new values be stored) and a "recovery" column
+ *        containing an INTEGER representing the recovery epoch (from what
+ *        epoch are we allowed to recover).  A recovery epoch of 0 means
+ *        normal operation (grace period not in force).  Note: sqlite stores
+ *        integers as signed values, so these must be cast to a uint64_t when
+ *        retrieving them from the database and back to an int64_t when storing
+ *        them in the database.
+ *
+ * rec-CCCCCCCCCCCCCCCC (where C is the hex representation of the epoch value):
+ *        a single "id" column containing a BLOB with the long-form clientid
+ *        as sent by the client.
  */
 
 #ifdef HAVE_CONFIG_H
@@ -47,16 +54,21 @@
 #include <sys/types.h>
 #include <fcntl.h>
 #include <unistd.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <limits.h>
 #include <sqlite3.h>
 #include <linux/limits.h>
 
 #include "xlog.h"
 #include "sqlite.h"
+#include "cld.h"
+#include "cld-internal.h"
 
-#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 2
+#define CLD_SQLITE_LATEST_SCHEMA_VERSION 3
 
 /* in milliseconds */
-#define CLTRACK_SQLITE_BUSY_TIMEOUT 10000
+#define CLD_SQLITE_BUSY_TIMEOUT 10000
 
 /* private data structures */
 
@@ -124,7 +136,7 @@ out:
 }
 
 static int
-sqlite_maindb_update_v1_to_v2(void)
+sqlite_maindb_update_schema(int oldversion)
 {
 	int ret, ret2;
 	char *err;
@@ -142,32 +154,66 @@ sqlite_maindb_update_v1_to_v2(void)
 	 * transaction to guard against racing DB setup attempts
 	 */
 	ret = sqlite_query_schema_version();
-	switch (ret) {
-	case 1:
-		/* Still at v1 -- do conversion */
-		break;
-	case CLTRACK_SQLITE_LATEST_SCHEMA_VERSION:
-		/* Someone else raced in and set it up */
-		ret = 0;
+	if (ret != oldversion) {
+		if (ret == CLD_SQLITE_LATEST_SCHEMA_VERSION)
+			/* Someone else raced in and set it up */
+			ret = 0;
+		else
+			/* Something went wrong -- fail! */
+			ret = -EINVAL;
 		goto rollback;
-	default:
-		/* Something went wrong -- fail! */
-		ret = -EINVAL;
+	}
+
+	/* Still at old version -- do conversion */
+
+	/* create grace table */
+	ret = sqlite3_exec(dbh, "CREATE TABLE grace "
+				"(current INTEGER , recovery INTEGER);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create grace table: %s", err);
+		goto rollback;
+	}
+
+	/* insert initial epochs into grace table */
+	ret = sqlite3_exec(dbh, "INSERT OR FAIL INTO grace "
+				"values (1, 0);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to set initial epochs: %s", err);
+		goto rollback;
+	}
+
+	/* create recovery table for current epoch */
+	ret = sqlite3_exec(dbh, "CREATE TABLE \"rec-0000000000000001\" "
+				"(id BLOB PRIMARY KEY);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create recovery table "
+				"for current epoch: %s", err);
+		goto rollback;
+	}
+
+	/* copy records from old clients table */
+	ret = sqlite3_exec(dbh, "INSERT INTO \"rec-0000000000000001\" "
+				"SELECT id FROM clients;",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to copy client records: %s", err);
 		goto rollback;
 	}
 
-	/* create v2 clients table */
-	ret = sqlite3_exec(dbh, "ALTER TABLE clients ADD COLUMN "
-				"has_session INTEGER;",
+	/* drop the old clients table */
+	ret = sqlite3_exec(dbh, "DROP TABLE clients;",
 				NULL, NULL, &err);
 	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "Unable to update clients table: %s", err);
+		xlog(L_ERROR, "Unable to drop old clients table: %s", err);
 		goto rollback;
 	}
 
 	ret = snprintf(buf, sizeof(buf), "UPDATE parameters SET value = %d "
 			"WHERE key = \"version\";",
-			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION);
+			CLD_SQLITE_LATEST_SCHEMA_VERSION);
 	if (ret < 0) {
 		xlog(L_ERROR, "sprintf failed!");
 		goto rollback;
@@ -205,7 +251,7 @@ rollback:
  * transaction. On any error, rollback the transaction.
  */
 static int
-sqlite_maindb_init_v2(void)
+sqlite_maindb_init_v3(void)
 {
 	int ret, ret2;
 	char *err = NULL;
@@ -227,7 +273,7 @@ sqlite_maindb_init_v2(void)
 	case 0:
 		/* Query failed again -- set up DB */
 		break;
-	case CLTRACK_SQLITE_LATEST_SCHEMA_VERSION:
+	case CLD_SQLITE_LATEST_SCHEMA_VERSION:
 		/* Someone else raced in and set it up */
 		ret = 0;
 		goto rollback;
@@ -245,20 +291,38 @@ sqlite_maindb_init_v2(void)
 		goto rollback;
 	}
 
-	/* create the "clients" table */
-	ret = sqlite3_exec(dbh, "CREATE TABLE clients (id BLOB PRIMARY KEY, "
-				"time INTEGER, has_session INTEGER);",
+	/* create grace table */
+	ret = sqlite3_exec(dbh, "CREATE TABLE grace "
+				"(current INTEGER , recovery INTEGER);",
 				NULL, NULL, &err);
 	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "Unable to create clients table: %s", err);
+		xlog(L_ERROR, "Unable to create grace table: %s", err);
 		goto rollback;
 	}
 
+	/* insert initial epochs into grace table */
+	ret = sqlite3_exec(dbh, "INSERT OR FAIL INTO grace "
+				"values (1, 0);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to set initial epochs: %s", err);
+		goto rollback;
+	}
+
+	/* create recovery table for current epoch */
+	ret = sqlite3_exec(dbh, "CREATE TABLE \"rec-0000000000000001\" "
+				"(id BLOB PRIMARY KEY);",
+				NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to create recovery table "
+				"for current epoch: %s", err);
+		goto rollback;
+	}
 
 	/* insert version into parameters table */
 	ret = snprintf(buf, sizeof(buf), "INSERT OR FAIL INTO parameters "
 			"values (\"version\", \"%d\");",
-			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION);
+			CLD_SQLITE_LATEST_SCHEMA_VERSION);
 	if (ret < 0) {
 		xlog(L_ERROR, "sprintf failed!");
 		goto rollback;
@@ -291,6 +355,42 @@ rollback:
 	goto out;
 }
 
+static int
+sqlite_startup_query_grace(void)
+{
+	int ret;
+	uint64_t tcur;
+	uint64_t trec;
+	sqlite3_stmt *stmt = NULL;
+
+	/* prepare select query */
+	ret = sqlite3_prepare_v2(dbh, "SELECT * FROM grace;", -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(D_GENERAL, "Unable to prepare select statement: %s",
+			sqlite3_errmsg(dbh));
+		goto out;
+	}
+
+	ret = sqlite3_step(stmt);
+	if (ret != SQLITE_ROW) {
+		xlog(D_GENERAL, "Select statement execution failed: %s",
+				sqlite3_errmsg(dbh));
+		goto out;
+	}
+
+	tcur = (uint64_t)sqlite3_column_int64(stmt, 0);
+	trec = (uint64_t)sqlite3_column_int64(stmt, 1);
+
+	current_epoch = tcur;
+	recovery_epoch = trec;
+	ret = 0;
+	xlog(D_GENERAL, "%s: current_epoch=%lu recovery_epoch=%lu",
+		__func__, current_epoch, recovery_epoch);
+out:
+	sqlite3_finalize(stmt);
+	return ret;
+}
+
 /* Open the database and set up the database handle for it */
 int
 sqlite_prepare_dbh(const char *topdir)
@@ -322,7 +422,7 @@ sqlite_prepare_dbh(const char *topdir)
 	}
 
 	/* set busy timeout */
-	ret = sqlite3_busy_timeout(dbh, CLTRACK_SQLITE_BUSY_TIMEOUT);
+	ret = sqlite3_busy_timeout(dbh, CLD_SQLITE_BUSY_TIMEOUT);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "Unable to set sqlite busy timeout: %s",
 				sqlite3_errmsg(dbh));
@@ -331,19 +431,26 @@ sqlite_prepare_dbh(const char *topdir)
 
 	ret = sqlite_query_schema_version();
 	switch (ret) {
-	case CLTRACK_SQLITE_LATEST_SCHEMA_VERSION:
+	case CLD_SQLITE_LATEST_SCHEMA_VERSION:
 		/* DB is already set up. Do nothing */
 		ret = 0;
 		break;
+	case 2:
+		/* Old DB -- update to new schema */
+		ret = sqlite_maindb_update_schema(2);
+		if (ret)
+			goto out_close;
+		break;
+
 	case 1:
 		/* Old DB -- update to new schema */
-		ret = sqlite_maindb_update_v1_to_v2();
+		ret = sqlite_maindb_update_schema(1);
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
@@ -351,11 +458,13 @@ sqlite_prepare_dbh(const char *topdir)
 		/* Unknown DB version -- downgrade? Fail */
 		xlog(L_ERROR, "Unsupported database schema version! "
 			"Expected %d, got %d.",
-			CLTRACK_SQLITE_LATEST_SCHEMA_VERSION, ret);
+			CLD_SQLITE_LATEST_SCHEMA_VERSION, ret);
 		ret = -EINVAL;
 		goto out_close;
 	}
 
+	ret = sqlite_startup_query_grace();
+
 	return ret;
 out_close:
 	sqlite3_close(dbh);
@@ -369,20 +478,22 @@ out_close:
  * Returns a non-zero sqlite error code, or SQLITE_OK (aka 0)
  */
 int
-sqlite_insert_client(const unsigned char *clname, const size_t namelen,
-			const bool has_session, const bool zerotime)
+sqlite_insert_client(const unsigned char *clname, const size_t namelen)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
 
-	if (zerotime)
-		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
-				"VALUES (?, 0, ?);", -1, &stmt, NULL);
-	else
-		ret = sqlite3_prepare_v2(dbh, "INSERT OR REPLACE INTO clients "
-				"VALUES (?, strftime('%s', 'now'), ?);", -1,
-				&stmt, NULL);
+	ret = snprintf(buf, sizeof(buf), "INSERT OR REPLACE INTO \"rec-%016lx\" "
+				"VALUES (?);", current_epoch);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		return ret;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+		return -EINVAL;
+	}
 
+	ret = sqlite3_prepare_v2(dbh, buf, -1, &stmt, NULL);
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: insert statement prepare failed: %s",
 			__func__, sqlite3_errmsg(dbh));
@@ -397,13 +508,6 @@ sqlite_insert_client(const unsigned char *clname, const size_t namelen,
 		goto out_err;
 	}
 
-	ret = sqlite3_bind_int(stmt, 2, (int)has_session);
-	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "%s: bind int failed: %s", __func__,
-				sqlite3_errmsg(dbh));
-		goto out_err;
-	}
-
 	ret = sqlite3_step(stmt);
 	if (ret == SQLITE_DONE)
 		ret = SQLITE_OK;
@@ -424,8 +528,18 @@ sqlite_remove_client(const unsigned char *clname, const size_t namelen)
 	int ret;
 	sqlite3_stmt *stmt = NULL;
 
-	ret = sqlite3_prepare_v2(dbh, "DELETE FROM clients WHERE id==?", -1,
-				 &stmt, NULL);
+	ret = snprintf(buf, sizeof(buf), "DELETE FROM \"rec-%016lx\" "
+				"WHERE id==?;", current_epoch);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		return ret;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+		return -EINVAL;
+	}
+
+	ret = sqlite3_prepare_v2(dbh, buf, -1, &stmt, NULL);
+
 	if (ret != SQLITE_OK) {
 		xlog(L_ERROR, "%s: statement prepare failed: %s",
 				__func__, sqlite3_errmsg(dbh));
@@ -459,18 +573,26 @@ out_err:
  * return an error.
  */
 int
-sqlite_check_client(const unsigned char *clname, const size_t namelen,
-			const bool has_session)
+sqlite_check_client(const unsigned char *clname, const size_t namelen)
 {
 	int ret;
 	sqlite3_stmt *stmt = NULL;
 
-	ret = sqlite3_prepare_v2(dbh, "SELECT count(*) FROM clients WHERE "
-				      "id==?", -1, &stmt, NULL);
+	ret = snprintf(buf, sizeof(buf), "SELECT count(*) FROM  \"rec-%016lx\" "
+				"WHERE id==?;", recovery_epoch);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		return ret;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+		return -EINVAL;
+	}
+
+	ret = sqlite3_prepare_v2(dbh, buf, -1, &stmt, NULL);
 	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "%s: unable to prepare update statement: %s",
-				__func__, sqlite3_errmsg(dbh));
-		goto out_err;
+		xlog(L_ERROR, "%s: select statement prepare failed: %s",
+			__func__, sqlite3_errmsg(dbh));
+		return ret;
 	}
 
 	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
@@ -495,37 +617,10 @@ sqlite_check_client(const unsigned char *clname, const size_t namelen,
 		goto out_err;
 	}
 
-	/* Only update timestamp for v4.0 clients */
-	if (has_session) {
-		ret = SQLITE_OK;
-		goto out_err;
-	}
-
 	sqlite3_finalize(stmt);
-	stmt = NULL;
-	ret = sqlite3_prepare_v2(dbh, "UPDATE OR FAIL clients SET "
-				      "time=strftime('%s', 'now') WHERE id==?",
-				 -1, &stmt, NULL);
-	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "%s: unable to prepare update statement: %s",
-				__func__, sqlite3_errmsg(dbh));
-		goto out_err;
-	}
 
-	ret = sqlite3_bind_blob(stmt, 1, (const void *)clname, namelen,
-				SQLITE_STATIC);
-	if (ret != SQLITE_OK) {
-		xlog(L_ERROR, "%s: bind blob failed: %s",
-				__func__, sqlite3_errmsg(dbh));
-		goto out_err;
-	}
-
-	ret = sqlite3_step(stmt);
-	if (ret == SQLITE_DONE)
-		ret = SQLITE_OK;
-	else
-		xlog(L_ERROR, "%s: unexpected return code from update: %s",
-				__func__, sqlite3_errmsg(dbh));
+	/* Now insert the client into the table for the current epoch */
+	return sqlite_insert_client(clname, namelen);
 
 out_err:
 	xlog(D_GENERAL, "%s: returning %d", __func__, ret);
@@ -599,3 +694,211 @@ sqlite_query_reclaiming(const time_t grace_start)
 			"reclaim", __func__, ret);
 	return ret;
 }
+
+int
+sqlite_grace_start(void)
+{
+	int ret, ret2;
+	char *err;
+	uint64_t tcur = current_epoch;
+	uint64_t trec = recovery_epoch;
+
+	/* begin transaction */
+	ret = sqlite3_exec(dbh, "BEGIN EXCLUSIVE TRANSACTION;", NULL, NULL,
+				&err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to begin transaction: %s", err);
+		goto rollback;
+	}
+
+	if (trec == 0) {
+		/*
+		 * A normal grace start - update the epoch values in the grace
+		 * table and create a new table for the current reboot epoch.
+		 */
+		trec = tcur;
+		tcur++;
+
+		ret = snprintf(buf, sizeof(buf), "UPDATE grace "
+				"SET current = %ld, recovery = %ld;",
+				(int64_t)tcur, (int64_t)trec);
+		if (ret < 0) {
+			xlog(L_ERROR, "sprintf failed!");
+			goto rollback;
+		} else if ((size_t)ret >= sizeof(buf)) {
+			xlog(L_ERROR, "sprintf output too long! (%d chars)",
+				ret);
+			ret = -EINVAL;
+			goto rollback;
+		}
+
+		ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "Unable to update epochs: %s", err);
+			goto rollback;
+		}
+
+		ret = snprintf(buf, sizeof(buf), "CREATE TABLE \"rec-%016lx\" "
+				"(id BLOB PRIMARY KEY);",
+				tcur);
+		if (ret < 0) {
+			xlog(L_ERROR, "sprintf failed!");
+			goto rollback;
+		} else if ((size_t)ret >= sizeof(buf)) {
+			xlog(L_ERROR, "sprintf output too long! (%d chars)",
+				ret);
+			ret = -EINVAL;
+			goto rollback;
+		}
+
+		ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "Unable to create table for current epoch: %s",
+				err);
+			goto rollback;
+		}
+	} else {
+		/* Server restarted while in grace - don't update the epoch
+		 * values in the grace table, just clear out the records for
+		 * the current reboot epoch.
+		 */
+		ret = snprintf(buf, sizeof(buf), "DELETE FROM \"rec-%016lx\";",
+				tcur);
+		if (ret < 0) {
+			xlog(L_ERROR, "sprintf failed!");
+			goto rollback;
+		} else if ((size_t)ret >= sizeof(buf)) {
+			xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+			ret = -EINVAL;
+			goto rollback;
+		}
+
+		ret = sqlite3_exec(dbh, (const char *)buf, NULL, NULL, &err);
+		if (ret != SQLITE_OK) {
+			xlog(L_ERROR, "Unable to clear table for current epoch: %s",
+				err);
+			goto rollback;
+		}
+	}
+
+	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to commit transaction: %s", err);
+		goto rollback;
+	}
+
+	current_epoch = tcur;
+	recovery_epoch = trec;
+	xlog(D_GENERAL, "%s: current_epoch=%lu recovery_epoch=%lu",
+		__func__, current_epoch, recovery_epoch);
+
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
+int
+sqlite_grace_done(void)
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
+	ret = sqlite3_exec(dbh, "UPDATE grace SET recovery = \"0\";",
+			NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to clear recovery epoch: %s", err);
+		goto rollback;
+	}
+
+	ret = snprintf(buf, sizeof(buf), "DROP TABLE \"rec-%016lx\";",
+		recovery_epoch);
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
+		xlog(L_ERROR, "Unable to drop table for recovery epoch: %s",
+			err);
+		goto rollback;
+	}
+
+	ret = sqlite3_exec(dbh, "COMMIT TRANSACTION;", NULL, NULL, &err);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "Unable to commit transaction: %s", err);
+		goto rollback;
+	}
+
+	recovery_epoch = 0;
+	xlog(D_GENERAL, "%s: current_epoch=%lu recovery_epoch=%lu",
+		__func__, current_epoch, recovery_epoch);
+
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
+
+int
+sqlite_iterate_recovery(int (*cb)(struct cld_client *clnt), struct cld_client *clnt)
+{
+	int ret;
+	sqlite3_stmt *stmt = NULL;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	if (recovery_epoch == 0) {
+		xlog(D_GENERAL, "%s: not in grace!", __func__);
+		return -EINVAL;
+	}
+
+	ret = snprintf(buf, sizeof(buf), "SELECT * FROM \"rec-%016lx\";",
+		recovery_epoch);
+	if (ret < 0) {
+		xlog(L_ERROR, "sprintf failed!");
+		return ret;
+	} else if ((size_t)ret >= sizeof(buf)) {
+		xlog(L_ERROR, "sprintf output too long! (%d chars)", ret);
+		return -EINVAL;
+	}
+
+	ret = sqlite3_prepare_v2(dbh, buf, -1, &stmt, NULL);
+	if (ret != SQLITE_OK) {
+		xlog(L_ERROR, "%s: select statement prepare failed: %s",
+			__func__, sqlite3_errmsg(dbh));
+		return ret;
+	}
+
+	while ((ret = sqlite3_step(stmt)) == SQLITE_ROW) {
+		memcpy(&cmsg->cm_u.cm_name.cn_id, sqlite3_column_blob(stmt, 0),
+			NFS4_OPAQUE_LIMIT);
+		cmsg->cm_u.cm_name.cn_len = sqlite3_column_bytes(stmt, 0);
+		cb(clnt);
+	}
+	if (ret == SQLITE_DONE)
+		ret = 0;
+	sqlite3_finalize(stmt);
+	return ret;
+}
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcld/sqlite.h
index 06e7c04..5c56f75 100644
--- a/utils/nfsdcld/sqlite.h
+++ b/utils/nfsdcld/sqlite.h
@@ -20,13 +20,16 @@
 #ifndef _SQLITE_H_
 #define _SQLITE_H_
 
+struct cld_client;
+
 int sqlite_prepare_dbh(const char *topdir);
-int sqlite_insert_client(const unsigned char *clname, const size_t namelen,
-				const bool has_session, const bool zerotime);
+int sqlite_insert_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_client(const unsigned char *clname, const size_t namelen);
-int sqlite_check_client(const unsigned char *clname, const size_t namelen,
-				const bool has_session);
+int sqlite_check_client(const unsigned char *clname, const size_t namelen);
 int sqlite_remove_unreclaimed(const time_t grace_start);
 int sqlite_query_reclaiming(const time_t grace_start);
+int sqlite_grace_start(void);
+int sqlite_grace_done(void);
+int sqlite_iterate_recovery(int (*cb)(struct cld_client *clnt), struct cld_client *clnt);
 
 #endif /* _SQLITE_H */
-- 
2.17.1

