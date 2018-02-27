Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57416 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751744AbeB0WNV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Feb 2018 17:13:21 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F10DFC0587C7
        for <linux-nfs@vger.kernel.org>; Tue, 27 Feb 2018 22:13:20 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-98.phx2.redhat.com [10.3.116.98])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AE56360181
        for <linux-nfs@vger.kernel.org>; Tue, 27 Feb 2018 22:13:20 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1 V2] mount.nfs: minorversion setting is being ignored with the -t flag
Date: Tue, 27 Feb 2018 17:13:18 -0500
Message-Id: <20180227221318.4866-2-steved@redhat.com>
In-Reply-To: <20180227221318.4866-1-steved@redhat.com>
References: <20180227221318.4866-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mount -t nfs or mount -t nfs4 and setting minorversion
should set the v4 minor version. This patch adds a few
checks to make sure the minor version is set.

The patch also translate the minorversion= option
to vers=4.x in the arguments passed to the kernel
when the kernel is later then v3.4.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c | 15 ++++++++++-----
 utils/mount/stropts.c | 15 +++++++++++++++
 2 files changed, 25 insertions(+), 5 deletions(-)

v1:
 Added kernel version check

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
index 777de39..d1b0708 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -767,6 +767,21 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 			mi->version.minor);
 #pragma GCC diagnostic warning "-Wformat-nonliteral"
 
+		if (po_append(options, version_opt) == PO_FAILED) {
+			errno = EINVAL;
+			goto out_fail;
+		}
+	} else if (po_get(options, "minorversion") &&
+		linux_version_code() > MAKE_VERSION(3, 4, 0)) {
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

