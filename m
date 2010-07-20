From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/3] SQUASHME: pnfs-block: use new commit api
Date: Tue, 20 Jul 2010 08:58:04 +0300
Message-ID: <1279605484-7419-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
Cc: andros@netapp.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21819 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754632Ab0GTF6G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:58:06 -0400
In-Reply-To: <4C453A50.7070009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 63d3b5a..e2ee90a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -99,9 +99,8 @@ dont_like_caller(struct nfs_page *req)
 }
 
 static enum pnfs_try_status
-bl_commit(struct pnfs_layout_type *lo,
-		int sync,
-		struct nfs_write_data *nfs_data)
+bl_commit(struct nfs_write_data *nfs_data,
+	  int sync)
 {
 	dprintk("%s enter\n", __func__);
 	return PNFS_NOT_ATTEMPTED;
-- 
1.7.1.1

