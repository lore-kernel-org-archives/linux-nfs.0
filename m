Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51358 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab1FGRcM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:32:12 -0400
Date: Tue, 7 Jun 2011 13:32:11 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 51/88] pnfsblock: expose block_class interface
Message-ID: <d6b1d80797eee8e066ff14101cfd13a4bf48e717.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Tao Guo <guotao@nrchpc.ac.cn>

Export symbol block_class instead of shost_class for much more
generic block device iterations.

Signed-off-by: Huang Haoi <huanghao@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 block/genhd.c        |    1 +
 drivers/scsi/hosts.c |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/block/genhd.c b/block/genhd.c
index 95822ae..6f19558 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -1108,6 +1108,7 @@ static void disk_release(struct device *dev)
 struct class block_class = {
 	.name		= "block",
 };
+EXPORT_SYMBOL(block_class);
 
 static char *block_devnode(struct device *dev, mode_t *mode)
 {
diff --git a/drivers/scsi/hosts.c b/drivers/scsi/hosts.c
index 7d91903..ac24f02 100644
--- a/drivers/scsi/hosts.c
+++ b/drivers/scsi/hosts.c
@@ -54,7 +54,6 @@ struct class shost_class = {
 	.name		= "scsi_host",
 	.dev_release	= scsi_host_cls_release,
 };
-EXPORT_SYMBOL(shost_class);
 
 /**
  *	scsi_host_set_state - Take the given host through the host state model.
-- 
1.7.4.1

