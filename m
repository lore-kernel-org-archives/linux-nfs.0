From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] make capabilities support optional
Date: Tue, 20 Apr 2010 04:46:53 -0400
Message-ID: <1271753213-17374-1-git-send-email-vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:54720 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754047Ab0DTIrW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 04:47:22 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id D9D9C1B40A0
	for <linux-nfs@vger.kernel.org>; Tue, 20 Apr 2010 08:47:21 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new code using libcap is quite minor, so rather than always reqiure
libcap support, make it a normal --enable type flag.  Current default
behavior is retained -- if libcap is found, it is enabled, else it is
disabled like every nfs-utils version in the past.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 aclocal/libcap.m4  |   18 +++++++++++++-----
 support/nsm/file.c |    4 ++++
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/aclocal/libcap.m4 b/aclocal/libcap.m4
index eabe507..68a624c 100644
--- a/aclocal/libcap.m4
+++ b/aclocal/libcap.m4
@@ -5,11 +5,19 @@ AC_DEFUN([AC_LIBCAP], [
   dnl look for prctl
   AC_CHECK_FUNC([prctl], , )
 
-  dnl look for the library; do not add to LIBS if found
-  AC_CHECK_LIB([cap], [cap_get_proc], [LIBCAP=-lcap], ,)
-  AC_SUBST(LIBCAP)
+  AC_ARG_ENABLE([caps],
+    [AS_HELP_STRING([--disable-caps], [Disable capabilities support])])
+
+  LIBCAP=
+
+  if test "x$enable_caps" != "xno" ; then
+    dnl look for the library; do not add to LIBS if found
+    AC_CHECK_LIB([cap], [cap_get_proc], [LIBCAP=-lcap], ,)
 
-  AC_CHECK_HEADERS([sys/capability.h], ,
-                   [AC_MSG_ERROR([libcap headers not found.])])
+    AC_CHECK_HEADERS([sys/capability.h], ,
+      [test "x$enable_caps" = "xyes" && AC_MSG_ERROR([libcap headers not found.])])
+  fi
+
+  AC_SUBST(LIBCAP)
 
 ])dnl
diff --git a/support/nsm/file.c b/support/nsm/file.c
index d469219..f4baeb9 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -67,7 +67,9 @@
 #endif
 
 #include <sys/types.h>
+#ifdef HAVE_SYS_CAPABILITY_H
 #include <sys/capability.h>
+#endif
 #include <sys/prctl.h>
 #include <sys/stat.h>
 
@@ -347,6 +349,7 @@ nsm_is_default_parentdir(void)
 static _Bool
 nsm_clear_capabilities(void)
 {
+#ifdef HAVE_SYS_CAPABILITY_H
 	cap_t caps;
 
 	caps = cap_from_text("cap_net_bind_service=ep");
@@ -362,6 +365,7 @@ nsm_clear_capabilities(void)
 	}
 
 	(void)cap_free(caps);
+#endif
 	return true;
 }
 
-- 
1.7.0.2

