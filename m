Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49748 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751754AbdFIN0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Jun 2017 09:26:11 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3BAA38535D
        for <linux-nfs@vger.kernel.org>; Fri,  9 Jun 2017 13:26:11 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-53.phx2.redhat.com [10.3.117.53])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E6E9E187B2
        for <linux-nfs@vger.kernel.org>; Fri,  9 Jun 2017 13:26:10 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2 V2] mount.nfs: Use default minor version when -o v4 is specified
Date: Fri,  9 Jun 2017 09:26:08 -0400
Message-Id: <20170609132608.12213-2-steved@redhat.com>
In-Reply-To: <20170609132608.12213-1-steved@redhat.com>
References: <20170609132608.12213-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When v4 is specified on the command line the
default minor version needs to be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 81fb945..d2d303f 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -119,14 +119,22 @@ static void nfs_default_version(struct nfsmount_info *mi)
 	if (mi->version.v_mode == V_DEFAULT &&
 		config_default_vers.v_mode != V_DEFAULT) {
 		mi->version.major = config_default_vers.major;
-		mi->version.minor = config_default_vers.minor;
+		if (config_default_vers.minor)
+			mi->version.minor = config_default_vers.minor;
+		else if (!mi->version.minor)
+			mi->version.minor = NFS_DEFAULT_MINOR;
 		return;
 	}
 
 	if (mi->version.v_mode == V_GENERAL) {
 		if (config_default_vers.v_mode != V_DEFAULT &&
-		    mi->version.major == config_default_vers.major)
-			mi->version.minor = config_default_vers.minor;
+		    mi->version.major == config_default_vers.major) {
+			if (mi->version.minor)
+				mi->version.minor = config_default_vers.minor;
+			else if (!mi->version.minor)
+				mi->version.minor = NFS_DEFAULT_MINOR;
+		} else if (!mi->version.minor)
+			mi->version.minor = NFS_DEFAULT_MINOR;
 		return;
 	}
 
@@ -740,10 +748,15 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 	}
 
 	if (mi->version.v_mode != V_SPECIFIC) {
-		if (mi->version.v_mode == V_GENERAL)
-			snprintf(version_opt, sizeof(version_opt) - 1,
-				"vers=%lu", mi->version.major);
-		else
+		if (mi->version.v_mode == V_GENERAL) {
+			if (mi->version.major > 3)
+				snprintf(version_opt, sizeof(version_opt) - 1,
+					"vers=%lu.%lu", mi->version.major,
+					mi->version.minor);
+			else 
+				snprintf(version_opt, sizeof(version_opt) - 1,
+					"vers=%lu", mi->version.major);
+		} else
 			snprintf(version_opt, sizeof(version_opt) - 1,
 				"vers=%lu.%lu", mi->version.major,
 				mi->version.minor);
-- 
2.9.4

