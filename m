Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f177.google.com ([209.85.212.177]:47686 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbaKWPJY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Nov 2014 10:09:24 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so3484454wiw.4
        for <linux-nfs@vger.kernel.org>; Sun, 23 Nov 2014 07:09:23 -0800 (PST)
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: linux-nfs@vger.kernel.org
Cc: "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Steve Dickson <steved@redhat.com>
Subject: [PATCH nfs-utils] configure: use pkg-config to find libtirpc
Date: Sun, 23 Nov 2014 16:09:17 +0100
Message-Id: <1416755357-12228-1-git-send-email-yann.morin.1998@free.fr>
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
Steve,

This is related to the libtirpc patch I sent just mere hours ago.

I was pretty amused to see, when looking who to send this patch to, that you
were taking care of applying patches for both libtirpc and nfs-utils. :-)

At least, now you've seen both patches, all should make sense! ;-)

Regards,
Yann E. MORIN.

---
 aclocal/libtirpc.m4 | 64 ++++++++---------------------------------------------
 1 file changed, 9 insertions(+), 55 deletions(-)

diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index b823364..dc74638 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -2,61 +2,15 @@ dnl Checks for TI-RPC library and headers
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
+  PKG_CHECK_MODULES([TIRPC], [libtirpc >= 0.2.4],
+                    [LIBTIRPC="${TIRPC_LIBS}"
+                     AM_CPPFLAGS="${AM_CPPFLAGS} ${TIRPC_CFLAGS}"
+                     AC_DEFINE([HAVE_LIBTIRPC], [1],
+                               [Define to 1 if you have and wish to use libtirpc.])],
+                    [AS_IF([test "$enable_tirpc" != "no"], [AC_MSG_ERROR([libtirpc not found.])],
+                           [LIBTIRPC=""])])
+
+  AC_SUBST([AM_CPPFLAGS])
   AC_SUBST(LIBTIRPC)
 
 ])dnl
-- 
1.9.1

