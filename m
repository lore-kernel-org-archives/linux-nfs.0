Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:37138 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750864AbeAHVuJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jan 2018 16:50:09 -0500
Received: by mail-io0-f176.google.com with SMTP id n14so16240299iob.4
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jan 2018 13:50:08 -0800 (PST)
Received: from manet.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id b34sm7622527itd.31.2018.01.08.13.50.07
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 13:50:07 -0800 (PST)
Subject: [PATCH RFC 2/3] Add LDAP-free version of libnfsjunct to nfs-utils
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 08 Jan 2018 16:50:07 -0500
Message-ID: <20180108215007.20133.81237.stgit@manet.1015granger.net>
In-Reply-To: <20180108213356.20133.54161.stgit@manet.1015granger.net>
References: <20180108213356.20133.54161.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

libnfsjunct is a dynamic library that mountd can load to enable
the Linux NFS server to support junctions. This patch moves the
non-LDAP parts of libnfsjunct into nfs-utils. This enables mountd to
continue to recognize and support NFS basic junctions.

mountd works fine whether or not there is a libnfsjunct installed
on the local system, just as it did before. Without libnfsjunct,
junctions on the NFS server appear to NFS clients like weird
directories.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 support/include/Makefile.am   |    1 
 support/include/nfs-plugin.h  |  101 ++++++++++++
 support/junction/Makefile.am  |    6 +
 support/junction/nfs-plugin.c |  350 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 458 insertions(+)
 create mode 100644 support/include/nfs-plugin.h
 create mode 100644 support/junction/nfs-plugin.c

diff --git a/support/include/Makefile.am b/support/include/Makefile.am
index 11cb162..a207d21 100644
--- a/support/include/Makefile.am
+++ b/support/include/Makefile.am
@@ -9,6 +9,7 @@ noinst_HEADERS = \
 	ha-callout.h \
 	junction.h \
 	misc.h \
+	nfs-plugin.h \
 	nfs_mntent.h \
 	nfs_paths.h \
 	nfslib.h \
diff --git a/support/include/nfs-plugin.h b/support/include/nfs-plugin.h
new file mode 100644
index 0000000..33e63f3
--- /dev/null
+++ b/support/include/nfs-plugin.h
@@ -0,0 +1,101 @@
+/*
+ * @file support/include/nfs-plugin.h
+ * @brief Definition of NFS junction plug-in API
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
+ * The purpose of this API is to provide an opaque mechanism for
+ * the NFS mountd daemon to resolve NFS basic and FedFS junctions.
+ * This interface is therefore quite specific to NFS.
+ */
+
+#ifndef NFS_PLUGIN_H
+#define NFS_PLUGIN_H
+
+#include <stdint.h>
+
+__BEGIN_DECLS
+
+/**
+ * Current version of API
+ */
+#define JP_API_VERSION		(1)
+
+/**
+ * NFS plug-in library soname; passed to dlopen(3)
+ */
+#define JP_NFSPLUGIN_SONAME	"libnfsjunct.so.0"
+
+/**
+ * A set of NFS FS locations
+ */
+struct nfs_fsloc_set;
+typedef struct nfs_fsloc_set	 *nfs_fsloc_set_t;
+
+/**
+ * Junction operation status codes
+ */
+enum jp_status {
+	JP_OK			=  0,
+	JP_INVAL		= -1,
+	JP_ACCESS		= -2,
+	JP_EXIST		= -3,
+	JP_TYPE_NOT_SUPP	= -4,
+	JP_OP_NOT_SUPP		= -5,
+	JP_ISJUNCTION		= -6,
+	JP_NOTJUNCTION		= -7,
+	JP_NSDBLOCAL		= -8,
+	JP_NSDBREMOTE		= -9,
+	JP_MEMORY		= -10,
+	JP_SYSTEM		= -11,
+	JP_PARSE		= -1000,
+	JP_EMPTY		= -1001,
+};
+
+/**
+ * Vector of methods provided by a junction plug-in
+ */
+struct jp_ops {
+	unsigned int	  jp_api_version;
+
+	enum jp_status	  (*jp_init)(_Bool want_debugging);
+	void		  (*jp_done)(void);
+
+	const char *	  (*jp_error)(enum jp_status status);
+	void		  (*jp_put_locations)(nfs_fsloc_set_t locset);
+	enum jp_status	  (*jp_get_locations)(const char *junct_path,
+					nfs_fsloc_set_t *locset);
+	void		  (*jp_rewind_locations)(nfs_fsloc_set_t locset);
+	enum jp_status	  (*jp_get_next_location)(nfs_fsloc_set_t locset,
+					char **hostname, char **export_path,
+					int *ttl);
+};
+
+/**
+ * Load this symbol to get access to the junction API
+ */
+extern struct jp_ops	  nfs_junction_ops;
+
+__END_DECLS
+
+#endif	/* !NFS_PLUGIN_H */
diff --git a/support/junction/Makefile.am b/support/junction/Makefile.am
index 97e7426..9494f55 100644
--- a/support/junction/Makefile.am
+++ b/support/junction/Makefile.am
@@ -29,6 +29,12 @@ noinst_LTLIBRARIES	= libjunction.la
 libjunction_la_SOURCES	= display.c export-cache.c junction.c \
 			  locations.c nfs.c path.c xml.c
 
