Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696AbcGIFPj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Jul 2016 01:15:39 -0400
From: "Jianhong.Yin" <yin-jianhong@163.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, "Jianhong.Yin" <yin-jianhong@163.com>,
        Jianhong Yin <jiyin@redhat.com>
Subject: [PATCH] exportfs: fix export point checking
Date: Sat,  9 Jul 2016 13:15:33 +0800
Message-Id: <1468041333-30255-1-git-send-email-yin-jianhong@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS does not support file and symbolic export, if the export point
is regular file should give warning to user.

Signed-off-by: Jianhong Yin <jiyin@redhat.com>
---
 utils/exportfs/exportfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 5db348b..a00b5ea 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -585,8 +585,8 @@ validate_export(nfs_export *exp)
 		xlog(L_ERROR, "Failed to stat %s: %m", path);
 		return;
 	}
-	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
-		xlog(L_ERROR, "%s is neither a directory nor a file. "
+	if (!S_ISDIR(stb.st_mode)) {
+		xlog(L_ERROR, "%s is not a directory. "
 			"Remote access will fail", path);
 		return;
 	}
-- 
2.5.5

