Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE8F13CB548
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 19:45:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787859955; cv=none; b=ZB9pOuWEMX0n2yRuDqGnSxCahtRTU4kTekjCoRuPIo09Svh/F8J0rKuZpSbzIKiH1WF+5v90hGo+iJmEQ99L7nIYLqYZambDQsKrwthS9NEWij95Ewl1YhXu/2EVe44uPySZkknuV/dMtQMJK/qZoLeUbdEgdD5xj32tRCiroRo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787859955; c=relaxed/simple;
	bh=lNrs2pUrkzbSZ8OTRjNZmgv1L23pIfEvWP9I/4OYNWM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pr1qo1ibwwIZuHuyffJ2qZDIe93puuCLg+fkS2taqHFeMdN/VSEd0BrqRL7ZOglYmbIo96opr5AclbmDGSRtyT9ADqAR2F22T08D39idc8jR0I7xjc1haqawaEc3yppD3UcyPld2XFTsZczj9lyfY3V39iSfOh90SAHex7zmhzc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=R8nAI8DX; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="R8nAI8DX"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787859951;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=HlTN+fjwlWRAMxdQu7Jm12nfY7GFyuy35CNvZWIz5ug=;
	b=R8nAI8DXeP0wZJlV4ULwNN/p3ucnjww6yMQfdB7zUeDQQaC0nYHewKlYo6TJ4wBKZV3K5B
	QVNzlMtnI/IvSrd0nTO8o09ZBAiFugZZ7pXZMf0tYptKVOQDJ8pqmLUEUg5H8lYXJ7h7K+
	hLqj4on5PHwm+gPoKSld6/SlSHPFqyI=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-382-C-pGabjzOIenEXsT3ZYQIw-1; Thu,
 27 Aug 2026 15:45:47 -0400
X-MC-Unique: C-pGabjzOIenEXsT3ZYQIw-1
X-Mimecast-MFC-AGG-ID: C-pGabjzOIenEXsT3ZYQIw_1787859946
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 44BC3185FCF7;
	Thu, 27 Aug 2026 19:45:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet03.pony-001.prod.iad2.dc.redhat.com [10.2.32.114])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D6D761800642;
	Thu, 27 Aug 2026 19:45:45 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 2ACE05294D30;
	Thu, 27 Aug 2026 15:45:45 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs/blocklayout: allow pNFS SCSI layout without pNFS block layout
Date: Thu, 27 Aug 2026 15:45:44 -0400
Message-ID: <20260827194544.459315-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

The pNFS block-volume layout (LAYOUT_BLOCK_VOLUME, RFC 5663) and the pNFS
SCSI layout (LAYOUT_SCSI, RFC 8154) are built from a single blocklayout
driver.  Until now CONFIG_PNFS_BLOCK was an unprompted symbol that pulled
in both layout types whenever NFS_V4 and BLK_DEV_DM were enabled, so a
kernel could not offer SCSI layout without also enabling block layout and
device-mapper.

Split the two into separate, independently selectable options.  Both types
share almost the entire driver (read/write path, extent tree, and the
device tree including the composite SLICE/CONCAT/STRIPE volume types), so
keep a single blocklayoutdriver module and compile only the type-specific
pieces in or out:

  - block.c   SIMPLE volume parsing, which resolves the device via the
              userspace pipefs daemon (rpc_pipefs.c) - block only.
  - scsi.c    SCSI leaf volume parsing and persistent-reservation
              register/unregister - SCSI only.

The remaining type-specific call sites in the shared core are guarded with
IS_ENABLED() so the reference to a not-built symbol is eliminated, and the
now cross-file helpers (bl_map_simple, bl_parse_simple, bl_parse_scsi,
bl_register_scsi, bl_unregister_scsi) are made global with prototypes in
blocklayout.h.

CONFIG_PNFS_BLOCK and CONFIG_PNFS_SCSI_LAYOUT are now prompted booleans
that only select which volume types are compiled in.  Module linkage is
carried by a single internal tristate, CONFIG_PNFS_BLOCK_LAYOUT_DRIVER,
which follows NFS_V4; making the two options booleans avoids a y/m mismatch
where a built-in composite would silently drop a module-only object.  SCSI
layout defaults on and no longer depends on BLK_DEV_DM; block layout now
defaults off.

