Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC8C736F8F2
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 17:26:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788542795; cv=none; b=rmzT810BGeUJmYBp44V5GBsmE83azAt/3marcFYj15rWIt2KgUZKk8Rwjl0VwVkBPESfPfCo07dcyWOPjyL2cBENTCqhTLWR/e2EcYpKW5H8NCMFduPBdH9fa63U2mdOZVM8Zk0ZEIZ4pEekwDmzWuVwdtZwarka45RP7fAkAWU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788542795; c=relaxed/simple;
	bh=gNLMBeyUtoUv6WdsOXY7BURgkUh9nCPBK5dwu0Zo2/E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=C3MbLTijsF3RvIWazWfXIZauJ27gpFFYl3pH+ToeEXCBLCMVrrxsBT9uypp2bDxi5Q84ifCpx4A5hym0wmZkzMj2RdRzoY1JjxKyz3oaJnUQSPeTluYre0CGFb6slPnNOHAwKa13mjHGr2VYIa8wHtfPoCkAAIR40ZTWiLHehVQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=d5dkONJO; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="d5dkONJO"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788542792;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=i+9530KHzlo3HoYrmEmpmMoE+NX//U9Ppk+I/9xupmM=;
	b=d5dkONJOd62bnkNGQtQJjfdkIy3Vj9CKDIt0e3eNYMjDb9q0lEhcJmZEWTjMHkexSYglpR
	JrzCECcftfauJw0zoiGT2Dj3RK0h1drIl92898qQnPCEZG9SnaZmlaBrA1W1t2TJFdOAoL
	iiW7DBPQv+s4mqpsGlSVScxJMe3Ump0=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-587-tNdT1Z5YNNCjK_AISSP3Mw-1; Fri,
 04 Sep 2026 13:26:29 -0400
X-MC-Unique: tNdT1Z5YNNCjK_AISSP3Mw-1
X-Mimecast-MFC-AGG-ID: tNdT1Z5YNNCjK_AISSP3Mw_1788542788
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 36B8618D624C;
	Fri,  4 Sep 2026 17:26:28 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet03.pony-001.prod.iad2.dc.redhat.com [10.2.32.114])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id CF61D1800642;
	Fri,  4 Sep 2026 17:26:27 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 344965362000;
	Fri, 04 Sep 2026 13:26:27 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: hch@infradead.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfs: split up block layout and SCSI layout support
Date: Fri,  4 Sep 2026 13:26:27 -0400
Message-ID: <20260904172627.1347637-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Add two new config options PNFS_BLOCK_LAYOUT and PNFS_SCSI_LAYOUT so
that SCSI layouts can be enabled without requiring block layouts.
Since block layouts are considered deprecated, PNFS_BLOCK_LAYOUT
defaults to n.

The original PNFS_BLOCK config is now invisible and gets set whenever
either of PNFS_BLOCK_LAYOUT or PNFS_SCSI_LAYOUT are enabled.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/Kconfig                   | 13 +++++++++++++
 fs/nfs/blocklayout/Makefile      |  3 ++-
 fs/nfs/blocklayout/blocklayout.c | 30 ++++++++++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayout.h | 12 ++++++++++++
 fs/nfs/blocklayout/dev.c         | 18 ++++++++++++++++++
 5 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6bb30543eff0..5047ace9cafd 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -123,8 +123,21 @@ config PNFS_FILE_LAYOUT
 
 config PNFS_BLOCK
 	tristate
+	default NFS_V4 if PNFS_BLOCK_LAYOUT || PNFS_SCSI_LAYOUT
+
+config PNFS_BLOCK_LAYOUT
+	bool "NFS client support for pNFS block layouts"
 	depends on NFS_V4 && BLK_DEV_DM
