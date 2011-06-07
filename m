Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45403 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739Ab1FGR7D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:59:03 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH] Fix build on Fedora 13.
Date: Tue,  7 Jun 2011 10:58:51 -0700
Message-Id: <1307469531-20595-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

Need sys/stat.h for S_ISDIR and S_ISREG symbols.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 99618c9... e057c5c... M	utils/exportfs/exportfs.c
:100644 100644 2aa3d4f... a8ce028... M	utils/mount/mount.c
 utils/exportfs/exportfs.c |    4 ++++
 utils/mount/mount.c       |    3 +++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 99618c9..e057c5c 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -12,6 +12,10 @@
 #include <config.h>
 #endif
 
+#ifdef HAVE_SYS_STAT_H
+#include <sys/stat.h>
+#endif
+
 #include <unistd.h>
 #include <stdlib.h>
 #include <string.h>
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 2aa3d4f..a8ce028 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -20,6 +20,9 @@
 
 #include "config.h"
 #include <unistd.h>
+#ifdef HAVE_SYS_STAT_H
+#include <sys/stat.h>
+#endif
 #include <sys/types.h>
 #include <stdio.h>
 #include <string.h>
-- 
1.7.3.4

