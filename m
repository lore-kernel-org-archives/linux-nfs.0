Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53058 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbcDNECm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Apr 2016 00:02:42 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 8FAA2340DC2
	for <linux-nfs@vger.kernel.org>; Thu, 14 Apr 2016 04:02:31 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH nfs-utils] fix building w/newer C libraries
Date: Thu, 14 Apr 2016 00:02:27 -0400
Message-Id: <1460606547-3957-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linux C libraries are moving away from implicitly including the header
sys/sysmacros.h via sys/types.h.  We would like to do this for glibc
now, but others (musl/etc...) have been doing it already.  This means
any code using major/minor/makedevs functions will fail to build when
they don't include that header.

Leverage the AC_HEADER_MAJOR macro that configure is already using to
pull in the right header.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 support/include/xcommon.h        | 6 ++++++
 support/nfs/nfsexport.c          | 1 +
 utils/blkmapd/device-discovery.c | 1 +
 utils/mountd/cache.c             | 1 +
 4 files changed, 9 insertions(+)

diff --git a/support/include/xcommon.h b/support/include/xcommon.h
index d1a4b18..23c9a13 100644
--- a/support/include/xcommon.h
+++ b/support/include/xcommon.h
@@ -17,6 +17,12 @@
 #include <stdlib.h>
 #include <string.h>
 
+#ifdef MAJOR_IN_MKDEV
+#include <sys/mkdev.h>
+#elif defined(MAJOR_IN_SYSMACROS)
+#include <sys/sysmacros.h>
+#endif
+
 #define streq(s, t)	(strcmp ((s), (t)) == 0)
 
 /* Functions in sundries.c that are used in mount.c and umount.c  */ 
diff --git a/support/nfs/nfsexport.c b/support/nfs/nfsexport.c
index afd7c90..4b13265 100644
--- a/support/nfs/nfsexport.c
+++ b/support/nfs/nfsexport.c
@@ -19,6 +19,7 @@
 
 #include "nfslib.h"
 #include "misc.h"
+#include "xcommon.h"
 
 	/* if /proc/net/rpc/... exists, then 
 	 * write to it, as that interface is more stable.
diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index b010628..052d582 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -51,6 +51,7 @@
 #include <libdevmapper.h>
 
 #include "device-discovery.h"
+#include "xcommon.h"
 
 #define EVENT_SIZE (sizeof(struct inotify_event))
 #define EVENT_BUFSIZE (1024 * EVENT_SIZE)
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 7847446..ec86a22 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -31,6 +31,7 @@
 #include "mountd.h"
 #include "fsloc.h"
 #include "pseudoflavors.h"
+#include "xcommon.h"
 
 #ifdef USE_BLKID
 #include "blkid/blkid.h"
-- 
2.7.4

