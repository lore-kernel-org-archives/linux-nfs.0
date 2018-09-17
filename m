Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39000 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726824AbeIQRFm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Sep 2018 13:05:42 -0400
From: jiyin@redhat.com
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH] nfs-utils mount: recover the lost EBUSY
Date: Mon, 17 Sep 2018 19:38:38 +0800
Message-Id: <20180917113838.31952-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

see: https://bugzilla.redhat.com/show_bug.cgi?id=1629705
[nfs-utils] mount -osharecache failure but return 'true'

mount.nfs4 -o context=system_u:object_r:user_home_dir_t:s0,sharecache $serv:$expdir $nfsmp
mount.nfs4 -o context=system_u:object_r:xferlog_t:s0,sharecache $serv:$expdir $nfsmp2
^^^ here mount fail, but return true. it confuse user!

Anyway, we should not hide the failure and pretend that it
does not exist.

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 utils/mount/stropts.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 4d2e37e..ca5bc7f 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -1078,15 +1078,6 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 		if (nfs_try_mount(mi))
 			return EX_SUCCESS;
 
-		if (errno == EBUSY)
-			/* The only cause of EBUSY is if exactly the desired
-			 * filesystem is already mounted.  That can arguably
-			 * be seen as success.  "mount -a" tries to optimise
-			 * out this case but sometimes fails.  Help it out
-			 * by pretending everything is rosy
-			 */
-			return EX_SUCCESS;
-
 		if (nfs_is_permanent_error(errno))
 			break;
 
-- 
2.17.1
