Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50583 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757218Ab1LNN5O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 08:57:14 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvEKf010885
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:14 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvC3c005913
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:13 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] clstated: add autoconf goop for sqlite
Date: Wed, 14 Dec 2011 08:57:08 -0500
Message-Id: <1323871032-3191-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mostly cribbed from Chuck Lever's new-statd rewrite a few years ago...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 aclocal/libsqlite3.m4 |   33 +++++++++++++++++++++++++++++++++
 configure.ac          |   22 ++++++++++++++++++++++
 utils/Makefile.am     |    5 ++++-
 3 files changed, 59 insertions(+), 1 deletions(-)
 create mode 100644 aclocal/libsqlite3.m4

diff --git a/aclocal/libsqlite3.m4 b/aclocal/libsqlite3.m4
new file mode 100644
index 0000000..73d1e46
--- /dev/null
+++ b/aclocal/libsqlite3.m4
@@ -0,0 +1,33 @@
+dnl Checks for matching sqlite3 header and library, and
+dnl sufficient sqlite3 version.
+dnl
+AC_DEFUN([AC_SQLITE3_VERS], [
+  AC_CHECK_HEADERS([sqlite3.h], ,)
+
+  dnl look for the library; do not add to LIBS if found
+  AC_CHECK_LIB([sqlite3], [sqlite3_libversion_number], [LIBSQLITE=-lsqlite3], ,)
+  AC_SUBST(LIBSQLITE)
+
+  AC_MSG_CHECKING(for suitable sqlite3 version)
+
+  AC_CACHE_VAL([libsqlite3_cv_is_recent],
+   [
+    saved_LIBS="$LIBS"
+    LIBS=-lsqlite3
+    AC_TRY_RUN([
+	#include <stdio.h>
+	#include <sqlite3.h>
+	int main()
+	{
+		int vers = sqlite3_libversion_number();
+
+		return vers != SQLITE_VERSION_NUMBER ||
+			vers < 3003000;
+	}
+       ], [libsqlite3_cv_is_recent=yes], [libsqlite3_cv_is_recent=no],
+       [libsqlite3_cv_is_recent=unknown])
+    LIBS="$saved_LIBS"])
+
+  AC_MSG_RESULT($libsqlite3_cv_is_recent)
+  AM_CONDITIONAL(CONFIG_SQLITE3, [test "$libsqlite3_cv_is_recent" = "yes"])
+])dnl
diff --git a/configure.ac b/configure.ac
index 822cf17..bc7f6db 100644
--- a/configure.ac
+++ b/configure.ac
@@ -186,6 +186,12 @@ else
 	AM_CONDITIONAL(MOUNT_CONFIG, [test "$enable_mount" = "yes"])
 fi
 
+AC_ARG_ENABLE(clstated,
+	[AC_HELP_STRING([--enable-clstated],
+			[Create clstated NFSv4 clientid tracking daemon. <:@default=yes@:>@])],
+	enable_clstated=$enableval,
+	enable_clstated="maybe")
+
 dnl Check for TI-RPC library and headers
 AC_LIBTIRPC
 
@@ -259,6 +265,9 @@ if test "$enable_nfsv4" = yes; then
   dnl check for the keyutils libraries and headers
   AC_KEYUTILS
 
+  dnl Check for sqlite3
+  AC_SQLITE3_VERS
+
   dnl librpcsecgss already has a dependency on libgssapi,
   dnl but we need to make sure we get the right version
   if test "$enable_gss" = yes; then
@@ -328,6 +337,19 @@ fi
 dnl Check for IPv6 support
 AC_IPV6
 
+dnl Decide what to do with clstated based on sqlite3 test result
+if test "$enable_nfsv4" = "yes" -a "$libsqlite3_cv_is_recent" != "yes" ; then
+	if test "$enable_clstated" = "yes"; then
+		AC_MSG_ERROR([clstated requires sqlite3])
+	elif test "$enable_clstated" != "no"; then
+		AC_MSG_WARN([clstated requires sqlite3, autodisabling it])
+		enable_clstated="no"
+	fi
+fi
+
+dnl Now set CONFIG_CLSTATED properly
+AM_CONDITIONAL(CONFIG_CLSTATED, [test "$enable_clstated" != "no" ])
+
 dnl *************************************************************
 dnl Check for headers
 dnl *************************************************************
diff --git a/utils/Makefile.am b/utils/Makefile.am
index beaf4e9..31562a3 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -21,8 +21,11 @@ if CONFIG_MOUNT
 OPTDIRS += mount
 endif
 
+if CONFIG_CLSTATED
+OPTDIRS += clstated
+endif
+
 SUBDIRS = \
-	clstated \
 	exportfs \
 	mountd \
 	nfsd \
-- 
1.7.1

