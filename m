Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:38295 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab2JALww (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 07:52:52 -0400
Received: by ghbg15 with SMTP id g15so1356084ghb.19
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2012 04:52:51 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] nfsdcltrack: rename the nfsdcld directory and options to nfsdcltrack
Date: Mon,  1 Oct 2012 07:52:40 -0400
Message-Id: <1349092365-23920-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
References: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll soon be adding a new nfsdcltrack program, at which point it won't
make much sense to call this directory and the config option "nfsdcld".
Rename it to be a bit more generic.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac                               | 20 ++++++++++----------
 utils/Makefile.am                          |  4 ++--
 utils/{nfsdcld => nfsdcltrack}/Makefile.am |  0
 utils/{nfsdcld => nfsdcltrack}/nfsdcld.c   |  0
 utils/{nfsdcld => nfsdcltrack}/nfsdcld.man |  0
 utils/{nfsdcld => nfsdcltrack}/sqlite.c    |  0
 utils/{nfsdcld => nfsdcltrack}/sqlite.h    |  0
 7 files changed, 12 insertions(+), 12 deletions(-)
 rename utils/{nfsdcld => nfsdcltrack}/Makefile.am (100%)
 rename utils/{nfsdcld => nfsdcltrack}/nfsdcld.c (100%)
 rename utils/{nfsdcld => nfsdcltrack}/nfsdcld.man (100%)
 rename utils/{nfsdcld => nfsdcltrack}/sqlite.c (100%)
 rename utils/{nfsdcld => nfsdcltrack}/sqlite.h (100%)

diff --git a/configure.ac b/configure.ac
index a174bf4..65d1bea 100644
--- a/configure.ac
+++ b/configure.ac
@@ -185,11 +185,11 @@ else
 	AM_CONDITIONAL(MOUNT_CONFIG, [test "$enable_mount" = "yes"])
 fi
 
-AC_ARG_ENABLE(nfsdcld,
-	[AC_HELP_STRING([--enable-nfsdcld],
-			[Create nfsdcld NFSv4 clientid tracking daemon. @<:@default=no@:>@])],
-	enable_nfsdcld=$enableval,
-	enable_nfsdcld="no")
+AC_ARG_ENABLE(nfsdcltrack,
+	[AC_HELP_STRING([--enable-nfsdcltrack],
+			[enable NFSv4 clientid tracking programs @<:@default=no@:>@])],
+	enable_nfsdctrack=$enableval,
+	enable_nfsdcltrack="no")
 
 dnl Check for TI-RPC library and headers
 AC_LIBTIRPC
@@ -269,12 +269,12 @@ if test "$enable_nfsv4" = yes; then
   dnl Check for sqlite3
   AC_SQLITE3_VERS
 
-  if test "$enable_nfsdcld" = "yes"; then
+  if test "$enable_nfsdcltrack" = "yes"; then
 	AC_CHECK_HEADERS([libgen.h sys/inotify.h], ,
-		AC_MSG_ERROR([Cannot find header needed for nfsdcld]))
+		AC_MSG_ERROR([Cannot find header needed for nfsdcltrack]))
 
   	if test "$libsqlite3_cv_is_recent" != "yes" ; then
-		AC_MSG_ERROR([nfsdcld requires sqlite3])
+		AC_MSG_ERROR([nfsdcltrack requires sqlite3])
 	fi
   fi
 
@@ -292,7 +292,7 @@ if test "$enable_nfsv41" = yes; then
 fi
 
 dnl enable nfsidmap when its support by libnfsidmap
-AM_CONDITIONAL(CONFIG_NFSDCLD, [test "$enable_nfsdcld" = "yes" ])
+AM_CONDITIONAL(CONFIG_NFSDCLTRACK, [test "$enable_nfsdcltrack" = "yes" ])
 AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
 
 
@@ -477,7 +477,7 @@ AC_CONFIG_FILES([
 	tools/nfs-iostat/Makefile
 	utils/Makefile
 	utils/blkmapd/Makefile
-	utils/nfsdcld/Makefile
+	utils/nfsdcltrack/Makefile
 	utils/exportfs/Makefile
 	utils/gssd/Makefile
 	utils/idmapd/Makefile
diff --git a/utils/Makefile.am b/utils/Makefile.am
index 09045dd..b892dc8 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -21,8 +21,8 @@ if CONFIG_MOUNT
 OPTDIRS += mount
 endif
 
-if CONFIG_NFSDCLD
-OPTDIRS += nfsdcld
+if CONFIG_NFSDCLTRACK
+OPTDIRS += nfsdcltrack
 endif
 
 SUBDIRS = \
diff --git a/utils/nfsdcld/Makefile.am b/utils/nfsdcltrack/Makefile.am
similarity index 100%
rename from utils/nfsdcld/Makefile.am
rename to utils/nfsdcltrack/Makefile.am
diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcltrack/nfsdcld.c
similarity index 100%
rename from utils/nfsdcld/nfsdcld.c
rename to utils/nfsdcltrack/nfsdcld.c
diff --git a/utils/nfsdcld/nfsdcld.man b/utils/nfsdcltrack/nfsdcld.man
similarity index 100%
rename from utils/nfsdcld/nfsdcld.man
rename to utils/nfsdcltrack/nfsdcld.man
diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcltrack/sqlite.c
similarity index 100%
rename from utils/nfsdcld/sqlite.c
rename to utils/nfsdcltrack/sqlite.c
diff --git a/utils/nfsdcld/sqlite.h b/utils/nfsdcltrack/sqlite.h
similarity index 100%
rename from utils/nfsdcld/sqlite.h
rename to utils/nfsdcltrack/sqlite.h
-- 
1.7.11.4

