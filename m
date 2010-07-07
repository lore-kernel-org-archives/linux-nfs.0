From: andros@netapp.com
Subject: [PATCH 15/16] SQUASHME pnfs-submit: do not reference a layout in destroy_layout.
Date: Wed,  7 Jul 2010 18:34:22 -0400
Message-ID: <1278542063-4009-16-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
 <1278542063-4009-3-git-send-email-andros@netapp.com>
 <1278542063-4009-4-git-send-email-andros@netapp.com>
 <1278542063-4009-5-git-send-email-andros@netapp.com>
 <1278542063-4009-6-git-send-email-andros@netapp.com>
 <1278542063-4009-7-git-send-email-andros@netapp.com>
 <1278542063-4009-8-git-send-email-andros@netapp.com>
 <1278542063-4009-9-git-send-email-andros@netapp.com>
 <1278542063-4009-10-git-send-email-andros@netapp.com>
 <1278542063-4009-11-git-send-email-andros@netapp.com>
 <1278542063-4009-12-git-send-email-andros@netapp.com>
 <1278542063-4009-13-git-send-email-andros@netapp.com>
 <1278542063-4009-14-git-send-email-andros@netapp.com>
 <1278542063-4009-15-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757545Ab0GGWed (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:33 -0400
In-Reply-To: <1278542063-4009-15-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7631efe..704288d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -391,7 +391,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	};
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	lo = grab_current_layout(nfsi);
+	lo = nfsi->layout;
 	if (lo) {
 		pnfs_free_layout(lo, &range);
 		WARN_ON(!list_empty(&nfsi->layout->segs));
-- 
1.6.6

