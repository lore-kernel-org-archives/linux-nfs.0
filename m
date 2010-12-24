Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53164 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750888Ab0LXFKb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Dec 2010 00:10:31 -0500
Message-ID: <4D142C4B.6080106@cn.fujitsu.com>
Date: Fri, 24 Dec 2010 13:14:51 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Steve Dickson <SteveD@redhat.com>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: [PATCH] libnsm.a: modify return value to false from 0 at nsm_drop_privileges()
References: <4D142BDA.6080809@cn.fujitsu.com>
In-Reply-To: <4D142BDA.6080809@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

At nsm_drop_privileges(), for improving readability, unify
the return value.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 support/nsm/file.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/nsm/file.c b/support/nsm/file.c
index e21c7d4..98b47bf 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -421,7 +421,7 @@ nsm_drop_privileges(const int pidfd)
 	 */
         if (prctl(PR_SET_KEEPCAPS, 1, 0, 0, 0) == -1) {
                 xlog(L_ERROR, "prctl(PR_SET_KEEPCAPS) failed: %m");
-		return 0;
+		return false;
 	}
 
 	if (setgroups(0, NULL) == -1) {
-- 1.7.3.3 

