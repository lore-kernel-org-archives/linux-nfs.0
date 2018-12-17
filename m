Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DD51C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 06:23:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 16105217F5
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 06:23:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726323AbeLQGXV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 01:23:21 -0500
Received: from mail5.windriver.com ([192.103.53.11]:33706 "EHLO mail5.wrs.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726256AbeLQGXU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Dec 2018 01:23:20 -0500
Received: from ALA-HCB.corp.ad.wrs.com (ala-hcb.corp.ad.wrs.com [147.11.189.41])
        by mail5.wrs.com (8.15.2/8.15.2) with ESMTPS id wBH6MxjJ007480
        (version=TLSv1 cipher=AES128-SHA bits=128 verify=FAIL)
        for <linux-nfs@vger.kernel.org>; Sun, 16 Dec 2018 22:23:09 -0800
Received: from pek-lpg-core2.corp.ad.wrs.com (128.224.153.41) by
 ALA-HCB.corp.ad.wrs.com (147.11.189.41) with Microsoft SMTP Server id
 14.3.408.0; Sun, 16 Dec 2018 22:22:48 -0800
From:   <mingli.yu@windriver.com>
To:     <linux-nfs@vger.kernel.org>
Subject: [PATCH] Makefile.am: fix undefined function for libnsm.a
Date:   Mon, 17 Dec 2018 14:22:47 +0800
Message-ID: <1545027767-411624-1-git-send-email-mingli.yu@windriver.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Mingli Yu <Mingli.Yu@windriver.com>

The source file of libnsm.a uses some function
in ../support/misc/file.c, add ../support/misc/file.c
to libnsm_a_SOURCES to fix build error when run
"make -C tests statdb_dump":
| ../support/nsm/libnsm.a(file.o): In function `nsm_make_pathname':
| /usr/src/debug/nfs-utils/2.3.3-r0/nfs-utils-2.3.3/support/nsm/file.c:175: undefined reference to `generic_make_pathname'
| /usr/src/debug/nfs-utils/2.3.3-r0/nfs-utils-2.3.3/support/nsm/file.c:175: undefined reference to `generic_make_pathname'
| /usr/src/debug/nfs-utils/2.3.3-r0/nfs-utils-2.3.3/support/nsm/file.c:175: undefined reference to `generic_make_pathname'
| ../support/nsm/libnsm.a(file.o): In function `nsm_setup_pathnames':
| /usr/src/debug/nfs-utils/2.3.3-r0/nfs-utils-2.3.3/support/nsm/file.c:280: undefined reference to `generic_setup_basedir'
| collect2: error: ld returned 1 exit status

As there is already one source file named file.c
as support/nsm/file.c in support/nsm/Makefile.am, 
so rename ../support/misc/file.c to ../support/misc/misc.c.

Signed-off-by: Mingli Yu <Mingli.Yu@windriver.com>
---
 support/misc/Makefile.am |   2 +-
 support/misc/file.c      | 111 -----------------------------------------------
 support/misc/misc.c      | 111 +++++++++++++++++++++++++++++++++++++++++++++++
 support/nsm/Makefile.am  |   2 +-
 4 files changed, 113 insertions(+), 113 deletions(-)
 delete mode 100644 support/misc/file.c
 create mode 100644 support/misc/misc.c

diff --git a/support/misc/Makefile.am b/support/misc/Makefile.am
index 8936b0d..d4c1f76 100644
--- a/support/misc/Makefile.am
+++ b/support/misc/Makefile.am
@@ -1,6 +1,6 @@
 ## Process this file with automake to produce Makefile.in
 
 noinst_LIBRARIES = libmisc.a
-libmisc_a_SOURCES = tcpwrapper.c from_local.c mountpoint.c file.c
+libmisc_a_SOURCES = tcpwrapper.c from_local.c mountpoint.c misc.c
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/support/misc/file.c b/support/misc/file.c
deleted file mode 100644
index e7c3819..0000000
--- a/support/misc/file.c
+++ /dev/null
@@ -1,111 +0,0 @@
-/*
- * Copyright 2009 Oracle.  All rights reserved.
- * Copyright 2017 Red Hat, Inc.  All rights reserved.
- *
- * This file is part of nfs-utils.
- *
- * nfs-utils is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * nfs-utils is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
- */
-
-#include <sys/stat.h>
-
-#include <string.h>
-#include <libgen.h>
-#include <stdio.h>
-#include <errno.h>
-#include <dirent.h>
-#include <stdlib.h>
-#include <stdbool.h>
-#include <limits.h>
-
-#include "xlog.h"
-#include "misc.h"
-
-/*
- * Returns a dynamically allocated, '\0'-terminated buffer
- * containing an appropriate pathname, or NULL if an error
- * occurs.  Caller must free the returned result with free(3).
- */
-__attribute__((__malloc__))
-char *
-generic_make_pathname(const char *base, const char *leaf)
-{
-	size_t size;
-	char *path;
-	int len;
-
-	size = strlen(base) + strlen(leaf) + 2;
-	if (size > PATH_MAX)
-		return NULL;
-
-	path = malloc(size);
-	if (path == NULL)
-		return NULL;
-
-	len = snprintf(path, size, "%s/%s", base, leaf);
-	if ((len < 0) || ((size_t)len >= size)) {
-		free(path);
-		return NULL;
-	}
-
-	return path;
-}
-
-
-/**
- * generic_setup_basedir - set up basedir
- * @progname: C string containing name of program, for error messages
- * @parentdir: C string containing pathname to on-disk state, or NULL
- * @base: character buffer to contain the basedir that is set up
- * @baselen: size of @base in bytes
- *
- * This runs before logging is set up, so error messages are directed
- * to stderr.
- *
- * Returns true and sets up our basedir, if @parentdir was valid
- * and usable; otherwise false is returned.
- */
-_Bool
-generic_setup_basedir(const char *progname, const char *parentdir, char *base,
-		      const size_t baselen)
-{
-	static char buf[PATH_MAX];
-	struct stat st;
-	char *path;
-
-	/* First: test length of name and whether it exists */
-	if ((strlen(parentdir) >= baselen) || (strlen(parentdir) >= PATH_MAX)) {
-		(void)fprintf(stderr, "%s: Directory name too long: %s",
-				progname, parentdir);
-		return false;
-	}
-	if (lstat(parentdir, &st) == -1) {
-		(void)fprintf(stderr, "%s: Failed to stat %s: %s",
-				progname, parentdir, strerror(errno));
-		return false;
-	}
-
-	/* Ensure we have a clean directory pathname */
-	strncpy(buf, parentdir, sizeof(buf)-1);
-	path = dirname(buf);
-	if (*path == '.') {
-		(void)fprintf(stderr, "%s: Unusable directory %s",
-				progname, parentdir);
-		return false;
-	}
-
-	xlog(D_CALL, "Using %s as the state directory", parentdir);
-	strcpy(base, parentdir);
-	return true;
-}
diff --git a/support/misc/misc.c b/support/misc/misc.c
new file mode 100644
index 0000000..e7c3819
--- /dev/null
+++ b/support/misc/misc.c
@@ -0,0 +1,111 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ * Copyright 2017 Red Hat, Inc.  All rights reserved.
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
+#include <sys/stat.h>
+
+#include <string.h>
+#include <libgen.h>
+#include <stdio.h>
+#include <errno.h>
+#include <dirent.h>
+#include <stdlib.h>
+#include <stdbool.h>
+#include <limits.h>
+
+#include "xlog.h"
+#include "misc.h"
+
+/*
+ * Returns a dynamically allocated, '\0'-terminated buffer
+ * containing an appropriate pathname, or NULL if an error
+ * occurs.  Caller must free the returned result with free(3).
+ */
+__attribute__((__malloc__))
+char *
+generic_make_pathname(const char *base, const char *leaf)
+{
+	size_t size;
+	char *path;
+	int len;
+
+	size = strlen(base) + strlen(leaf) + 2;
+	if (size > PATH_MAX)
+		return NULL;
+
+	path = malloc(size);
+	if (path == NULL)
+		return NULL;
+
+	len = snprintf(path, size, "%s/%s", base, leaf);
+	if ((len < 0) || ((size_t)len >= size)) {
+		free(path);
+		return NULL;
+	}
+
+	return path;
+}
+
+
+/**
+ * generic_setup_basedir - set up basedir
+ * @progname: C string containing name of program, for error messages
+ * @parentdir: C string containing pathname to on-disk state, or NULL
+ * @base: character buffer to contain the basedir that is set up
+ * @baselen: size of @base in bytes
+ *
+ * This runs before logging is set up, so error messages are directed
+ * to stderr.
+ *
+ * Returns true and sets up our basedir, if @parentdir was valid
+ * and usable; otherwise false is returned.
+ */
+_Bool
+generic_setup_basedir(const char *progname, const char *parentdir, char *base,
+		      const size_t baselen)
+{
+	static char buf[PATH_MAX];
+	struct stat st;
+	char *path;
+
+	/* First: test length of name and whether it exists */
+	if ((strlen(parentdir) >= baselen) || (strlen(parentdir) >= PATH_MAX)) {
+		(void)fprintf(stderr, "%s: Directory name too long: %s",
+				progname, parentdir);
+		return false;
+	}
+	if (lstat(parentdir, &st) == -1) {
+		(void)fprintf(stderr, "%s: Failed to stat %s: %s",
+				progname, parentdir, strerror(errno));
+		return false;
+	}
+
+	/* Ensure we have a clean directory pathname */
+	strncpy(buf, parentdir, sizeof(buf)-1);
+	path = dirname(buf);
+	if (*path == '.') {
+		(void)fprintf(stderr, "%s: Unusable directory %s",
+				progname, parentdir);
+		return false;
+	}
+
+	xlog(D_CALL, "Using %s as the state directory", parentdir);
+	strcpy(base, parentdir);
+	return true;
+}
diff --git a/support/nsm/Makefile.am b/support/nsm/Makefile.am
index 8f5874e..68f1a46 100644
--- a/support/nsm/Makefile.am
+++ b/support/nsm/Makefile.am
@@ -10,7 +10,7 @@ GENFILES	= $(GENFILES_CLNT) $(GENFILES_SVC) $(GENFILES_XDR) $(GENFILES_H)
 EXTRA_DIST	= sm_inter.x
 
 noinst_LIBRARIES = libnsm.a
-libnsm_a_SOURCES = $(GENFILES) file.c rpc.c
+libnsm_a_SOURCES = $(GENFILES) ../misc/misc.c file.c rpc.c
 
 BUILT_SOURCES = $(GENFILES)
 
-- 
2.7.4

