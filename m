From: andros@netapp.com
Subject: [PATCH 1/4] SQUASHME pnfs-submit: cleanup layoutcommit call
Date: Thu,  3 Jun 2010 12:25:24 -0400
Message-ID: <1275582327-9285-2-git-send-email-andros@netapp.com>
References: <1275582327-9285-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55065 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137Ab0FCQZ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 12:25:29 -0400
In-Reply-To: <1275582327-9285-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

pnfs_layoutcommit_inode prints its status upon exit.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8cc4412..3e940ec 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -766,15 +766,9 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 				!pnfs_return_layout_barrier(nfsi, &arg));
 		}
 
-		if (layoutcommit_needed(nfsi)) {
-			status = pnfs_layoutcommit_inode(ino, wait);
-			if (status) {
-				dprintk("%s: layoutcommit failed, status=%d. "
-					"Returning layout anyway\n",
-					__func__, status);
-				status = 0;
-			}
-		}
+		if (layoutcommit_needed(nfsi))
+			/* Return layout even if layoutcommit fails */
+			pnfs_layoutcommit_inode(ino, wait);
 	}
 send_return:
 	status = return_layout(ino, &arg, stateid, type, lo, wait);
-- 
1.6.2.5

