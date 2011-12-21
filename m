Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361Ab1LUUfZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 15:35:25 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 03/10] nfsdcld: add autoconf goop for sqlite
Date: Wed, 21 Dec 2011 15:35:15 -0500
Message-Id: <1324499722-10363-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1324499722-10363-1-git-send-email-jlayton@redhat.com>
References: <1324499722-10363-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mostly cribbed from Chuck Lever's new-statd rewrite a few years ago...

This adds an autoconf test for the sqlite3 library and includes. If
they're not working properly and nfsdcld was enabled, then configure
will error out.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 aclocal/libsqlite3.m4 |   33 +++++++++++++++++++++++++++++++++
 configure.ac          |    7 +++++++
 2 files changed, 40 insertions(+), 0 deletions(-)
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
index eb071ef..e43ec3e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -265,9 +265,16 @@ if test "$enable_nfsv4" = yes; then
   dnl check for the keyutils libraries and headers
   AC_KEYUTILS
 
+  dnl Check for sqlite3
+  AC_SQLITE3_VERS
+
   if test "$enable_nfsdcld" = "yes"; then
     AC_CHECK_HEADERS([linux/nfsd/cld.h], ,
 		     AC_MSG_ERROR([Cannot find header needed for nfsdcld]))
+
+    if test "$libsqlite3_cv_is_recent" != "yes" ; then
+      AC_MSG_ERROR([nfsdcld requires sqlite3])
+    fi
   fi
 
   AM_CONDITIONAL(CONFIG_NFSDCLD, [test "$enable_nfsdcld" = "yes" ])
-- 
1.7.1

