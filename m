Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36145 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbeA2X3P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jan 2018 18:29:15 -0500
Received: by mail-io0-f181.google.com with SMTP id l17so9463046ioc.3
        for <linux-nfs@vger.kernel.org>; Mon, 29 Jan 2018 15:29:15 -0800 (PST)
Received: from manet.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w6sm4850185itc.5.2018.01.29.15.29.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 15:29:12 -0800 (PST)
Subject: [PATCH v4 3/5] Add LDAP-free version of libjunction to nfs-utils
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 29 Jan 2018 18:29:11 -0500
Message-ID: <20180129232911.10141.48015.stgit@manet.1015granger.net>
In-Reply-To: <20180129232527.10141.69789.stgit@manet.1015granger.net>
References: <20180129232527.10141.69789.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A "junction" is a physical filesystem object that contains an NFS
referral. On Linux, a junction is a directory with special mode bits
that has an extended attribute containing referral location
information, represented as XML.

A junction can contain either a list of target locations, or it
can contain the location of an LDAP directory entry where the actual
referral information is maintained. The former is called an "NFS
basic junction", the latter is a "FedFS junction".

libjunction contains support for reading or updating a junction
that resides on an NFS server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 support/junction/Makefile.am    |    4 
 support/junction/display.c      |  159 ++++
 support/junction/export-cache.c |  118 +++
 support/junction/junction.c     |  494 ++++++++++++
 support/junction/locations.c    |  131 +++
 support/junction/nfs.c          | 1564 +++++++++++++++++++++++++++++++++++++++
 support/junction/path.c         |  345 +++++++++
 support/junction/xml.c          |  401 ++++++++++
 8 files changed, 3216 insertions(+)
 create mode 100644 support/junction/display.c
 create mode 100644 support/junction/export-cache.c
 create mode 100644 support/junction/junction.c
 create mode 100644 support/junction/locations.c
 create mode 100644 support/junction/nfs.c
 create mode 100644 support/junction/path.c
 create mode 100644 support/junction/xml.c

diff --git a/support/junction/Makefile.am b/support/junction/Makefile.am
index 0d43b0a..97e7426 100644
--- a/support/junction/Makefile.am
+++ b/support/junction/Makefile.am
@@ -25,6 +25,10 @@
 
 noinst_HEADERS		= junction-internal.h
 
+noinst_LTLIBRARIES	= libjunction.la
+libjunction_la_SOURCES	= display.c export-cache.c junction.c \
+			  locations.c nfs.c path.c xml.c
+
 MAINTAINERCLEANFILES	= Makefile.in
 
 AM_CPPFLAGS		= -I. -I../include -I/usr/include/libxml2
