From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/3] SQUASHME: pnfs-obj: use new commit api
Date: Tue, 20 Jul 2010 08:58:43 +0300
Message-ID: <1279605523-7546-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
Cc: andros@netapp.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51543 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754693Ab0GTF6p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:58:45 -0400
In-Reply-To: <4C453A50.7070009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 1381c60..6595bfc 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -297,9 +297,7 @@ static void _rpc_commit_complete(struct work_struct *work)
  * Commit data remotely on OSDs
  */
 enum pnfs_try_status
-objlayout_commit(struct pnfs_layout_type *pnfslay,
-		 int sync,
-		 struct nfs_write_data *wdata)
+objlayout_commit(struct nfs_write_data *wdata, int how)
 {
 	int status = PNFS_ATTEMPTED;
 
-- 
1.7.1.1