blocklayout.h no longer includes device-mapper.h (it was unused); it
includes blkdev.h for the block_device/sector_t/BLK_OPEN_* definitions used
in the header.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/Kconfig                   |  20 ++-
 fs/nfs/Makefile                  |   2 +-
 fs/nfs/blocklayout/Makefile      |  12 +-
 fs/nfs/blocklayout/block.c       |  40 ++++++
 fs/nfs/blocklayout/blocklayout.c |  43 ++++---
 fs/nfs/blocklayout/blocklayout.h |  14 ++-
 fs/nfs/blocklayout/dev.c         | 209 +++----------------------------
 fs/nfs/blocklayout/scsi.c        | 175 ++++++++++++++++++++++++++
 8 files changed, 300 insertions(+), 215 deletions(-)
 create mode 100644 fs/nfs/blocklayout/block.c
 create mode 100644 fs/nfs/blocklayout/scsi.c

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6bb30543eff0..9166ac623ba8 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -122,9 +122,27 @@ config PNFS_FILE_LAYOUT
 	default NFS_V4
 
 config PNFS_BLOCK
-	tristate
+	bool "pNFS block layout support"
 	depends on NFS_V4 && BLK_DEV_DM
+	default n
+	help
+	  Enable support for the pNFS block-volume layout type (RFC 5663).
+
+config PNFS_SCSI_LAYOUT
+	bool "pNFS SCSI layout support"
+	depends on NFS_V4
 	default NFS_V4
+	help
+	  Enable support for the pNFS SCSI layout type (RFC 8154). This does
+	  not require device-mapper and can be enabled without PNFS_BLOCK.
+
+# Internal: the shared block/scsi layout driver module, built when either layout
+# type is enabled. The two options above are booleans that only select which
+# volume types are compiled in; this symbol is the single modularity knob and
+# follows NFS_V4, so the composite module never lands in both obj-y and obj-m.
+config PNFS_BLOCK_LAYOUT_DRIVER
+	tristate
+	default NFS_V4 if PNFS_BLOCK || PNFS_SCSI_LAYOUT
 
 config PNFS_FLEXFILE_LAYOUT
 	tristate
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index c895521f27f3..49c06b759b60 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -34,5 +34,5 @@ nfsv4-$(CONFIG_NFS_V4_0)	+= nfs40client.o nfs40proc.o
 nfsv4-$(CONFIG_NFS_V4_2)	+= nfs42proc.o nfs42xattr.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += filelayout/
-obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
+obj-$(CONFIG_PNFS_BLOCK_LAYOUT_DRIVER) += blocklayout/
 obj-$(CONFIG_PNFS_FLEXFILE_LAYOUT) += flexfilelayout/
diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 7668a1bfb5fa..832012d1c1fc 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,6 +2,14 @@
 #
 # Makefile for the pNFS block layout driver kernel module
 #
-obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
+obj-$(CONFIG_PNFS_BLOCK_LAYOUT_DRIVER) += blocklayoutdriver.o
 
