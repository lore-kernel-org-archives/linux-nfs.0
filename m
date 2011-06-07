Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51734 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757391Ab1FGRdN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:33:13 -0400
Date: Tue, 7 Jun 2011 13:33:11 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 60/88] SQUASHME: pnfs-block: nfs4_blk_add_block_disk ret must
 be signed
Message-ID: <d050d13a4254d5ae992cb8de5b9536c5bd3c6821.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

otherwise checking for ret < 0 is futile.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayoutdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index ef39c36..a866f5c 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -105,7 +105,8 @@ nfs4_blk_add_block_disk(struct device *cdev,
 	static char *claim_ptr = "I belong to pnfs block driver";
 	struct block_device *bdev;
 	struct gendisk *gd;
-	unsigned int major, minor, ret = 0;
+	unsigned int major, minor;
+	int ret;
 	dev_t dev;
 
 	dprintk("%s enter \n", __func__);
-- 
1.7.4.1

