Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:48358 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507Ab1IBTQz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Sep 2011 15:16:55 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id EBF561B4024
	for <linux-nfs@vger.kernel.org>; Fri,  2 Sep 2011 19:16:54 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsidmap: auto disable when keyutils is not found
Date: Fri,  2 Sep 2011 15:16:55 -0400
Message-Id: <1314991015-21484-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Since we already auto-disable based on libnfsidmap capabilities, don't
make keyutils a hard failure.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 aclocal/keyutils.m4    |    4 ++--
 aclocal/libnfsidmap.m4 |    3 +--
 configure.ac           |    2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/aclocal/keyutils.m4 b/aclocal/keyutils.m4
index 84bc112..a392c0e 100644
--- a/aclocal/keyutils.m4
+++ b/aclocal/keyutils.m4
@@ -6,6 +6,6 @@ AC_DEFUN([AC_KEYUTILS], [
   AC_CHECK_LIB([keyutils], [keyctl_instantiate], [LIBKEYUTILS=-lkeyutils], ,)
   AC_SUBST(LIBKEYUTILS)
 
-  AC_CHECK_HEADERS([keyutils.h], ,
-  		   [AC_MSG_ERROR([keyutils.h header not found.])])
+  AC_CHECK_HEADERS([keyutils.h])
+
 ])dnl
diff --git a/aclocal/libnfsidmap.m4 b/aclocal/libnfsidmap.m4
index 4faa923..484b1ec 100644
--- a/aclocal/libnfsidmap.m4
+++ b/aclocal/libnfsidmap.m4
@@ -15,7 +15,6 @@ AC_DEFUN([AC_LIBNFSIDMAP], [
                           [Define to 1 if you have the `nfs4_set_debug' function.])])
 
   dnl only enable nfsidmap when libnfsidmap supports it
-  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [enable_nfsidmap=yes],
-               [enable_nfsidmap=no])
+  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid])
 
 ])dnl
diff --git a/configure.ac b/configure.ac
index c9fb27b..1a28f8a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -266,7 +266,7 @@ if test "$enable_nfsv4" = yes; then
   fi
 fi
 dnl enable nfsidmap when its support by libnfsidmap
-AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$enable_nfsidmap" = "yes"])
+AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
 
 
 if test "$knfsd_cv_glibc2" = no; then
-- 
1.7.6

