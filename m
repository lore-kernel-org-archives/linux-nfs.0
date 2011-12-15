Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3186 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756356Ab1LOSoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 13:44:03 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi2H4010879
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:02 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi17f010403
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:02 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/7] nfsdcld: add autoconf goop for sqlite
Date: Thu, 15 Dec 2011 13:43:57 -0500
Message-Id: <1323974641-16515-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
References: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
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
index c5b6a0f..bf018a2 100644
--- a/configure.ac
+++ b/configure.ac
@@ -186,6 +186,12 @@ else
 	AM_CONDITIONAL(MOUNT_CONFIG, [test "$enable_mount" = "yes"])
 fi
 
+AC_ARG_ENABLE(nfsdcld,
+	[AC_HELP_STRING([--enable-nfsdcld],
+			[Create nfsdcld NFSv4 clientid tracking daemon. <:@default=yes@:>@])],
+	enable_nfsdcld=$enableval,
+	enable_nfsdcld="maybe")
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
 
+dnl Decide what to do with nfsdcld based on sqlite3 test result
+if test "$enable_nfsv4" = "yes" -a "$libsqlite3_cv_is_recent" != "yes" ; then
+	if test "$enable_nfsdcld" = "yes"; then
+		AC_MSG_ERROR([nfsdcld requires sqlite3])
+	elif test "$enable_nfsdcld" != "no"; then
+		AC_MSG_WARN([nfsdcld requires sqlite3, autodisabling it])
+		enable_nfsdcld="no"
+	fi
+fi
+
+dnl Now set CONFIG_NFSDCLD properly
+AM_CONDITIONAL(CONFIG_NFSDCLD, [test "$enable_nfsdcld" != "no" ])
+
 dnl *************************************************************
 dnl Check for headers
 dnl *************************************************************
diff --git a/utils/Makefile.am b/utils/Makefile.am
index f42c7ee..5df7ca7 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -21,8 +21,11 @@ if CONFIG_MOUNT
 OPTDIRS += mount
 endif
 
+if CONFIG_NFSDCLD
+OPTDIRS += nfsdcld
+endif
+
 SUBDIRS = \
-	nfsdcld \
 	exportfs \
 	mountd \
 	nfsd \
-- 
1.7.1

