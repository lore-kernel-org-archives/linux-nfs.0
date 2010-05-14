From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Subject: [PATCH 1/2] pnfsblock: expose block_class interface
Date: Fri, 14 May 2010 16:46:42 +0800
Message-ID: <20100514084619.GA10293@vmware>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fred Isaman <iisaman@umich.edu>, Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:33201 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758866Ab0ENJvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 05:51:12 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Export symbol block_class instead of shost_class for much more
generic block device iterations.

Signed-off-by: Huang Haoi <huanghao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
---
 block/genhd.c        |    1 +
 drivers/scsi/hosts.c |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/block/genhd.c b/block/genhd.c
index d13ba76..6faa1c6 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -1009,6 +1009,7 @@ static void disk_release(struct device *dev)
 struct class block_class = {
 	.name		= "block",
 };
+EXPORT_SYMBOL(block_class);
 
 static char *block_devnode(struct device *dev, mode_t *mode)
 {
diff --git a/drivers/scsi/hosts.c b/drivers/scsi/hosts.c
index 1b22b02..f1c2547 100644
--- a/drivers/scsi/hosts.c
+++ b/drivers/scsi/hosts.c
@@ -53,7 +53,6 @@ struct class shost_class = {
 	.name		= "scsi_host",
 	.dev_release	= scsi_host_cls_release,
 };
-EXPORT_SYMBOL(shost_class);
 
 /**
  *	scsi_host_set_state - Take the given host through the host state model.
-- 
1.6.3.3