+	default n
+	help
+	  Enable support for the pNFS block-volume layout type (RFC 5663).
+
+config PNFS_SCSI_LAYOUT
+	bool "NFS client support for pNFS SCSI layouts"
+	depends on NFS_V4
 	default NFS_V4
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
index d54a141a89b3..793d15e72064 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -470,17 +470,21 @@ static struct pnfs_layout_hdr *__bl_alloc_layout_hdr(struct inode *inode,
 	return &bl->bl_layout;
 }
 
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 static struct pnfs_layout_hdr *bl_alloc_layout_hdr(struct inode *inode,
 						   gfp_t gfp_flags)
 {
 	return __bl_alloc_layout_hdr(inode, gfp_flags, false);
 }
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 static struct pnfs_layout_hdr *sl_alloc_layout_hdr(struct inode *inode,
 						   gfp_t gfp_flags)
 {
 	return __bl_alloc_layout_hdr(inode, gfp_flags, true);
 }
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 
 static void bl_free_lseg(struct pnfs_layout_segment *lseg)
 {
@@ -954,6 +958,7 @@ static const struct nfs_pageio_ops bl_pg_write_ops = {
 	.pg_cleanup = pnfs_generic_pg_cleanup,
 };
 
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 static struct pnfs_layoutdriver_type blocklayout_type = {
 	.id				= LAYOUT_BLOCK_VOLUME,
 	.name				= "LAYOUT_BLOCK_VOLUME",
@@ -977,7 +982,9 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.pg_write_ops			= &bl_pg_write_ops,
 	.sync				= pnfs_generic_sync,
 };
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 static struct pnfs_layoutdriver_type scsilayout_type = {
 	.id				= LAYOUT_SCSI,
 	.name				= "LAYOUT_SCSI",
@@ -1001,6 +1008,7 @@ static struct pnfs_layoutdriver_type scsilayout_type = {
 	.pg_write_ops			= &bl_pg_write_ops,
 	.sync				= pnfs_generic_sync,
 };
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 
 
 static int __init nfs4blocklayout_init(void)
@@ -1009,6 +1017,7 @@ static int __init nfs4blocklayout_init(void)
 
 	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
 
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 	ret = bl_init_pipefs();
 	if (ret)
 		goto out;
@@ -1016,18 +1025,31 @@ static int __init nfs4blocklayout_init(void)
 	ret = pnfs_register_layoutdriver(&blocklayout_type);
 	if (ret)
 		goto out_cleanup_pipe;
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 	ret = pnfs_register_layoutdriver(&scsilayout_type);
 	if (ret)
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 		goto out_unregister_block;
+#else
+		return ret;
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 	return 0;
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 out_unregister_block:
 	pnfs_unregister_layoutdriver(&blocklayout_type);
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 out_cleanup_pipe:
 	bl_cleanup_pipefs();
 out:
 	return ret;
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 }
 
 static void __exit nfs4blocklayout_exit(void)
@@ -1035,13 +1057,21 @@ static void __exit nfs4blocklayout_exit(void)
 	dprintk("%s: NFSv4 Block Layout Driver Unregistering...\n",
 	       __func__);
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 	pnfs_unregister_layoutdriver(&scsilayout_type);
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 	pnfs_unregister_layoutdriver(&blocklayout_type);
 	bl_cleanup_pipefs();
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 }
 
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 MODULE_ALIAS("nfs-layouttype4-3");
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 MODULE_ALIAS("nfs-layouttype4-5");
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 
 module_init(nfs4blocklayout_init);
 module_exit(nfs4blocklayout_exit);
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 6da40ca19570..5f13d2df6c81 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -34,7 +34,9 @@
 
 #include <linux/device-mapper.h>
 #include <linux/nfs_fs.h>
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 #include <linux/sunrpc/rpc_pipe_fs.h>
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 
 #include "../nfs4_fs.h"
 #include "../pnfs.h"
@@ -46,7 +48,9 @@
 
 struct pnfs_block_dev;
 
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 #define PNFS_BLOCK_MAX_UUIDS	4
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 #define PNFS_BLOCK_MAX_DEVICES	64
 
 /*
@@ -58,6 +62,7 @@ struct pnfs_block_dev;
 struct pnfs_block_volume {
 	enum pnfs_block_volume_type	type;
 	union {
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 		struct {
 			int		len;
 			int		nr_sigs;
@@ -67,6 +72,7 @@ struct pnfs_block_volume {
 				u8		sig[PNFS_BLOCK_UUID_LEN];
 			} sigs[PNFS_BLOCK_MAX_UUIDS];
 		} simple;
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 		struct {
 			u64		start;
 			u64		len;
@@ -81,6 +87,7 @@ struct pnfs_block_volume {
 			u32		volumes_count;
 			u32		volumes[PNFS_BLOCK_MAX_DEVICES];
 		} stripe;
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 		struct {
 			enum scsi_code_set		code_set;
 			enum scsi_designator_type	designator_type;
@@ -88,6 +95,7 @@ struct pnfs_block_volume {
 			u8				designator[256];
 			u64				pr_key;
 		} scsi;
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 	};
 };
 
@@ -161,6 +169,7 @@ BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
 	return BLK_LO2EXT(lseg->pls_layout);
 }
 
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 struct bl_pipe_msg {
 	struct rpc_pipe_msg msg;
 	wait_queue_head_t *bl_wq;
@@ -176,6 +185,7 @@ struct bl_msg_hdr {
 #define BL_DEVICE_REQUEST_INIT         0x0 /* Start request */
 #define BL_DEVICE_REQUEST_PROC         0x1 /* User level process succeeds */
 #define BL_DEVICE_REQUEST_ERR          0x2 /* User level process fails */
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 
 /* dev.c */
 bool bl_register_dev(struct pnfs_block_dev *d);
