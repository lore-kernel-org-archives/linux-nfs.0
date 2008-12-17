From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] mount: revert recent fix for build problems on old systems
Date: Wed, 17 Dec 2008 15:37:19 -0500
Message-ID: <20081217203719.14933.40848.stgit@ingres.1015granger.net>
References: <20081217203301.14933.81853.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:37210 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbYLQUig (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2008 15:38:36 -0500
In-Reply-To: <20081217203301.14933.81853.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Revert the patch that added local definitions of AI_ADDRCONFIG and
friends to utils/mount/network.c.  While old header versions don't
have those flags, even older versions of getaddrinfo(3) don't
support those flags at all.

The result is this error:

  mount.nfs: DNS resolution failed for 10.10.10.10: Bad value for ai_flags

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 6a9a41a..afa47a4 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -50,24 +50,6 @@
 #include "nfsrpc.h"
 #include "network.h"
 
-/*
- * Earlier versions of glibc's /usr/include/netdb.h exclude these
- * definitions because it was thought they were not part of a stable
- * POSIX standard.  However, they are defined by RFC 2553 and 3493
- * and in POSIX 1003.1-2001, so these definitions were added in later
- * versions of netdb.h.
- */
-#ifndef AI_V4MAPPED
-#define AI_V4MAPPED     0x0008  /* IPv4-mapped addresses are acceptable.  */
-#endif	/* AI_V4MAPPED */
-#ifndef AI_ALL
-#define AI_ALL          0x0010  /* Return both IPv4 and IPv6 addresses.  */
-#endif	/* AI_ALL */
-#ifndef AI_ADDRCONFIG
-#define AI_ADDRCONFIG   0x0020  /* Use configuration of this host to choose \
-				   returned address type.  */
-#endif	/* AI_ADDRCONFIG */
-
 #define PMAP_TIMEOUT	(10)
 #define CONNECT_TIMEOUT	(20)
 #define MOUNT_TIMEOUT	(30)

