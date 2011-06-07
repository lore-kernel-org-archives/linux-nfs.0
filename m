Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51600 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451Ab1FGRct (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:32:49 -0400
Date: Tue, 7 Jun 2011 13:32:47 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 57/88] SQUASHME: pnfsblock: write_end_cleanup adjust for
 removed ok_to_use_pnfs
Message-ID: <28b4f3b81ac3c03a110d6837773ba352dbd075b1.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

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
1.7.4.1

