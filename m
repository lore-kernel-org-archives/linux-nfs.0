Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36601 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540Ab1FNVDZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:03:25 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/8] pnfsd-exofs: Add pNFS export support
Date: Tue, 14 Jun 2011 17:03:18 -0400
Message-Id: <1308085398-12602-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7CA2F.7030407@panasas.com>
References: <4DF7CA2F.7030407@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add a new file export.c that implements the pnfs_export_operations.
And set a pointer to it in the super_block.

Implemented: LAYOUTGET, simple LAYOUTCOMMIT, simple LAYOUTRETURN

missing: GETDEVICEINFO, Recalls. These will come in next patches

export.c inclusion is dependent on CONFIG_PNFSD defined. If not
then the few used functions from export.c are defined empty
in exofs.h.

In that case of PNFSD EXPORTFS_OSD_LAYOUT must be selected
in fs/exofs/Kconfig

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/Kbuild   |    1 +
 fs/exofs/Kconfig  |    1 +
 fs/exofs/exofs.h  |    7 ++
 fs/exofs/export.c |  198 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/exofs/super.c  |    1 +
 5 files changed, 208 insertions(+), 0 deletions(-)
 create mode 100644 fs/exofs/export.c

diff --git a/fs/exofs/Kbuild b/fs/exofs/Kbuild
index 2d0f757..5458546 100644
--- a/fs/exofs/Kbuild
+++ b/fs/exofs/Kbuild
@@ -13,4 +13,5 @@
 #
 
 exofs-y := ios.o inode.o file.o symlink.o namei.o dir.o super.o
+exofs-$(CONFIG_PNFSD) +=  export.o
 obj-$(CONFIG_EXOFS_FS) += exofs.o
diff --git a/fs/exofs/Kconfig b/fs/exofs/Kconfig
index 86194b2..77c677f 100644
--- a/fs/exofs/Kconfig
+++ b/fs/exofs/Kconfig
@@ -1,6 +1,7 @@
 config EXOFS_FS
 	tristate "exofs: OSD based file system support"
 	depends on SCSI_OSD_ULD
+	select EXPORTFS_OSD_LAYOUT if PNFSD
 	help
 	  EXOFS is a file system that uses an OSD storage device,
 	  as its backing storage.
diff --git a/fs/exofs/exofs.h b/fs/exofs/exofs.h
index e103dbd..3469d77 100644
--- a/fs/exofs/exofs.h
+++ b/fs/exofs/exofs.h
@@ -301,4 +301,11 @@ extern const struct inode_operations exofs_special_inode_operations;
 extern const struct inode_operations exofs_symlink_inode_operations;
 extern const struct inode_operations exofs_fast_symlink_inode_operations;
 
+/* export.c */
+#ifdef CONFIG_PNFSD
+void exofs_init_export(struct super_block *sb);
+#else
+static inline void exofs_init_export(struct super_block *sb) {}
+#endif
+
 #endif
