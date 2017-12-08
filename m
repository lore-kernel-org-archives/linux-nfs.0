Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44584 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753080AbdLHRxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Dec 2017 12:53:00 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 1/3] pnfs/blocklayout: set PNFS_LAYOUTRETURN_ON_ERROR
Date: Fri,  8 Dec 2017 12:52:57 -0500
Message-Id: <cfb6cede39077dd12a98f2fa444e5ed730bd72c0.1512748321.git.bcodding@redhat.com>
In-Reply-To: <cover.1512748321.git.bcodding@redhat.com>
References: <cover.1512748321.git.bcodding@redhat.com>
In-Reply-To: <cover.1512748321.git.bcodding@redhat.com>
References: <cover.1512748321.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there's an error doing I/O to block device, and the client resends the
I/O to the MDS, the MDS must recall the layout from the client before
processing the I/O.  Let's preempt that exchange by returning the layout
before falling back to the MDS when there's an error.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.c | 2 ++
 fs/nfs/pnfs.h                    | 4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d8863a804b15..f66c9f2816a5 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -887,6 +887,7 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.name				= "LAYOUT_BLOCK_VOLUME",
 	.owner				= THIS_MODULE,
 	.flags				= PNFS_LAYOUTRET_ON_SETATTR |
+					  PNFS_LAYOUTRET_ON_ERROR |
 					  PNFS_READ_WHOLE_PAGE,
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
@@ -910,6 +911,7 @@ static struct pnfs_layoutdriver_type scsilayout_type = {
 	.name				= "LAYOUT_SCSI",
 	.owner				= THIS_MODULE,
 	.flags				= PNFS_LAYOUTRET_ON_SETATTR |
+					  PNFS_LAYOUTRET_ON_ERROR |
 					  PNFS_READ_WHOLE_PAGE,
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 99731e3e332f..4b4120b6824a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -524,8 +524,10 @@ static inline int pnfs_return_layout(struct inode *ino)
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *nfss = NFS_SERVER(ino);
 
-	if (pnfs_enabled_sb(nfss) && nfsi->layout)
+	if (pnfs_enabled_sb(nfss) && nfsi->layout) {
+		set_bit(NFS_LAYOUT_RETURN_REQUESTED, &nfsi->layout->plh_flags);
 		return _pnfs_return_layout(ino);
+	}
 
 	return 0;
 }
-- 
2.9.3

