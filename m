Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:46540 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329Ab3DMUDA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 13 Apr 2013 16:03:00 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 7320E33DFA6
	for <linux-nfs@vger.kernel.org>; Sat, 13 Apr 2013 20:02:59 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH [nfs-utils]] do not fail sqlite check when cross-compiling
Date: Sat, 13 Apr 2013 16:04:35 -0400
Message-Id: <1365883476-5288-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're cross-compiling, we can't do a runtime test of sqlite,
so just assume that the user has a good enough version rather
than falling over.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 configure.ac | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 3d7ab0a..a594a7b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -274,9 +274,14 @@ if test "$enable_nfsv4" = yes; then
 	AC_CHECK_HEADERS([libgen.h sys/inotify.h], ,
 		AC_MSG_ERROR([Cannot find header needed for nfsdcltrack]))
 
-  	if test "$libsqlite3_cv_is_recent" != "yes" ; then
-		AC_MSG_ERROR([nfsdcltrack requires sqlite-devel])
-	fi
+    case $libsqlite3_cv_is_recent in
+    yes) ;;
+    unknown)
+      dnl do not fail when cross-compiling
+      AC_MSG_WARN([assuming sqlite is at least v3.3]) ;;
+    *)
+      AC_MSG_ERROR([nfsdcltrack requires sqlite-devel]) ;;
+    esac
   fi
 
 else
-- 
1.8.1.2