@@ -195,10 +205,12 @@ bool ext_tree_lookup(struct pnfs_block_layout *bl, sector_t isect,
 int ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg);
 void ext_tree_mark_committed(struct nfs4_layoutcommit_args *arg, int status);
 
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 /* rpc_pipefs.c */
 dev_t bl_resolve_deviceid(struct nfs_server *server,
 		struct pnfs_block_volume *b, gfp_t gfp_mask);
 int __init bl_init_pipefs(void);
 void bl_cleanup_pipefs(void);
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index c926b7e43827..7ead577b03b0 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -15,6 +15,7 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 static void bl_unregister_scsi(struct pnfs_block_dev *dev)
 {
 	struct block_device *bdev = file_bdev(dev->bdev_file);
@@ -45,6 +46,7 @@ static bool bl_register_scsi(struct pnfs_block_dev *dev)
 	trace_bl_pr_key_reg(bdev, dev->pr_key);
 	return true;
 }
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 
 static void bl_unregister_dev(struct pnfs_block_dev *dev)
 {
@@ -56,9 +58,11 @@ static void bl_unregister_dev(struct pnfs_block_dev *dev)
 		return;
 	}
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 	if (dev->type == PNFS_BLOCK_VOLUME_SCSI &&
 		test_and_clear_bit(PNFS_BDEV_REGISTERED, &dev->flags))
 		bl_unregister_scsi(dev);
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 }
 
 bool bl_register_dev(struct pnfs_block_dev *dev)
@@ -76,8 +80,10 @@ bool bl_register_dev(struct pnfs_block_dev *dev)
 		return true;
 	}
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 	if (dev->type == PNFS_BLOCK_VOLUME_SCSI)
 		return bl_register_scsi(dev);
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 	return true;
 }
 
@@ -122,6 +128,7 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 	b->type = be32_to_cpup(p++);
 
 	switch (b->type) {
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 	case PNFS_BLOCK_VOLUME_SIMPLE:
 		p = xdr_inline_decode(xdr, 4);
 		if (!p)
@@ -155,6 +162,7 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 				(XDR_QUADLEN(b->simple.sigs[i].sig_len) << 2);
 		}
 		break;
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 	case PNFS_BLOCK_VOLUME_SLICE:
 		p = xdr_inline_decode(xdr, 8 + 8 + 4);
 		if (!p)
@@ -198,6 +206,7 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 		for (i = 0; i < b->stripe.volumes_count; i++)
 			b->stripe.volumes[i] = be32_to_cpup(p++);
 		break;
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 	case PNFS_BLOCK_VOLUME_SCSI:
 		p = xdr_inline_decode(xdr, 4 + 4 + 4);
 		if (!p)
@@ -216,6 +225,7 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 			return -EIO;
 		p = xdr_decode_hyper(p, &b->scsi.pr_key);
 		break;
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 	default:
 		dprintk("unknown volume type!\n");
 		return -EIO;
@@ -293,6 +303,7 @@ bl_parse_deviceid(struct nfs_server *server, struct pnfs_block_dev *d,
 		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask);
 
 
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 static int
 bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
 		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
@@ -320,7 +331,9 @@ bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
 		file_bdev(bdev_file)->bd_disk->disk_name);
 	return 0;
 }
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 static bool
 bl_validate_designator(struct pnfs_block_volume *v)
 {
@@ -449,6 +462,7 @@ bl_parse_scsi(struct nfs_server *server, struct pnfs_block_dev *d,
 	d->bdev_file = NULL;
 	return error;
 }
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 
 static int
 bl_parse_slice(struct nfs_server *server, struct pnfs_block_dev *d,
@@ -537,16 +551,20 @@ bl_parse_deviceid(struct nfs_server *server, struct pnfs_block_dev *d,
 	d->type = volumes[idx].type;
 
 	switch (d->type) {
+#ifdef CONFIG_PNFS_BLOCK_LAYOUT
 	case PNFS_BLOCK_VOLUME_SIMPLE:
 		return bl_parse_simple(server, d, volumes, idx, gfp_mask);
+#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
 	case PNFS_BLOCK_VOLUME_SLICE:
 		return bl_parse_slice(server, d, volumes, idx, gfp_mask);
 	case PNFS_BLOCK_VOLUME_CONCAT:
 		return bl_parse_concat(server, d, volumes, idx, gfp_mask);
 	case PNFS_BLOCK_VOLUME_STRIPE:
 		return bl_parse_stripe(server, d, volumes, idx, gfp_mask);
+#ifdef CONFIG_PNFS_SCSI_LAYOUT
 	case PNFS_BLOCK_VOLUME_SCSI:
 		return bl_parse_scsi(server, d, volumes, idx, gfp_mask);
+#endif /* CONFIG_PNFS_SCSI_LAYOUT */
 	default:
 		dprintk("unsupported volume type: %d\n", d->type);
 		return -EIO;
-- 
2.55.0

