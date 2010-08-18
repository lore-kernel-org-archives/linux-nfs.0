Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082Ab0HROod (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:33 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 08/11] SQUASHME pnfs_submit rename pnfs_layout_type 8
Date: Wed, 18 Aug 2010 10:44:15 -0400
Message-Id: <1282142658-21579-9-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-8-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
 <1282142658-21579-3-git-send-email-andros@netapp.com>
 <1282142658-21579-4-git-send-email-andros@netapp.com>
 <1282142658-21579-5-git-send-email-andros@netapp.com>
 <1282142658-21579-6-git-send-email-andros@netapp.com>
 <1282142658-21579-7-git-send-email-andros@netapp.com>
 <1282142658-21579-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: layoutreturn

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8879fab..10cf7e2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5698,7 +5698,7 @@ static void nfs4_pnfs_layoutreturn_done(struct rpc_task *task, void *calldata)
 static void nfs4_pnfs_layoutreturn_release(void *calldata)
 {
 	struct nfs4_pnfs_layoutreturn *lrp = calldata;
-	struct pnfs_layout_type *lo = NFS_I(lrp->args.inode)->layout;
+	struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
 
 	dprintk("--> %s return_type %d lo %p\n", __func__,
 		lrp->args.return_type, lo);
-- 
1.6.2.5