-blocklayoutdriver-y += blocklayout.o dev.o extent_tree.o rpc_pipefs.o
+# Shared core: device tree incl. composite SLICE/CONCAT/STRIPE volumes (used by
+# both layout types), extent tree, common layout ops, init/exit.
+blocklayoutdriver-y += blocklayout.o dev.o extent_tree.o
+
+# Block-layout-specific: SIMPLE volumes resolved via the userspace pipefs daemon.
+blocklayoutdriver-$(CONFIG_PNFS_BLOCK) += block.o rpc_pipefs.o
+
+# SCSI-layout-specific: SCSI leaf volume parse and PR register/unregister.
+blocklayoutdriver-$(CONFIG_PNFS_SCSI_LAYOUT) += scsi.o
diff --git a/fs/nfs/blocklayout/block.c b/fs/nfs/blocklayout/block.c
new file mode 100644
index 000000000000..530373a71c98
--- /dev/null
+++ b/fs/nfs/blocklayout/block.c
@@ -0,0 +1,40 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (c) 2014-2016 Christoph Hellwig.
+ */
+#include <linux/blkdev.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_xdr.h>
+
+#include "blocklayout.h"
+
+#define NFSDBG_FACILITY		NFSDBG_PNFS_LD
+
+int
+bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
+{
+	struct pnfs_block_volume *v = &volumes[idx];
+	struct file *bdev_file;
+	dev_t dev;
+
+	dev = bl_resolve_deviceid(server, v, gfp_mask);
+	if (!dev)
+		return -EIO;
+
+	bdev_file = bdev_file_open_by_dev(dev, BLK_OPEN_READ | BLK_OPEN_WRITE,
+				       NULL, NULL);
+	if (IS_ERR(bdev_file)) {
+		printk(KERN_WARNING "pNFS: failed to open device %d:%d (%ld)\n",
+			MAJOR(dev), MINOR(dev), PTR_ERR(bdev_file));
+		return PTR_ERR(bdev_file);
+	}
+	d->bdev_file = bdev_file;
+	d->len = bdev_nr_bytes(file_bdev(bdev_file));
+	d->map = bl_map_simple;
+
+	printk(KERN_INFO "pNFS: using block device %s\n",
+		file_bdev(bdev_file)->bd_disk->disk_name);
+	return 0;
+}
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d54a141a89b3..8f85849d3e05 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1005,27 +1005,33 @@ static struct pnfs_layoutdriver_type scsilayout_type = {
 
 static int __init nfs4blocklayout_init(void)
 {
-	int ret;
+	int ret = 0;
 
 	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
 
-	ret = bl_init_pipefs();
-	if (ret)
-		goto out;
+	if (IS_ENABLED(CONFIG_PNFS_BLOCK)) {
+		ret = bl_init_pipefs();
+		if (ret)
+			goto out;
 
-	ret = pnfs_register_layoutdriver(&blocklayout_type);
-	if (ret)
-		goto out_cleanup_pipe;
+		ret = pnfs_register_layoutdriver(&blocklayout_type);
+		if (ret)
+			goto out_cleanup_pipe;
+	}
 
-	ret = pnfs_register_layoutdriver(&scsilayout_type);
-	if (ret)
-		goto out_unregister_block;
+	if (IS_ENABLED(CONFIG_PNFS_SCSI_LAYOUT)) {
+		ret = pnfs_register_layoutdriver(&scsilayout_type);
+		if (ret)
+			goto out_unregister_block;
+	}
 	return 0;
 
 out_unregister_block:
-	pnfs_unregister_layoutdriver(&blocklayout_type);
+	if (IS_ENABLED(CONFIG_PNFS_BLOCK))
+		pnfs_unregister_layoutdriver(&blocklayout_type);
 out_cleanup_pipe:
-	bl_cleanup_pipefs();
+	if (IS_ENABLED(CONFIG_PNFS_BLOCK))
+		bl_cleanup_pipefs();
 out:
 	return ret;
 }
@@ -1035,13 +1041,20 @@ static void __exit nfs4blocklayout_exit(void)
 	dprintk("%s: NFSv4 Block Layout Driver Unregistering...\n",
 	       __func__);
 
-	pnfs_unregister_layoutdriver(&scsilayout_type);
-	pnfs_unregister_layoutdriver(&blocklayout_type);
-	bl_cleanup_pipefs();
+	if (IS_ENABLED(CONFIG_PNFS_SCSI_LAYOUT))
+		pnfs_unregister_layoutdriver(&scsilayout_type);
+	if (IS_ENABLED(CONFIG_PNFS_BLOCK)) {
+		pnfs_unregister_layoutdriver(&blocklayout_type);
+		bl_cleanup_pipefs();
+	}
 }
 
+#if IS_ENABLED(CONFIG_PNFS_BLOCK)
 MODULE_ALIAS("nfs-layouttype4-3");
+#endif
+#if IS_ENABLED(CONFIG_PNFS_SCSI_LAYOUT)
 MODULE_ALIAS("nfs-layouttype4-5");
+#endif
 
 module_init(nfs4blocklayout_init);
 module_exit(nfs4blocklayout_exit);
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 6da40ca19570..07740bbfeb67 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -32,7 +32,7 @@
 #ifndef FS_NFS_NFS4BLOCKLAYOUT_H
 #define FS_NFS_NFS4BLOCKLAYOUT_H
 
-#include <linux/device-mapper.h>
+#include <linux/blkdev.h>
 #include <linux/nfs_fs.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 
