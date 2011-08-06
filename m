Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from georges.telenet-ops.be ([195.130.137.68]:58671 "EHLO
	georges.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787Ab1HFKLW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 06:11:22 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH] mount.nfs: Preserve any explicit port=2049 option
Date: Sat,  6 Aug 2011 12:11:36 +0200
Message-Id: <1312625496-2496-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If NFS port (2049) is supplied explicitly, don't ignore this setting by requesting it to portmapper again. Thanks to Ben Hutchings <ben@decadent.org.uk> for the patch.

Signed-off-by: Luk Claes <luk@debian.org>
---
 utils/mount/stropts.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index f1aa503..8b2799c 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -437,8 +437,8 @@ static int nfs_construct_new_options(struct mount_options *options,
 	if (po_append(options, new_option) == PO_FAILED)
 		return 0;
 
-	po_remove_all(options, "port");
-	if (nfs_pmap->pm_port != NFS_PORT) {
+	if(po_remove_all(options, "port") == PO_FOUND ||
+	   nfs_pmap->pm_port != NFS_PORT) {
 		snprintf(new_option, sizeof(new_option) - 1,
 			 "port=%lu", nfs_pmap->pm_port);
 		if (po_append(options, new_option) == PO_FAILED)
-- 
1.7.5.4