+lib_LTLIBRARIES		= libnfsjunct.la
+libnfsjunct_la_SOURCES	= nfs-plugin.c
+libnfsjunct_la_LIBADD	= $(LIBXML2) \
+			  ../../support/nfs/libnfs.la \
+			  libjunction.la
+
 MAINTAINERCLEANFILES	= Makefile.in
 
 AM_CPPFLAGS		= -I. -I../include -I/usr/include/libxml2
diff --git a/support/junction/nfs-plugin.c b/support/junction/nfs-plugin.c
new file mode 100644
index 0000000..61039ca
--- /dev/null
+++ b/support/junction/nfs-plugin.c
@@ -0,0 +1,350 @@
+/**
+ * @file support/junction/nfs-plugin.c
+ * @brief DLL to resolve junction information
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
+#include <stdarg.h>
+
+#include <string.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <errno.h>
+
+#include <libxml/parser.h>
+
+#include "fedfs_admin.h"
+#include "nfs-plugin.h"
+#include "junction.h"
+
+#define VERSION			"0.12.0"
+#define FEDFS_NFS_BASIC_TTL	(300)
+
+struct nfs_fsloc_set {
+	int			  ns_ttl;
+	struct nfs_fsloc	 *ns_current;
+	struct nfs_fsloc	 *ns_list;
+};
+
+static _Bool debug = false;
+
+/**
+ * Write a debugging message to stderr
+ *
+ * @param fmt NUL-terminated C string containing output format specification
+ *
+ * NB:	Caller may have already opened syslog for her own use.  We can't
+ *	hijack it here, so using xlog() is right out.  Thus output is
+ *	directed to stderr via fprintf(3).
+ */
+static void
+nfs_jp_debug(const char *fmt, ...)
+{
+	va_list args;
+
+	if (!debug)
+		return;
+
+	va_start(args, fmt);
+	vfprintf(stderr, fmt, args);
+	va_end(args);
+}
+
+/**
+ * Perform any plug-in startup processing
+ *
+ * @param want_debugging true if caller wants to enable debugging output
+ * @return a junction status code
+ */
+static enum jp_status
+nfs_jp_init(_Bool want_debugging)
+{
+	debug = want_debugging;
+	nfs_jp_debug("%s: Junction plug-in version " VERSION "\n", __func__);
+	xmlInitParser();
+	return JP_OK;
+}
+
+/**
+ * Perform any plug-in shutdown processing
+ *
+ * Nothing to be done for NFS junctions.
+ */
+static void
+nfs_jp_done(void)
+{
+	nfs_jp_debug("%s: Finishing\n", __func__);
+	xmlCleanupParser();
+	return;
+}
+
+/**
+ * Given an status code, return a pointer to a static error message
+ *
+ * @param status a junction plug-in status code
+ * @return a static NUL-terminated string
+ */
+static const char *
+nfs_jp_error(enum jp_status status)
+{
+	static char buf[128];
+
+	switch (status) {
+	case JP_OK:
+		return "Success";
+	case JP_INVAL:
+		return "Invalid parameter";
+	case JP_ACCESS:
+		return "Permission denied";
+	case JP_EXIST:
+		return "Object cannot be made into a junction";
+	case JP_TYPE_NOT_SUPP:
+		return "Junction type not supported";
+	case JP_OP_NOT_SUPP:
+		return "Junction method not supported";
+	case JP_ISJUNCTION:
+		return "Object is a junction";
+	case JP_NOTJUNCTION:
+		return "Object is not a junction";
+	case JP_NSDBLOCAL:
+		return "A local NSDB configuration error occurred";
+	case JP_NSDBREMOTE:
+		return "An error occurred on the NSDB";
+	case JP_MEMORY:
+		return "Memory allocation failure";
+	case JP_SYSTEM:
+		snprintf(buf, sizeof(buf), "System error (%d): %s",
+				status, strerror(errno));
+		return buf;
+	case JP_PARSE:
+		return "Failed to parse locations data";
+	case JP_EMPTY:
+		return "No more locations in location set";
+	}
+
+	snprintf(buf, sizeof(buf), "Unknown error (%d)", status);
+	return buf;
+}
+
+/**
+ * Release a set of NFS locations
+ *
+ * @param locset set of NFS locations to release
+ */
+static void
+nfs_jp_put_locations(nfs_fsloc_set_t locset)
+{
+	if (locset == NULL) {
+		nfs_jp_debug("%s: Invalid parameters\n", __func__);
+		return;
+	}
+
+	nfs_jp_debug("%s: Freeing location set %p, ns_list=%p\n",
+		__func__, locset, locset->ns_list);
+	nfs_free_locations(locset->ns_list);
+	free(locset);
+}
+
+/**
+ * Internal function to allocate a set of NFS locations
+ *
+ * @return dynamically allocated nfs_fsloc_set_t object
+ *
+ * If return value is non-NULL, caller must free it with
+ * nfs_jp_put_locations().
+ */
+__attribute_malloc__
+static nfs_fsloc_set_t
+nfs_jp_alloc_locations(void)
+{
+	return calloc(1, sizeof(struct nfs_fsloc_set));
+}
+
+/**
+ * Internal function to rewind a set of locations
+ *
+ * @param locset set of NFS locations to rewind
+ */
+static void
+nfs_jp_do_rewind_locations(nfs_fsloc_set_t locset)
+{
+	locset->ns_current = locset->ns_list;
+}
+
+/**
+ * Resolve NFS basic junction information into a set of NFS locations
+ *
+ * @param junct_path NUL-terminated C string containing POSIX path of junction
+ * @param locset OUT set of NFS locations
+ * @return a junction status code
+ *
+ * If this entry point returns JP_OK, the caller must free the returned
+ * set of locations by calling the jp_put_locations entry point.
+ */
+static enum jp_status
+nfs_jp_get_basic(const char *junct_path, nfs_fsloc_set_t *locset)
+{
+	nfs_fsloc_set_t new;
+	FedFsStatus retval;
+
+	new = nfs_jp_alloc_locations();
+	if (new == NULL) {
+		nfs_jp_debug("%s: No memory\n", __func__);
+		return JP_MEMORY;
+	}
+
+	retval = nfs_get_locations(junct_path, &new->ns_list);
+	if (retval != FEDFS_OK) {
+		nfs_jp_debug("%s: Failed to get locations: %s\n",
+			__func__, nsdb_display_fedfsstatus(retval));
+		nfs_jp_put_locations(new);
+		return JP_PARSE;
+	}
+
+	nfs_jp_debug("%s: Returning location set %p\n", __func__, new);
+	nfs_jp_do_rewind_locations(new);
+	new->ns_ttl = FEDFS_NFS_BASIC_TTL;
+	*locset = new;
+	return JP_OK;
+}
+
+/**
+ * Resolve junction information into a set of NFS locations
+ *
+ * @param junct_path NUL-terminated C string containing POSIX path of junction
+ * @param locset OUT set of NFS locations
+ * @return a junction status code
+ *
+ * If this entry point returns JP_OK, the caller must free the returned
+ * set of locations by calling the jp_put_locations entry point.
+ */
+static enum jp_status
+nfs_jp_get_locations(const char *junct_path, nfs_fsloc_set_t *locset)
+{
+	FedFsStatus retval;
+
+	if (junct_path == NULL || locset == NULL) {
+		nfs_jp_debug("%s: Invalid parameters\n", __func__);
+		return JP_INVAL;
+	}
+	nfs_jp_debug("%s: %s\n", __func__, junct_path);
+
+	retval = nfs_is_junction(junct_path);
+	if (retval == FEDFS_OK)
+		return nfs_jp_get_basic(junct_path, locset);
+
+	nfs_jp_debug("%s: Not a junction\n", __func__);
+	return JP_NOTJUNCTION;
+}
+
+/**
+ * Reset the current location to the first location in the list
+ *
+ * @param locset set of NFS locations
+ */
+static void
+nfs_jp_rewind_locations(nfs_fsloc_set_t locset)
+{
+	if (locset == NULL) {
+		nfs_jp_debug("%s: Invalid parameters\n", __func__);
+		return;
+	}
+
+	nfs_jp_debug("%s: Rewinding %p\n", __func__, locset);
+	nfs_jp_do_rewind_locations(locset);
+}
+
+/**
+ * Get the fileserver hostname and export path from the next location in the set
+ *
+ * @param locset set of NFS locations
+ * @param hostname OUT NUL-terminated C string containing hostname of fileserver
+ * @param export_path OUT NUL-terminated C string containing export path
+ * @param ttl OUT cache time-to-live, in seconds
+ * @return a junction status code
+ *
+ * If this entry point returns JP_OK, the caller must free the hostname
+ * and export_path strings with free(3).
+ */
+static enum jp_status
+nfs_jp_get_next_location(nfs_fsloc_set_t locset,
+		char **hostname, char **export_path, int *ttl)
+{
+	char *hostname_tmp, *export_path_tmp;
+	struct nfs_fsloc *fsloc;
+
+	if (locset == NULL || hostname == NULL ||
+	    export_path == NULL || ttl == NULL) {
+		nfs_jp_debug("%s: Invalid parameters\n", __func__);
+		return JP_INVAL;
+	}
+	nfs_jp_debug("%s: locset=%p, ns_current=%p, ns_list=%p\n",
+		__func__, locset, locset->ns_current, locset->ns_list);
+
+	if (locset->ns_current == NULL) {
+		nfs_jp_debug("%s: No locations\n", __func__);
+		return JP_EMPTY;
+	}
+	fsloc = locset->ns_current;
+
+	hostname_tmp = strdup(fsloc->nfl_hostname);
+	if (hostname_tmp == NULL) {
+		nfs_jp_debug("%s: No memory\n", __func__);
+		return JP_MEMORY;
+	}
+
+	if (nsdb_path_array_to_posix(fsloc->nfl_rootpath,
+					&export_path_tmp) != FEDFS_OK) {
+		free(hostname_tmp);
+		nfs_jp_debug("%s: Failed to parse\n", __func__);
+		return JP_PARSE;
+	}
+
+	nfs_jp_debug("%s: Success; hostname=%s path=%s\n",
+		__func__, hostname_tmp, export_path_tmp);
+	*hostname = hostname_tmp;
+	*export_path = export_path_tmp;
+	*ttl = locset->ns_ttl;
+	locset->ns_current = locset->ns_current->nfl_next;
+	return JP_OK;
+}
+
+/**
+ * Vector of methods provided by this plug-in
+ */
+struct jp_ops nfs_junction_ops = {
+	.jp_api_version		= JP_API_VERSION,
+	.jp_init		= nfs_jp_init,
+	.jp_done		= nfs_jp_done,
+	.jp_error		= nfs_jp_error,
+	.jp_put_locations	= nfs_jp_put_locations,
+	.jp_get_locations	= nfs_jp_get_locations,
+	.jp_rewind_locations	= nfs_jp_rewind_locations,
+	.jp_get_next_location	= nfs_jp_get_next_location,
+};

