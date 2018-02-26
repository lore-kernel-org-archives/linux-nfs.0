Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63574 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751165AbeBZTPp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Feb 2018 14:15:45 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2FC9E6ACF
        for <linux-nfs@vger.kernel.org>; Mon, 26 Feb 2018 19:15:45 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-20.phx2.redhat.com [10.3.116.20])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DEEEE60C8D
        for <linux-nfs@vger.kernel.org>; Mon, 26 Feb 2018 19:15:44 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] mount.nfs: minorversion setting is being ignored with -t flag
Date: Mon, 26 Feb 2018 14:15:42 -0500
Message-Id: <20180226191542.31447-2-steved@redhat.com>
In-Reply-To: <20180226191542.31447-1-steved@redhat.com>
References: <20180226191542.31447-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mount -t nfs or mount -t nfs4 and setting minorversion
should set the v4 minor version. This patch adds a few
checks to make sure the minor version is set.

The patch also translate the minorversion= option
to vers=4.x in the arguments passed to the kernel.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c | 15 ++++++++++-----
 utils/mount/stropts.c | 14 ++++++++++++++
 2 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 8ab5be8..8d6e4c6 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1275,8 +1275,8 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
 		}
 	}
 
-	if (!found && strcmp(type, "nfs4") == 0)
-		version_val = type + 3;
+	if (!found && strncmp(type, "nfs", 3) == 0)
+		version_val = "4";
 	else if (!found)
 		return 1;
 	else if (i <= 2 ) {
@@ -1308,9 +1308,14 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
 		if (!(version->minor = strtol(version_val, &cptr, 10)) && cptr == version_val)
 			goto ret_error;
 		version->v_mode = V_SPECIFIC;
-	} else if (version->major > 3 && *cptr == '\0')
-		version->v_mode = V_GENERAL;
-
+	} else if (version->major > 3 && *cptr == '\0') {
+		version_val = po_get(options, "minorversion");
+		if (version_val != NULL) {
+			version->minor = strtol(version_val, &cptr, 10);
+			version->v_mode = V_SPECIFIC;
+		} else 
+			version->v_mode = V_GENERAL;
+	}
 	if (*cptr != '\0')
 		goto ret_error;
 
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 777de39..6bbfd71 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -767,6 +767,20 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 			mi->version.minor);
 #pragma GCC diagnostic warning "-Wformat-nonliteral"
 
+		if (po_append(options, version_opt) == PO_FAILED) {
+			errno = EINVAL;
+			goto out_fail;
+		}
+	} else if (po_get(options, "minorversion")) {
+		/*
+	 	 * convert minorversion= into vers=4.x
+	 	 */
+		po_remove_all(options, "minorversion");
+
+		snprintf(version_opt, sizeof(version_opt) - 1,
+			"vers=%lu.%lu", mi->version.major,
+			mi->version.minor);
+
 		if (po_append(options, version_opt) == PO_FAILED) {
 			errno = EINVAL;
 			goto out_fail;
-- 
2.14.3

