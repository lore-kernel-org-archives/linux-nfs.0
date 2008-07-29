From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] mount.nfs command: old glibc missing some flags
Date: Tue, 29 Jul 2008 12:16:10 -0400
Message-ID: <20080729161512.7588.18445.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: gzp-2g/1Y3AqmNE@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:47940 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755375AbYG2QSH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2008 12:18:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Old versions of glibc (< 2.4) have a getaddrinfo(3) implementation, but
do not include public definitions of the AI_V4MAPPED, AI_ALL, and
AI_ADDRCONFIG flags because it was believed that these flags were not
standardized.  However, these flags have standard definitions both in
POSIX 1003 and in RFCs, and were thus included in later releases of
glibc.

To allow the mount.nfs command to build on systems with these older
versions of glibc, add conditional definitions for these flags in
utils/mount/network.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Untested.  Gabor, can you please try this?

 utils/mount/network.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 75354a7..0023769 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -48,6 +48,24 @@
 #include "mount_constants.h"
 #include "network.h"
 
+/*
+ * Earlier versions of glibc's /usr/include/netdb.h exclude these
+ * definitions because it was thought they were not part of a stable
+ * POSIX standard.  However, they are defined by RFC 2553 and 3493
+ * and in POSIX 1003.1-2001, so these definitions were added in later
+ * versions of netdb.h.
+ */
+#ifndef AI_V4MAPPED
+#define AI_V4MAPPED     0x0008  /* IPv4-mapped addresses are acceptable.  */
+#endif	/* AI_V4MAPPED */
+#ifndef AI_ALL
+#define AI_ALL          0x0010  /* Return both IPv4 and IPv6 addresses.  */
+#endif	/* AI_ALL */
+#ifndef AI_ADDRCONFIG
+#define AI_ADDRCONFIG   0x0020  /* Use configuration of this host to choose \
+				   returned address type.  */
+#endif	/* AI_ADDRCONFIG */
+
 #define PMAP_TIMEOUT	(10)
 #define CONNECT_TIMEOUT	(20)
 #define MOUNT_TIMEOUT	(30)

