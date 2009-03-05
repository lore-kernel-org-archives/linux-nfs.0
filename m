From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/9] configure: Move rpcsecgss checking into aclocal
Date: Thu, 05 Mar 2009 12:42:13 -0500
Message-ID: <20090305174212.30471.24926.stgit@ingres.1015granger.net>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17922 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766AbZCERmt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:42:49 -0500
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Introduce two more aclocal scripts for handling rpcsecgss
dependency checking.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 Makefile.am             |    3 ++-
 aclocal/librpcsecgss.m4 |   16 ++++++++++++++++
 aclocal/rpcsec_vers.m4  |    9 +++++++++
 configure.ac            |   23 ++++++++---------------
 4 files changed, 35 insertions(+), 16 deletions(-)
 create mode 100644 aclocal/librpcsecgss.m4
 create mode 100644 aclocal/rpcsec_vers.m4

diff --git a/Makefile.am b/Makefile.am
index 6541fb7..098446b 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -43,7 +43,8 @@ EXTRA_DIST = \
 	aclocal/tcp-wrappers.m4 \
 	aclocal/libtirpc.m4 \
 	aclocal/libevent.m4 \
-	aclocal/libnfsidmap.m4
+	aclocal/libnfsidmap.m4 \
+	aclocal/rpcsec_vers.m4
 
 ACLOCAL_AMFLAGS = -I aclocal
 
diff --git a/aclocal/librpcsecgss.m4 b/aclocal/librpcsecgss.m4
new file mode 100644
index 0000000..a81819e
--- /dev/null
+++ b/aclocal/librpcsecgss.m4
@@ -0,0 +1,16 @@
+dnl Checks for rpcsecgss library and headers
+dnl KRB5LIBS must be set before this function is invoked.
+dnl
+AC_DEFUN([AC_LIBRPCSECGSS], [
+
+  dnl Check for library, but do not add -lrpcsecgss to LIBS
+  AC_CHECK_LIB([rpcsecgss], [authgss_create_default], [librpcsecgss=1],
+               [AC_MSG_ERROR([librpcsecgss not found.])],
+               [-lgssglue -ldl])
+
+  AC_CHECK_LIB([rpcsecgss], [authgss_set_debug_level],
+  	       [AC_DEFINE([HAVE_AUTHGSS_SET_DEBUG_LEVEL], 1,
+               [Define to 1 if you have the `authgss_set_debug_level' function.])],,
+               [-lgssglue -ldl])
+
+])dnl
diff --git a/aclocal/rpcsec_vers.m4 b/aclocal/rpcsec_vers.m4
new file mode 100644
index 0000000..df7cfb9
--- /dev/null
+++ b/aclocal/rpcsec_vers.m4
@@ -0,0 +1,9 @@
+dnl Checks librpcsec version
+AC_DEFUN([AC_RPCSEC_VERSION], [
+
+  PKG_CHECK_MODULES([RPCSECGSS], [librpcsecgss >= 0.16], ,
+                    [AC_MSG_ERROR([Unable to locate information required to use librpcsecgss.  If you have pkgconfig installed, you might try setting environment variable PKG_CONFIG_PATH to /usr/local/lib/pkgconfig])])
+
+  PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.1])
+
+])dnl
diff --git a/configure.ac b/configure.ac
index 0d5f5a6..7d25384 100644
--- a/configure.ac
+++ b/configure.ac
@@ -203,17 +203,13 @@ if test "$enable_nfsv4" = yes; then
   dnl check for nfsidmap libraries and headers
   AC_LIBNFSIDMAP
 
-    dnl librpcsecgss already has a dependency on libgssapi,
-    dnl but we need to make sure we get the right version
-    if test "$enable_gss" = yes; then
-     PKG_CHECK_MODULES(RPCSECGSS, librpcsecgss >= 0.16, ,
-      [AC_MSG_ERROR([Unable to locate information required to use librpcsecgss.  If you have pkgconfig installed, you might try setting environment variable PKG_CONFIG_PATH to /usr/local/lib/pkgconfig])
-      ]
-     )
-    PKG_CHECK_MODULES(GSSGLUE, libgssglue >= 0.1)
-    fi
-
+  dnl librpcsecgss already has a dependency on libgssapi,
+  dnl but we need to make sure we get the right version
+  if test "$enable_gss" = yes; then
+    AC_RPCSEC_VERSION
+  fi
 fi
+
 if test "$knfsd_cv_glibc2" = no; then
     AC_CHECK_LIB(bsd, daemon, [LIBBSD="-lbsd"])
 fi
@@ -249,11 +245,8 @@ if test "$enable_gss" = yes; then
   dnl Check for Kerberos V5
   AC_KERBEROS_V5
 
-  dnl This is not done until here because we need to have KRBLIBS set
-  dnl ("librpcsecgss=1" is so that it doesn't get added to LIBS)
-  AC_CHECK_LIB(rpcsecgss, authgss_create_default, [librpcsecgss=1], AC_MSG_ERROR([librpcsecgss needed for nfsv4 support]), -lgssglue -ldl)
-  AC_CHECK_LIB(rpcsecgss, authgss_set_debug_level,
-  	       AC_DEFINE(HAVE_AUTHGSS_SET_DEBUG_LEVEL, 1, [Define this if the rpcsec_gss library has the function authgss_set_debug_level]),, -lgssglue -ldl)
+  dnl Invoked after AC_KERBEROS_V5; AC_LIBRPCSECGSS needs to have KRBLIBS set
+  AC_LIBRPCSECGSS
 
 fi
 

