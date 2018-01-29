Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35222 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbeA2X3F (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jan 2018 18:29:05 -0500
Received: by mail-it0-f44.google.com with SMTP id e1so11310168ita.0
        for <linux-nfs@vger.kernel.org>; Mon, 29 Jan 2018 15:29:05 -0800 (PST)
Received: from manet.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id p135sm355852itp.2.2018.01.29.15.29.04
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 15:29:04 -0800 (PST)
Subject: [PATCH v4 2/5] Add infrastructure for libjunction
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 29 Jan 2018 18:29:03 -0500
Message-ID: <20180129232903.10141.41369.stgit@manet.1015granger.net>
In-Reply-To: <20180129232527.10141.69789.stgit@manet.1015granger.net>
References: <20180129232527.10141.69789.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The source code for libjunction used to be maintained in
fedfs-utils, but fedfs-utils is being retired. Although interest in
FedFS junctions has waned, NFS basic junctions are still appealing
enough that we've decided we want to continue supporting them.
Therefore this patch moves the non-LDAP parts of libjunction into
nfs-utils, to enable nfs-utils to also support the user-visible
pieces of NFS basic junctions.

I've added yet another configure command line option to control
whether libjunction is built. It defaults to "disabled" for the
moment. Reasons you might want to leave it disabled:

- Your distribution still provides fedfs-utils, which already has
a working libjunction which is installed separately

- Your distribution does not provide libxml2, which is required
to support libjunction

When it's disabled, nfs-utils builds just like it did before this
patch, and there's no new dependency on libxml2.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 aclocal/libxml2.m4                   |   15 ++++
 configure.ac                         |   11 +++
 support/Makefile.am                  |    4 +
 support/junction/Makefile.am         |   30 ++++++++
 support/junction/junction-internal.h |  121 ++++++++++++++++++++++++++++++++++
 5 files changed, 181 insertions(+)
 create mode 100644 aclocal/libxml2.m4
 create mode 100644 support/junction/Makefile.am
 create mode 100644 support/junction/junction-internal.h

diff --git a/aclocal/libxml2.m4 b/aclocal/libxml2.m4
new file mode 100644
index 0000000..5c399b2
--- /dev/null
+++ b/aclocal/libxml2.m4
@@ -0,0 +1,15 @@
+dnl Checks for libxml2.so
+AC_DEFUN([AC_LIBXML2], [
+
+  if test "$enable_junction" = yes; then
+
+    dnl look for the library; do not add to LIBS if found
+    AC_CHECK_LIB([xml2], [xmlParseFile], [LIBXML2=-lxml2],
+                 [AC_MSG_ERROR([libxml2 not found.])])
+    AC_SUBST(LIBXML2)
+
+    dnl XXX should also check for presence of xml headers
+
+  fi
+
+])dnl
diff --git a/configure.ac b/configure.ac
index 672dd40..8e7f036 100644
--- a/configure.ac
+++ b/configure.ac
@@ -180,6 +180,13 @@ else
 	enable_libmount=no
 fi
 
+AC_ARG_ENABLE(junction,
+	[AC_HELP_STRING([--enable-junction],
+			[enable support for NFS junctions @<:@default=no@:>@])],
+	enable_junction=$enableval,
+	enable_junction=no)
+AM_CONDITIONAL(CONFIG_JUNCTION, [test "$enable_junction" = "yes" ])
+
 AC_ARG_ENABLE(tirpc,
 	[AC_HELP_STRING([--disable-tirpc],
 			[disable use of TI-RPC library @<:@default=no@:>@])],
@@ -244,6 +251,9 @@ AC_LIBTIRPC
 dnl Check for -lcap
 AC_LIBCAP
 
+dnl Check for -lxml2
+AC_LIBXML2
+
 # Check whether user wants TCP wrappers support
 AC_TCP_WRAPPERS
 
@@ -572,6 +582,7 @@ AC_CONFIG_FILES([
 	support/include/sys/fs/Makefile
 	support/include/sys/Makefile
 	support/include/Makefile
+	support/junction/Makefile
 	support/misc/Makefile
 	support/nfs/Makefile
 	support/nsm/Makefile
diff --git a/support/Makefile.am b/support/Makefile.am
index 8365d3b..c962d4d 100644
--- a/support/Makefile.am
+++ b/support/Makefile.am
@@ -6,6 +6,10 @@ if CONFIG_NFSV4
 OPTDIRS += nfsidmap
 endif
 
+if CONFIG_JUNCTION
+OPTDIRS += junction
+endif
+
 SUBDIRS = export include misc nfs nsm $(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/support/junction/Makefile.am b/support/junction/Makefile.am
new file mode 100644
index 0000000..0d43b0a
--- /dev/null
+++ b/support/junction/Makefile.am
@@ -0,0 +1,30 @@
+##
+## @file support/junction/Makefile.am
+## @brief Process this file with automake to produce src/libjunction/Makefile.in
+##
+
+##
+## Copyright 2010, 2018 Oracle.  All rights reserved.
+##
+## This file is part of nfs-utils.
+##
+## nfs-utils is free software; you can redistribute it and/or modify
+## it under the terms of the GNU General Public License version 2.0 as
+## published by the Free Software Foundation.
+##
+## nfs-utils is distributed in the hope that it will be useful, but
+## WITHOUT ANY WARRANTY; without even the implied warranty of
+## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+## GNU General Public License version 2.0 for more details.
+##
+## You should have received a copy of the GNU General Public License
+## version 2.0 along with nfs-utils.  If not, see:
+##
+##      http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
+##
+
+noinst_HEADERS		= junction-internal.h
+
+MAINTAINERCLEANFILES	= Makefile.in
+
+AM_CPPFLAGS		= -I. -I../include -I/usr/include/libxml2
diff --git a/support/junction/junction-internal.h b/support/junction/junction-internal.h
new file mode 100644
index 0000000..3dff4cc
--- /dev/null
+++ b/support/junction/junction-internal.h
@@ -0,0 +1,121 @@
+/*
+ * @file support/junction/junction-internal.h
+ * @brief Internal declarations for libjunction.a
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
+#ifndef _FEDFS_JUNCTION_INTERNAL_H_
+#define _FEDFS_JUNCTION_INTERNAL_H_
+
+#include <libxml/tree.h>
+#include <libxml/xpath.h>
+
+/**
+ ** Names of extended attributes that store junction data
+ **/
+
+/**
+ * Name of extended attribute containing saved mode bits
+ */
+#define JUNCTION_XATTR_NAME_MODE	"trusted.junction.mode"
+
+/**
+ * Name of extended attribute containing NFS-related junction data
+ */
+#define JUNCTION_XATTR_NAME_NFS		"trusted.junction.nfs"
+
+
+/**
+ ** Names of XML elements and attributes that represent junction data
+ **/
+
+/**
+ * Tag name of root element of a junction XML document
+ */
+#define JUNCTION_XML_ROOT_TAG		(const xmlChar *)"junction"
+
+/**
+ * Tag name of fileset element of a junction XML document
+ */
+#define JUNCTION_XML_FILESET_TAG	(const xmlChar *)"fileset"
+
+/**
+ * Tag name of savedmode element of a junction XML document
+ */
+#define JUNCTION_XML_SAVEDMODE_TAG	(const xmlChar *)"savedmode"
+
+/**
+ * Name of mode bits attribute on a savedmode element
+ */
+#define JUNCTION_XML_MODEBITS_ATTR	(const xmlChar *)"bits"
+
+/**
+ ** Junction helper functions
+ **/
+
+FedFsStatus	 junction_open_path(const char *pathname, int *fd);
+FedFsStatus	 junction_is_directory(int fd, const char *path);
+FedFsStatus	 junction_is_sticky_bit_set(int fd, const char *path);
+FedFsStatus	 junction_set_sticky_bit(int fd, const char *path);
+FedFsStatus	 junction_is_xattr_present(int fd, const char *path,
+				const char *name);
+FedFsStatus	 junction_read_xattr(int fd, const char *path, const char *name,
+				char **contents);
+FedFsStatus	 junction_get_xattr(int fd, const char *path, const char *name,
+				void **contents, size_t *contentlen);
+FedFsStatus	 junction_set_xattr(int fd, const char *path, const char *name,
+			const void *contents, const size_t contentlen);
+FedFsStatus	 junction_remove_xattr(int fd, const char *pathname,
+			const char *name);
+FedFsStatus	 junction_get_mode(const char *pathname, mode_t *mode);
+FedFsStatus	 junction_save_mode(const char *pathname);
+FedFsStatus	 junction_restore_mode(const char *pathname);
+
+
+/**
+ ** XML helper functions
+ **/
+
+_Bool		 junction_xml_is_empty(const xmlChar *content);
+_Bool		 junction_xml_match_node_name(xmlNodePtr node,
+			const xmlChar *name);
+xmlNodePtr	 junction_xml_find_child_by_name(xmlNodePtr parent,
+			const xmlChar *name);
+_Bool		 junction_xml_get_bool_attribute(xmlNodePtr node,
+			const xmlChar *attrname, _Bool *value);
+void		 junction_xml_set_bool_attribute(xmlNodePtr node,
+			const xmlChar *attrname, _Bool value);
+_Bool		 junction_xml_get_u8_attribute(xmlNodePtr node,
+			const xmlChar *attrname, uint8_t *value);
+_Bool		 junction_xml_get_int_attribute(xmlNodePtr node,
+			const xmlChar *attrname, int *value);
+void		 junction_xml_set_int_attribute(xmlNodePtr node,
+			const xmlChar *attrname, int value);
+_Bool		 junction_xml_get_int_content(xmlNodePtr node, int *value);
+xmlNodePtr	 junction_xml_set_int_content(xmlNodePtr parent,
+			const xmlChar *name, int value);
+FedFsStatus	 junction_xml_parse(const char *pathname, const char *name,
+			xmlDocPtr *doc);
+FedFsStatus	 junction_xml_write(const char *pathname, const char *name,
+			xmlDocPtr doc);
+
+#endif	/* !_FEDFS_JUNCTION_INTERNAL_H_ */