diff --git a/fs/exofs/export.c b/fs/exofs/export.c
new file mode 100644
index 0000000..0a068b7
--- /dev/null
+++ b/fs/exofs/export.c
@@ -0,0 +1,198 @@
+/*
+ * export.c - Implementation of the pnfs_export_operations
+ *
+ * Copyright (C) 2009 Panasas Inc.
+ * All rights reserved.
+ *
+ * Boaz Harrosh <bharrosh@panasas.com>
+ *
+ * This file is part of exofs.
+ *
+ * exofs is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.  Since it is based on ext2, and the only
+ * valid version of GPL for the Linux kernel is version 2, the only valid
+ * version of GPL for exofs is version 2.
+ *
+ * exofs is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with exofs; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+
+#include <linux/nfsd/nfsd4_pnfs.h>
+#include "exofs.h"
+
+#include "linux/nfsd/pnfs_osd_xdr_srv.h"
+
+static int exofs_layout_type(struct super_block *sb)
+{
+	return LAYOUT_OSD2_OBJECTS;
+}
+
+static void set_dev_id(struct nfs4_deviceid *pnfs_devid, u64 sbid, u64 devid)
+{
+	struct nfsd4_pnfs_deviceid *dev_id =
+		(struct nfsd4_pnfs_deviceid *)pnfs_devid;
+
+	dev_id->sbid  = sbid;
+	dev_id->devid = devid;
+}
+
+static enum nfsstat4 exofs_layout_get(
+	struct inode *inode,
+	struct exp_xdr_stream *xdr,
+	const struct nfsd4_pnfs_layoutget_arg *args,
+	struct nfsd4_pnfs_layoutget_res *res)
+{
+	struct exofs_i_info *oi = exofs_i(inode);
+	struct exofs_sb_info *sbi = inode->i_sb->s_fs_info;
+	struct exofs_layout *el = &sbi->layout;
+	struct pnfs_osd_object_cred *creds = NULL;
+	struct pnfs_osd_layout layout;
+	__be32 *start;
+	unsigned i;
+	enum nfsstat4 nfserr;
+
+	res->lg_seg.offset = 0;
+	res->lg_seg.length = NFS4_MAX_UINT64;
+	res->lg_seg.iomode = IOMODE_RW;
+	res->lg_return_on_close = true; /* TODO: unused but will be soon */
+
+	/* skip opaque size, will be filled-in later */
+	start = exp_xdr_reserve_qwords(xdr, 1);
+	if (!start) {
+		nfserr = NFS4ERR_TOOSMALL;
+		goto out;
+	}
+
+	/* Fill in a pnfs_osd_layout struct */
+	layout.olo_map = sbi->data_map;
+	layout.olo_comps_index = 0;
+	layout.olo_num_comps = el->s_numdevs;
+	layout.olo_comps = creds;
+
+	nfserr = pnfs_osd_xdr_encode_layout_hdr(xdr, &layout);
+	if (unlikely(nfserr))
+		goto out;
+
+	/* Encode layout components */
+	for (i = 0; i < el->s_numdevs; i++) {
+		struct pnfs_osd_object_cred cred;
+		osd_id id = exofs_oi_objno(oi);
+		unsigned dev = exofs_layout_od_id(el, id, i);
+
+		set_dev_id(&cred.oc_object_id.oid_device_id, args->lg_sbid,
+			   dev);
+		cred.oc_object_id.oid_partition_id = el->s_pid;
+		cred.oc_object_id.oid_object_id = id;
+		cred.oc_osd_version = osd_dev_is_ver1(el->s_ods[dev]) ?
+						PNFS_OSD_VERSION_1 :
+						PNFS_OSD_VERSION_2;
+		cred.oc_cap_key_sec = PNFS_OSD_CAP_KEY_SEC_NONE;
+
+		cred.oc_cap_key.cred_len	= 0;
+		cred.oc_cap_key.cred		= NULL;
+
+		cred.oc_cap.cred_len	= OSD_CAP_LEN;
+		cred.oc_cap.cred	= oi->i_cred;
+		nfserr = pnfs_osd_xdr_encode_layout_cred(xdr, &cred);
+		if (unlikely(nfserr))
+			goto out;
+	}
+
+	exp_xdr_encode_opaque_len(start, xdr->p);
+	nfserr = NFS4_OK;
+	/* TODO: Takes the inode ref here, add to inode's layouts list */
+
+out:
+	kfree(creds);
+	EXOFS_DBGMSG("(0x%lx) nfserr=%u xdr_bytes=%zu\n",
+		     inode->i_ino, nfserr, exp_xdr_qbytes(xdr->p - start));
+	return nfserr;
+}
+
+/* NOTE: inode mutex must NOT be held */
+static int exofs_layout_commit(
+	struct inode *inode,
+	const struct nfsd4_pnfs_layoutcommit_arg *args,
+	struct nfsd4_pnfs_layoutcommit_res *res)
+{
+	struct timespec mtime;
+	loff_t i_size;
+
+	/* NOTE: I would love to call inode_setattr here
+	 *	 but i cannot since this will cause an eventual vmtruncate,
+	 *	 which will cause a layout_recall. So open code the i_size
+	 *	 and mtime/atime changes under i_mutex.
+	 */
+	mutex_lock_nested(&inode->i_mutex, I_MUTEX_NORMAL);
+
+	if (args->lc_mtime.seconds) {
+		mtime.tv_sec = args->lc_mtime.seconds;
+		mtime.tv_nsec = args->lc_mtime.nseconds;
+
+		/* layout commit may only make time bigger, since there might
+		 * be reordering of the notifications and it might arrive after
+		 * A local change.
+		 * TODO: if mtime > ctime then we know set_attr did an mtime
+		 * in the future. and we can let this update through
+		 */
+		if (0 <= timespec_compare(&mtime, &inode->i_mtime))
+			mtime = inode->i_mtime;
+	} else {
+		mtime = current_fs_time(inode->i_sb);
+	}
+
+	/* TODO: Will below work? since mark_inode_dirty has it's own
+	 *       Time handling
+	 */
+	inode->i_atime = inode->i_mtime = mtime;
+
+	i_size = i_size_read(inode);
+	if (args->lc_newoffset) {
+		loff_t new_size = args->lc_last_wr + 1;
+
+		if (i_size < new_size) {
+			i_size_write(inode, i_size = new_size);
+			res->lc_size_chg = 1;
+			res->lc_newsize = new_size;
+		}
+	}
+	/* TODO: else { i_size = osd_get_object_length() } */
+
+/* TODO: exofs does not currently use the osd_xdr part of the layout_commit */
+
+	mark_inode_dirty_sync(inode);
+
+	mutex_unlock(&inode->i_mutex);
+	EXOFS_DBGMSG("(0x%lx) i_size=0x%llx lcp->off=0x%llx\n",
+		     inode->i_ino, i_size, args->lc_last_wr);
+	return 0;
+}
+
+static int exofs_layout_return(
+	struct inode *inode,
+	const struct nfsd4_pnfs_layoutreturn_arg *args)
+{
+	/* TODO: Decode the pnfs_osd_ioerr if lrf_body_len > 0 */
+
+	/* TODO: When layout_get takes the inode ref put_ref here */
+	return 0;
+}
+
+struct pnfs_export_operations exofs_pnfs_ops = {
+	.layout_type	= exofs_layout_type,
+	.layout_get	= exofs_layout_get,
+	.layout_commit	= exofs_layout_commit,
+	.layout_return	= exofs_layout_return,
+};
+
+void exofs_init_export(struct super_block *sb)
+{
+	sb->s_pnfs_op = &exofs_pnfs_ops;
+}
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index 06065bd..96ecb15 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -770,6 +770,7 @@ static int exofs_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_fs_info = sbi;
 	sb->s_op = &exofs_sops;
 	sb->s_export_op = &exofs_export_ops;
+	exofs_init_export(sb);
 	root = exofs_iget(sb, EXOFS_ROOT_ID - EXOFS_OBJ_OFF);
 	if (IS_ERR(root)) {
 		EXOFS_ERR("ERROR: exofs_iget failed\n");
-- 
1.7.3.4

