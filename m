From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 4/7] SQUASHME: pnfsblock: write_end_cleanup adjust for removed ok_to_use_pnfs
Date: Fri, 11 Jun 2010 03:40:36 -0400
Message-ID: <1276242039-18649-5-git-send-email-iisaman@netapp.com>
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
 <1276242039-18649-2-git-send-email-iisaman@netapp.com>
 <1276242039-18649-3-git-send-email-iisaman@netapp.com>
 <1276242039-18649-4-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32582 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869Ab0FKHk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:40:56 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7eoVe027834
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:40:55 -0700 (PDT)
In-Reply-To: <1276242039-18649-4-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index b1df445..43a5617 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1048,9 +1048,13 @@ bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
 	sector_t *pos;
 	struct address_space *mapping = filp->f_mapping;
 	struct pnfs_fsdata *fake_data;
+	struct pnfs_layout_segment *lseg;
 
 	if (!fsdata)
 		return;
+	lseg = fsdata->lseg;
+	if (!lseg)
+		return;
 	pos = fsdata->private;
 	if (!pos)
 		return;
@@ -1079,7 +1083,8 @@ bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
 				unlock_page(page);
 				continue;
 			}
-			fake_data->ok_to_use_pnfs = 1;
+			get_lseg(lseg);
+			fake_data->lseg = lseg;
 			fake_data->bypass_eof = 1;
 			mapping->a_ops->write_end(filp, mapping,
 						  index << PAGE_CACHE_SHIFT,
-- 
1.6.6.1

