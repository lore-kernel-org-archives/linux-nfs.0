Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156AbaCHNWs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Mar 2014 08:22:48 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s28DMmfi031953
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 8 Mar 2014 08:22:48 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-53-96.rdu2.redhat.com [10.10.53.96])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s28DMlaH023403
	for <linux-nfs@vger.kernel.org>; Sat, 8 Mar 2014 08:22:48 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs: background mount now do directly into background
Date: Sat,  8 Mar 2014 08:22:44 -0500
Message-Id: <1394284964-12997-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Modern day kernel will no longer return all timeout
errors instead the process spins endlessly in the kernel.
This behavior will cause the foreground mount to hang, never
allowing the mount to go into background.

So this patch eliminates the foreground mount cause
background mounts to go directly into background

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c |   31 ++++++++-----------------------
 1 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a642394..92a7245 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -913,28 +913,6 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 }
 
 /*
- * Handle "background" NFS mount [first try]
- *
- * Returns a valid mount command exit code.
- *
- * EX_BG should cause the caller to fork and invoke nfsmount_child.
- */
-static int nfsmount_parent(struct nfsmount_info *mi)
-{
-	if (nfs_try_mount(mi))
-		return EX_SUCCESS;
-
-	/* retry background mounts when the server is not up */
-	if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP) {
-		mount_error(mi->spec, mi->node, errno);
-		return EX_FAIL;
-	}
-
-	sys_mount_errors(mi->hostname, errno, 1, 1);
-	return EX_BG;
-}
-
-/*
  * Handle "background" NFS mount [retry daemon]
  *
  * Returns a valid mount command exit code: EX_SUCCESS if successful,
@@ -982,7 +960,14 @@ static int nfsmount_child(struct nfsmount_info *mi)
 static int nfsmount_bg(struct nfsmount_info *mi)
 {
 	if (!mi->child)
-		return nfsmount_parent(mi);
+		/* 
+		 * Modern day kernels no longer return all 
+		 * timeouts errors in all cases, instead 
+		 * the process spins in the kernel, which 
+		 * will hang a foreground mount. So background
+		 * mounts have to go directly into background
+		 */
+		return EX_BG;
 	else
 		return nfsmount_child(mi);
 }
-- 
1.7.1

