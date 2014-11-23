Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:61102 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbaKWRnq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Nov 2014 12:43:46 -0500
Received: by mail-wg0-f49.google.com with SMTP id x12so10385836wgg.22
        for <linux-nfs@vger.kernel.org>; Sun, 23 Nov 2014 09:43:45 -0800 (PST)
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Steve Dickson <steved@redhat.com>
Subject: [PATCH nfs-utils v2] configure: use pkg-config to find libtirpc
Date: Sun, 23 Nov 2014 18:43:39 +0100
Message-Id: <1416764619-6211-1-git-send-email-yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we use a custom function to find libtirpc's headers and
libraries. This works fine for shared linking.

But for static linking, this forgets to link with -lpthread, which is
required by libtirpc.

A recent patch was sent to libtirpc to add that missing -lpthread in its
Libs.private section of its .pc file. Thus, pkg-config will soon be able
to return the appropriate libraries.

So, use pkg-config to find libtirpc.

And for older libtirpc versions, there is no change in behaviour: we're
still missing the -lpthread. But once libtirpc has been fixed, we'll
automatically get that missing library for free! :-)

Remove the --with-libirpc flag as it is no longer needed: pkg-config
will provide us with the -I and -L flags, now.

Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
Cc: Steve Dickson <steved@redhat.com>

---
Changes v1 -> v2:
  - posted to the appropriate locations  (thanks Steve)
  - do not do the check if libtirpc is disabled from command line
    with --disable-libtirpc
---
 aclocal/libtirpc.m4 | 67 ++++++++++-------------------------------------------
 1 file changed, 12 insertions(+), 55 deletions(-)

diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index b823364..ebc1bea 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -2,61 +2,18 @@ dnl Checks for TI-RPC library and headers
 dnl
 AC_DEFUN([AC_LIBTIRPC], [
 
-  AC_ARG_WITH([tirpcinclude],
-              [AC_HELP_STRING([--with-tirpcinclude=DIR],
-                              [use TI-RPC headers in DIR])],
-              [tirpc_header_dir=$withval],
-              [tirpc_header_dir=/usr/include/tirpc])
-
-  dnl if --enable-tirpc was specifed, the following components
-  dnl must be present, and we set up HAVE_ macros for them.
-
-  if test "$enable_tirpc" != "no"; then
-
-    dnl look for the library
-    AC_CHECK_LIB([tirpc], [clnt_tli_create], [:],
-                 [if test "$enable_tirpc" = "yes"; then
-			AC_MSG_ERROR([libtirpc not found.])
-		  else
-			AC_MSG_WARN([libtirpc not found. TIRPC disabled!])
-			enable_tirpc="no"
-		  fi])
-  fi
-
-  if test "$enable_tirpc" != "no"; then
-
-    dnl Check if library contains authgss_free_private_data
-    AC_CHECK_LIB([tirpc], [authgss_free_private_data], [have_free_private_data=yes],
-			[have_free_private_data=no])
-  fi
-
-  if test "$enable_tirpc" != "no"; then
-    dnl also must have the headers installed where we expect
-    dnl look for headers; add -I compiler option if found
-    AC_CHECK_HEADERS([${tirpc_header_dir}/netconfig.h],
-    		      AC_SUBST([AM_CPPFLAGS], ["-I${tirpc_header_dir}"]),
-		      [if test "$enable_tirpc" = "yes"; then
-			 AC_MSG_ERROR([libtirpc headers not found.])
-		       else
-			 AC_MSG_WARN([libtirpc headers not found. TIRPC disabled!])
-			 enable_tirpc="no"
-		       fi])
-
-  fi
-
-  dnl now set $LIBTIRPC accordingly
-  if test "$enable_tirpc" != "no"; then
-    AC_DEFINE([HAVE_LIBTIRPC], 1,
-              [Define to 1 if you have and wish to use libtirpc.])
-    LIBTIRPC="-ltirpc"
-    if test "$have_free_private_data" = "yes"; then
-      AC_DEFINE([HAVE_AUTHGSS_FREE_PRIVATE_DATA], 1,
-	      [Define to 1 if your rpcsec library provides authgss_free_private_data,])
-    fi
-  else
-    LIBTIRPC=""
-  fi
-
+  PKG_PROG_PKG_CONFIG([0.9.0])
+  AS_IF(
+    [test "$enable_tirpc" != "no"],
+    [PKG_CHECK_MODULES([TIRPC], [libtirpc >= 0.2.4],
+                      [LIBTIRPC="${TIRPC_LIBS}"
+                       AM_CPPFLAGS="${AM_CPPFLAGS} ${TIRPC_CFLAGS}"
+                       AC_DEFINE([HAVE_LIBTIRPC], [1],
+                                 [Define to 1 if you have and wish to use libtirpc.])],
+                      [AS_IF([test "$enable_tirpc" != "no"], [AC_MSG_ERROR([libtirpc not found.])],
+                             [LIBTIRPC=""])])])
+
+  AC_SUBST([AM_CPPFLAGS])
   AC_SUBST(LIBTIRPC)
 
 ])dnl
-- 
1.9.1

