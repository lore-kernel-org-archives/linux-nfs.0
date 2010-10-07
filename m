Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59485 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab0JGQhP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 12:37:15 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@rhel6-1.androsmac.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/3] pnfs_submit: move layout segment valid test
Date: Thu,  7 Oct 2010 12:37:08 -0700
Message-Id: <1286480230-9418-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@rhel6-1.androsmac.org>

Do not get_lseg for a non-valid lseg.
Prepare for calling put_lseg outside of inode i_lock.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6b2a95d..24620cf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -845,7 +845,8 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo,
 	list_for_each_entry(lseg, &lo->segs, fi_list) {
 		if (is_matching_lseg(lseg, range)) {
 			ret = lseg;
-			get_lseg(ret);
+			if (lseg->valid)
+				get_lseg(ret);
 			break;
 		}
 		if (cmp_layout(range, &lseg->range) > 0)
@@ -889,7 +890,6 @@ pnfs_update_layout(struct inode *ino,
 	/* Check to see if the layout for the given range already exists */
 	lseg = pnfs_has_layout(lo, &arg);
 	if (lseg && !lseg->valid) {
-		put_lseg_locked(lseg);
 		/* someone is cleaning the layout */
 		lseg = NULL;
 		goto out_unlock;
-- 
1.6.6

