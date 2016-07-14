Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48086 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbcGNFgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2016 01:36:07 -0400
From: "Jianhong.Yin" <yin-jianhong@163.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH] exportfs: fix export point checking
Date: Thu, 14 Jul 2016 13:35:59 +0800
Message-Id: <1468474559-24168-1-git-send-email-yin-jianhong@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS does not support regular file export and mount,
use S_ISLNK instead S_ISREG
---
 utils/exportfs/exportfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 5db348b..74baa08 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -585,8 +585,8 @@ validate_export(nfs_export *exp)
 		xlog(L_ERROR, "Failed to stat %s: %m", path);
 		return;
 	}
-	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
-		xlog(L_ERROR, "%s is neither a directory nor a file. "
+	if (!S_ISDIR(stb.st_mode) && !S_ISLNK(stb.st_mode)) {
+		xlog(L_ERROR, "%s is neither a directory nor a symlink. "
 			"Remote access will fail", path);
 		return;
 	}
-- 
2.5.5

