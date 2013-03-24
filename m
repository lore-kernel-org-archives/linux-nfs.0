Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:44789 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754858Ab3CXVht (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Mar 2013 17:37:49 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 3A69A33DB6D
	for <linux-nfs@vger.kernel.org>; Sun, 24 Mar 2013 21:37:48 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH [nfs-utils]] check for libio.h availability
Date: Sun, 24 Mar 2013 17:42:02 -0400
Message-Id: <1364161322-25601-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On some systems (like uClibc), there isn't a libio.h header.  But it
isn't also needed on them.  So check for the header first.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 configure.ac               | 2 +-
 support/include/sockaddr.h | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index f461219..cc7f3b4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -358,7 +358,7 @@ AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h \
                  stdlib.h string.h sys/file.h sys/ioctl.h sys/mount.h \
                  sys/param.h sys/socket.h sys/time.h sys/vfs.h \
                  syslog.h unistd.h com_err.h et/com_err.h \
-                 ifaddrs.h nfs-plugin.h])
+                 ifaddrs.h nfs-plugin.h libio.h])
 
 dnl *************************************************************
 dnl Checks for typedefs, structures, and compiler characteristics
diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
index 72766db..a1c30f9 100644
--- a/support/include/sockaddr.h
+++ b/support/include/sockaddr.h
@@ -20,7 +20,13 @@
 #ifndef NFS_UTILS_SOCKADDR_H
 #define NFS_UTILS_SOCKADDR_H
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#ifdef HAVE_LIBIO_H
 #include <libio.h>
+#endif
 #include <stdbool.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
-- 
1.8.1.2

