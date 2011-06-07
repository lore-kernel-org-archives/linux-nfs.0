Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53072 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1FGR1g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:27:36 -0400
Date: Tue, 7 Jun 2011 13:27:34 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 15/88] pnfsblock: dm kernel interface
Message-ID: <6982c7d89e262c885b459b7dc4a62990ed6c8bbe.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

We need kernel access to what is currently a user-mode only ioctl interface.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 drivers/md/dm-ioctl.c            |   24 ++++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayout.h |    4 ++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
index 4cacdad..d0d417e 100644
--- a/drivers/md/dm-ioctl.c
+++ b/drivers/md/dm-ioctl.c
@@ -713,6 +713,12 @@ static int dev_create(struct dm_ioctl *param, size_t param_size)
 	return 0;
 }
 
+int dm_dev_create(struct dm_ioctl *param)
+{
+	return dev_create(param, sizeof(*param));
+}
+EXPORT_SYMBOL(dm_dev_create);
+
 /*
  * Always use UUID for lookups if it's present, otherwise use name or dev.
  */
@@ -808,6 +814,12 @@ static int dev_remove(struct dm_ioctl *param, size_t param_size)
 	return 0;
 }
 
+int dm_dev_remove(struct dm_ioctl *param)
+{
+	return dev_remove(param, sizeof(*param));
+}
+EXPORT_SYMBOL(dm_dev_remove);
+
 /*
  * Check a string doesn't overrun the chunk of
  * memory we copied from userland.
@@ -990,6 +1002,12 @@ static int do_resume(struct dm_ioctl *param)
 	return r;
 }
 
+int dm_do_resume(struct dm_ioctl *param)
+{
+	return do_resume(param);
+}
+EXPORT_SYMBOL(dm_do_resume);
+
 /*
  * Set or unset the suspension state of a device.
  * If the device already is in the requested state we just return its status.
@@ -1256,6 +1274,12 @@ out:
 	return r;
 }
 
+int dm_table_load(struct dm_ioctl *param, size_t param_size)
+{
+	return table_load(param, param_size);
+}
+EXPORT_SYMBOL(dm_table_load);
+
 static int table_clear(struct dm_ioctl *param, size_t param_size)
 {
 	struct hash_cell *hc;
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 4af6685..2c6e1fe 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -35,8 +35,12 @@
 #include <linux/nfs_fs.h>
 #include <linux/pnfs_xdr.h> /* Needed by nfs4_pnfs.h */
 #include <linux/nfs4_pnfs.h>
+#include <linux/dm-ioctl.h> /* Needed for struct dm_ioctl*/
 
 extern struct class shost_class; /* exported from drivers/scsi/hosts.c */
+extern int dm_dev_create(struct dm_ioctl *param); /* from dm-ioctl.c */
+extern int dm_dev_remove(struct dm_ioctl *param); /* from dm-ioctl.c */
+
 
 struct block_mount_id {
 	struct super_block		*bm_sb;     /* back pointer */
-- 
1.7.4.1

