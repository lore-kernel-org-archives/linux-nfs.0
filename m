Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ares08.inai.de ([46.4.84.70]:52490 "EHLO ares08.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751264AbaJFV0x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Oct 2014 17:26:53 -0400
From: Jan Engelhardt <jengelh@inai.de>
To: steved@redhat.com
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] build: rename configure.in -> .ac
Date: Mon,  6 Oct 2014 23:19:30 +0200
Message-Id: <1412630374-23246-2-git-send-email-jengelh@inai.de>
In-Reply-To: <1412630374-23246-1-git-send-email-jengelh@inai.de>
References: <1412630374-23246-1-git-send-email-jengelh@inai.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The .in suffix is long obsolete and newer autotools versions
rightfully start nagging about it.

$ autoreconf -fi
aclocal: warning: autoconf input should be named 'configure.ac',
not 'configure.in'
automake: warning: autoconf input should be named 'configure.ac',
not 'configure.in'

Signed-off-by: Jan Engelhardt <jengelh@inai.de>
---
 configure.ac | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 configure.in | 67 ------------------------------------------------------------
 2 files changed, 67 insertions(+), 67 deletions(-)
 create mode 100644 configure.ac
 delete mode 100644 configure.in

diff --git a/configure.ac b/configure.ac
new file mode 100644
index 0000000..cb5740b
--- /dev/null
+++ b/configure.ac
@@ -0,0 +1,67 @@
+#                                               -*- Autoconf -*-
+# Process this file with autoconf to produce a configure script.
+
+AC_PREREQ([2.66])
+AC_INIT([libnfsidmap],[0.25],[linux-nfs@vger.kernel.org])
+AC_CONFIG_SRCDIR([nfsidmap.h])
+AC_CONFIG_MACRO_DIR([m4])
+AM_INIT_AUTOMAKE
+LT_INIT
+
+# Checks for programs.
+AC_PROG_CC
+
+# Checks for libraries.
+
+AC_ARG_ENABLE([ldap],
+	[AS_HELP_STRING([--disable-ldap],[Disable support for LDAP @<:@default=detect@:>@])])
+if test "x$enable_ldap" != "xno" ; then
+	AC_CHECK_HEADER([ldap.h],
+		[AC_CHECK_LIB([ldap], [ldap_initialize],
+		              [have_ldap="yes"],[have_ldap="no"])],
+		[have_ldap="no"])
+	if test "x$have_ldap" = "xyes" ; then
+		AC_DEFINE([ENABLE_LDAP], 1, [Enable LDAP Support])
+	elif test "x$enable_ldap$have_ldap" = "xyesno" ; then
+		AC_MSG_ERROR(LDAP support not found!)
+	fi
+fi
+AM_CONDITIONAL(ENABLE_LDAP, test "x$have_ldap" = "xyes")
+
+# Should we build gums mapping library?
+AC_ARG_ENABLE([gums],
+	[AS_HELP_STRING([--enable-gums],[Enable support for the GUMS mapping library @<:@default=false@:>@])])
+if test "x$enable_gums" = "xyes" ; then
+	AC_DEFINE([ENABLE_GUMS], 1, [Enable GUMS mapping library support])
+fi
+AM_CONDITIONAL(ENABLE_GUMS, test "x$enable_gums" = "xyes")
+
+#Where do the Plugins live
+AC_ARG_WITH(pluginpath,
+    [AS_HELP_STRING([--with-pluginpath=/foo],[Causes the library to look in /foo instead of /usr/lib/libnfsidmap for plugins
+    ])],
+    path_plugins=$withval,
+    path_plugins=""
+    )
+if test -n "$path_plugins" ; then
+	AC_DEFINE_UNQUOTED(PATH_PLUGINS, "$path_plugins",
+		[Define this to change the plugins path])
+fi
+AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
+
+AC_CONFIG_HEADERS([./config.h])
+# Checks for header files.
+AC_HEADER_STDC
+AC_CHECK_HEADERS([stdlib.h string.h unistd.h errno.h])
+
+# Checks for typedefs, structures, and compiler characteristics.
+AC_TYPE_UID_T
+AC_TYPE_SIZE_T
+
+# Checks for library functions.
+AC_FUNC_MALLOC
+AC_CHECK_FUNCS([strchr strdup])
+
+AC_CONFIG_FILES([Makefile])
+AC_CONFIG_FILES([libnfsidmap.pc])
+AC_OUTPUT
diff --git a/configure.in b/configure.in
deleted file mode 100644
index cb5740b..0000000
--- a/configure.in
+++ /dev/null
@@ -1,67 +0,0 @@
-#                                               -*- Autoconf -*-
-# Process this file with autoconf to produce a configure script.
-
-AC_PREREQ([2.66])
-AC_INIT([libnfsidmap],[0.25],[linux-nfs@vger.kernel.org])
-AC_CONFIG_SRCDIR([nfsidmap.h])
-AC_CONFIG_MACRO_DIR([m4])
-AM_INIT_AUTOMAKE
-LT_INIT
-
-# Checks for programs.
-AC_PROG_CC
-
-# Checks for libraries.
-
-AC_ARG_ENABLE([ldap],
-	[AS_HELP_STRING([--disable-ldap],[Disable support for LDAP @<:@default=detect@:>@])])
-if test "x$enable_ldap" != "xno" ; then
-	AC_CHECK_HEADER([ldap.h],
-		[AC_CHECK_LIB([ldap], [ldap_initialize],
-		              [have_ldap="yes"],[have_ldap="no"])],
-		[have_ldap="no"])
-	if test "x$have_ldap" = "xyes" ; then
-		AC_DEFINE([ENABLE_LDAP], 1, [Enable LDAP Support])
-	elif test "x$enable_ldap$have_ldap" = "xyesno" ; then
-		AC_MSG_ERROR(LDAP support not found!)
-	fi
-fi
-AM_CONDITIONAL(ENABLE_LDAP, test "x$have_ldap" = "xyes")
-
-# Should we build gums mapping library?
-AC_ARG_ENABLE([gums],
-	[AS_HELP_STRING([--enable-gums],[Enable support for the GUMS mapping library @<:@default=false@:>@])])
-if test "x$enable_gums" = "xyes" ; then
-	AC_DEFINE([ENABLE_GUMS], 1, [Enable GUMS mapping library support])
-fi
-AM_CONDITIONAL(ENABLE_GUMS, test "x$enable_gums" = "xyes")
-
-#Where do the Plugins live
-AC_ARG_WITH(pluginpath,
-    [AS_HELP_STRING([--with-pluginpath=/foo],[Causes the library to look in /foo instead of /usr/lib/libnfsidmap for plugins
-    ])],
-    path_plugins=$withval,
-    path_plugins=""
-    )
-if test -n "$path_plugins" ; then
-	AC_DEFINE_UNQUOTED(PATH_PLUGINS, "$path_plugins",
-		[Define this to change the plugins path])
-fi
-AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
-
-AC_CONFIG_HEADERS([./config.h])
-# Checks for header files.
-AC_HEADER_STDC
-AC_CHECK_HEADERS([stdlib.h string.h unistd.h errno.h])
-
-# Checks for typedefs, structures, and compiler characteristics.
-AC_TYPE_UID_T
-AC_TYPE_SIZE_T
-
-# Checks for library functions.
-AC_FUNC_MALLOC
-AC_CHECK_FUNCS([strchr strdup])
-
-AC_CONFIG_FILES([Makefile])
-AC_CONFIG_FILES([libnfsidmap.pc])
-AC_OUTPUT
-- 
2.0.0