@@ -182,6 +182,18 @@ bool bl_register_dev(struct pnfs_block_dev *d);
 struct nfs4_deviceid_node *bl_alloc_deviceid_node(struct nfs_server *server,
 		struct pnfs_device *pdev, gfp_t gfp_mask);
 void bl_free_deviceid_node(struct nfs4_deviceid_node *d);
+bool bl_map_simple(struct pnfs_block_dev *dev, u64 offset,
+		struct pnfs_block_dev_map *map);
+
+/* block.c */
+int bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask);
+
+/* scsi.c */
+int bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask);
+bool bl_register_scsi(struct pnfs_block_dev *dev);
+void bl_unregister_scsi(struct pnfs_block_dev *dev);
 
 /* extent_tree.c */
 int ext_tree_insert(struct pnfs_block_layout *bl,
diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 368d20daf67b..897e3022da3d 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -4,48 +4,14 @@
  */
 #include <linux/sunrpc/svc.h>
 #include <linux/blkdev.h>
-#include <linux/fs_struct.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_xdr.h>
-#include <linux/pr.h>
 
 #include "blocklayout.h"
-#include "../nfs4trace.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
-static void bl_unregister_scsi(struct pnfs_block_dev *dev)
-{
-	struct block_device *bdev = file_bdev(dev->bdev_file);
-	const struct pr_ops *ops = bdev->bd_disk->fops->pr_ops;
-	int status;
-
-	status = ops->pr_register(bdev, dev->pr_key, 0, false);
-	if (status)
-		trace_bl_pr_key_unreg_err(bdev, dev->pr_key, status);
-	else
-		trace_bl_pr_key_unreg(bdev, dev->pr_key);
-}
-
-static bool bl_register_scsi(struct pnfs_block_dev *dev)
-{
-	struct block_device *bdev = file_bdev(dev->bdev_file);
-	const struct pr_ops *ops = bdev->bd_disk->fops->pr_ops;
-	int status;
-
-	if (test_and_set_bit(PNFS_BDEV_REGISTERED, &dev->flags))
-		return true;
-
-	status = ops->pr_register(bdev, 0, dev->pr_key, true);
-	if (status) {
-		trace_bl_pr_key_reg_err(bdev, dev->pr_key, status);
-		return false;
-	}
-	trace_bl_pr_key_reg(bdev, dev->pr_key);
-	return true;
-}
-
 static void bl_unregister_dev(struct pnfs_block_dev *dev)
 {
 	u32 i;
@@ -56,7 +22,8 @@ static void bl_unregister_dev(struct pnfs_block_dev *dev)
 		return;
 	}
 
-	if (dev->type == PNFS_BLOCK_VOLUME_SCSI &&
+	if (IS_ENABLED(CONFIG_PNFS_SCSI_LAYOUT) &&
+		dev->type == PNFS_BLOCK_VOLUME_SCSI &&
 		test_and_clear_bit(PNFS_BDEV_REGISTERED, &dev->flags))
 		bl_unregister_scsi(dev);
 }
@@ -76,7 +43,8 @@ bool bl_register_dev(struct pnfs_block_dev *dev)
 		return true;
 	}
 
-	if (dev->type == PNFS_BLOCK_VOLUME_SCSI)
+	if (IS_ENABLED(CONFIG_PNFS_SCSI_LAYOUT) &&
+	    dev->type == PNFS_BLOCK_VOLUME_SCSI)
 		return bl_register_scsi(dev);
 	return true;
 }
@@ -222,7 +190,7 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 	return 0;
 }
 
