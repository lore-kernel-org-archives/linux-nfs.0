Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:40042 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752746Ab0H3QzV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:55:21 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Tao Guo <guotao@nrchpc.ac.cn>, linux-nfs@vger.kernel.org
Cc: Jim Rees <rees@umich.edu>
Subject: [PATCH] SQUASHME: pnfs-block: Revert "pnfsblock: expose block_class interface"
Date: Mon, 30 Aug 2010 19:55:18 +0300
Message-Id: <1283187318-23251-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Following 462557a pnfs-block: Remove device creation from kernel
exporting block_class is not needed anymore.

This reverts commit f0004c24a5c923af2eba64506055bb83882bcf0e.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 block/genhd.c        |    1 -
 drivers/scsi/hosts.c |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/block/genhd.c b/block/genhd.c
index 4b48172..59a2db6 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -1009,7 +1009,6 @@ static void disk_release(struct device *dev)
 struct class block_class = {
 	.name		= "block",
 };
-EXPORT_SYMBOL(block_class);
 
 static char *block_devnode(struct device *dev, mode_t *mode)
 {
diff --git a/drivers/scsi/hosts.c b/drivers/scsi/hosts.c
index 0a121f8..7958885 100644
--- a/drivers/scsi/hosts.c
+++ b/drivers/scsi/hosts.c
@@ -54,6 +54,7 @@ struct class shost_class = {
 	.name		= "scsi_host",
 	.dev_release	= scsi_host_cls_release,
 };
+EXPORT_SYMBOL(shost_class);
 
 /**
  *	scsi_host_set_state - Take the given host through the host state model.
-- 
1.7.2.2

