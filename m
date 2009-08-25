From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: disable IPv6 support in nfsd for now
Date: Tue, 25 Aug 2009 08:52:16 -0400
Message-ID: <1251204736-8343-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57193 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbZHYMwX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 08:52:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IPv6 support for nfsd was finished before some of the other daemons
(mountd and statd in particular). That could be a problem in the future
if someone were to boot a kernel that supports IPv6 serving with an
older nfs-utils. For now, hardcode the IPv6 switch into the off position
until the other daemons are functional.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfsd.c   |    9 +++++++++
 utils/nfsd/nfssvc.c |    9 +++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 650c593..1cda1e5 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -27,6 +27,15 @@
 #include "nfssvc.h"
 #include "xlog.h"
 
+/*
+ * IPv6 support for nfsd was finished before some of the other daemons (mountd
+ * and statd in particular). That could be a problem in the future if someone
+ * were to boot a kernel that supports IPv6 serving with  an older nfs-utils. For
+ * now, hardcode the IPv6 switch into the off position until the other daemons
+ * are functional.
+ */
+#undef IPV6_SUPPORTED
+
 static void	usage(const char *);
 
 static struct option longopts[] =
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index ee862b2..12d3253 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -22,6 +22,15 @@
 #include "nfslib.h"
 #include "xlog.h"
 
+/*
+ * IPv6 support for nfsd was finished before some of the other daemons (mountd
+ * and statd in particular). That could be a problem in the future if someone
+ * were to boot a kernel that supports IPv6 serving with an older nfs-utils. For
+ * now, hardcode the IPv6 switch into the off position until the other daemons
+ * are functional.
+ */
+#undef IPV6_SUPPORTED
+
 #define NFSD_PORTS_FILE     "/proc/fs/nfsd/portlist"
 #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
 #define NFSD_THREAD_FILE  "/proc/fs/nfsd/threads"
-- 
1.6.2.5

