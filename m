Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbcD0P72 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 11:59:28 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 41DE7124573
	for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2016 15:59:28 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-55-91.rdu2.redhat.com [10.10.55.91])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u3RFxRlN032350
	for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2016 11:59:27 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Remove rpcsecgss library support
Date: Wed, 27 Apr 2016 11:59:26 -0400
Message-Id: <1461772766-8901-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

librpcsecgss has not been used in years
so and there is no longer an upstream for
it so the support for the library has
been removed

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 aclocal/librpcsecgss.m4 | 21 ---------------------
 configure.ac            |  3 ---
 utils/gssd/gssd.c       | 15 +++++----------
 3 files changed, 5 insertions(+), 34 deletions(-)
 delete mode 100644 aclocal/librpcsecgss.m4

diff --git a/aclocal/librpcsecgss.m4 b/aclocal/librpcsecgss.m4
deleted file mode 100644
index e833141..0000000
--- a/aclocal/librpcsecgss.m4
+++ /dev/null
@@ -1,21 +0,0 @@
-dnl Checks for rpcsecgss library and headers
-dnl KRB5LIBS must be set before this function is invoked.
-dnl
-AC_DEFUN([AC_LIBRPCSECGSS], [
-
-  dnl libtirpc provides an rpcsecgss API
-  if test "$enable_tirpc" = no; then
-
-    dnl Check for library, but do not add -lrpcsecgss to LIBS
-    AC_CHECK_LIB([rpcsecgss], [authgss_create_default], [librpcsecgss=1],
-                 [AC_MSG_ERROR([librpcsecgss not found.])])
-
-    AC_CHECK_LIB([rpcsecgss], [authgss_set_debug_level],
-                 [AC_DEFINE([HAVE_AUTHGSS_SET_DEBUG_LEVEL], 1,
-                 [Define to 1 if you have the `authgss_set_debug_level' function.])])
-
-    AC_DEFINE([HAVE_AUTHGSS_FREE_PRIVATE_DATA], 1,
-	      [Define to 1 if your rpcsec library provides authgss_free_private_data,])
-  fi
-
-])dnl
diff --git a/configure.ac b/configure.ac
index 25d2ba4..b87ee68 100644
--- a/configure.ac
+++ b/configure.ac
@@ -382,9 +382,6 @@ if test "$enable_gss" = yes; then
   dnl Check for Kerberos V5
   AC_KERBEROS_V5
 
-  dnl Invoked after AC_KERBEROS_V5; AC_LIBRPCSECGSS needs to have KRBLIBS set
-  AC_LIBRPCSECGSS
-
   dnl librpcsecgss already has a dependency on libgssapi,
   dnl but we need to make sure we get the right version
   if test "$enable_gss" = yes; then
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 7ba27b1..810f872 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -866,21 +866,16 @@ main(int argc, char *argv[])
 		progname = argv[0];
 
 	initerr(progname, verbosity, fg);
-#ifdef HAVE_AUTHGSS_SET_DEBUG_LEVEL
-	if (verbosity && rpc_verbosity == 0)
-		rpc_verbosity = verbosity;
-	authgss_set_debug_level(rpc_verbosity);
-#elif HAVE_LIBTIRPC_SET_DEBUG
+#ifdef HAVE_LIBTIRPC_SET_DEBUG
 	/*
-	 * Only set the libtirpc debug level if explicitly requested via -r...
-	 * gssd is chatty enough as it is.
+	 * Only set the libtirpc debug level if explicitly requested via -r.
 	 */
 	if (rpc_verbosity > 0)
 		libtirpc_set_debug(progname, rpc_verbosity, fg);
 #else
-        if (rpc_verbosity > 0)
-		printerr(0, "Warning: rpcsec_gss library does not "
-			    "support setting debug level\n");
+	if (rpc_verbosity > 0)
+		printerr(0, "Warning: libtirpc does not "
+			    "support setting debug levels\n");
 #endif
 
 	if (gssd_check_mechs() != 0)
-- 
2.5.0

