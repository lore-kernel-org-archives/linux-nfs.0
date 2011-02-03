Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53797 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932365Ab1BCS3B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Feb 2011 13:29:01 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/3] pnfs: do not need to clear NFS_LAYOUT_BULK_RECALL flag
Date: Thu,  3 Feb 2011 13:28:51 -0500
Message-Id: <1296757732-16261-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1296757732-16261-1-git-send-email-iisaman@netapp.com>
References: <1296757732-16261-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We do not need to clear the NFS_LAYOUT_BULK_RECALL, as setting it
guarantees that NFS_LAYOUT_DESTROYED will be set once any outstanding
io is finished.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c8d9b21..c17edfb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -254,7 +254,6 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 			/* List does not take a reference, so no need for put here */
 			list_del_init(&lseg->pls_layout->plh_layouts);
 			spin_unlock(&clp->cl_lock);
-			clear_bit(NFS_LAYOUT_BULK_RECALL, &lseg->pls_layout->plh_flags);
 			set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
 			/* Matched by initial refcount set in alloc_init_layout_hdr */
 			put_layout_hdr_locked(lseg->pls_layout);
@@ -754,7 +753,6 @@ pnfs_update_layout(struct inode *ino,
 			spin_lock(&clp->cl_lock);
 			list_del_init(&lo->plh_layouts);
 			spin_unlock(&clp->cl_lock);
-			clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 		}
 		spin_unlock(&ino->i_lock);
 	}
-- 
1.7.2.1

