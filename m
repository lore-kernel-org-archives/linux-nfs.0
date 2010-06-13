Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4839 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228Ab0FMTGp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jun 2010 15:06:45 -0400
Received: from localhost.localdomain (btp6na24.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5DJ6Q4l027412
	for <linux-nfs@vger.kernel.org>; Sun, 13 Jun 2010 12:06:27 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] SQUASHME: pnfs-submit: avoid NULL dereference in filelayout_commit dprintk
Date: Sun, 13 Jun 2010 15:06:26 -0400
Message-Id: <1276455986-15911-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

ds_nfs_client will be NULL when filelayout_commit is called.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b82e4ff..e6d45b8 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -569,8 +569,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 	struct nfs_write_data *dsdata;
 	struct nfs4_pnfs_ds *ds;
 
-	dprintk("%s data %p pnfs_client %p sync %d\n",
-		__func__, data, data->fldata.ds_nfs_client->cl_rpcclient, sync);
+	dprintk("%s data %p sync %d\n", __func__, data, sync);
 
 	/* Alloc room for both in one go */
 	ds_page_list = kzalloc((NFS4_PNFS_MAX_MULTI_CNT + 1) *
-- 
1.6.6.1

