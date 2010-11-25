Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57012 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750997Ab0KYKD7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Nov 2010 05:03:59 -0500
Message-ID: <4CEE357D.2030007@cn.fujitsu.com>
Date: Thu, 25 Nov 2010 18:07:57 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Steve Dickson <SteveD@redhat.com>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount: avoid po_destroy to modify errno what we really want
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We should return the errno that was set before po_destroy,
rather than the errno that was set at po_destroy.

Because the po_destroy function don't affect the return value,
this patch just revert the saved errno after po_destroy.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 utils/mount/stropts.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 50a1a2a..d554877 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -592,7 +592,7 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
 		struct sockaddr *sap, socklen_t salen)
 {
 	struct mount_options *options = po_dup(mi->options);
-	int result = 0;
+	int result = 0, save = 0;
 
 	if (!options) {
 		errno = ENOMEM;
@@ -637,7 +637,9 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
 	result = nfs_sys_mount(mi, options);
 
 out_fail:
+	save = errno;
 	po_destroy(options);
+	errno = save;
 	return result;
 }
 
@@ -673,7 +675,7 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 		struct sockaddr *sap, socklen_t salen)
 {
 	struct mount_options *options = po_dup(mi->options);
-	int result = 0;
+	int result = 0, save = 0;
 
 	if (!options) {
 		errno = ENOMEM;
@@ -724,7 +726,9 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 	result = nfs_sys_mount(mi, options);
 
 out_fail:
+	save = errno;
 	po_destroy(options);
+	errno = save;
 	return result;
 }
 
-- 
1.7.3.2


