Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13736 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab1BVRrd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 12:47:33 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfs: fix lock inversion in pnfs_layout_process
Date: Tue, 22 Feb 2011 09:47:29 -0800
Message-Id: <1298396849-19340-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Introduced in cab1647c Revert "pnfs-submit: wave2: remove cl_layoutrecalls list"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5a47b76..c184e41 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1045,7 +1045,6 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		goto out;
 	}
 
-	spin_lock(&ino->i_lock);
 	/* decrement needs to be done before call to pnfs_layoutget_blocked */
 	atomic_dec(&lo->plh_outstanding);
 	spin_lock(&clp->cl_lock);
@@ -1056,6 +1055,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 	spin_unlock(&clp->cl_lock);
 
+	spin_lock(&ino->i_lock);
 	if (pnfs_layoutgets_blocked(lo, &res->stateid)) {
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
-- 
1.7.3.4

