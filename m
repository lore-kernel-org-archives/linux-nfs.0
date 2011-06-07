Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52054 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799Ab1FGReG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:34:06 -0400
Date: Tue, 7 Jun 2011 13:34:05 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 68/88] SQUASHME: pnfs-block: Revert "pnfsblock: expose
 block_class interface"
Message-ID: <95b0dfe374f28fc29651467dc0e87e271373ba7b.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Following 462557a pnfs-block: Remove device creation from kernel
exporting block_class is not needed anymore.

This reverts commit f0004c24a5c923af2eba64506055bb83882bcf0e.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 block/genhd.c        |    1 -
 drivers/scsi/hosts.c |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/block/genhd.c b/block/genhd.c
index 6f19558..95822ae 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -1108,7 +1108,6 @@ static void disk_release(struct device *dev)
 struct class block_class = {
 	.name		= "block",
 };
-EXPORT_SYMBOL(block_class);
 
 static char *block_devnode(struct device *dev, mode_t *mode)
 {
diff --git a/drivers/scsi/hosts.c b/drivers/scsi/hosts.c
index ac24f02..7d91903 100644
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
1.7.4.1

