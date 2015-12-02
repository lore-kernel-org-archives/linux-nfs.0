Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:39045 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756984AbbLBLRg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2015 06:17:36 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NYQ02T4YA1AGUD0@mailout3.samsung.com> for
 linux-nfs@vger.kernel.org; Wed, 02 Dec 2015 20:17:34 +0900 (KST)
From: Vivek Trivedi <t.vivek@samsung.com>
To: linux-nfs@vger.kernel.org
Cc: a.sahrawat@samsung.com, pankaj.m@samsung.com,
        Vivek Trivedi <t.vivek@samsung.com>
Subject: [PATCH 1/2] nfs-utils: libnsm.a: do not close file if open failed
Date: Wed, 02 Dec 2015 16:46:37 +0530
Message-id: <1449054998-19308-1-git-send-email-t.vivek@samsung.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If file open failed, no need to issue close system call in
nsm_get_state and closeall.

Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
---
 support/nfs/closeall.c |    3 ++-
 support/nsm/file.c     |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/support/nfs/closeall.c b/support/nfs/closeall.c
index 38fb162..a69bf35 100644
--- a/support/nfs/closeall.c
+++ b/support/nfs/closeall.c
@@ -31,6 +31,7 @@ closeall(int min)
 	} else {
 		int fd = sysconf(_SC_OPEN_MAX);
 		while (--fd >= min)
-			(void) close(fd);
+			if(fd >= 0)
+				(void) close(fd);
 	}
 }
diff --git a/support/nsm/file.c b/support/nsm/file.c
index 4711c2c..7a8b504 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -536,7 +536,8 @@ nsm_get_state(_Bool update)
 		state++;
 
 update:
-	(void)close(fd);
+	if(fd >= 0)
+		(void)close(fd);
 
 	if (update) {
 		state += 2;
-- 
1.7.9.5

