Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47208 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752452AbdFMRbO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 13:31:14 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8A57A23E6D8
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jun 2017 17:31:13 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 409C28B7A0
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jun 2017 17:31:13 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2 V3] mount.nfs: Use default minor version when -t nfs4 is specified
Date: Tue, 13 Jun 2017 13:31:11 -0400
Message-Id: <20170613173112.8596-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the nfs4 filesystem specified, the default major
and minor versions should be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

v2: Added the NFS_DEFAULT_MAJOR/MINOR defines
v3: Add back the setting of v_mode to V_GENERAL in nfs_set_version()

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c0266e5..fbea6fb 100644
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
@@ -316,7 +323,9 @@ static int nfs_set_version(struct nfsmount_info *mi)
 		return 0;
 
 	if (strncmp(mi->type, "nfs4", 4) == 0) {
-		mi->version.major = 4;
+		/* Set to default values */
+		mi->version.major = NFS_DEFAULT_MAJOR;
+		mi->version.minor = NFS_DEFAULT_MINOR;
 		mi->version.v_mode = V_GENERAL;
 	}
 	/*
-- 
2.9.4

