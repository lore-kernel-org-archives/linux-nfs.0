Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44014 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754173AbeCGRh2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Mar 2018 12:37:28 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4823FBD87
        for <linux-nfs@vger.kernel.org>; Wed,  7 Mar 2018 17:37:28 +0000 (UTC)
Message-ID: <1520444246.7682.9.camel@redhat.com>
Subject: [PATCH] nfs-utils: Test if extra compiler warnings are available
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Wed, 07 Mar 2018 17:37:26 +0000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some of the latest compiler warnings flags are not available
on older compilers so this adds macros to test they are supported

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 configure.ac | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index f4eba1f..e0c9039 100644
--- a/configure.ac
+++ b/configure.ac
@@ -550,7 +550,6 @@ my_am_cflags="\
  -Werror=strict-prototypes \
  -Werror=missing-prototypes \
  -Werror=missing-declarations \
- -Werror=format-overflow=2 \
  -Werror=format=2 \
  -Werror=undef \
  -Werror=missing-include-dirs \
@@ -560,15 +559,29 @@ my_am_cflags="\
  -Werror=return-type \
  -Werror=switch \
  -Werror=overflow \
- -Werror=int-conversion \
  -Werror=parentheses \
- -Werror=incompatible-pointer-types \
- -Werror=misleading-indentation \
  -Werror=aggregate-return \
  -Werror=unused-result \
  -fno-strict-aliasing \
 "
 
+AC_DEFUN([CHECK_CCSUPPORT], [
+  my_save_cflags="$CFLAGS"
+  CFLAGS=$1
+  AC_MSG_CHECKING([whether CC supports $1])
+  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([])],
+    [AC_MSG_RESULT([yes])]
+    [$2+=$1],
+    [AC_MSG_RESULT([no])]
+  )
+  CFLAGS="$my_save_cflags"
+])
+
+CHECK_CCSUPPORT([-Werror=format-overflow=2], [my_am_cflags])
+CHECK_CCSUPPORT([-Werror=int-conversion], [my_am_cflags])
+CHECK_CCSUPPORT([-Werror=incompatible-pointer-types], [my_am_cflags])
+CHECK_CCSUPPORT([-Werror=misleading-indentation], [my_am_cflags])
+
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
 
 # Make sure that $ACLOCAL_FLAGS are used during a rebuild
-- 
1.8.3.1




