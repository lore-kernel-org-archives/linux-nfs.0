Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48284 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750788AbdFHSdR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 14:33:17 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EEF81A0238
        for <linux-nfs@vger.kernel.org>; Thu,  8 Jun 2017 18:33:16 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AD896189C8
        for <linux-nfs@vger.kernel.org>; Thu,  8 Jun 2017 18:33:16 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH V2] mount.nfs: Use default minor version when -t nfs4 is specified
Date: Thu,  8 Jun 2017 14:33:14 -0400
Message-Id: <20170608183314.15247-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the nfs4 filesystem specified, the default major
and minor versions should be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c0266e5..81fb945 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -73,6 +73,13 @@
 #define NFS_DEF_BG_TIMEOUT_MINUTES	(10000u)
 #endif
 
+#ifndef NFS_DEFAULT_MAJOR
+#define NFS_DEFAULT_MAJOR	4
+#endif
+#ifndef NFS_DEFAULT_MINOR
+#define NFS_DEFAULT_MINOR	2
+#endif
+
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
@@ -124,8 +131,8 @@ static void nfs_default_version(struct nfsmount_info *mi)
 	}
 
 #endif /* MOUNT_CONFIG */
-	mi->version.major = 4;
-	mi->version.minor = 2;
+	mi->version.major = NFS_DEFAULT_MAJOR;
+	mi->version.minor = NFS_DEFAULT_MINOR;
 }
 
 /*
@@ -316,8 +323,9 @@ static int nfs_set_version(struct nfsmount_info *mi)
 		return 0;
 
 	if (strncmp(mi->type, "nfs4", 4) == 0) {
-		mi->version.major = 4;
-		mi->version.v_mode = V_GENERAL;
+		/* Set to default values */
+		mi->version.major = NFS_DEFAULT_MAJOR;
+		mi->version.minor = NFS_DEFAULT_MINOR;
 	}
 	/*
 	 * Before 2.6.32, the kernel NFS client didn't
-- 
2.9.4