diff --git a/support/junction/display.c b/support/junction/display.c
new file mode 100644
index 0000000..77b131f
--- /dev/null
+++ b/support/junction/display.c
@@ -0,0 +1,159 @@
+/**
+ * @file support/junction/display.c
+ * @brief Shared display helper functions
+ */
+
+/*
+ * Copyright 2010, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <stdbool.h>
+#include <stdint.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+
+#include "junction.h"
+
+/**
+ * Return human-readable equivalent of a FedFsConnectionSec value
+ *
+ * @param sectype FedFsConneccionSec value
+ * @return a static NUL-terminated C string
+ */
+const char *
+nsdb_display_fedfsconnectionsec(const FedFsConnectionSec sectype)
+{
+	switch (sectype) {
+	case FEDFS_SEC_NONE:
+		return "FEDFS_SEC_NONE";
+	case FEDFS_SEC_TLS:
+		return "FEDFS_SEC_TLS";
+	default:
+		break;
+	}
+	return "unrecognized security type";
+}
+
+/**
+ * Return human-readable equivalent of a FedFsStatus value
+ *
+ * @param status FedFsStatus code
+ * @return a static NUL-terminated C string
+ */
+const char *
+nsdb_display_fedfsstatus(const FedFsStatus status)
+{
+	switch (status) {
+	case FEDFS_OK:
+		return "FEDFS_OK";
+	case FEDFS_ERR_ACCESS:
+		return "FEDFS_ERR_ACCESS";
+	case FEDFS_ERR_BADCHAR:
+		return "FEDFS_ERR_BADCHAR";
+	case FEDFS_ERR_BADNAME:
+		return "FEDFS_ERR_BADNAME";
+	case FEDFS_ERR_NAMETOOLONG:
+		return "FEDFS_ERR_NAMETOOLONG";
+	case FEDFS_ERR_LOOP:
+		return "FEDFS_ERR_LOOP";
+	case FEDFS_ERR_BADXDR:
+		return "FEDFS_ERR_BADXDR";
+	case FEDFS_ERR_EXIST:
+		return "FEDFS_ERR_EXIST";
+	case FEDFS_ERR_INVAL:
+		return "FEDFS_ERR_INVAL";
+	case FEDFS_ERR_IO:
+		return "FEDFS_ERR_IO";
+	case FEDFS_ERR_NOSPC:
+		return "FEDFS_ERR_NOSPC";
+	case FEDFS_ERR_NOTJUNCT:
+		return "FEDFS_ERR_NOTJUNCT";
+	case FEDFS_ERR_NOTLOCAL:
+		return "FEDFS_ERR_NOTLOCAL";
+	case FEDFS_ERR_PERM:
+		return "FEDFS_ERR_PERM";
+	case FEDFS_ERR_ROFS:
+		return "FEDFS_ERR_ROFS";
+	case FEDFS_ERR_SVRFAULT:
+		return "FEDFS_ERR_SVRFAULT";
+	case FEDFS_ERR_NOTSUPP:
+		return "FEDFS_ERR_NOTSUPP";
+	case FEDFS_ERR_NSDB_ROUTE:
+		return "FEDFS_ERR_NSDB_ROUTE";
+	case FEDFS_ERR_NSDB_DOWN:
+		return "FEDFS_ERR_NSDB_DOWN";
+	case FEDFS_ERR_NSDB_CONN:
+		return "FEDFS_ERR_NSDB_CONN";
+	case FEDFS_ERR_NSDB_AUTH:
+		return "FEDFS_ERR_NSDB_AUTH";
+	case FEDFS_ERR_NSDB_LDAP:
+		return "FEDFS_ERR_NSDB_LDAP";
+	case FEDFS_ERR_NSDB_LDAP_VAL:
+		return "FEDFS_ERR_NSDB_LDAP_VAL";
+	case FEDFS_ERR_NSDB_NONCE:
+		return "FEDFS_ERR_NSDB_NONCE";
+	case FEDFS_ERR_NSDB_NOFSN:
+		return "FEDFS_ERR_NSDB_NOFSN";
+	case FEDFS_ERR_NSDB_NOFSL:
+		return "FEDFS_ERR_NSDB_NOFSL";
+	case FEDFS_ERR_NSDB_RESPONSE:
+		return "FEDFS_ERR_NSDB_RESPONSE";
+	case FEDFS_ERR_NSDB_FAULT:
+		return "FEDFS_ERR_NSDB_FAULT";
+	case FEDFS_ERR_NSDB_PARAMS:
+		return "FEDFS_ERR_NSDB_PARAMS";
+	case FEDFS_ERR_NSDB_LDAP_REFERRAL:
+		return "FEDFS_ERR_NSDB_LDAP_REFERRAL";
+	case FEDFS_ERR_NSDB_LDAP_REFERRAL_VAL:
+		return "FEDFS_ERR_NSDB_LDAP_REFERRAL_VAL";
+	case FEDFS_ERR_NSDB_PARAMS_LDAP_REFERRAL:
+		return "FEDFS_ERR_NSDB_PARAMS_LDAP_REFERRAL";
+	case FEDFS_ERR_PATH_TYPE_UNSUPP:
+		return "FEDFS_ERR_PATH_TYPE_UNSUPP";
+	case FEDFS_ERR_DELAY:
+		return "FEDFS_ERR_DELAY";
+	case FEDFS_ERR_NO_CACHE:
+		return "FEDFS_ERR_NO_CACHE";
+	case FEDFS_ERR_UNKNOWN_CACHE:
+		return "FEDFS_ERR_UNKNOWN_CACHE";
+	case FEDFS_ERR_NO_CACHE_UPDATE:
+		return "FEDFS_ERR_NO_CACHE_UPDATE";
+	default:
+		break;
+	}
+	return "an unrecognized error code";
+}
+
+/**
+ * Display human-readable FedFsStatus on stderr
+ *
+ * @param status FedFsStatus value to display
+ */
+void
+nsdb_print_fedfsstatus(const FedFsStatus status)
+{
+	if (status == FEDFS_OK) {
+		printf("Call completed successfully\n");
+		return;
+	}
+
+	fprintf(stderr, "Server returned %s\n",
+			nsdb_display_fedfsstatus(status));
+}
diff --git a/support/junction/export-cache.c b/support/junction/export-cache.c
new file mode 100644
index 0000000..4e578c9
--- /dev/null
+++ b/support/junction/export-cache.c
@@ -0,0 +1,118 @@
+/**
+ * @file support/junction/export-cache.c
+ * @brief Try to flush NFSD's exports cache
+ */
+
+/*
+ * Copyright 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <time.h>
+
+
+#include "junction.h"
+#include "xlog.h"
+
+/**
+ * Ordered list of proc files to poke when requesting an NFSD cache flush
+ */
+static const char *junction_proc_files[] = {
+	"/proc/net/rpc/auth.unix.ip/flush",
+	"/proc/net/rpc/auth.unix.gid/flush",
+	"/proc/net/rpc/nfsd.fh/flush",
+	"/proc/net/rpc/nfsd.export/flush",
+	NULL,
+};
+
+/**
+ * Write time into one file
+ *
+ * @param pathname NUL-terminated C string containing POSIX pathname of file to write
+ * @param flushtime NUL-terminated C string containing current time in seconds since the Epoch
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+junction_write_time(const char *pathname, const char *flushtime)
+{
+	FedFsStatus retval;
+	ssize_t len;
+	int fd;
+
+	fd = open(pathname, O_RDWR);
+	if (fd == -1) {
+		xlog(D_GENERAL, "%s: Failed to open %s: %m",
+			__func__, pathname);
+		/* If the proc files don't exist, no server
+		 * is running on this system */
+		return FEDFS_ERR_NO_CACHE_UPDATE;
+	}
+
+	len = write(fd, flushtime, strlen(flushtime));
+	if (len != (ssize_t)strlen(flushtime)) {
+		xlog(D_GENERAL, "%s: Failed to write %s: %m",
+			__func__, pathname);
+		/* If the proc files exist but the update failed,
+		 * we don't know the state of the cache */
+		retval = FEDFS_ERR_UNKNOWN_CACHE;
+	} else
+		/* Cache flush succeeded */
+		retval = FEDFS_OK;
+
+	(void)close(fd);
+	return retval;
+}
+
+/**
+ * Flush the kernel NFSD's exports cache
+ *
+ * @return a FedFsStatus code
+ */
+FedFsStatus
+junction_flush_exports_cache(void)
+{
+	FedFsStatus retval;
+	char flushtime[20];
+	unsigned int i;
+	time_t now;
+
+	xlog(D_CALL, "%s: Flushing NFSD caches...", __func__);
+
+	now = time(NULL);
+	if (now == -1) {
+		xlog(D_GENERAL, "%s: time(3) failed", __func__);
+		return FEDFS_ERR_SVRFAULT;
+	}
+	snprintf(flushtime, sizeof(flushtime), "%ld\n", now);
+
+	for (i = 0; junction_proc_files[i] != NULL; i++) {
+		retval = junction_write_time(junction_proc_files[i], flushtime);
+		if (retval != FEDFS_OK)
+			return retval;
+	}
+	return FEDFS_OK;
+}
diff --git a/support/junction/junction.c b/support/junction/junction.c
new file mode 100644
index 0000000..ab6caa6
--- /dev/null
+++ b/support/junction/junction.c
@@ -0,0 +1,494 @@
+/**
+ * @file support/junction/junction.c
+ * @brief Common utilities for managing junctions on the local file system
+ */
+
+/*
+ * Copyright 2010, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <wchar.h>
+#include <memory.h>
+#include <signal.h>
+#include <errno.h>
+#include <dirent.h>
+
+#include <sys/xattr.h>
+
+#include "junction.h"
+#include "junction-internal.h"
+#include "xlog.h"
+
+/**
+ * Open a file system object
+ *
+ * @param pathname NUL-terminated C string containing pathname of an object
+ * @param fd OUT: a file descriptor number is filled in
+ * @return a FedFsStatus code
+ */
+FedFsStatus
+junction_open_path(const char *pathname, int *fd)
+{
+	int tmp;
+
+	if (pathname == NULL || fd == NULL)
+		return FEDFS_ERR_INVAL;
+
+	tmp = open(pathname, O_DIRECTORY);
+	if (tmp == -1) {
+		switch (errno) {
+		case EPERM:
+			return FEDFS_ERR_ACCESS;
+		case EACCES:
+			return FEDFS_ERR_PERM;
+		default:
+			xlog(D_GENERAL, "%s: Failed to open path %s: %m",
+				__func__, pathname);
+			return FEDFS_ERR_INVAL;
+		}
+	}
+
+	*fd = tmp;
+	return FEDFS_OK;
+}
+
+/**
+ * Predicate: is object a directory?
+ *
+ * @param fd an open file descriptor
+ * @param path NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ */
+FedFsStatus
+junction_is_directory(int fd, const char *path)
+{
+	struct stat stb;
+
+	if (fstat(fd, &stb) == -1) {
+		xlog(D_GENERAL, "%s: failed to stat %s: %m",
+				__func__, path);
+		return FEDFS_ERR_ACCESS;
+	}
+
+	if (!S_ISDIR(stb.st_mode)) {
+		xlog(D_CALL, "%s: %s is not a directory",
+				__func__, path);
+		return FEDFS_ERR_INVAL;
+	}
+
+	xlog(D_CALL, "%s: %s is a directory", __func__, path);
+	return FEDFS_OK;
+}
+
+/**
+ * Predicate: is a directory's sticky bit set?
+ *
+ * @param fd an open file descriptor
+ * @param path NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ */
+FedFsStatus
+junction_is_sticky_bit_set(int fd, const char *path)
+{
+	struct stat stb;
+
+	if (fstat(fd, &stb) == -1) {
+		xlog(D_GENERAL, "%s: failed to stat %s: %m",
+				__func__, path);
+		return FEDFS_ERR_ACCESS;
+	}
+
+	if (stb.st_mode & (S_IXUSR|S_IXGRP|S_IXOTH)) {
+		xlog(D_CALL, "%s: execute bit set on %s",
+				__func__, path);
+		return FEDFS_ERR_NOTJUNCT;
+	}
+
+	if (!(stb.st_mode & S_ISVTX)) {
+		xlog(D_CALL, "%s: sticky bit not set on %s",
+				__func__, path);
+		return FEDFS_ERR_NOTJUNCT;
+	}
+
+	xlog(D_CALL, "%s: sticky bit is set on %s", __func__, path);
+	return FEDFS_OK;
+}
+
+/**
+ * Set just a directory's sticky bit
+ *
+ * @param fd an open file descriptor
+ * @param path NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ */
+FedFsStatus
+junction_set_sticky_bit(int fd, const char *path)
+{
+	struct stat stb;
+
+	if (fstat(fd, &stb) == -1) {
+		xlog(D_GENERAL, "%s: failed to stat %s: %m",
+			__func__, path);
+		return FEDFS_ERR_ACCESS;
+	}
+
+	stb.st_mode &= (unsigned int)~ALLPERMS;
+	stb.st_mode |= S_ISVTX;
+
+	if (fchmod(fd, stb.st_mode) == -1) {
+		xlog(D_GENERAL, "%s: failed to set sticky bit on %s: %m",
+			__func__, path);
+		return FEDFS_ERR_ROFS;
+	}
+
+	xlog(D_CALL, "%s: set sticky bit on %s", __func__, path);
+	return FEDFS_OK;
+}
+
+/**
+ * Predicate: does a directory have an xattr named "name"?
+ *
+ * @param fd an open file descriptor
+ * @param path NUL-terminated C string containing pathname of a directory
+ * @param name NUL-terminated C string containing name of xattr to check
+ * @return a FedFsStatus code
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+FedFsStatus
+junction_is_xattr_present(int fd, const char *path, const char *name)
+{
+	ssize_t rc;
+
+	/*
+	 * Do not assume the total number of extended attributes
+	 * this object may have.
+	 */
+	rc = fgetxattr(fd, name, NULL, 0);
+	if (rc == -1) {
+		switch (errno) {
+		case EPERM:
+			xlog(D_CALL, "%s: no access to xattr %s on %s",
+				__func__, name, path);
+			return FEDFS_ERR_PERM;
+		case ENODATA:
+			xlog(D_CALL, "%s: no xattr %s present on %s",
+				__func__, name, path);
+			return FEDFS_ERR_NOTJUNCT;
+		default:
+			xlog(D_CALL, "%s: xattr %s not found on %s: %m",
+				__func__, name, path);
+			return FEDFS_ERR_IO;
+		}
+	}
+
+	xlog(D_CALL, "%s: xattr %s found on %s",
+			__func__, name, path);
+	return FEDFS_OK;
+}
+
+/**
+ * Read the contents of xattr "name"
+ *
+ * @param fd an open file descriptor
+ * @param path NUL-terminated C string containing pathname of a directory
+ * @param name NUL-terminated C string containing name of xattr to retrieve
+ * @param contents OUT: NUL-terminated C string containing contents of xattr
+ * @return a FedFsStatus code
+ *
+ * If junction_read_xattr() returns FEDFS_OK, the caller must free "*contents"
+ * with free(3).
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+FedFsStatus
+junction_read_xattr(int fd, const char *path, const char *name, char **contents)
+{
+	char *xattrbuf = NULL;
+	ssize_t len;
+
+	len = fgetxattr(fd, name, xattrbuf, 0);
+	if (len < 0) {
+		xlog(D_GENERAL, "%s: failed to get size of xattr %s on %s: %m",
+			__func__, name, path);
+		return FEDFS_ERR_ACCESS;
+	}
+
+	xattrbuf = malloc((size_t)len + 1);
+	if (xattrbuf == NULL) {
+		xlog(D_GENERAL, "%s: failed to get buffer for xattr %s on %s",
+			__func__, name, path);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	if (fgetxattr(fd, name, xattrbuf, (size_t)len) == -1) {
+		xlog(D_GENERAL, "%s: failed to get xattr %s on %s: %m",
+			__func__, name, path);
+		free(xattrbuf);
+		return FEDFS_ERR_ACCESS;
+	}
+	xattrbuf[len] = '\0';
+
+	xlog(D_CALL, "%s: read xattr %s from path %s",
+			__func__, name, path);
+	*contents = xattrbuf;
+	return FEDFS_OK;
+}
+
+/**
+ * Retrieve the contents of xattr "name"
+ *
+ * @param fd an open file descriptor
+ * @param path NUL-terminated C string containing pathname of a directory
+ * @param name NUL-terminated C string containing name of xattr to retrieve
+ * @param contents OUT: opaque byte array containing contents of xattr
+ * @param contentlen OUT: size of "contents"
+ * @return a FedFsStatus code
+ *
+ * If junction_get_xattr() returns FEDFS_OK, the caller must free "*contents"
+ * with free(3).
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+FedFsStatus
+junction_get_xattr(int fd, const char *path, const char *name, void **contents,
+		size_t *contentlen)
+{
+	void *xattrbuf = NULL;
+	ssize_t len;
+
+	len = fgetxattr(fd, name, xattrbuf, 0);
+	if (len < 0) {
+		xlog(D_GENERAL, "%s: failed to get size of xattr %s on %s: %m",
+			__func__, name, path);
+		return FEDFS_ERR_ACCESS;
+	}
+
+	xattrbuf = malloc((size_t)len);
+	if (xattrbuf == NULL) {
+		xlog(D_GENERAL, "%s: failed to get buffer for xattr %s on %s",
+			__func__, name, path);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	if (fgetxattr(fd, name, xattrbuf, (size_t)len) == -1) {
+		xlog(D_GENERAL, "%s: failed to get xattr %s on %s: %m",
+			__func__, name, path);
+		free(xattrbuf);
+		return FEDFS_ERR_ACCESS;
+	}
+
+	xlog(D_CALL, "%s: read xattr %s from path %s",
+			__func__, name, path);
+	*contents = xattrbuf;
+	*contentlen = (size_t)len;
+	return FEDFS_OK;
+}
+
+/**
+ * Update the contents of an xattr
+ *
+ * @param fd an open file descriptor
+ * @param path NUL-terminated C string containing pathname of a directory
+ * @param name NUL-terminated C string containing name of xattr to set
+ * @param contents opaque byte array containing contents of xattr
+ * @param contentlen size of "contents"
+ * @return a FedFsStatus code
+ *
+ * The extended attribute is created if it does not exist.
+ * Its contents are replaced if it does.
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+FedFsStatus
+junction_set_xattr(int fd, const char *path, const char *name,
+			const void *contents, const size_t contentlen)
+{
+	/*
+	 * XXX: Eventually should distinguish among several errors:
+	 *	object isn't there, no root access, some other issue
+	 */
+	if (fsetxattr(fd, name, contents, contentlen, 0) == -1) {
+		xlog(D_GENERAL, "%s: Failed to set xattr %s on %s: %m",
+			__func__, name, path);
+		return FEDFS_ERR_IO;
+	}
+
+	xlog(D_CALL, "%s: Wrote xattr %s from path %s",
+			__func__, name, path);
+	return FEDFS_OK;
+}
+
+/**
+ * Remove one xattr
+ *
+ * @param fd an open file descriptor
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @param name NUL-terminated C string containing name of xattr to set
+ * @return a FedFsStatus code
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+FedFsStatus
+junction_remove_xattr(int fd, const char *pathname, const char *name)
+{
+	/*
+	 * XXX: Eventually should distinguish among several errors:
+	 *	object isn't there, no root access, some other issue
+	 */
+	if (fremovexattr(fd, name) == -1) {
+		xlog(D_GENERAL, "%s: failed to remove xattr %s from %s: %m",
+			__func__, name, pathname);
+		return FEDFS_ERR_ACCESS;
+	}
+	xlog(D_CALL, "%s: removed xattr %s from path %s",
+			__func__, name, pathname);
+	return FEDFS_OK;
+}
+
+/**
+ * Retrieve object's mode bits.
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @param mode OUT: mode bits
+ * @return a FedFsStatus code
+ */
+FedFsStatus
+junction_get_mode(const char *pathname, mode_t *mode)
+{
+	FedFsStatus retval;
+	struct stat stb;
+	int fd;
+
+	retval = junction_open_path(pathname, &fd);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	if (fstat(fd, &stb) == -1) {
+		xlog(D_GENERAL, "%s: failed to stat %s: %m",
+			__func__, pathname);
+		(void)close(fd);
+		return FEDFS_ERR_ACCESS;
+	}
+	(void)close(fd);
+
+	xlog(D_CALL, "%s: pathname %s has mode %o",
+		__func__, pathname, stb.st_mode);
+	*mode = stb.st_mode;
+	return FEDFS_OK;
+
+}
+
+/**
+ * Save the object's mode in an xattr.  Saved mode is human-readable.
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ */
+FedFsStatus
+junction_save_mode(const char *pathname)
+{
+	FedFsStatus retval;
+	mode_t mode;
+	char buf[8];
+	int fd;
+
+	retval = junction_get_mode(pathname, &mode);
+	if (retval != FEDFS_OK)
+		return retval;
+	(void)snprintf(buf, sizeof(buf), "%o", ALLPERMS & mode);
+
+	retval = junction_open_path(pathname, &fd);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = junction_set_xattr(fd, pathname, JUNCTION_XATTR_NAME_MODE,
+				buf, strlen(buf));
+	if (retval != FEDFS_OK)
+		goto out;
+
+	retval = junction_set_sticky_bit(fd, pathname);
+	if (retval != FEDFS_OK) {
+		(void)junction_remove_xattr(fd, pathname,
+						JUNCTION_XATTR_NAME_MODE);
+		goto out;
+	}
+
+	xlog(D_CALL, "%s: saved mode %o to %s", __func__, mode, pathname);
+	retval = FEDFS_OK;
+
+out:
+	(void)close(fd);
+	return retval;
+
+}
+
+/**
+ * Restore an object's mode bits
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ */
+FedFsStatus
+junction_restore_mode(const char *pathname)
+{
+	FedFsStatus retval;
+	char *buf = NULL;
+	mode_t mode;
+	int fd;
+
+	retval = junction_open_path(pathname, &fd);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = junction_read_xattr(fd, pathname, JUNCTION_XATTR_NAME_MODE, &buf);
+	if (retval != FEDFS_OK)
+		goto out;
+
+	retval = FEDFS_ERR_SVRFAULT;
+	if (sscanf((char *)buf, "%o", &mode) != 1) {
+		xlog(D_GENERAL, "%s: failed to parse saved mode on %s",
+			__func__, pathname);
+		goto out;
+	}
+
+	retval = FEDFS_ERR_ROFS;
+	if (fchmod(fd, mode) == -1) {
+		xlog(D_GENERAL, "%s: failed to set mode of %s to %o: %m",
+			__func__, pathname, mode);
+		goto out;
+	}
+
+	xlog(D_CALL, "%s: restored mode %o to %s", __func__, mode, pathname);
+	retval = FEDFS_OK;
+
+out:
+	free(buf);
+	(void)close(fd);
+	return retval;
+}
diff --git a/support/junction/locations.c b/support/junction/locations.c
new file mode 100644
index 0000000..c577981
--- /dev/null
+++ b/support/junction/locations.c
@@ -0,0 +1,131 @@
+/**
+ * @file support/junction/locations.c
+ * @brief Utility functions to manage NFS locations data
+ */
+
+/*
+ * Copyright 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+
+#include <stdbool.h>
+#include <stdint.h>
+#include <stdlib.h>
+#include <stdio.h>
+
+#include <string.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <errno.h>
+
+#include "junction.h"
+
+/**
+ * Free an array of NUL-terminated C strings
+ *
+ * @param array array of pointers to C strings
+ */
+void
+nfs_free_string_array(char **array)
+{
+	unsigned int i;
+
+	if (array == NULL)
+		return;
+	for (i = 0; array[i] != NULL; i++)
+		free(array[i]);
+	free(array);
+}
+
+/**
+ * Duplicate an array of NUL-terminated C strings
+ *
+ * @param array array of pointers to C strings
+ * @return freshly allocated array of points to C strings, or NULL
+ *
+ * Caller must free the returned array with nfs_free_string_array()
+ */
+__attribute_malloc__ char **
+nfs_dup_string_array(char **array)
+{
+	unsigned int size, i;
+	char **result;
+
+	if (array == NULL)
+		return NULL;
+
+	for (size = 0; array[size] != NULL; size++);
+
+	result = calloc(size + 1, sizeof(char *));
+	if (result == NULL)
+		return NULL;
+	for (i = 0; i < size; i++) {
+		result[i] = strdup(array[i]);
+		if (result[i] == NULL) {
+			nfs_free_string_array(result);
+			return NULL;
+		}
+	}
+	return result;
+}
+
+/**
+ * Free a single NFS location
+ *
+ * @param location pointer to nfs_fsloc data
+ */
+void
+nfs_free_location(struct nfs_fsloc *location)
+{
+	nfs_free_string_array(location->nfl_rootpath);
+	free(location->nfl_hostname);
+	free(location);
+}
+
+/**
+ * Free a list of NFS locations
+ *
+ * @param locations pointer to list of one or more locations
+ */
+void
+nfs_free_locations(struct nfs_fsloc *locations)
+{
+	struct nfs_fsloc *fsloc;
+
+	while (locations != NULL) {
+		fsloc = locations;
+		locations = fsloc->nfl_next;
+		nfs_free_location(fsloc);
+	}
+}
+
+/**
+ * Allocate a fresh nfs_fsloc structure
+ *
+ * @return pointer to new empty nfs_fsloc data structure
+ *
+ * Caller must free returned locations with nfs_free_location().
+ */
+struct nfs_fsloc *
+nfs_new_location(void)
+{
+	return calloc(1, sizeof(struct nfs_fsloc));
+}
diff --git a/support/junction/nfs.c b/support/junction/nfs.c
new file mode 100644
index 0000000..73e3533
--- /dev/null
+++ b/support/junction/nfs.c
@@ -0,0 +1,1564 @@
+/**
+ * @file support/junction/nfs.c
+ * @brief Create, delete, and read NFS junctions on the local file system
+ */
+
+/*
+ * Copyright 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+/*
+ * An NFS junction is a list of NFS FSLs, represented in a well-formed XML
+ * document:
+ *
+ * <?xml version="1.0" encoding="UTF-8"?>
+ * <junction>
+ *   <savedmode bits="1777" />
+ *   <fileset>
+ *     <location>
+ *       <host name="fileserver.example.net" port="2049" />
+ *       <path>
+ *         <component>foo</component>
+ *         <component>bar</component>
+ *         <component>baz</component>
+ *       </path>
+ *       <currency>-1</currency>
+ *       <genflags writable="false" going="false" split="true" />
+ *       <transflags rdma="true" />
+ *       <class simul="0" handle="0" fileid="0"
+ *              writever="0" change="0" readdir="0" />
+ *       <read rank="0" order="0" />
+ *       <write rank="0" order="0" />
+ *       <flags varsub="false" />
+ *       <validfor>0</validfor>
+ *     </location>
+ *
+ *     ....
+ *
+ *   </fileset>
+ * </junction>
+ *
+ * NFS junction XML is stored in an extended attribute called
+ * "trusted.junction.nfs".   The parent object is a directory.
+ *
+ * To help file servers discover junctions efficiently, the directory
+ * has no execute bits, and the sticky bit is set.  In addition, an
+ * extended attribute called "trusted.junction.type" is added.  The
+ * contents are ignored in user space.
+ *
+ * Finally, for pre-existing directories that are converted to
+ * junctions, their mode bits are saved in an extended attribute called
+ * "trusted.junction.mode".  When the junction data is removed, the
+ * directory's mode bits are restored from this information.
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+
+#include <rpcsvc/nfs_prot.h>
+
+#include "junction.h"
+#include "junction-internal.h"
+#include "xlog.h"
+
+/**
+ * Tag name of NFS location element of a junction XML document
+ */
+#define NFS_XML_LOCATION_TAG		(const xmlChar *)"location"
+
+/**
+ * Tag name of host child element of an NFS location element
+ */
+#define NFS_XML_HOST_TAG		(const xmlChar *)"host"
+
+/**
+ * Name of hostname attribute of a host element
+ */
+#define NFS_XML_HOST_NAME_ATTR		(const xmlChar *)"name"
+
+/**
+ * Name of IP port attribute of a host element
+ */
+#define NFS_XML_HOST_PORT_ATTR		(const xmlChar *)"port"
+
+/**
+ * Tag name of path child element of an NFS location element
+ */
+#define NFS_XML_PATH_TAG		(const xmlChar *)"path"
+
+/**
+ * Tag name of component child element of a path element
+ */
+#define NFS_XML_COMPONENT_TAG		(const xmlChar *)"component"
+
+/**
+ * Tag name of currency child element of an NFS location element
+ */
+#define NFS_XML_CURRENCY_TAG		(const xmlChar *)"currency"
+
+/**
+ * Tag name of genflags child element of an NFS location element
+ */
+#define NFS_XML_GENFLAGS_TAG		(const xmlChar *)"genflags"
+
+/**
+ * Name of writable attribute of a genflags element
+ */
+#define NFS_XML_GENFLAGS_WRITABLE_ATTR	(const xmlChar *)"writable"
+
+/**
+ * Name of going attribute of a genflags element
+ */
+#define NFS_XML_GENFLAGS_GOING_ATTR	(const xmlChar *)"going"
+
+/**
+ * Name of split attribute of a genflags element
+ */
+#define	NFS_XML_GENFLAGS_SPLIT_ATTR	(const xmlChar *)"split"
+
+/**
+ * Tag name of transflags child element of an NFS location element
+ */
+#define NFS_XML_TRANSFLAGS_TAG		(const xmlChar *)"transflags"
+
+/**
+ * Name of rdma attribute of a transflags element
+ */
+#define NFS_XML_TRANSFLAGS_RDMA_ATTR	(const xmlChar *)"rdma"
+
+/**
+ * Tag name of class child element of an NFS location element
+ */
+#define NFS_XML_CLASS_TAG		(const xmlChar *)"class"
+
+/**
+ * Name of simul attribute of a class element
+ */
+#define NFS_XML_CLASS_SIMUL_ATTR	(const xmlChar *)"simul"
+
+/**
+ * Name of handle attribute of a class element
+ */
+#define NFS_XML_CLASS_HANDLE_ATTR	(const xmlChar *)"handle"
+
+/**
+ * Name of fileid attribute of a class element
+ */
+#define NFS_XML_CLASS_FILEID_ATTR	(const xmlChar *)"fileid"
+
+/**
+ * Name of writever attribute of a class element
+ */
+#define NFS_XML_CLASS_WRITEVER_ATTR	(const xmlChar *)"writever"
+
+/**
+ * Name of change attribute of a class element
+ */
+#define NFS_XML_CLASS_CHANGE_ATTR	(const xmlChar *)"change"
+
+/**
+ * Name of readdir attribute of a class element
+ */
+#define NFS_XML_CLASS_READDIR_ATTR	(const xmlChar *)"readdir"
+
+/**
+ * Tag name of read child element of an NFS location element
+ */
+#define NFS_XML_READ_TAG		(const xmlChar *)"read"
+
+/**
+ * Name of rank attribute of a read element
+ */
+#define NFS_XML_READ_RANK_ATTR		(const xmlChar *)"rank"
+
+/**
+ * Name of order attribute of a read element
+ */
+#define NFS_XML_READ_ORDER_ATTR		(const xmlChar *)"order"
+
+/**
+ * Tag name of write attribute of an NFS location element
+ */
+#define NFS_XML_WRITE_TAG		(const xmlChar *)"write"
+
+/**
+ * Name of rank attribute of a write element
+ */
+#define NFS_XML_WRITE_RANK_ATTR		(const xmlChar *)"rank"
+
+/**
+ * Name of order attribute of a write element
+ */
+#define NFS_XML_WRITE_ORDER_ATTR	(const xmlChar *)"order"
+
+/**
+ * Tag name of flags child element of an NFS location element
+ */
+#define NFS_XML_FLAGS_TAG		(const xmlChar *)"flags"
+
+/**
+ * Name of varsub attribute of a flags element
+ */
+#define NFS_XML_FLAGS_VARSUB_ATTR	(const xmlChar *)"varsub"
+
+/**
+ * Tag name of a validfor child element of an NFS location element
+ */
+#define NFS_XML_VALIDFOR_TAG		(const xmlChar *)"validfor"
+
+/**
+ * XPath path to NFS location elements in a junction document
+ */
+#define NFS_XML_LOCATION_XPATH		(const xmlChar *)	\
+						"/junction/fileset/location"
+
+
+/**
+ * Remove all NFS-related xattrs from a directory
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+static FedFsStatus
+nfs_remove_locations(const char *pathname)
+{
+	FedFsStatus retval;
+	int fd;
+
+	retval = junction_open_path(pathname, &fd);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = junction_remove_xattr(fd, pathname, JUNCTION_XATTR_NAME_NFS);
+
+	(void)close(fd);
+	return retval;
+}
+
+/**
+ * Add a "host" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_host_xml(const char *pathname, xmlNodePtr parent,
+		struct nfs_fsloc *fsloc)
+{
+	uint16_t port = fsloc->nfl_hostport;
+	xmlNodePtr new;
+
+	new = xmlNewTextChild(parent, NULL, NFS_XML_HOST_TAG, NULL);
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add host element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	xmlSetProp(new, NFS_XML_HOST_NAME_ATTR,
+			(const xmlChar *)fsloc->nfl_hostname);
+	if (port != NFS_PORT && port != 0)
+		junction_xml_set_int_attribute(new, NFS_XML_HOST_PORT_ATTR,
+									port);
+
+	return FEDFS_OK;
+}
+
+/**
+ * Add a "path" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_path_xml(const char *pathname, xmlNodePtr parent,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr new;
+	int i;
+
+	new = xmlNewTextChild(parent, NULL, NFS_XML_PATH_TAG, NULL);
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add path element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	for (i = 0; fsloc->nfl_rootpath[i] != NULL; i++) {
+		xmlNodePtr component;
+
+		component = xmlNewTextChild(new , NULL,
+						NFS_XML_COMPONENT_TAG,
+						(const xmlChar *)
+						fsloc->nfl_rootpath[i]);
+		if (component == NULL) {
+			xlog(D_GENERAL, "%s: Failed to add component "
+					"element for %s",
+				__func__, pathname);
+			return FEDFS_ERR_SVRFAULT;
+		}
+	}
+
+	return FEDFS_OK;
+}
+
+/**
+ * Add a "currency" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_currency_xml(__attribute__((unused)) const char *pathname,
+		xmlNodePtr parent, struct nfs_fsloc *fsloc)
+{
+	if (junction_xml_set_int_content(parent, NFS_XML_CURRENCY_TAG,
+						fsloc->nfl_currency) == NULL)
+		return FEDFS_ERR_SVRFAULT;
+	return FEDFS_OK;
+}
+
+/**
+ * Add a "genflags" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_genflags_xml(const char *pathname, xmlNodePtr parent,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr new;
+
+	new = xmlNewTextChild(parent, NULL, NFS_XML_GENFLAGS_TAG, NULL);
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add genflags element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	junction_xml_set_bool_attribute(new, NFS_XML_GENFLAGS_WRITABLE_ATTR,
+					fsloc->nfl_genflags.nfl_writable);
+	junction_xml_set_bool_attribute(new, NFS_XML_GENFLAGS_GOING_ATTR,
+					fsloc->nfl_genflags.nfl_going);
+	junction_xml_set_bool_attribute(new, NFS_XML_GENFLAGS_SPLIT_ATTR,
+					fsloc->nfl_genflags.nfl_split);
+
+	return FEDFS_OK;
+}
+
+/**
+ * Add a "transflags" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_transflags_xml(const char *pathname, xmlNodePtr parent,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr new;
+
+	new = xmlNewTextChild(parent, NULL, NFS_XML_TRANSFLAGS_TAG, NULL);
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add transflags element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	junction_xml_set_bool_attribute(new, NFS_XML_TRANSFLAGS_RDMA_ATTR,
+					fsloc->nfl_transflags.nfl_rdma);
+
+	return FEDFS_OK;
+}
+
+/**
+ * Add a "class" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_class_xml(const char *pathname, xmlNodePtr parent,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr new;
+
+	new = xmlNewTextChild(parent, NULL, NFS_XML_CLASS_TAG, NULL);
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add class element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	junction_xml_set_int_attribute(new, NFS_XML_CLASS_SIMUL_ATTR,
+						fsloc->nfl_info.nfl_simul);
+	junction_xml_set_int_attribute(new, NFS_XML_CLASS_HANDLE_ATTR,
+						fsloc->nfl_info.nfl_handle);
+	junction_xml_set_int_attribute(new, NFS_XML_CLASS_FILEID_ATTR,
+						fsloc->nfl_info.nfl_fileid);
+	junction_xml_set_int_attribute(new, NFS_XML_CLASS_WRITEVER_ATTR,
+						fsloc->nfl_info.nfl_writever);
+	junction_xml_set_int_attribute(new, NFS_XML_CLASS_CHANGE_ATTR,
+						fsloc->nfl_info.nfl_change);
+	junction_xml_set_int_attribute(new, NFS_XML_CLASS_READDIR_ATTR,
+						fsloc->nfl_info.nfl_readdir);
+
+	return FEDFS_OK;
+}
+
+/**
+ * Add a "read" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_read_xml(const char *pathname, xmlNodePtr parent,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr new;
+
+	new = xmlNewTextChild(parent, NULL, NFS_XML_READ_TAG, NULL);
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add read element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	junction_xml_set_int_attribute(new, NFS_XML_READ_RANK_ATTR,
+					fsloc->nfl_info.nfl_readrank);
+	junction_xml_set_int_attribute(new, NFS_XML_READ_ORDER_ATTR,
+					fsloc->nfl_info.nfl_readorder);
+
+	return FEDFS_OK;
+}
+
+/**
+ * Add a "write" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_write_xml(const char *pathname, xmlNodePtr parent,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr new;
+
+	new = xmlNewTextChild(parent, NULL, NFS_XML_WRITE_TAG, NULL);
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add write element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	junction_xml_set_int_attribute(new, NFS_XML_WRITE_RANK_ATTR,
+					fsloc->nfl_info.nfl_writerank);
+	junction_xml_set_int_attribute(new, NFS_XML_WRITE_ORDER_ATTR,
+					fsloc->nfl_info.nfl_writeorder);
+
+	return FEDFS_OK;
+}
+
+/**
+ * Add a "flags" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_flags_xml(const char *pathname, xmlNodePtr parent,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr new;
+
+	new = xmlNewTextChild(parent, NULL, NFS_XML_FLAGS_TAG, NULL);
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add flags element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	junction_xml_set_bool_attribute(new, NFS_XML_FLAGS_VARSUB_ATTR,
+					fsloc->nfl_flags.nfl_varsub);
+
+	return FEDFS_OK;
+}
+
+/**
+ * Add a "validfor" child to a "location" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param parent parent element to which to add "host" child
+ * @param fsloc NFS location containing host information to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_validfor_xml(__attribute__((unused)) const char *pathname,
+		xmlNodePtr parent, struct nfs_fsloc *fsloc)
+{
+	if (junction_xml_set_int_content(parent, NFS_XML_VALIDFOR_TAG,
+						fsloc->nfl_validfor) == NULL)
+		return FEDFS_ERR_SVRFAULT;
+	return FEDFS_OK;
+}
+
+/**
+ * Construct and add one "location" element to a "fileset"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param fileset fileset element of junction XML parse tree
+ * @param fsloc one NFS location to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_location_xml(const char *pathname, xmlNodePtr fileset,
+		struct nfs_fsloc *fsloc)
+{
+	FedFsStatus retval;
+	xmlNodePtr new;
+
+	new = xmlNewTextChild(fileset, NULL, NFS_XML_LOCATION_TAG, NULL);
+	if (new == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add location element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	retval = nfs_location_host_xml(pathname, new, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_location_path_xml(pathname, new, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_location_currency_xml(pathname, new, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_location_genflags_xml(pathname, new, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_location_transflags_xml(pathname, new, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_location_class_xml(pathname, new, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_location_read_xml(pathname, new, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_location_write_xml(pathname, new, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_location_flags_xml(pathname, new, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	return nfs_location_validfor_xml(pathname, new, fsloc);
+}
+
+/**
+ * Construct and add a "fileset" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param root root element of junction XML parse tree
+ * @param fslocs list of NFS locations to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_fileset_xml(const char *pathname, xmlNodePtr root,
+		struct nfs_fsloc *fslocs)
+{
+	struct nfs_fsloc *next;
+	xmlNodePtr fileset;
+	FedFsStatus retval;
+
+	fileset = xmlNewTextChild(root, NULL, JUNCTION_XML_FILESET_TAG, NULL);
+	if (fileset == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add fileset element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	for (next = fslocs; next != NULL; next = next->nfl_next) {
+		retval = nfs_location_xml(pathname, fileset, next);
+		if (retval != FEDFS_OK)
+			return retval;
+	}
+
+	return FEDFS_OK;
+}
+
+/**
+ * Construct a "savedmode" element
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param root root element of XML document tree
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_savedmode_xml(const char *pathname, xmlNodePtr root)
+{
+	xmlNodePtr savedmode;
+	FedFsStatus retval;
+	mode_t mode;
+	char buf[8];
+
+	retval = junction_get_mode(pathname, &mode);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	savedmode = xmlNewTextChild(root, NULL, JUNCTION_XML_SAVEDMODE_TAG, NULL);
+	if (savedmode == NULL) {
+		xlog(D_GENERAL, "%s: Failed to add savedmode element for %s\n",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	(void)snprintf(buf, sizeof(buf), "%o", ALLPERMS & mode);
+	xmlSetProp(savedmode, JUNCTION_XML_MODEBITS_ATTR, (const xmlChar *)buf);
+
+	return FEDFS_OK;
+}
+
+/**
+ * Construct NFS junction XML document from list of NFS locations
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param doc an XML parse tree in which to construct the junction XML document
+ * @param fslocs list of NFS locations to add
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_junction_xml(const char *pathname, xmlDocPtr doc,
+		struct nfs_fsloc *fslocs)
+{
+	FedFsStatus retval;
+	xmlNodePtr root;
+
+	root = xmlNewNode(NULL, JUNCTION_XML_ROOT_TAG);
+	if (root == NULL) {
+		xlog(D_GENERAL, "%s: Failed to create root element for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+	(void)xmlDocSetRootElement(doc, root);
+
+	retval = nfs_savedmode_xml(pathname, root);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	return nfs_fileset_xml(pathname, root, fslocs);
+}
+
+/**
+ * Write NFS locations information into an NFS junction extended attribute
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param doc an empty XML parse tree in which to construct the junction XML document
+ * @param fslocs list of NFS locations to add
+ * @return a FedFsStatus code
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+static FedFsStatus
+nfs_write_junction(const char *pathname, xmlDocPtr doc,
+		struct nfs_fsloc *fslocs)
+{
+	FedFsStatus retval;
+
+	retval = nfs_junction_xml(pathname, doc, fslocs);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	return junction_xml_write(pathname, JUNCTION_XATTR_NAME_NFS, doc);
+}
+
+/**
+ * Store NFS locations information into a junction object
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param fslocs list of NFS locations to add
+ * @return a FedFsStatus code
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+static FedFsStatus
+nfs_store_locations(const char *pathname, struct nfs_fsloc *fslocs)
+{
+	FedFsStatus retval;
+	xmlDocPtr doc;
+
+	doc = xmlNewDoc((xmlChar *)"1.0");
+	if (doc == NULL) {
+		xlog(D_GENERAL, "%s: Failed to create XML doc for %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	retval = nfs_write_junction(pathname, doc, fslocs);
+
+	xmlFreeDoc(doc);
+	return retval;
+}
+
+/**
+ * Add NFS junction information to a pre-existing object
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param fslocs list of NFS locations to add
+ * @return a FedFsStatus code
+ *
+ * An error occurs if the object referred to by "pathname" does not
+ * exist or contains existing junction data.
+ */
+FedFsStatus
+nfs_add_junction(const char *pathname, struct nfs_fsloc *fslocs)
+{
+	FedFsStatus retval;
+
+	if (fslocs == NULL)
+		return FEDFS_ERR_INVAL;
+
+	retval = nfs_is_prejunction(pathname);
+	if (retval != FEDFS_ERR_NOTJUNCT)
+		return retval;
+
+	retval = nfs_store_locations(pathname, fslocs);
+	if (retval != FEDFS_OK)
+		goto out_err;
+
+	retval = junction_save_mode(pathname);
+	if (retval != FEDFS_OK)
+		goto out_err;
+
+	return retval;
+
+out_err:
+	(void)nfs_remove_locations(pathname);
+	return retval;
+}
+
+/**
+ * Remove NFS junction information from an object
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ *
+ * An error occurs if the object referred to by "pathname" does not
+ * exist or does not contain NFS junction data.
+ */
+FedFsStatus
+nfs_delete_junction(const char *pathname)
+{
+	FedFsStatus retval;
+
+	retval = nfs_is_junction(pathname);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = junction_restore_mode(pathname);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	return nfs_remove_locations(pathname);
+}
+
+/**
+ * Parse the first "host" child of "location"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_host(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	FedFsStatus retval;
+	xmlChar *hostname;
+	xmlNodePtr node;
+	int hostport;
+
+	retval = FEDFS_ERR_NOTJUNCT;
+	node = junction_xml_find_child_by_name(location, NFS_XML_HOST_TAG);
+	if (node == NULL)
+		return retval;
+
+	hostname = xmlGetProp(node, NFS_XML_HOST_NAME_ATTR);
+	if (!junction_xml_get_int_attribute(node, NFS_XML_HOST_PORT_ATTR,
+							&hostport))
+		fsloc->nfl_hostport = NFS_PORT;
+	else {
+		if (hostport < 1 || hostport > UINT16_MAX) {
+			xlog(D_GENERAL, "%s: Bad port attribute on %s",
+				__func__, pathname);
+			goto out;
+		}
+		fsloc->nfl_hostport = (uint16_t)hostport;
+	}
+	if (hostname == NULL) {
+		xlog(D_GENERAL, "%s: No hostname attribute on %s",
+			__func__, pathname);
+		goto out;
+	}
+	fsloc->nfl_hostname = strdup((const char *)hostname);
+	if (fsloc->nfl_hostname == NULL) {
+		retval = FEDFS_ERR_SVRFAULT;
+		goto out;
+	}
+
+	retval = FEDFS_OK;
+
+out:
+	xmlFree(hostname);
+	return retval;
+}
+
+/**
+ * Parse the first "path" child of "location" into a path array
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_path(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr node, component;
+	unsigned int count;
+	xmlChar *value;
+	char **result;
+
+	node = junction_xml_find_child_by_name(location, NFS_XML_PATH_TAG);
+	if (node == NULL)
+		return FEDFS_ERR_NOTJUNCT;
+
+	count = 0;
+	for (component = node->children;
+	     component != NULL;
+	     component = component->next) {
+		if (!junction_xml_match_node_name(component,
+						NFS_XML_COMPONENT_TAG))
+			continue;
+		value = xmlNodeGetContent(component);
+		if (junction_xml_is_empty(value)) {
+			xlog(D_GENERAL, "%s: Bad pathname component in %s",
+				__func__, pathname);
+			return FEDFS_ERR_NOTJUNCT;
+		}
+		xmlFree(value);
+		count++;
+	}
+	xlog(D_GENERAL, "%s: Found %u component(s)", __func__, count);
+
+	if (count == 0) {
+		xlog(D_GENERAL, "%s: Zero-component pathname", __func__);
+		fsloc->nfl_rootpath = (char **)calloc(1, sizeof(char *));
+		if (fsloc->nfl_rootpath == NULL)
+			return FEDFS_ERR_SVRFAULT;
+		fsloc->nfl_rootpath[0] = NULL;
+		return FEDFS_OK;
+	}
+
+	result = calloc(count + 1, sizeof(char *));
+	if (result == NULL)
+		return FEDFS_ERR_SVRFAULT;
+
+	count = 0;
+	for (component = node->children;
+	     component != NULL;
+	     component = component->next) {
+		if (!junction_xml_match_node_name(component,
+						NFS_XML_COMPONENT_TAG))
+			continue;
+		value = xmlNodeGetContent(component);
+		result[count] = strdup((const char *)value);
+		xmlFree(value);
+		if (result[count] == NULL) {
+			nfs_free_string_array(result);
+			return FEDFS_ERR_SVRFAULT;
+		}
+		count++;
+	}
+
+	fsloc->nfl_rootpath = result;
+	return FEDFS_OK;
+}
+
+/**
+ * Parse the first "currency" child of "location"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_currency(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr node;
+
+	node = junction_xml_find_child_by_name(location, NFS_XML_CURRENCY_TAG);
+	if (node == NULL)
+		goto out_err;
+
+	if (!junction_xml_get_int_content(node, &fsloc->nfl_currency))
+		goto out_err;
+
+	return FEDFS_OK;
+
+out_err:
+	xlog(D_GENERAL, "%s: Missing or invalid currency element in %s",
+		__func__, pathname);
+	return FEDFS_ERR_NOTJUNCT;
+}
+
+/**
+ * Parse the first "genflags" child of "location"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_genflags(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr node;
+
+	node = junction_xml_find_child_by_name(location, NFS_XML_GENFLAGS_TAG);
+	if (node == NULL)
+		goto out_err;
+
+	if (!junction_xml_get_bool_attribute(node,
+					NFS_XML_GENFLAGS_WRITABLE_ATTR,
+					&fsloc->nfl_genflags.nfl_writable))
+		goto out_err;
+	if (!junction_xml_get_bool_attribute(node,
+					NFS_XML_GENFLAGS_GOING_ATTR,
+					&fsloc->nfl_genflags.nfl_going))
+		goto out_err;
+	if (!junction_xml_get_bool_attribute(node,
+					NFS_XML_GENFLAGS_SPLIT_ATTR,
+					&fsloc->nfl_genflags.nfl_split))
+		goto out_err;
+
+	return FEDFS_OK;
+
+out_err:
+	xlog(D_GENERAL, "%s: Missing or invalid genflags element in %s",
+		__func__, pathname);
+	return FEDFS_ERR_NOTJUNCT;
+}
+
+/**
+ * Parse the first "transflags" child of "location"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_transflags(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr node;
+
+	node = junction_xml_find_child_by_name(location, NFS_XML_TRANSFLAGS_TAG);
+	if (node == NULL)
+		goto out_err;
+
+	if (!junction_xml_get_bool_attribute(node,
+					NFS_XML_TRANSFLAGS_RDMA_ATTR,
+					&fsloc->nfl_transflags.nfl_rdma))
+		goto out_err;
+
+	return FEDFS_OK;
+
+out_err:
+	xlog(D_GENERAL, "%s: Missing or invalid transflags element in %s",
+		__func__, pathname);
+	return FEDFS_ERR_NOTJUNCT;
+}
+
+/**
+ * Parse the first "class" child of "location"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_class(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr node;
+
+	node = junction_xml_find_child_by_name(location, NFS_XML_CLASS_TAG);
+	if (node == NULL)
+		goto out_err;
+
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_CLASS_SIMUL_ATTR,
+					&fsloc->nfl_info.nfl_simul))
+		goto out_err;
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_CLASS_HANDLE_ATTR,
+					&fsloc->nfl_info.nfl_handle))
+		goto out_err;
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_CLASS_FILEID_ATTR,
+					&fsloc->nfl_info.nfl_fileid))
+		goto out_err;
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_CLASS_WRITEVER_ATTR,
+					&fsloc->nfl_info.nfl_writever))
+		goto out_err;
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_CLASS_WRITEVER_ATTR,
+					&fsloc->nfl_info.nfl_writever))
+		goto out_err;
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_CLASS_CHANGE_ATTR,
+					&fsloc->nfl_info.nfl_change))
+		goto out_err;
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_CLASS_READDIR_ATTR,
+					&fsloc->nfl_info.nfl_readdir))
+		goto out_err;
+
+	return FEDFS_OK;
+
+out_err:
+	xlog(D_GENERAL, "%s: Missing or invalid class element in %s",
+		__func__, pathname);
+	return FEDFS_ERR_NOTJUNCT;
+}
+
+/**
+ * Parse the first "read" child of "location"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_read(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr node;
+
+	node = junction_xml_find_child_by_name(location, NFS_XML_READ_TAG);
+	if (node == NULL)
+		goto out_err;
+
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_READ_RANK_ATTR,
+					&fsloc->nfl_info.nfl_readrank))
+		goto out_err;
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_READ_ORDER_ATTR,
+					&fsloc->nfl_info.nfl_readorder))
+		goto out_err;
+
+	return FEDFS_OK;
+
+out_err:
+	xlog(D_GENERAL, "%s: Missing or invalid read element in %s",
+		__func__, pathname);
+	return FEDFS_ERR_NOTJUNCT;
+}
+
+/**
+ * Parse the first "write" child of "location"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_write(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr node;
+
+	node = junction_xml_find_child_by_name(location, NFS_XML_WRITE_TAG);
+	if (node == NULL)
+		goto out_err;
+
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_WRITE_RANK_ATTR,
+					&fsloc->nfl_info.nfl_writerank))
+		goto out_err;
+	if (!junction_xml_get_u8_attribute(node,
+					NFS_XML_WRITE_ORDER_ATTR,
+					&fsloc->nfl_info.nfl_writeorder))
+		goto out_err;
+
+	return FEDFS_OK;
+
+out_err:
+	xlog(D_GENERAL, "%s: Missing or invalid write element in %s",
+		__func__, pathname);
+	return FEDFS_ERR_NOTJUNCT;
+}
+
+/**
+ * Parse the first "flags" child of "location"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_flags(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr node;
+
+	node = junction_xml_find_child_by_name(location, NFS_XML_FLAGS_TAG);
+	if (node == NULL)
+		goto out_err;
+
+	if (!junction_xml_get_bool_attribute(node,
+					NFS_XML_FLAGS_VARSUB_ATTR,
+					&fsloc->nfl_flags.nfl_varsub))
+		goto out_err;
+
+	return FEDFS_OK;
+
+out_err:
+	xlog(D_GENERAL, "%s: Missing or invalid flags element in %s",
+		__func__, pathname);
+	return FEDFS_ERR_NOTJUNCT;
+}
+
+/**
+ * Parse the first "validfor" child of "location"
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ */
+static FedFsStatus
+nfs_parse_location_validfor(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	xmlNodePtr node;
+
+	node = junction_xml_find_child_by_name(location, NFS_XML_VALIDFOR_TAG);
+	if (node == NULL)
+		goto out_err;
+
+	if (!junction_xml_get_int_content(node, &fsloc->nfl_validfor))
+		goto out_err;
+
+	return FEDFS_OK;
+
+out_err:
+	xlog(D_GENERAL, "%s: Missing or invalid validfor element in %s",
+		__func__, pathname);
+	return FEDFS_ERR_NOTJUNCT;
+}
+
+/**
+ * Parse children of NFS location element in an NFS junction
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc a blank nfs_fsloc to fill in
+ * @return a FedFsStatus code
+ *
+ * All children are required only-once elements, and may appear in any order.
+ * Extraneous or repeated elements are ignored for now.
+ */
+static FedFsStatus
+nfs_parse_location_children(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc *fsloc)
+{
+	FedFsStatus retval;
+
+	retval = nfs_parse_location_host(pathname, location, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_parse_location_path(pathname, location, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_parse_location_currency(pathname, location, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_parse_location_genflags(pathname, location, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_parse_location_transflags(pathname, location, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_parse_location_class(pathname, location, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_parse_location_read(pathname, location, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_parse_location_write(pathname, location, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	retval = nfs_parse_location_flags(pathname, location, fsloc);
+	if (retval != FEDFS_OK)
+		return retval;
+	return nfs_parse_location_validfor(pathname, location, fsloc);
+}
+
+/**
+ * Parse NFS location element in an NFS junction
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param location XML parse tree containing fileset location element
+ * @param fsloc OUT: a single NFS location item
+ * @return a FedFsStatus code
+ *
+ * If nfs_parse_location() returns FEDFS_OK, caller must free the returned
+ * location with nfs_free_location().
+ */
+static FedFsStatus
+nfs_parse_node(const char *pathname, xmlNodePtr location,
+		struct nfs_fsloc **fsloc)
+{
+	struct nfs_fsloc *tmp;
+	FedFsStatus retval;
+
+	tmp = nfs_new_location();
+	if (tmp == NULL)
+		return FEDFS_ERR_SVRFAULT;
+
+	retval = nfs_parse_location_children(pathname, location, tmp);
+	if (retval != FEDFS_OK)
+		nfs_free_location(tmp);
+	else
+		*fsloc = tmp;
+	return retval;
+}
+
+/**
+ * Build list of NFS locations from a nodeset
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param nodeset XML nodeset containing "location" elements
+ * @param fslocs OUT: pointer to a list of NFS locations
+ * @return a FedFsStatus code
+ *
+ * If nfs_parse_nodeset() returns FEDFS_OK, caller must free the returned
+ * list of locations with nfs_free_locations().
+ */
+static FedFsStatus
+nfs_parse_nodeset(const char *pathname, xmlNodeSetPtr nodeset,
+		struct nfs_fsloc **fslocs)
+{
+	struct nfs_fsloc *location, *result = NULL;
+	FedFsStatus retval;
+	int i;
+
+	if (xmlXPathNodeSetIsEmpty(nodeset)) {
+		xlog(D_GENERAL, "%s: No fileset locations found in %s",
+			__func__, pathname);
+		return FEDFS_ERR_NOTJUNCT;
+	}
+
+	for (i = 0; i < nodeset->nodeNr; i++) {
+		xmlNodePtr node = nodeset->nodeTab[i];
+
+		retval = nfs_parse_node(pathname, node, &location);
+		if (retval != FEDFS_OK) {
+			nfs_free_locations(result);
+			return retval;
+		}
+
+		if (result == NULL)
+			result = location;
+		else
+			result->nfl_next = location;
+	}
+
+	*fslocs = result;
+	return FEDFS_OK;
+}
+
+/**
+ * Parse fileset location information from junction XML
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param context XML path context containing junction XML
+ * @param fslocs OUT: pointer to a list of NFS locations
+ * @return a FedFsStatus code
+ *
+ * If nfs_parse_context() returns FEDFS_OK, caller must free the returned
+ * list of locations with nfs_free_locations().
+ */
+static FedFsStatus
+nfs_parse_context(const char *pathname, xmlXPathContextPtr context,
+		struct nfs_fsloc **fslocs)
+{
+	xmlXPathObjectPtr object;
+	FedFsStatus retval;
+
+	object = xmlXPathEvalExpression(NFS_XML_LOCATION_XPATH, context);
+	if (object == NULL) {
+		xlog(D_GENERAL, "%s: Failed to evaluate XML in %s",
+			__func__, pathname);
+		return FEDFS_ERR_NOTJUNCT;
+	}
+
+	retval = nfs_parse_nodeset(pathname, object->nodesetval, fslocs);
+
+	xmlXPathFreeObject(object);
+	return retval;
+}
+
+/**
+ * Parse NFS locations information from junction XML
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param doc XML parse tree containing junction XML document
+ * @param fslocs OUT: pointer to a list of NFS locations
+ * @return a FedFsStatus code
+ *
+ * If nfs_parse_xml() returns FEDFS_OK, caller must free the returned
+ * list of locations with nfs_free_locations().
+ */
+static FedFsStatus
+nfs_parse_xml(const char *pathname, xmlDocPtr doc, struct nfs_fsloc **fslocs)
+{
+	xmlXPathContextPtr context;
+	FedFsStatus retval;
+
+	context = xmlXPathNewContext(doc);
+	if (context == NULL) {
+		xlog(D_GENERAL, "%s: Failed to create XPath context from %s",
+			__func__, pathname);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	retval = nfs_parse_context(pathname, context, fslocs);
+
+	xmlXPathFreeContext(context);
+	return retval;
+}
+
+/**
+ * Retrieve list of NFS locations from an NFS junction
+ *
+ * @param pathname NUL-terminated C string containing pathname of a junction
+ * @param fslocs OUT: pointer to a list of NFS locations
+ * @return a FedFsStatus code
+ *
+ * If nfs_get_locations() returns FEDFS_OK, caller must free the returned
+ * list of locations with nfs_free_locations().
+ */
+FedFsStatus
+nfs_get_locations(const char *pathname, struct nfs_fsloc **fslocs)
+{
+	FedFsStatus retval;
+	xmlDocPtr doc;
+
+	if (fslocs == NULL)
+		return FEDFS_ERR_INVAL;
+
+	retval = junction_xml_parse(pathname, JUNCTION_XATTR_NAME_NFS, &doc);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = nfs_parse_xml(pathname, doc, fslocs);
+
+	xmlFreeDoc(doc);
+	return retval;
+}
+
+/**
+ * Predicate: does "pathname" refer to an object that can become an NFS junction?
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ *
+ * Return values:
+ *	FEDFS_ERR_NOTJUNCT:	"pathname" refers to an object that can be
+ *				made into a NFS junction
+ *	FEDFS_ERR_EXIST:	"pathname" refers to something that is
+ *				already a junction
+ *	FEDFS_ERR_INVAL:	"pathname" does not exist
+ *	Other:			Some error occurred, "pathname" not
+ *				investigated
+ */
+FedFsStatus
+nfs_is_prejunction(const char *pathname)
+{
+	FedFsStatus retval;
+	int fd;
+
+	retval = junction_open_path(pathname, &fd);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = junction_is_directory(fd, pathname);
+	if (retval != FEDFS_OK)
+		goto out_close;
+
+	retval = junction_is_sticky_bit_set(fd, pathname);
+	switch (retval) {
+	case FEDFS_ERR_NOTJUNCT:
+		break;
+	case FEDFS_OK:
+		goto out_exist;
+	default:
+		goto out_close;
+	}
+
+	retval = junction_is_xattr_present(fd, pathname, JUNCTION_XATTR_NAME_NFS);
+	switch (retval) {
+	case FEDFS_ERR_NOTJUNCT:
+		break;
+	case FEDFS_OK:
+		goto out_exist;
+	default:
+		goto out_close;
+	}
+
+out_close:
+	(void)close(fd);
+	return retval;
+out_exist:
+	retval = FEDFS_ERR_EXIST;
+	goto out_close;
+}
+
+/**
+ * Verify that junction contains NFS junction XML
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ *
+ * Return values:
+ *	FEDFS_OK:		"pathname" refers to an NFS junction
+ *	FEDFS_ERR_NOTJUNCT:	"pathname" refers to something that is
+ *				not an NFS junction
+ *	FEDFS_ERR_INVAL:	"pathname" does not exist
+ *	Other:			Some error occurred, "pathname" not
+ *				investigated
+ *
+ * NB: This is an expensive test.  However, it is only done if the object
+ * actually has a junction extended attribute, meaning it should be done
+ * rarely.  If this is really a problem, we can make the XML test cheaper.
+ */
+static FedFsStatus
+nfs_is_junction_xml(const char *pathname)
+{
+	struct nfs_fsloc *fslocs = NULL;
+	FedFsStatus retval;
+	xmlDocPtr doc;
+
+	retval = junction_xml_parse(pathname, JUNCTION_XATTR_NAME_NFS, &doc);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = nfs_parse_xml(pathname, doc, &fslocs);
+	nfs_free_locations(fslocs);
+
+	xmlFreeDoc(doc);
+	return retval;
+}
+
+/**
+ * Predicate: does "pathname" refer to an NFS junction?
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @return a FedFsStatus code
+ *
+ * Return values:
+ *	FEDFS_OK:		"pathname" refers to an NFS junction
+ *	FEDFS_ERR_NOTJUNCT:	"pathname" refers to an object that is
+ *				not a junction
+ *	FEDFS_ERR_INVAL:	"pathname" does not exist
+ *	Other:			Some error occurred, "pathname" not
+ *				investigated
+ */
+FedFsStatus
+nfs_is_junction(const char *pathname)
+{
+	FedFsStatus retval;
+	int fd;
+
+	retval = junction_open_path(pathname, &fd);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = junction_is_directory(fd, pathname);
+	if (retval != FEDFS_OK)
+		goto out_close;
+
+	retval = junction_is_sticky_bit_set(fd, pathname);
+	if (retval != FEDFS_OK)
+		goto out_close;
+
+	retval = junction_is_xattr_present(fd, pathname, JUNCTION_XATTR_NAME_NFS);
+	if (retval != FEDFS_OK)
+		goto out_close;
+
+	(void)close(fd);
+
+	return nfs_is_junction_xml(pathname);
+
+out_close:
+	(void)close(fd);
+	return retval;
+}
diff --git a/support/junction/path.c b/support/junction/path.c
new file mode 100644
index 0000000..d33808f
--- /dev/null
+++ b/support/junction/path.c
@@ -0,0 +1,345 @@
+/**
+ * @file support/junction/path.c
+ * @brief Encode and decode FedFS pathnames
+ */
+
+/*
+ * Copyright 2010, 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+
+#include <stdbool.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <errno.h>
+
+#include <netinet/in.h>
+
+#include "junction.h"
+#include "xlog.h"
+
+#define STRLEN_SLASH	((size_t)1)	/* strlen("/") */
+
+#define XDR_UINT_BYTES	(sizeof(uint32_t))
+
+/**
+ * Compute count of XDR 4-octet units from byte count
+ *
+ * @param bytes number of bytes to convert
+ * @return equivalent number of XDR 4-octet units
+ */
+static inline size_t
+nsdb_quadlen(size_t bytes)
+{
+	return (bytes + 3) >> 2;
+}
+
+/**
+ * Free array of NUL-terminated C strings
+ *
+ * @param strings array of char * to be released
+ */
+void
+nsdb_free_string_array(char **strings)
+{
+	int i;
+
+	if (strings == NULL)
+		return;
+	for (i = 0; strings[i] != NULL; i++)
+		free(strings[i]);
+	free(strings);
+}
+
+static FedFsStatus
+nsdb_alloc_zero_component_pathname(char ***path_array)
+{
+	char **result;
+
+	xlog(D_GENERAL, "%s: Zero-component pathname", __func__);
+
+	result = (char **)calloc(1, sizeof(char *));
+	if (result == NULL)
+		return FEDFS_ERR_SVRFAULT;
+	result[0] = NULL;
+	*path_array = result;
+	return FEDFS_OK;
+}
+
+/**
+ * Sanitize an incoming POSIX path
+ *
+ * @param pathname NUL-terminated C string containing a POSIX pathname
+ * @return NUL-terminated C string containing sanitized path
+ *
+ * Caller must free the returned pathname with free(3).
+ *
+ * Remove multiple sequential slashes and any trailing slashes,
+ * but leave "/" by itself alone.
+ */
+static __attribute_malloc__ char *
+nsdb_normalize_path(const char *pathname)
+{
+	size_t i, j, len;
+	char *result;
+
+	len = strlen(pathname);
+	if (len == 0) {
+		xlog(D_CALL, "%s: NULL pathname", __func__);
+		return NULL;
+	}
+
+	result = malloc(len + 1);
+	if (result == NULL)
+		return NULL;
+
+	for (i = 0, j = 0; i < len; i++) {
+		if (pathname[i] == '/' && pathname[i + 1] == '/')
+			continue;
+		result[j++] = pathname[i];
+	}
+	result[j] = '\0';
+
+	if (j > 1 && result[j - 1] == '/')
+		result[j - 1] = '\0';
+
+	xlog(D_CALL, "%s: result = '%s'", __func__, result);
+	return result;
+}
+
+/**
+ * Count the number of components in a POSIX pathname
+ *
+ * @param pathname NUL-terminated C string containing a POSIX pathname
+ * @param len OUT: number of bytes the encoded XDR stream will consume
+ * @param cnt OUT: component count
+ * @return true when successful
+ */
+static _Bool
+nsdb_count_components(const char *pathname, size_t *len,
+		unsigned int *cnt)
+{
+	char *start, *component;
+	unsigned int count;
+	size_t length;
+
+	/* strtok(3) will tromp on the string */
+	start = strdup(pathname);
+	if (start == NULL)
+		return false;
+
+	length = XDR_UINT_BYTES;
+	count = 0;
+	component = start;
+	for ( ;; ) {
+		char *next;
+		size_t tmp;
+
+		if (*component == '/')
+			component++;
+		if (*component == '\0')
+			break;
+		next = strchrnul(component, '/');
+		tmp = (size_t)(next - component);
+		if (tmp > 255)
+			return false;
+		length += XDR_UINT_BYTES + (nsdb_quadlen(tmp) << 2);
+		count++;
+
+		if (*next == '\0')
+			break;
+		component = next;
+	}
+
+	free(start);
+
+	xlog(D_CALL, "%s: length = %zu, count = %u, path = '%s'",
+		__func__, length, count, pathname);
+	*len = length;
+	*cnt = count;
+	return true;
+}
+
+/**
+ * Predicate: is input character set for a POSIX pathname valid UTF-8?
+ *
+ * @param pathname NUL-terminated C string containing a POSIX path
+ * @return true if the string is valid UTF-8
+ *
+ * XXX: implement this
+ */
+static _Bool
+nsdb_pathname_is_utf8(__attribute__((unused)) const char *pathname)
+{
+	return true;
+}
+
+/**
+ * Construct a local POSIX-style pathname from an array of component strings
+ *
+ * @param path_array array of pointers to NUL-terminated C strings
+ * @param pathname OUT: pointer to NUL-terminated UTF-8 C string containing a POSIX-style path
+ * @return a FedFsStatus code
+ *
+ * Caller must free the returned pathname with free(3).
+ */
+FedFsStatus
+nsdb_path_array_to_posix(char * const *path_array, char **pathname)
+{
+	char *component, *result;
+	unsigned int i, count;
+	size_t length, len;
+
+	if (path_array == NULL || pathname == NULL)
+		return FEDFS_ERR_INVAL;
+
+	if (path_array[0] == NULL) {
+		xlog(D_GENERAL, "%s: Zero-component pathname", __func__);
+		result = strdup("/");
+		if (result == NULL)
+			return FEDFS_ERR_SVRFAULT;
+		*pathname = result;
+		return FEDFS_OK;
+	}
+
+	for (length = 0, count = 0;
+	     path_array[count] != NULL;
+	     count++) {
+		component = path_array[count];
+		len = strlen(component);
+
+		if (len == 0) {
+			xlog(D_GENERAL, "%s: Zero-length component", __func__);
+			return FEDFS_ERR_BADNAME;
+		}
+		if (len > NAME_MAX) {
+			xlog(D_GENERAL, "%s: Component length too long", __func__);
+			return FEDFS_ERR_NAMETOOLONG;
+		}
+		if (strchr(component, '/') != NULL) {
+			xlog(D_GENERAL, "%s: Local separator character "
+					"found in component", __func__);
+			return FEDFS_ERR_BADNAME;
+		}
+		if (!nsdb_pathname_is_utf8(component)) {
+			xlog(D_GENERAL, "%s: Bad character in component",
+				__func__);
+			return FEDFS_ERR_BADCHAR;
+		}
+
+		length += STRLEN_SLASH + len;
+
+		if (length > PATH_MAX) {
+			xlog(D_GENERAL, "%s: Pathname too long", __func__);
+			return FEDFS_ERR_NAMETOOLONG;
+		}
+	}
+
+	result = calloc(1, length + 1);
+	if (result == NULL)
+		return FEDFS_ERR_SVRFAULT;
+
+	for (i = 0; i < count; i++) {
+		strcat(result, "/");
+		strcat(result, path_array[i]);
+	}
+	*pathname = nsdb_normalize_path(result);
+	free(result);
+	if (*pathname == NULL)
+		return FEDFS_ERR_SVRFAULT;
+	return FEDFS_OK;
+}
+
+/**
+ * Construct an array of component strings from a local POSIX-style pathname
+ *
+ * @param pathname NUL-terminated C string containing a POSIX-style pathname
+ * @param path_array OUT: pointer to array of pointers to NUL-terminated C strings
+ * @return a FedFsStatus code
+ *
+ * Caller must free "path_array" with nsdb_free_string_array().
+ */
+FedFsStatus
+nsdb_posix_to_path_array(const char *pathname, char ***path_array)
+{
+	char *normalized, *component, **result;
+	unsigned int i, count;
+	size_t length;
+
+	if (pathname == NULL || path_array == NULL)
+		return FEDFS_ERR_INVAL;
+
+	if (!nsdb_pathname_is_utf8(pathname)) {
+		xlog(D_GENERAL, "%s: Bad character in pathname", __func__);
+		return FEDFS_ERR_BADCHAR;
+	}
+
+	normalized = nsdb_normalize_path(pathname);
+	if (normalized == NULL)
+		return FEDFS_ERR_SVRFAULT;
+
+	if (!nsdb_count_components(normalized, &length, &count)) {
+		free(normalized);
+		return FEDFS_ERR_BADNAME;
+	}
+
+	if (count == 0) {
+		free(normalized);
+		return nsdb_alloc_zero_component_pathname(path_array);
+	}
+
+	result = (char **)calloc(count + 1, sizeof(char *));
+	if (result == NULL) {
+		free(normalized);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	component = normalized;
+	for (i = 0; ; i++) {
+		char *next;
+
+		if (*component == '/')
+			component++;
+		if (*component == '\0')
+			break;
+		next = strchrnul(component, '/');
+		length = (size_t)(next - component);
+		if (length > 255)
+			return FEDFS_ERR_SVRFAULT;
+
+		result[i] = strndup(component, length);
+		if (result[i] == NULL) {
+			nsdb_free_string_array(result);
+			return FEDFS_ERR_SVRFAULT;
+		}
+
+		if (*next == '\0')
+			break;
+		component = next;
+	}
+
+	*path_array = result;
+	free(normalized);
+	return FEDFS_OK;
+}
diff --git a/support/junction/xml.c b/support/junction/xml.c
new file mode 100644
index 0000000..79b0770
--- /dev/null
+++ b/support/junction/xml.c
@@ -0,0 +1,401 @@
+/**
+ * @file support/junction/xml.c
+ * @brief Common utilities for managing junction XML
+ */
+
+/*
+ * Copyright 2011, 2018 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2.0 as
+ * published by the Free Software Foundation.
+ *
+ * nfs-utils is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License version 2.0 for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2.0 along with nfs-utils.  If not, see:
+ *
+ *	http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+ */
+
+#include <sys/types.h>
+#include <sys/stat.h>
+
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+
+#include "junction.h"
+#include "junction-internal.h"
+#include "xlog.h"
+
+/**
+ * Predicate: is element content empty?
+ *
+ * @param content element content to test
+ * @return true if content is empty
+ */
+_Bool
+junction_xml_is_empty(const xmlChar *content)
+{
+	return content == NULL || *content == '\0';
+}
+
+/**
+ * Match an XML parse tree node by its name
+ *
+ * @param node pointer to a node in an XML parse tree
+ * @param name NUL-terminated C string containing name to match
+ * @return true if "node" is named "name"
+ */
+_Bool
+junction_xml_match_node_name(xmlNodePtr node, const xmlChar *name)
+{
+	return (node->type == XML_ELEMENT_NODE) &&
+		(xmlStrcmp(node->name, name) == 0);
+}
+
+/**
+ * Find a first-level child of "parent" named "name"
+ *
+ * @param parent pointer to node whose children are to be searched
+ * @param name NUL-terminated C string containing name to match
+ * @return pointer to child of "parent" whose name is "name"
+ */
+xmlNodePtr
+junction_xml_find_child_by_name(xmlNodePtr parent, const xmlChar *name)
+{
+	xmlNodePtr node;
+
+	for (node = parent->children; node != NULL; node = node->next)
+		if (junction_xml_match_node_name(node, name))
+			return node;
+	return NULL;
+}
+
+/**
+ * Read attribute into a boolean
+ *
+ * @param node pointer to a node in an XML parse tree
+ * @param attrname NUL-terminated C string containing attribute name
+ * @param value OUT: attribute's value converted to an integer
+ * @return true if attribute "attrname" has a valid boolean value
+ */
+_Bool
+junction_xml_get_bool_attribute(xmlNodePtr node, const xmlChar *attrname,
+		_Bool *value)
+{
+	xmlChar *prop;
+	_Bool retval;
+
+	retval = false;
+	prop = xmlGetProp(node, attrname);
+	if (prop == NULL)
+		goto out;
+
+	if (xmlStrcmp(prop, (const xmlChar *)"true") == 0) {
+		*value = true;
+		retval = true;
+		goto out;
+	}
+
+	if (xmlStrcmp(prop, (const xmlChar *)"false") == 0) {
+		*value = false;
+		retval = true;
+		goto out;
+	}
+
+out:
+	xmlFree(prop);
+	return retval;
+}
+
+/**
+ * Set attribute to a boolean
+ *
+ * @param node pointer to a node in an XML parse tree
+ * @param attrname NUL-terminated C string containing attribute name
+ * @param value boolean value to set
+ */
+void
+junction_xml_set_bool_attribute(xmlNodePtr node, const xmlChar *attrname,
+					_Bool value)
+{
+	xmlSetProp(node, attrname, (const xmlChar *)(value ? "true" : "false"));
+}
+
+/**
+ * Read attribute into an uint8_t
+ *
+ * @param node pointer to a node in an XML parse tree
+ * @param attrname NUL-terminated C string containing attribute name
+ * @param value OUT: attribute's value converted to an uint8_t
+ * @return true if attribute "attrname" has a valid uint8_t value
+ */
+_Bool
+junction_xml_get_u8_attribute(xmlNodePtr node, const xmlChar *attrname,
+		uint8_t *value)
+{
+	char *endptr;
+	_Bool retval;
+	char *prop;
+	long tmp;
+
+	retval = false;
+	prop = (char *)xmlGetProp(node, attrname);
+	if (prop == NULL)
+		goto out;
+
+	errno = 0;
+	tmp = strtol(prop, &endptr, 10);
+	if (errno != 0 || *endptr != '\0' || tmp > 255 || tmp < 0)
+		goto out;
+
+	*value = (uint8_t)tmp;
+	retval = true;
+
+out:
+	xmlFree(prop);
+	return retval;
+}
+
+/**
+ * Read attribute into an integer
+ *
+ * @param node pointer to a node in an XML parse tree
+ * @param attrname NUL-terminated C string containing attribute name
+ * @param value OUT: attribute's value converted to an integer
+ * @return true if attribute "attrname" has a valid integer value
+ */
+_Bool
+junction_xml_get_int_attribute(xmlNodePtr node, const xmlChar *attrname,
+		int *value)
+{
+	char *endptr;
+	_Bool retval;
+	char *prop;
+	long tmp;
+
+	retval = false;
+	prop = (char *)xmlGetProp(node, attrname);
+	if (prop == NULL)
+		goto out;
+
+	errno = 0;
+	tmp = strtol(prop, &endptr, 10);
+	if (errno != 0 || *endptr != '\0' || tmp > INT32_MAX || tmp < INT32_MIN)
+		goto out;
+
+	*value = (int)tmp;
+	retval = true;
+
+out:
+	xmlFree(prop);
+	return retval;
+}
+
+/**
+ * Set attribute to an integer
+ *
+ * @param node pointer to a node in an XML parse tree
+ * @param attrname NUL-terminated C string containing attribute name
+ * @param value integer value to set
+ */
+void
+junction_xml_set_int_attribute(xmlNodePtr node, const xmlChar *attrname,
+		int value)
+{
+	char buf[16];
+
+	snprintf(buf, sizeof(buf), "%d", value);
+	xmlSetProp(node, attrname, (const xmlChar *)buf);
+}
+
+/**
+ * Read node content into an integer
+ *
+ * @param node pointer to a node in an XML parse tree
+ * @param value OUT: node's content converted to an integer
+ * @return true if "node" has valid integer content
+ */
+_Bool
+junction_xml_get_int_content(xmlNodePtr node, int *value)
+{
+	xmlChar *content;
+	char *endptr;
+	_Bool retval;
+	long tmp;
+
+	retval = false;
+	content = xmlNodeGetContent(node);
+	if (content == NULL)
+		goto out;
+
+	errno = 0;
+	tmp = strtol((const char *)content, &endptr, 10);
+	if (errno != 0 || *endptr != '\0' || tmp > INT32_MAX || tmp < INT32_MIN)
+		goto out;
+
+	*value = (int)tmp;
+	retval = true;
+
+out:
+	xmlFree(content);
+	return retval;
+}
+
+/**
+ * Add a child node with integer content
+ *
+ * @param parent  pointer to a node in an XML parse tree
+ * @param name NUL-terminated C string containing name of child to add
+ * @param value set node content to this value
+ * @return pointer to new child node
+ */
+xmlNodePtr
+junction_xml_set_int_content(xmlNodePtr parent, const xmlChar *name, int value)
+{
+	char buf[16];
+
+	snprintf(buf, sizeof(buf), "%d", value);
+	return xmlNewTextChild(parent, NULL, name, (const xmlChar *)buf);
+}
+
+/**
+ * Parse XML document in a buffer into an XML document tree
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @param name NUL-terminated C string containing name of xattr to replace
+ * @param buf opaque byte array containing XML to parse
+ * @param len size of "buf" in bytes
+ * @param doc OUT: an XML parse tree containing junction XML
+ * @return a FedFsStatus code
+ *
+ * If junction_parse_xml_buf() returns success, caller must free "*doc"
+ * using xmlFreeDoc(3).
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+static FedFsStatus
+junction_parse_xml_buf(const char *pathname, const char *name,
+		void *buf, size_t len, xmlDocPtr *doc)
+{
+	xmlDocPtr tmp;
+
+	tmp = xmlParseMemory(buf, (int)len);
+	if (tmp == NULL) {
+		xlog(D_GENERAL, "Failed to parse XML in %s(%s)\n",
+			pathname, name);
+		return FEDFS_ERR_SVRFAULT;
+	}
+
+	*doc = tmp;
+	return FEDFS_OK;
+}
+
+/**
+ * Read an XML document from an extended attribute into an XML document tree
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @param fd an open file descriptor
+ * @param name NUL-terminated C string containing name of xattr to replace
+ * @param doc OUT: an XML parse tree containing junction XML
+ * @return a FedFsStatus code
+ *
+ * If junction_parse_xml_read() returns success, caller must free "*doc"
+ * using xmlFreeDoc(3).
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+static FedFsStatus
+junction_parse_xml_read(const char *pathname, int fd, const char *name,
+		xmlDocPtr *doc)
+{
+	FedFsStatus retval;
+	void *buf = NULL;
+	size_t len;
+
+	retval = junction_get_xattr(fd, pathname, name, &buf, &len);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	xlog(D_CALL, "%s: XML document contained in junction:\n%.*s",
+		__func__, len, buf);
+
+	retval = junction_parse_xml_buf(pathname, name, buf, len, doc);
+
+	free(buf);
+	return retval;
+}
+
+/**
+ * Read an XML document from an extended attribute into an XML document tree
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @param name NUL-terminated C string containing name of xattr to replace
+ * @param doc OUT: an XML parse tree containing junction XML
+ * @return a FedFsStatus code
+ *
+ * If junction_parse_xml() returns success, caller must free "*doc"
+ * using xmlFreeDoc(3).
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+FedFsStatus
+junction_xml_parse(const char *pathname, const char *name, xmlDocPtr *doc)
+{
+	FedFsStatus retval;
+	int fd;
+
+	retval = junction_open_path(pathname, &fd);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = junction_parse_xml_read(pathname, fd, name, doc);
+
+	(void)close(fd);
+	return retval;
+}
+
+/**
+ * Write an XML document into an extended attribute
+ *
+ * @param pathname NUL-terminated C string containing pathname of a directory
+ * @param name NUL-terminated C string containing name of xattr to replace
+ * @param doc an XML parse tree containing junction XML
+ * @return a FedFsStatus code
+ *
+ * @note Access to trusted attributes requires CAP_SYS_ADMIN.
+ */
+FedFsStatus
+junction_xml_write(const char *pathname, const char *name, xmlDocPtr doc)
+{
+	xmlChar *buf = NULL;
+	FedFsStatus retval;
+	int fd, len;
+
+	retval = junction_open_path(pathname, &fd);
+	if (retval != FEDFS_OK)
+		return retval;
+
+	retval = FEDFS_ERR_SVRFAULT;
+	xmlIndentTreeOutput = 1;
+	xmlDocDumpFormatMemoryEnc(doc, &buf, &len, "UTF-8", 1);
+	if (len < 0)
+		goto out;
+
+	retval = junction_set_xattr(fd, pathname, name, buf, (size_t)len);
+
+out:
+	xmlFree(buf);
+	(void)close(fd);
+	return retval;
+}