-static bool bl_map_simple(struct pnfs_block_dev *dev, u64 offset,
+bool bl_map_simple(struct pnfs_block_dev *dev, u64 offset,
 		struct pnfs_block_dev_map *map)
 {
 	map->start = dev->start;
@@ -291,162 +259,6 @@ bl_parse_deviceid(struct nfs_server *server, struct pnfs_block_dev *d,
 		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask);
 
 
-static int
-bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
-		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
-{
-	struct pnfs_block_volume *v = &volumes[idx];
-	struct file *bdev_file;
-	dev_t dev;
-
-	dev = bl_resolve_deviceid(server, v, gfp_mask);
-	if (!dev)
-		return -EIO;
-
-	bdev_file = bdev_file_open_by_dev(dev, BLK_OPEN_READ | BLK_OPEN_WRITE,
-				       NULL, NULL);
-	if (IS_ERR(bdev_file)) {
-		printk(KERN_WARNING "pNFS: failed to open device %d:%d (%ld)\n",
-			MAJOR(dev), MINOR(dev), PTR_ERR(bdev_file));
-		return PTR_ERR(bdev_file);
-	}
-	d->bdev_file = bdev_file;
-	d->len = bdev_nr_bytes(file_bdev(bdev_file));
-	d->map = bl_map_simple;
-
-	printk(KERN_INFO "pNFS: using block device %s\n",
-		file_bdev(bdev_file)->bd_disk->disk_name);
-	return 0;
-}
-
-static bool
-bl_validate_designator(struct pnfs_block_volume *v)
-{
-	switch (v->scsi.designator_type) {
-	case PS_DESIGNATOR_EUI64:
-		if (v->scsi.code_set != PS_CODE_SET_BINARY)
-			return false;
-
-		if (v->scsi.designator_len != 8 &&
-		    v->scsi.designator_len != 10 &&
-		    v->scsi.designator_len != 16)
-			return false;
-
-		return true;
-	case PS_DESIGNATOR_NAA:
-		if (v->scsi.code_set != PS_CODE_SET_BINARY)
-			return false;
-
-		if (v->scsi.designator_len != 8 &&
-		    v->scsi.designator_len != 16)
-			return false;
-
-		return true;
-	case PS_DESIGNATOR_T10:
-	case PS_DESIGNATOR_NAME:
-		pr_err("pNFS: unsupported designator "
-			"(code set %d, type %d, len %d.\n",
-			v->scsi.code_set,
-			v->scsi.designator_type,
-			v->scsi.designator_len);
-		return false;
-	default:
-		pr_err("pNFS: invalid designator "
-			"(code set %d, type %d, len %d.\n",
-			v->scsi.code_set,
-			v->scsi.designator_type,
-			v->scsi.designator_len);
-		return false;
-	}
-}
-
-static struct file *
-bl_open_path(struct pnfs_block_volume *v, const char *prefix)
-{
-	struct file *bdev_file;
-	const char *devname __free(kfree) = NULL;
-
-	devname = kasprintf(GFP_KERNEL, "/dev/disk/by-id/%s%*phN",
-			prefix, v->scsi.designator_len, v->scsi.designator);
-	if (!devname)
-		return ERR_PTR(-ENOMEM);
-
-	if (tsk_is_kthread(current)) {
-		scoped_with_init_fs()
-			bdev_file = bdev_file_open_by_path(devname,
-					BLK_OPEN_READ | BLK_OPEN_WRITE,
-					NULL, NULL);
-	} else {
-		bdev_file = bdev_file_open_by_path(devname,
-				BLK_OPEN_READ | BLK_OPEN_WRITE, NULL, NULL);
-	}
-	if (IS_ERR(bdev_file)) {
-		dprintk("failed to open device %s (%ld)\n",
-			devname, PTR_ERR(bdev_file));
-	} else {
-		pr_info("pNFS: using block device %s\n",
-			file_bdev(bdev_file)->bd_disk->disk_name);
-	}
-
-	return bdev_file;
-}
-
-static int
-bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
-		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
-{
-	struct pnfs_block_volume *v = &volumes[idx];
-	struct block_device *bdev;
-	const struct pr_ops *ops;
-	struct file *bdev_file;
-	int error;
-
-	if (!bl_validate_designator(v))
-		return -EINVAL;
-
-	/*
-	 * Try to open the RH/Fedora specific dm-mpath udev path first, as the
-	 * wwn- links will only point to the first discovered SCSI device there.
-	 * On other distributions like Debian, the default SCSI by-id path will
-	 * point to the dm-multipath device if one exists.
-	 */
-	bdev_file = bl_open_path(v, "dm-uuid-mpath-0x");
-	if (IS_ERR(bdev_file))
-		bdev_file = bl_open_path(v, "wwn-0x");
-	if (IS_ERR(bdev_file))
-		bdev_file = bl_open_path(v, "nvme-eui.");
-	if (IS_ERR(bdev_file)) {
-		pr_warn("pNFS: no device found for volume %*phN\n",
-			v->scsi.designator_len, v->scsi.designator);
-		return PTR_ERR(bdev_file);
-	}
-	d->bdev_file = bdev_file;
-	bdev = file_bdev(bdev_file);
-
-	d->len = bdev_nr_bytes(bdev);
-	d->map = bl_map_simple;
-	d->pr_key = v->scsi.pr_key;
-
-	if (d->len == 0) {
-		error = -ENODEV;
-		goto out_blkdev_put;
-	}
-
-	ops = bdev->bd_disk->fops->pr_ops;
-	if (!ops) {
-		pr_err("pNFS: block device %s does not support reservations.",
-				bdev->bd_disk->disk_name);
-		error = -EINVAL;
-		goto out_blkdev_put;
-	}
-
-	return 0;
-
-out_blkdev_put:
-	fput(d->bdev_file);
-	return error;
-}
-
 static int
 bl_parse_slice(struct nfs_server *server, struct pnfs_block_dev *d,
 		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
@@ -529,7 +341,9 @@ bl_parse_deviceid(struct nfs_server *server, struct pnfs_block_dev *d,
 
 	switch (d->type) {
 	case PNFS_BLOCK_VOLUME_SIMPLE:
-		return bl_parse_simple(server, d, volumes, idx, gfp_mask);
+		if (IS_ENABLED(CONFIG_PNFS_BLOCK))
+			return bl_parse_simple(server, d, volumes, idx, gfp_mask);
+		break;
 	case PNFS_BLOCK_VOLUME_SLICE:
 		return bl_parse_slice(server, d, volumes, idx, gfp_mask);
 	case PNFS_BLOCK_VOLUME_CONCAT:
@@ -537,11 +351,16 @@ bl_parse_deviceid(struct nfs_server *server, struct pnfs_block_dev *d,
 	case PNFS_BLOCK_VOLUME_STRIPE:
 		return bl_parse_stripe(server, d, volumes, idx, gfp_mask);
 	case PNFS_BLOCK_VOLUME_SCSI:
-		return bl_parse_scsi(server, d, volumes, idx, gfp_mask);
+		if (IS_ENABLED(CONFIG_PNFS_SCSI_LAYOUT))
+			return bl_parse_scsi(server, d, volumes, idx, gfp_mask);
+		break;
 	default:
 		dprintk("unsupported volume type: %d\n", d->type);
 		return -EIO;
 	}
+
+	dprintk("unsupported volume type: %d\n", d->type);
+	return -EIO;
 }
 
 struct nfs4_deviceid_node *
diff --git a/fs/nfs/blocklayout/scsi.c b/fs/nfs/blocklayout/scsi.c
new file mode 100644
index 000000000000..2a691e5be9a2
--- /dev/null
+++ b/fs/nfs/blocklayout/scsi.c
@@ -0,0 +1,175 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (c) 2014-2016 Christoph Hellwig.
+ */
+#include <linux/sunrpc/svc.h>
+#include <linux/blkdev.h>
+#include <linux/fs_struct.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_xdr.h>
+#include <linux/pr.h>
+
+#include "blocklayout.h"
+#include "../nfs4trace.h"
+
+#define NFSDBG_FACILITY		NFSDBG_PNFS_LD
+
+void bl_unregister_scsi(struct pnfs_block_dev *dev)
+{
+	struct block_device *bdev = file_bdev(dev->bdev_file);
+	const struct pr_ops *ops = bdev->bd_disk->fops->pr_ops;
+	int status;
+
+	status = ops->pr_register(bdev, dev->pr_key, 0, false);
+	if (status)
+		trace_bl_pr_key_unreg_err(bdev, dev->pr_key, status);
+	else
+		trace_bl_pr_key_unreg(bdev, dev->pr_key);
+}
+
+bool bl_register_scsi(struct pnfs_block_dev *dev)
+{
+	struct block_device *bdev = file_bdev(dev->bdev_file);
+	const struct pr_ops *ops = bdev->bd_disk->fops->pr_ops;
+	int status;
+
+	if (test_and_set_bit(PNFS_BDEV_REGISTERED, &dev->flags))
+		return true;
+
+	status = ops->pr_register(bdev, 0, dev->pr_key, true);
+	if (status) {
+		trace_bl_pr_key_reg_err(bdev, dev->pr_key, status);
+		return false;
+	}
+	trace_bl_pr_key_reg(bdev, dev->pr_key);
+	return true;
+}
+
+static bool
+bl_validate_designator(struct pnfs_block_volume *v)
+{
+	switch (v->scsi.designator_type) {
+	case PS_DESIGNATOR_EUI64:
+		if (v->scsi.code_set != PS_CODE_SET_BINARY)
+			return false;
+
+		if (v->scsi.designator_len != 8 &&
+		    v->scsi.designator_len != 10 &&
+		    v->scsi.designator_len != 16)
+			return false;
+
+		return true;
+	case PS_DESIGNATOR_NAA:
+		if (v->scsi.code_set != PS_CODE_SET_BINARY)
+			return false;
+
+		if (v->scsi.designator_len != 8 &&
+		    v->scsi.designator_len != 16)
+			return false;
+
+		return true;
+	case PS_DESIGNATOR_T10:
+	case PS_DESIGNATOR_NAME:
+		pr_err("pNFS: unsupported designator "
+			"(code set %d, type %d, len %d.\n",
+			v->scsi.code_set,
+			v->scsi.designator_type,
+			v->scsi.designator_len);
+		return false;
+	default:
+		pr_err("pNFS: invalid designator "
+			"(code set %d, type %d, len %d.\n",
+			v->scsi.code_set,
+			v->scsi.designator_type,
+			v->scsi.designator_len);
+		return false;
+	}
+}
+
+static struct file *
+bl_open_path(struct pnfs_block_volume *v, const char *prefix)
+{
+	struct file *bdev_file;
+	const char *devname __free(kfree) = NULL;
+
+	devname = kasprintf(GFP_KERNEL, "/dev/disk/by-id/%s%*phN",
+			prefix, v->scsi.designator_len, v->scsi.designator);
+	if (!devname)
+		return ERR_PTR(-ENOMEM);
+
+	if (tsk_is_kthread(current)) {
+		scoped_with_init_fs()
+			bdev_file = bdev_file_open_by_path(devname,
+					BLK_OPEN_READ | BLK_OPEN_WRITE,
+					NULL, NULL);
+	} else {
+		bdev_file = bdev_file_open_by_path(devname,
+				BLK_OPEN_READ | BLK_OPEN_WRITE, NULL, NULL);
+	}
+	if (IS_ERR(bdev_file)) {
+		dprintk("failed to open device %s (%ld)\n",
+			devname, PTR_ERR(bdev_file));
+	} else {
+		pr_info("pNFS: using block device %s\n",
+			file_bdev(bdev_file)->bd_disk->disk_name);
+	}
+
+	return bdev_file;
+}
+
+int
+bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
+{
+	struct pnfs_block_volume *v = &volumes[idx];
+	struct block_device *bdev;
+	const struct pr_ops *ops;
+	struct file *bdev_file;
+	int error;
+
+	if (!bl_validate_designator(v))
+		return -EINVAL;
+
+	/*
+	 * Try to open the RH/Fedora specific dm-mpath udev path first, as the
+	 * wwn- links will only point to the first discovered SCSI device there.
+	 * On other distributions like Debian, the default SCSI by-id path will
+	 * point to the dm-multipath device if one exists.
+	 */
+	bdev_file = bl_open_path(v, "dm-uuid-mpath-0x");
+	if (IS_ERR(bdev_file))
+		bdev_file = bl_open_path(v, "wwn-0x");
+	if (IS_ERR(bdev_file))
+		bdev_file = bl_open_path(v, "nvme-eui.");
+	if (IS_ERR(bdev_file)) {
+		pr_warn("pNFS: no device found for volume %*phN\n",
+			v->scsi.designator_len, v->scsi.designator);
+		return PTR_ERR(bdev_file);
+	}
+	d->bdev_file = bdev_file;
+	bdev = file_bdev(bdev_file);
+
+	d->len = bdev_nr_bytes(bdev);
+	d->map = bl_map_simple;
+	d->pr_key = v->scsi.pr_key;
+
+	if (d->len == 0) {
+		error = -ENODEV;
+		goto out_blkdev_put;
+	}
+
+	ops = bdev->bd_disk->fops->pr_ops;
+	if (!ops) {
+		pr_err("pNFS: block device %s does not support reservations.",
+				bdev->bd_disk->disk_name);
+		error = -EINVAL;
+		goto out_blkdev_put;
+	}
+
+	return 0;
+
+out_blkdev_put:
+	fput(d->bdev_file);
+	return error;
+}
-- 
2.55.0

