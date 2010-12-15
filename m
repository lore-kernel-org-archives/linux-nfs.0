Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57906 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227Ab0LOQD0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 11:03:26 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBFG3Low001580
	for <linux-nfs@vger.kernel.org>; Wed, 15 Dec 2010 08:03:25 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/11] wave 2: remove trigger_flush
Date: Wed, 15 Dec 2010 11:03:07 -0500
Message-Id: <1292428991-30788-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
References: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We intend to just stop using the layout, no need to flush page cache.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 918d6c5..afa51c3 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -111,11 +111,6 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 
 #if defined(CONFIG_NFS_V4_1)
 
-static void trigger_flush(struct inode *ino)
-{
-	write_inode_now(ino, 0);
-}
-
 static int initiate_layout_draining(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
@@ -154,8 +149,6 @@ static int initiate_layout_draining(struct nfs_client *clp,
 		}
 		pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 		spin_unlock(&lo->inode->i_lock);
-		if (rv == NFS4_OK)
-			trigger_flush(lo->inode);
 		pnfs_free_lseg_list(&free_me_list);
 	} else {
 		struct pnfs_layout_hdr *tmp;
@@ -185,7 +178,6 @@ static int initiate_layout_draining(struct nfs_client *clp,
 			nfs4_asynch_forget_layouts(lo, &range, &free_me_list);
 			list_del_init(&lo->plh_bulk_recall);
 			spin_unlock(&lo->inode->i_lock);
-			trigger_flush(lo->inode);
 			put_layout_hdr(lo);
 			rv = NFS4_OK;
 		}
-- 
1.7.2.1

