Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60583 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758691Ab0J1TKI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 15:10:08 -0400
Received: from localhost.localdomain (elee16240.hq.netapp.com [10.58.53.47] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o9SJA27h000482
	for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 12:10:06 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] pnfs-submit: nfs4_layoutreturn_release would crash on a bulk return
Date: Thu, 28 Oct 2010 15:10:00 -0400
Message-Id: <1288293001-26289-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288293001-26289-1-git-send-email-iisaman@netapp.com>
References: <1288293001-26289-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Only reference lo if in the FILE case.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4705ea6..96bd822 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5669,12 +5669,11 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 static void nfs4_layoutreturn_release(void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
-	struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
 
-	dprintk("--> %s return_type %d lo %p\n", __func__,
-		lrp->args.return_type, lo);
+	dprintk("--> %s return_type %d\n", __func__, lrp->args.return_type);
 
 	if (lrp->args.return_type == RETURN_FILE) {
+		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
 		spin_lock(&lo->inode->i_lock);
 		if (!lrp->res.lrs_present)
 			pnfs_invalidate_layout_stateid(lo);
-- 
1.7.2.1

