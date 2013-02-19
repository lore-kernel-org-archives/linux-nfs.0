Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:48081 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932923Ab3BSSsA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 13:48:00 -0500
From: Mike Frysinger <vapier@gentoo.org>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH [rpcbind]] fix building one systems w/out nss.h
Date: Tue, 19 Feb 2013 13:48:10 -0500
Message-Id: <1361299690-19402-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nss.h header is glibc-specific, so use the existing HAVE_NSS_H define
to avoid including/using it when it is not available.

URL: http://bugs.gentoo.org/458024
Reported-by: Mark Reiche <porphyr@gmx.de>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 src/rpcbind.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/src/rpcbind.c b/src/rpcbind.c
index 9a0504d..83dbe93 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -67,7 +67,11 @@
 #include <pwd.h>
 #include <string.h>
 #include <errno.h>
+#ifdef HAVE_NSS_H
 #include <nss.h>
+#else
+static inline void __nss_configure_lookup(const char *db, const char *s) {}
+#endif
 #include "rpcbind.h"
 
 /*#define RPCBIND_DEBUG*/
-- 
1.8.1.2

