From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/9] configure: move IPv6 feature checks into aclocal/
Date: Thu, 05 Mar 2009 12:42:24 -0500
Message-ID: <20090305174223.30471.80584.stgit@ingres.1015granger.net>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:18256 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638AbZCERnB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:43:01 -0500
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: for consistency with other local feature checks, move IPv6
feature checks into aclocal/

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 Makefile.am     |    3 ++-
 aclocal/ipv6.m4 |   29 +++++++++++++++++++++++++++++
 configure.ac    |   17 ++---------------
 3 files changed, 33 insertions(+), 16 deletions(-)
 create mode 100644 aclocal/ipv6.m4

diff --git a/Makefile.am b/Makefile.am
index 098446b..b3a6e91 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -44,7 +44,8 @@ EXTRA_DIST = \
 	aclocal/libtirpc.m4 \
 	aclocal/libevent.m4 \
 	aclocal/libnfsidmap.m4 \
-	aclocal/rpcsec_vers.m4
+	aclocal/rpcsec_vers.m4 \
+	aclocal/ipv6.m4
 
 ACLOCAL_AMFLAGS = -I aclocal
 
diff --git a/aclocal/ipv6.m4 b/aclocal/ipv6.m4
new file mode 100644
index 0000000..0564b3e
--- /dev/null
+++ b/aclocal/ipv6.m4
@@ -0,0 +1,29 @@
+dnl Checks for IPv6 support
+dnl
+AC_DEFUN([AC_IPV6], [
+
+  AC_CHECK_DECL([AI_ADDRCONFIG],
+                [AC_DEFINE([HAVE_DECL_AI_ADDRCONFIG], 1,
+                           [Define this to 1 if AI_ADDRCONFIG macro is defined])], ,
+                [ #include <netdb.h> ])
+
+  if test "$enable_ipv6" = yes; then
+
+    dnl TI-RPC required for IPv6
+    if test "$enable_tirpc" = no; then
+      AC_MSG_ERROR(['--enable-ipv6' requires '--enable-tirpc'.])
+    fi
+
+    dnl IPv6-enabled networking functions required for IPv6
+    AC_CHECK_FUNCS([getnameinfo bindresvport_sa], , ,
+                   [AC_MSG_ERROR([Missing functions needed for IPv6.])])
+
+    dnl Need to detect presence of IPv6 networking at run time via
+    dnl getaddrinfo(3); old versions of glibc do not support ADDRCONFIG
+    AC_CHECK_DECL([AI_ADDRCONFIG], ,
+                  [AC_MSG_ERROR([full getaddrinfo(3) implementation needed for IPv6 support])],
+                  [ #include <netdb.h> ])
+
+  fi
+
+])dnl
diff --git a/configure.ac b/configure.ac
index 7d25384..e34b7e2 100644
--- a/configure.ac
+++ b/configure.ac
@@ -250,21 +250,8 @@ if test "$enable_gss" = yes; then
 
 fi
 
-AC_CHECK_DECL([AI_ADDRCONFIG],
-              AC_DEFINE([HAVE_DECL_AI_ADDRCONFIG], 1,
-                         [Define this to 1 if AI_ADDRCONFIG macro is defined]), ,
-              [ #include <netdb.h> ] )
-
-if test "$enable_ipv6" = yes; then
-  if test "$enable_tirpc" = no; then
-    AC_MSG_ERROR('--enable-ipv6' requires '--enable-tirpc'.)
-  fi
-  AC_CHECK_FUNCS([getnameinfo bindresvport_sa], , ,
-                 [AC_MSG_ERROR([Missing functions needed for IPv6.])])
-  AC_CHECK_DECL([AI_ADDRCONFIG], ,
-               AC_MSG_ERROR([full getaddrinfo(3) implementation needed for IPv6 support]),
-               [ #include <netdb.h> ] )
-fi
+dnl Check for IPv6 support
+AC_IPV6
 
 dnl *************************************************************
 dnl Check for headers

