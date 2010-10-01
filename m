Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab0JAQDl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 12:03:41 -0400
Received: from localhost.localdomain (vpn2ntap-420885.hq.netapp.com [10.58.51.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o91G3Uen008238
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 09:03:39 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] SQUASHME: pnfs-devinfo-submit: fix comments in pnfs_layout*_release
Date: Fri,  1 Oct 2010 12:02:47 -0400
Message-Id: <1285948971-2048-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
References: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

comments were not changed with the functions

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5ba2c45..7013916 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -390,11 +390,7 @@ pnfs_layoutget_release(struct pnfs_layout_hdr *lo)
 	struct nfs_inode *nfsi = NFS_I(lo->inode);
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	/*
-	 * Matched in _pnfs_update_layout for layoutget
-	 * and by get_layout in _pnfs_return_layout for layoutreturn
-	 */
-	put_layout_hdr_locked(lo);
+	put_layout_hdr_locked(lo); /* Matched in _pnfs_update_layout */
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	wake_up_all(&nfsi->lo_waitq);
 }
@@ -408,11 +404,7 @@ pnfs_layoutreturn_release(struct pnfs_layout_hdr *lo,
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (range)
 		pnfs_clear_lseg_list(lo, range);
-	/*
-	 * Matched in _pnfs_update_layout for layoutget
-	 * and by get_layout in _pnfs_return_layout for layoutreturn
-	 */
-	put_layout_hdr_locked(lo);
+	put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	wake_up_all(&nfsi->lo_waitq);
 }
-- 
1.7.2.1

