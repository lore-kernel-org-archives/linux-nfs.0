Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47868 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754113AbdA3TdK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Jan 2017 14:33:10 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: neilb@suse.com, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH RFC 1/2] libnsm.a: refactor nsm_setup_pathnames() and nsm_make_pathname()
Date: Mon, 30 Jan 2017 14:32:48 -0500
Message-Id: <1485804769-14393-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1485804769-14393-1-git-send-email-smayhew@redhat.com>
References: <1485804769-14393-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the logic in nsm_setup_pathnames() and nsm_make_pathname() to
similar generic functions in libmisc.a so that the exportfs and
rpc.mountd programs can make use of them later.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/include/misc.h   |   3 ++
 support/misc/Makefile.am |   2 +-
 support/misc/file.c      | 110 +++++++++++++++++++++++++++++++++++++++++++++++
 support/nsm/file.c       |  45 ++-----------------
 utils/statd/Makefile.am  |   1 +
 5 files changed, 118 insertions(+), 43 deletions(-)
 create mode 100644 support/misc/file.c

diff --git a/support/include/misc.h b/support/include/misc.h
index eedc1fe..6f9b47c 100644
--- a/support/include/misc.h
+++ b/support/include/misc.h
@@ -15,6 +15,9 @@
 int	randomkey(unsigned char *keyout, int len);
 int	weakrandomkey(unsigned char *keyout, int len);
 
+char *generic_make_pathname(const char *, const char *);
+_Bool generic_setup_basedir(const char *, const char *, char *);
+
 extern int is_mountpoint(char *path);
 
 /* size of the file pointer buffers for rpc procfs files */
diff --git a/support/misc/Makefile.am b/support/misc/Makefile.am
index 1048580..8936b0d 100644
--- a/support/misc/Makefile.am
+++ b/support/misc/Makefile.am
@@ -1,6 +1,6 @@
 ## Process this file with automake to produce Makefile.in
 
 noinst_LIBRARIES = libmisc.a
-libmisc_a_SOURCES = tcpwrapper.c from_local.c mountpoint.c
+libmisc_a_SOURCES = tcpwrapper.c from_local.c mountpoint.c file.c
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/support/misc/file.c b/support/misc/file.c
new file mode 100644
index 0000000..ee6d264
--- /dev/null
+++ b/support/misc/file.c
@@ -0,0 +1,110 @@
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
+
+#include "xlog.h"
+#include "misc.h"
+
+static _Bool
+error_check(const int len, const size_t buflen)
+{
+	return (len < 0) || ((size_t)len >= buflen);
+}
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
+	if (error_check(len, size)) {
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
+ * @base: C string used to contain the basedir that is set up
+ *
+ * This runs before logging is set up, so error messages are directed
+ * to stderr.
+ *
+ * Returns true and sets up our basedir, if @parentdir was valid
+ * and usable; otherwise false is returned.
+ */
+_Bool
+generic_setup_basedir(const char *progname, const char *parentdir, char *base)
+{
+	static char buf[PATH_MAX];
+	struct stat st;
+	char *path;
+
+	/* First: test length of name and whether it exists */
+	if (lstat(parentdir, &st) == -1) {
+		(void)fprintf(stderr, "%s: Failed to stat %s: %s",
+				progname, parentdir, strerror(errno));
+		return false;
+	}
+
+	/* Ensure we have a clean directory pathname */
+	strncpy(buf, parentdir, sizeof(buf));
+	path = dirname(buf);
+	if (*path == '.') {
+		(void)fprintf(stderr, "%s: Unusable directory %s",
+				progname, parentdir);
+		return false;
+	}
+
+	xlog(D_CALL, "Using %s as the state directory", parentdir);
+	strncpy(base, parentdir, strlen(base));
+	base[strlen(parentdir)] = '\0';
+	return true;
+}
diff --git a/support/nsm/file.c b/support/nsm/file.c
index aafa755..865be54 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -88,6 +88,7 @@
 
 #include "xlog.h"
 #include "nsm.h"
+#include "misc.h"
 
 #define RPCARGSLEN	(4 * (8 + 1))
 #define LINELEN		(RPCARGSLEN + SM_PRIV_SIZE * 2 + 1)
@@ -170,25 +171,7 @@ __attribute__((__malloc__))
 static char *
 nsm_make_pathname(const char *directory)
 {
-	size_t size;
-	char *path;
-	int len;
-
-	size = strlen(nsm_base_dirname) + strlen(directory) + 2;
-	if (size > PATH_MAX)
-		return NULL;
-
-	path = malloc(size);
-	if (path == NULL)
-		return NULL;
-
-	len = snprintf(path, size, "%s/%s", nsm_base_dirname, directory);
-	if (error_check(len, size)) {
-		free(path);
-		return NULL;
-	}
-
-	return path;
+	return generic_make_pathname(nsm_base_dirname, directory);
 }
 
 /*
@@ -293,29 +276,7 @@ out:
 _Bool
 nsm_setup_pathnames(const char *progname, const char *parentdir)
 {
-	static char buf[PATH_MAX];
-	struct stat st;
-	char *path;
-
-	/* First: test length of name and whether it exists */
-	if (lstat(parentdir, &st) == -1) {
-		(void)fprintf(stderr, "%s: Failed to stat %s: %s",
-				progname, parentdir, strerror(errno));
-		return false;
-	}
-
-	/* Ensure we have a clean directory pathname */
-	strncpy(buf, parentdir, sizeof(buf));
-	path = dirname(buf);
-	if (*path == '.') {
-		(void)fprintf(stderr, "%s: Unusable directory %s",
-				progname, parentdir);
-		return false;
-	}
-
-	xlog(D_CALL, "Using %s as the state directory", parentdir);
-	strncpy(nsm_base_dirname, parentdir, sizeof(nsm_base_dirname));
-	return true;
+	return generic_setup_basedir(progname, parentdir, nsm_base_dirname);
 }
 
 /**
diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index 152b680..ea32075 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -18,6 +18,7 @@ statd_LDADD = ../../support/nsm/libnsm.a \
 	      $(LIBWRAP) $(LIBNSL) $(LIBCAP) $(LIBTIRPC)
 sm_notify_LDADD = ../../support/nsm/libnsm.a \
 		  ../../support/nfs/libnfs.a \
+	          ../../support/misc/libmisc.a \
 		  $(LIBNSL) $(LIBCAP) $(LIBTIRPC)
 
 EXTRA_DIST = sim_sm_inter.x $(man8_MANS) simulate.c
-- 
2.7.4

