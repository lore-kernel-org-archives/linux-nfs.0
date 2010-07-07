From: andros@netapp.com
Subject: [PATCH 16/16] SQUASHME pnfs-submit: remove grab_current_layout
Date: Wed,  7 Jul 2010 18:34:23 -0400
Message-ID: <1278542063-4009-17-git-send-email-andros@netapp.com>
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
 <1278542063-4009-16-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757687Ab0GGWee (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:34 -0400
In-Reply-To: <1278542063-4009-16-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 704288d..6832237 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -324,17 +324,6 @@ get_layout(struct pnfs_layout_type *lo)
 	lo->refcount++;
 }
 
-static inline struct pnfs_layout_type *
-grab_current_layout(struct nfs_inode *nfsi)
-{
-	struct pnfs_layout_type *lo = nfsi->layout;
-
-	if (!lo)
-		return NULL;
-	get_layout(lo);
-	return lo;
-}
-
 static inline void
 put_layout_locked(struct pnfs_layout_type *lo)
 {
-- 
1.6.6

