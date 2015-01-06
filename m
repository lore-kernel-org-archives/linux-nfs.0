Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f177.google.com ([74.125.82.177]:57204 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbbAFXIH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 18:08:07 -0500
Received: by mail-we0-f177.google.com with SMTP id q59so180995wes.36
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 15:08:05 -0800 (PST)
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: linux-nfs@vger.kernel.org
Cc: "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 3/4] configure:restore the old way of checking for libtirpc
Date: Wed,  7 Jan 2015 00:07:59 +0100
Message-Id: <9eef40dddd6c313a09150bffad4ff3b444a81cac.1420585444.git.yann.morin.1998@free.fr>
In-Reply-To: <cover.1420585444.git.yann.morin.1998@free.fr>
References: <cover.1420585444.git.yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since 8534063 (configure: use pkg-config to find libtirpc), we use
pkg-config to check for libtirpc (he!).

As reported on the list, some user do not have the libtirpc registered
with pkg-config (even though it has been since at least 0.1.8).

So, partially restore the old checking code, as it was before 8534063,
but adapted to work with the pkg-config check, and also adapted to only
use proper macros (AS_IF) instead of shell constructs.

Re-introduce that old code in a separate function, so it is easy to get
rid of when we only want to support pkg-config in the future (i.e. when
virtually all libtirpc versions in the wild have been properly
installed).

Reported-by: Chuck Lever <check.lever@oracle.com>
Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
Cc: Steve Dickson <SteveD@redhat.com>
---
 aclocal/libtirpc.m4 | 36 ++++++++++++++++++++++++++++++++++--
 1 file changed, 34 insertions(+), 2 deletions(-)

diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index 9ea17c5..5e9d76e 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -10,10 +10,42 @@ AC_DEFUN([AC_LIBTIRPC], [
                        AM_CPPFLAGS="${AM_CPPFLAGS} ${TIRPC_CFLAGS}"
                        AC_DEFINE([HAVE_LIBTIRPC], [1],
                                  [Define to 1 if you have and wish to use libtirpc.])],
-                      [AS_IF([test "$enable_tirpc" = "yes"], [AC_MSG_ERROR([libtirpc not found.])],
-                             [LIBTIRPC=""])])])
+                      [AC_LIBTIRPC_OLD
+                       AS_IF([test "$enable_tirpc" = "yes" -a -z "${LIBTIRPC}"],
+                             [AC_MSG_ERROR([libtirpc not found.])])])])
 
   AC_SUBST([AM_CPPFLAGS])
   AC_SUBST(LIBTIRPC)
 
 ])dnl
+
+dnl Old way of checking libtirpc without pkg-config
+dnl This can go away when virtually all libtirpc provide a .pc file
+dnl
+AC_DEFUN([AC_LIBTIRPC_OLD], [
+
+  AC_ARG_WITH([tirpcinclude],
+              [AC_HELP_STRING([--with-tirpcinclude=DIR],
+                              [use TI-RPC headers in DIR])],
+              [tirpc_header_dir=$withval],
+              [tirpc_header_dir=/usr/include/tirpc])
+
+  dnl Look for the library
+  AC_CHECK_LIB([tirpc], [clnt_tli_create],
+               [has_libtirpc="yes"],
+               [has_libtirpc="no"])
+
+  dnl Also must have the headers installed where we expect
+  dnl to look for headers; add -I compiler option if found
+  AS_IF([test "$has_libtirpc" = "yes"],
+        [AC_CHECK_HEADERS([${tirpc_header_dir}/netconfig.h],
+                          [AC_SUBST([AM_CPPFLAGS], ["-I${tirpc_header_dir}"])],
+                          [has_libtirpc="no"])])
+
+  dnl Now set $LIBTIRPC accordingly
+  AS_IF([test "$has_libtirpc" = "yes"],
+        [AC_DEFINE([HAVE_LIBTIRPC], [1],
+                   [Define to 1 if you have and wish to use libtirpc.])
+         LIBTIRPC="-ltirpc"])
+
+])dnl
-- 
1.9.1

