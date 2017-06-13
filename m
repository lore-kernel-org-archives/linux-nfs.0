Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54102 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752525AbdFMRbO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 13:31:14 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E5B8EC05FFCA
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jun 2017 17:31:13 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A2E208B7A5
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jun 2017 17:31:13 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2 V2] mount.nfs: Use default minor version when -o v4 is specified
Date: Tue, 13 Jun 2017 13:31:12 -0400
Message-Id: <20170613173112.8596-2-steved@redhat.com>
In-Reply-To: <20170613173112.8596-1-steved@redhat.com>
References: <20170613173112.8596-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When v4 is specified on the command line the
default minor version needs to be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

V2: Removed pointless check of v_mode in nfs_do_mount_v4()

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index fbea6fb..9330d42 100644
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
+			if (config_default_vers.minor)
+				mi->version.minor = config_default_vers.minor;
+			else if (!mi->version.minor)
+				mi->version.minor = NFS_DEFAULT_MINOR;
+		} else if (!mi->version.minor)
+			mi->version.minor = NFS_DEFAULT_MINOR;
 		return;
 	}
 
@@ -741,13 +749,9 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 	}
 
 	if (mi->version.v_mode != V_SPECIFIC) {
-		if (mi->version.v_mode == V_GENERAL)
-			snprintf(version_opt, sizeof(version_opt) - 1,
-				"vers=%lu", mi->version.major);
-		else
-			snprintf(version_opt, sizeof(version_opt) - 1,
-				"vers=%lu.%lu", mi->version.major,
-				mi->version.minor);
+		snprintf(version_opt, sizeof(version_opt) - 1,
+			"vers=%lu.%lu", mi->version.major,
+			mi->version.minor);
 
 		if (po_append(options, version_opt) == PO_FAILED) {
 			errno = EINVAL;
-- 
2.9.4

