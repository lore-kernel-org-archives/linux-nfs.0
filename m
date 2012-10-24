Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:39682 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934913Ab2JXP0T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 11:26:19 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so666905vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 08:26:18 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/10] nfsdcltrack: flip the default in autoconf to "yes" for it
Date: Wed, 24 Oct 2012 11:25:59 -0400
Message-Id: <1351092359-25842-11-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351092359-25842-1-git-send-email-jlayton@redhat.com>
References: <1351092359-25842-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow nfsdcltrack to be built by default if all of the requirements
for it are in place. Set the initial state of $enable_nfsdcltrack
to "maybe", and fix the appropriate tests to just disable building
the binary unless someone explicitly requests it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/configure.ac b/configure.ac
index 65d1bea..aa41e0a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -187,9 +187,9 @@ fi
 
 AC_ARG_ENABLE(nfsdcltrack,
 	[AC_HELP_STRING([--enable-nfsdcltrack],
-			[enable NFSv4 clientid tracking programs @<:@default=no@:>@])],
+			[enable NFSv4 clientid tracking programs @<:@default=yes@:>@])],
 	enable_nfsdctrack=$enableval,
-	enable_nfsdcltrack="no")
+	enable_nfsdcltrack="maybe")
 
 dnl Check for TI-RPC library and headers
 AC_LIBTIRPC
@@ -269,12 +269,22 @@ if test "$enable_nfsv4" = yes; then
   dnl Check for sqlite3
   AC_SQLITE3_VERS
 
-  if test "$enable_nfsdcltrack" = "yes"; then
+  if test "$enable_nfsdcltrack" != "no"; then
 	AC_CHECK_HEADERS([libgen.h sys/inotify.h], ,
-		AC_MSG_ERROR([Cannot find header needed for nfsdcltrack]))
-
-  	if test "$libsqlite3_cv_is_recent" != "yes" ; then
+		if test "$enable_nfsdcltrack" = "yes"; then
+			AC_MSG_ERROR([Cannot find header needed for nfsdcltrack])
+		else
+			AC_MSG_WARN([Cannot find header needed for nfsdcltrack. Disabling it.])
+			enable_nfsdcltrack="no"
+		fi
+	)
+  fi
+  if test "$libsqlite3_cv_is_recent" != "yes" ; then
+	if test "$enable_nfsdcltrack" = "yes"; then
 		AC_MSG_ERROR([nfsdcltrack requires sqlite3])
+	elif test "$enable_nfsdcltrack" != "no"; then
+		AC_MSG_WARN([nfsdcltrack requires sqlite3. Disabling it.])
+		enable_nfsdcltrack="no"
 	fi
   fi
 
@@ -292,7 +302,7 @@ if test "$enable_nfsv41" = yes; then
 fi
 
 dnl enable nfsidmap when its support by libnfsidmap
-AM_CONDITIONAL(CONFIG_NFSDCLTRACK, [test "$enable_nfsdcltrack" = "yes" ])
+AM_CONDITIONAL(CONFIG_NFSDCLTRACK, [test "$enable_nfsdcltrack" != "no" ])
 AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
 
 
-- 
1.7.11.7

