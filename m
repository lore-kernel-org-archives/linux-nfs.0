Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45800 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727353AbeJTXEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Oct 2018 19:04:34 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 269FD81DE5
        for <linux-nfs@vger.kernel.org>; Sat, 20 Oct 2018 14:53:49 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-120-63.rdu2.redhat.com [10.10.120.63])
        by smtp.corp.redhat.com (Postfix) with ESMTP id BC9A170465
        for <linux-nfs@vger.kernel.org>; Sat, 20 Oct 2018 14:53:48 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: Only ignore EBUSY when a filesystem is already mount
Date: Sat, 20 Oct 2018 10:53:47 -0400
Message-Id: <20181020145347.134233-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

EBUSY errors can be caused by using the -o sharecache
flag and different context= values. So make sure
the filesytem is mounted before ignoring the EBUSY error.

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1629705

Found-by: Jianhong.Yin <yin-jianhong@163.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/Makefile.am |  1 +
 utils/mount/stropts.c   | 16 ++++++++++------
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 7b97c31..ad0be93 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -27,6 +27,7 @@ endif
 
 mount_nfs_LDADD = ../../support/nfs/libnfs.la \
 		  ../../support/export/libexport.a \
+		  ../../support/misc/libmisc.a \
 		  $(LIBTIRPC)
 
 mount_nfs_SOURCES = $(mount_common)
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 4d2e37e..eed0356 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -48,6 +48,7 @@
 #include "version.h"
 #include "parse_dev.h"
 #include "conffile.h"
+#include "misc.h"
 
 #ifndef NFS_PROGRAM
 #define NFS_PROGRAM	(100003)
@@ -1078,12 +1079,15 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 		if (nfs_try_mount(mi))
 			return EX_SUCCESS;
 
-		if (errno == EBUSY)
-			/* The only cause of EBUSY is if exactly the desired
-			 * filesystem is already mounted.  That can arguably
-			 * be seen as success.  "mount -a" tries to optimise
-			 * out this case but sometimes fails.  Help it out
-			 * by pretending everything is rosy
+#pragma GCC diagnostic ignored "-Wdiscarded-qualifiers"
+		if (errno == EBUSY && is_mountpoint(mi->node))
+#pragma GCC diagnostic warning "-Wdiscarded-qualifiers"
+			/*
+			 * EBUSY can happen when mounting a filesystem that
+			 * is already mounted or when the context= are
+			 * different when using the -o sharecache
+			 *
+			 * Only error out in the latter case.
 			 */
 			return EX_SUCCESS;
 
-- 
2.17.2
