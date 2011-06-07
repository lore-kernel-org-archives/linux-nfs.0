Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50941 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116Ab1FGRbH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:31:07 -0400
Date: Tue, 7 Jun 2011 13:31:05 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 43/88] SQUASHME: pnfsblock: fix bug when decoding block
 device info.
Message-ID: <6907342571a9ea8211134ccf39dcdf538bacc146.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Tao Guo <guotao@nrchpc.ac.cn>

Skip local block device if its gendisk structure is NULL.

Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayoutdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index ac5c117..9fc3d46 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -375,7 +375,7 @@ static int map_sig_to_device(struct pnfs_blk_sig *sig,
 	struct visible_block_device *vis_dev;
 
 	list_for_each_entry(vis_dev, sdlist, vi_node) {
-		if (vis_dev->vi_mapped)
+		if (vis_dev->vi_mapped || !vis_dev->vi_bdev->bd_disk)
 			continue;
 		mapped = verify_sig(vis_dev->vi_bdev, sig);
 		if (mapped) {
-- 
1.7.4.1

