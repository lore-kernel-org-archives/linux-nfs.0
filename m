Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:36378 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab1GBOcu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Jul 2011 10:32:50 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH] Do not segfault because of kernel version
Date: Sat,  2 Jul 2011 16:32:29 +0200
Message-Id: <1309617149-3993-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

mount.nfs segfaults if kernel version number does not contain
at least 3 components delimited with a dot.

Avoid this by matching up to three unsigned integers inialised
to zero, separated by dots.

Signed-off-by: Luk Claes <luk@debian.org>
---
 utils/mount/version.h |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/utils/mount/version.h b/utils/mount/version.h
index af61a6f..2642eab 100644
--- a/utils/mount/version.h
+++ b/utils/mount/version.h
@@ -23,8 +23,7 @@
 #ifndef _NFS_UTILS_MOUNT_VERSION_H
 #define _NFS_UTILS_MOUNT_VERSION_H
 
-#include <stdlib.h>
-#include <string.h>
+#include <stdio.h>
 
 #include <sys/utsname.h>
 
@@ -37,14 +36,14 @@ static inline unsigned int MAKE_VERSION(unsigned int p, unsigned int q,
 static inline unsigned int linux_version_code(void)
 {
 	struct utsname my_utsname;
-	unsigned int p, q, r;
+	unsigned int p, q = 0, r = 0;
 
 	if (uname(&my_utsname))
 		return 0;
 
-	p = (unsigned int)atoi(strtok(my_utsname.release, "."));
-	q = (unsigned int)atoi(strtok(NULL, "."));
-	r = (unsigned int)atoi(strtok(NULL, "."));
+	if (sscanf(my_utsname.release, "%u.%u.%u", &p, &q, &r) < 1)
+		return 0;
+	
 	return MAKE_VERSION(p, q, r);
 }
 
-- 
1.7.5.4

