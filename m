Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.alpinelinux.org ([74.117.189.114]:48721 "EHLO
	mail.alpinelinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbaLPIit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 03:38:49 -0500
From: Natanael Copa <ncopa@alpinelinux.org>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 2/9] Provide getrpcbynumber and getrpcbyname if those are missing
Date: Tue, 16 Dec 2014 09:28:53 +0100
Message-Id: <1418718540-13667-3-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
References: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We enable the config.h again and check if getrpcbynumber and
getrpcbyname exists on the building patform. If it does not exist, then
provide those functions.

This is needed for musl libc.

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 configure.ac    |  6 ++++--
 src/getrpcent.c | 10 ++++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index 10d17ea..0180801 100644
--- a/configure.ac
+++ b/configure.ac
@@ -24,14 +24,16 @@ if test "x$enable_ipv6" != xno; then
 fi
 
 AC_PROG_CC
-m4_pattern_allow(AM_CONFIG_HEADERS(config.h))
+AC_CONFIG_HEADERS([config.h])
 AC_PROG_LIBTOOL
 AC_HEADER_DIRENT
 AC_PREFIX_DEFAULT(/usr)
 AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h locale.h netdb.h netinet/in.h stddef.h stdint.h stdlib.h string.h sys/ioctl.h sys/param.h sys/socket.h sys/time.h syslog.h unistd.h])
 AC_CHECK_LIB([pthread], [pthread_create])
 AC_CHECK_LIB([nsl], [yp_get_default_domain])
-
+AC_CHECK_FUNCS([getrpcbyname getrpcbynumber])
 
 AC_CONFIG_FILES([Makefile src/Makefile man/Makefile doc/Makefile])
 AC_OUTPUT(libtirpc.pc)
+
+
diff --git a/src/getrpcent.c b/src/getrpcent.c
index 1b54b6d..6da006a 100644
--- a/src/getrpcent.c
+++ b/src/getrpcent.c
@@ -50,6 +50,10 @@
 #include <libc_private.h>
 #endif
 
+#if HAVE_CONFIG_H
+#include "config.h"
+#endif
+
 /*
  * Internet version.
  */
@@ -89,7 +93,7 @@ _rpcdata()
 	return (d);
 }
 
-#ifdef GQ
+#if !HAVE_GETRPCBYNYMBER
 struct rpcent *
 getrpcbynumber(number)
 	int number;
@@ -135,7 +139,9 @@ no_yp:
 	endrpcent();
 	return (p);
 }
+#endif /* !HAVE_GETRPCBYNUMBER */
 
+#if !HAVE_GETRPCBYNAME
 struct rpcent *
 getrpcbyname(name)
 	const char *name;
@@ -158,7 +164,7 @@ done:
 	endrpcent();
 	return (rpc);
 }
-#endif /* GQ */
+#endif /* !HAVE_GETRPCBYNAME */
 
 void
 setrpcent(f)
-- 
2.2.0

