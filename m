Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754204Ab2DYPkZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 11:40:25 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q3PFePvQ008078
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 25 Apr 2012 11:40:25 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q3PFeOgY017442
	for <linux-nfs@vger.kernel.org>; Wed, 25 Apr 2012 11:40:24 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] mounts.nfs: v2 and v3 background mounts should retry when server is down.
Date: Wed, 25 Apr 2012 11:39:50 -0400
Message-Id: <1335368390-26767-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The point of background mounts is to have the mount
retried if the mount fails. This patch allows the v2/v3
background mount to proceed in the case when the server
is down by not making EOPNOTSUPP a permanent error.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d52e21a..e09aa7c 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -911,7 +911,8 @@ static int nfsmount_parent(struct nfsmount_info *mi)
 	if (nfs_try_mount(mi))
 		return EX_SUCCESS;
 
-	if (nfs_is_permanent_error(errno)) {
+	/* retry background mounts when the server is not up */
+	if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP) {
 		mount_error(mi->spec, mi->node, errno);
 		return EX_FAIL;
 	}
@@ -946,7 +947,8 @@ static int nfsmount_child(struct nfsmount_info *mi)
 		if (nfs_try_mount(mi))
 			return EX_SUCCESS;
 
-		if (nfs_is_permanent_error(errno))
+		/* retry background mounts when the server is not up */
+		if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP)
 			break;
 
 		if (time(NULL) > timeout)
-- 
1.7.7.6

