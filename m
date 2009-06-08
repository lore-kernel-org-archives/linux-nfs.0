From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: make --enable-tirpc the default when configuring
Date: Mon,  8 Jun 2009 09:03:52 -0400
Message-ID: <1244466232-947-1-git-send-email-jlayton@redhat.com>
Cc: steved@redhat.com, chuck.lever@oracle.com, Dan.Muntz@netapp.com,
	vapier@gentoo.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:51615 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbZFHNDw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2009 09:03:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make --enable-tirpc the default. If --enable-tirpc wasn't explicitly
specified, but TIRPC libs or headers aren't present then just throw a
warning and disable it. If it was explicitly specified, then throw an
error and exit if they aren't present.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 aclocal/ipv6.m4     |    2 +-
 aclocal/libtirpc.m4 |   22 +++++++++++++++++-----
 configure.ac        |    4 ++--
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/aclocal/ipv6.m4 b/aclocal/ipv6.m4
index ba9dcc2..2490f3d 100644
--- a/aclocal/ipv6.m4
+++ b/aclocal/ipv6.m4
@@ -11,7 +11,7 @@ AC_DEFUN([AC_IPV6], [
 
     dnl TI-RPC required for IPv6
     if test "$enable_tirpc" = no; then
-      AC_MSG_ERROR(['--enable-ipv6' requires '--enable-tirpc'.])
+      AC_MSG_ERROR(['--enable-ipv6' requires TIRPC support.])
     fi
 
     dnl IPv6-enabled networking functions required for IPv6
diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index af4c7d3..9f0fde0 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -11,17 +11,29 @@ AC_DEFUN([AC_LIBTIRPC], [
   dnl if --enable-tirpc was specifed, the following components
   dnl must be present, and we set up HAVE_ macros for them.
 
-  if test "$enable_tirpc" = yes; then
+  if test "$enable_tirpc" != "no"; then
 
     dnl look for the library; add to LIBS if found
     AC_CHECK_LIB([tirpc], [clnt_tli_create], ,
-                 [AC_MSG_ERROR([libtirpc not found.])])
+                 [if test "$enable_tirpc" = "yes"; then
+			AC_MSG_ERROR([libtirpc not found.])
+		  else
+			AC_MSG_WARN([libtirpc not found. TIRPC disabled!])
+			enable_tirpc="no"
+		  fi])
+  fi
 
+  if test "$enable_tirpc" != "no"; then
     dnl also must have the headers installed where we expect
     dnl look for headers; add -I compiler option if found
-    AC_CHECK_HEADERS([${tirpc_header_dir}/netconfig.h], ,
-                     [AC_MSG_ERROR([libtirpc headers not found.])])
-    AC_SUBST([AM_CPPFLAGS], ["-I${tirpc_header_dir}"])
+    AC_CHECK_HEADERS([${tirpc_header_dir}/netconfig.h],
+    		      AC_SUBST([AM_CPPFLAGS], ["-I${tirpc_header_dir}"]),
+		      [if test "$enable_tirpc" = "yes"; then
+			 AC_MSG_ERROR([libtirpc headers not found.])
+		       else
+			 AC_MSG_WARN([libtirpc headers not found. TIRPC disabled!])
+			 enable_tirpc="no"
+		       fi])
 
   fi
 
diff --git a/configure.ac b/configure.ac
index 9ad64ed..95c88a9 100644
--- a/configure.ac
+++ b/configure.ac
@@ -120,9 +120,9 @@ AC_ARG_ENABLE(mount,
 	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" = "yes"])
 AC_ARG_ENABLE(tirpc,
 	[AC_HELP_STRING([--enable-tirpc],
-			[enable use of TI-RPC @<:@default=no@:>@])],
+			[enable use of TI-RPC @<:@default=yes@:>@])],
 	enable_tirpc=$enableval,
-	enable_tirpc=no)
+	enable_tirpc='')
 AC_ARG_ENABLE(ipv6,
 	[AC_HELP_STRING([--enable-ipv6],
                         [enable support for IPv6 @<:@default=no@:>@])],
-- 
1.6.0.6

