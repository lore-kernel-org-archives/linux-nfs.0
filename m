Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50863 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761133Ab2EQXeh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 19:34:37 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so3158300pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 May 2012 16:34:37 -0700 (PDT)
From: =?UTF-8?q?Diego=20Elio=20Petten=C3=B2?= <flameeyes@flameeyes.eu>
To: linux-nfs@vger.kernel.org
Cc: =?UTF-8?q?Diego=20Elio=20Petten=C3=B2?= <flameeyes@flameeyes.eu>
Subject: [nfs-utils PATCH] build: avoid AM_CONDITIONAL in conditional execution.
Date: Thu, 17 May 2012 16:34:31 -0700
Message-Id: <1337297671-9614-1-git-send-email-flameeyes@flameeyes.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Automake does not support conditional AM_CONDITIONAL calls; what that
means is that you always have to execute AM_CONDITIONAL one way or the
other. Both the libsqlite3.m4 file and the nfsdcld conditionals are
executed only when NFSv4 is enabled, which breaks building with
--disable-nfsv4.

Remove the SQLite3 conditional altogether as it's never used, and move
the nfsdcld conditional outside of the conditional code.

Signed-off-by: Diego Elio Pettenò <flameeyes@flameeyes.eu>
---
 aclocal/libsqlite3.m4 |    1 -
 configure.ac          |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/aclocal/libsqlite3.m4 b/aclocal/libsqlite3.m4
index 73d1e46..8c38993 100644
--- a/aclocal/libsqlite3.m4
+++ b/aclocal/libsqlite3.m4
@@ -29,5 +29,4 @@ AC_DEFUN([AC_SQLITE3_VERS], [
     LIBS="$saved_LIBS"])
 
   AC_MSG_RESULT($libsqlite3_cv_is_recent)
-  AM_CONDITIONAL(CONFIG_SQLITE3, [test "$libsqlite3_cv_is_recent" = "yes"])
 ])dnl
diff --git a/configure.ac b/configure.ac
index 9ba53e2..b408f1b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -278,8 +278,6 @@ if test "$enable_nfsv4" = yes; then
 	fi
   fi
 
-  AM_CONDITIONAL(CONFIG_NFSDCLD, [test "$enable_nfsdcld" = "yes" ])
-
   dnl librpcsecgss already has a dependency on libgssapi,
   dnl but we need to make sure we get the right version
   if test "$enable_gss" = yes; then
@@ -293,6 +291,7 @@ if test "$enable_nfsv41" = yes; then
 fi
 
 dnl enable nfsidmap when its support by libnfsidmap
+AM_CONDITIONAL(CONFIG_NFSDCLD, [test "$enable_nfsdcld" = "yes" ])
 AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
 
 
-- 
1.7.8.6

