Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1BF77489FC8
	for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2026 18:24:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790101484; cv=none; b=Ol0E7k3BthQPw4rpawSSDMaPWU8rden9ETLxB81VIr3Os6Rgxu+TEDXdMfTRt4fWKtLtU6a3sxN6nVTK7c40A2nnvo50oCMyvyuTqowDBC3YB+baHbHpxlh6kxEgATgPnNKVz1+JL+XvQjA3pPT+B3jxuxTJlVOtqrlZmvJ7PjU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790101484; c=relaxed/simple;
	bh=Makz4ArxCE6DxPGP6hXIm+U4qe5mZFn5ENR8KYoPtKQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=kiNjkAgN5hipTnUQv1xGlw7mKKI1lZY0DOaNtoQjkOD26yif/pKFnbPPkQPInY+Z0V7ZorPaNZWqiYVy1ridQeiz4NsEVeb+MHW1aU9Q3Rgn2ViViXj3K1/HiAv+IQtghbEr4pFwWn/d8UnrgS87PDBYSxt13m/8miP4vf0lWKQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=jFwT5iZV; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="jFwT5iZV"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790101482;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=bFG0dVU4nckxzAfanEWEximTgc6B3GCzWrfXtih7gk8=;
	b=jFwT5iZVrzZlEj3S7H2Iwpjf4dK/rJmasSVvJL3i8stCTfsVlWMR3gPTs6U8dah2YqZKyb
	lOcFQDHykNzeD1ggC/5ksc+9cNNo465cYVJJjJPhK4Bj6xF/Q/XwjMlCFyzY1vGG5A5IKS
	nLnGhgF0QO+CI83ov+qtWG629pAmODs=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-333-1zIVtj7TNgqUvWdJInpDmA-1; Tue,
 22 Sep 2026 14:24:38 -0400
X-MC-Unique: 1zIVtj7TNgqUvWdJInpDmA-1
X-Mimecast-MFC-AGG-ID: 1zIVtj7TNgqUvWdJInpDmA_1790101477
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 3CE6F1805A16;
	Tue, 22 Sep 2026 18:24:37 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id F3C971956049;
	Tue, 22 Sep 2026 18:24:36 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 4F08E557E66A;
	Tue, 22 Sep 2026 14:24:36 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: hch@infradead.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3] nfs: split up block layout and SCSI layout support
Date: Tue, 22 Sep 2026 14:24:36 -0400
Message-ID: <20260922182436.957454-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Add two new config options PNFS_BLOCK_LAYOUT and PNFS_SCSI_LAYOUT so
that SCSI layouts can be enabled without requiring block layouts.
Since block layouts are considered deprecated, PNFS_BLOCK_LAYOUT
is off by default.

The original PNFS_BLOCK config is now invisible and gets selected when
either of PNFS_BLOCK_LAYOUT or PNFS_SCSI_LAYOUT are enabled.

Also added a dependency on BLOCK to the Kconfig to fix undefined symbol
warnings from the kernel test robot.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
v3 changes:
- Make PNFS_BLOCK_LAYOUT and PNFS_SCSI_LAYOUT select PNFS_BLOCK instead
  of having PNFS_BLOCK depend on PNFS_BLOCK_LAYOUT or PNFS_SCSI_LAYOUT
- Remove redundant 'default n' from PNFS_BLOCK_LAYOUT
- Shuffled stuff around in blocklayout.c to reduce the number of ifdefs
- Added separate helpers to blocklayout.c for registering/unregistering
  the blocklayout and scsilayout types, along with stubs for when
  either of those are disabled
- In dev.c, wrapped blocklayout-specific and scsilayout-specific
  functions in appropriate ifdef blocks and created the necessary stubs
  for when either of those are disabled.
- Added dependency on BLOCK to the Kconfig to fix undefined symbol
  warnings from the kernel test robot

 fs/nfs/Kconfig                   |  17 ++++-
 fs/nfs/blocklayout/Makefile      |   3 +-
 fs/nfs/blocklayout/blocklayout.c | 113 ++++++++++++++++++++++---------
 fs/nfs/blocklayout/dev.c         |  32 ++++++++-
 4 files changed, 129 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6bb30543eff0..64c249f800a9 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -123,8 +123,23 @@ config PNFS_FILE_LAYOUT
 
 config PNFS_BLOCK
 	tristate
-	depends on NFS_V4 && BLK_DEV_DM
+
+config PNFS_BLOCK_LAYOUT
+	bool "NFS client support for pNFS block layouts"
+	depends on NFS_V4 && BLOCK && BLK_DEV_DM
+	select PNFS_BLOCK
+	help
+	  Enable support for the pNFS block-volume layout type (RFC 5663).
+
+	  If unsure, say N.
+
+config PNFS_SCSI_LAYOUT
+	bool "NFS client support for pNFS SCSI layouts"
+	depends on NFS_V4 && BLOCK
 	default NFS_V4
+	select PNFS_BLOCK
+	help
+	  Enable suport for the pNFS SCSI layout type (RFC 8154).
 
 config PNFS_FLEXFILE_LAYOUT
 	tristate
diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 7668a1bfb5fa..3403cb7fe201 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -4,4 +4,5 @@
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
 
-blocklayoutdriver-y += blocklayout.o dev.o extent_tree.o rpc_pipefs.o
+blocklayoutdriver-y += blocklayout.o dev.o extent_tree.o
+blocklayoutdriver-$(CONFIG_PNFS_BLOCK_LAYOUT) += rpc_pipefs.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d54a141a89b3..680b3b343859 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -470,18 +470,6 @@ static struct pnfs_layout_hdr *__bl_alloc_layout_hdr(struct inode *inode,
 	return &bl->bl_layout;
 }
 
-static struct pnfs_layout_hdr *bl_alloc_layout_hdr(struct inode *inode,
-						   gfp_t gfp_flags)
-{
-	return __bl_alloc_layout_hdr(inode, gfp_flags, false);
-}
-
-static struct pnfs_layout_hdr *sl_alloc_layout_hdr(struct inode *inode,
-						   gfp_t gfp_flags)
-{
-	return __bl_alloc_layout_hdr(inode, gfp_flags, true);
-}
-
 static void bl_free_lseg(struct pnfs_layout_segment *lseg)
 {
 	dprintk("%s enter\n", __func__);
@@ -954,6 +942,13 @@ static const struct nfs_pageio_ops bl_pg_write_ops = {
 	.pg_cleanup = pnfs_generic_pg_cleanup,
 };
 
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
+static struct pnfs_layout_hdr *bl_alloc_layout_hdr(struct inode *inode,
+						   gfp_t gfp_flags)
+{
+	return __bl_alloc_layout_hdr(inode, gfp_flags, false);
+}
+
 static struct pnfs_layoutdriver_type blocklayout_type = {
 	.id				= LAYOUT_BLOCK_VOLUME,
 	.name				= "LAYOUT_BLOCK_VOLUME",
@@ -978,6 +973,48 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.sync				= pnfs_generic_sync,
 };
 
+static int __init pnfs_register_blocklayout(void)
+{
+	int ret;
+
+	ret = bl_init_pipefs();
+	if (ret)
+		return ret;
+
+	ret = pnfs_register_layoutdriver(&blocklayout_type);
+	if (ret) {
+		bl_cleanup_pipefs();
+		return ret;
+	}
+
+	return 0;
+}
+
+static void __exit pnfs_unregister_blocklayout(void)
+{
+	pnfs_unregister_layoutdriver(&blocklayout_type);
+	bl_cleanup_pipefs();
+}
+
+MODULE_ALIAS("nfs-layouttype4-3");
+#else
+static int __init pnfs_register_blocklayout(void)
+{
+	return 0;
+}
+
+static void __exit pnfs_unregister_blocklayout(void)
+{
+}
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
+
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
+static struct pnfs_layout_hdr *sl_alloc_layout_hdr(struct inode *inode,
+						   gfp_t gfp_flags)
+{
+	return __bl_alloc_layout_hdr(inode, gfp_flags, true);
+}
+
 static struct pnfs_layoutdriver_type scsilayout_type = {
 	.id				= LAYOUT_SCSI,
 	.name				= "LAYOUT_SCSI",
@@ -1002,6 +1039,28 @@ static struct pnfs_layoutdriver_type scsilayout_type = {
 	.sync				= pnfs_generic_sync,
 };
 
+static int __init pnfs_register_scsilayout(void)
+{
+	return pnfs_register_layoutdriver(&scsilayout_type);
+}
+
+static void __exit pnfs_unregister_scsilayout(void)
+{
+	pnfs_unregister_layoutdriver(&scsilayout_type);
+}
+
+MODULE_ALIAS("nfs-layouttype4-5");
+#else
+static int __init pnfs_register_scsilayout(void)
+{
+	return 0;
+}
+
+static void __exit pnfs_unregister_scsilayout(void)
+{
+}
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
+
 
 static int __init nfs4blocklayout_init(void)
 {
@@ -1009,25 +1068,17 @@ static int __init nfs4blocklayout_init(void)
 
 	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
 
-	ret = bl_init_pipefs();
+	ret = pnfs_register_blocklayout();
 	if (ret)
-		goto out;
+		return ret;
 
-	ret = pnfs_register_layoutdriver(&blocklayout_type);
-	if (ret)
-		goto out_cleanup_pipe;
+	ret = pnfs_register_scsilayout();
+	if (ret) {
+		pnfs_unregister_blocklayout();
+		return ret;
+	}
 
-	ret = pnfs_register_layoutdriver(&scsilayout_type);
-	if (ret)
-		goto out_unregister_block;
 	return 0;
-
-out_unregister_block:
-	pnfs_unregister_layoutdriver(&blocklayout_type);
-out_cleanup_pipe:
-	bl_cleanup_pipefs();
-out:
-	return ret;
 }
 
 static void __exit nfs4blocklayout_exit(void)
@@ -1035,13 +1086,9 @@ static void __exit nfs4blocklayout_exit(void)
 	dprintk("%s: NFSv4 Block Layout Driver Unregistering...\n",
 	       __func__);
 
-	pnfs_unregister_layoutdriver(&scsilayout_type);
-	pnfs_unregister_layoutdriver(&blocklayout_type);
-	bl_cleanup_pipefs();
+	pnfs_unregister_scsilayout();
+	pnfs_unregister_blocklayout();
 }
 
-MODULE_ALIAS("nfs-layouttype4-3");
-MODULE_ALIAS("nfs-layouttype4-5");
-
 module_init(nfs4blocklayout_init);
 module_exit(nfs4blocklayout_exit);
diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index c926b7e43827..00462e6affb1 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -15,6 +15,7 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 static void bl_unregister_scsi(struct pnfs_block_dev *dev)
 {
 	struct block_device *bdev = file_bdev(dev->bdev_file);
@@ -45,6 +46,16 @@ static bool bl_register_scsi(struct pnfs_block_dev *dev)
 	trace_bl_pr_key_reg(bdev, dev->pr_key);
 	return true;
 }
+#else
+static void bl_unregister_scsi(struct pnfs_block_dev *dev)
+{
+}
+
+static bool bl_register_scsi(struct pnfs_block_dev *dev)
+{
+	return false;
+}
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 
 static void bl_unregister_dev(struct pnfs_block_dev *dev)
 {
@@ -292,7 +303,7 @@ static int
 bl_parse_deviceid(struct nfs_server *server, struct pnfs_block_dev *d,
 		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask);
 
-
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 static int
 bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
 		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
@@ -320,7 +331,17 @@ bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
 		file_bdev(bdev_file)->bd_disk->disk_name);
 	return 0;
 }
+#else
+static int
+bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
+                struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
+{
+	dprintk("unsupported volume type: %d\n", PNFS_BLOCK_VOLUME_SIMPLE);
+	return -EIO;
+}
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 static bool
 bl_validate_designator(struct pnfs_block_volume *v)
 {
@@ -449,6 +470,15 @@ bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
 	d->bdev_file = NULL;
 	return error;
 }
+#else
+static int
+bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
+{
+	dprintk("unsupported volume type: %d\n", PNFS_BLOCK_VOLUME_SCSI);
+	return -EIO;
+}
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 
 static int
 bl_parse_slice(struct nfs_server *server, struct pnfs_block_dev *d,
-- 
2.55.0

