Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59845 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbcB2NYN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Feb 2016 08:24:13 -0500
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] nfsd: add SCSI layout support
Date: Mon, 29 Feb 2016 14:24:07 +0100
Message-Id: <1456752247-6549-4-git-send-email-hch@lst.de>
In-Reply-To: <1456752247-6549-1-git-send-email-hch@lst.de>
References: <1456752247-6549-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a simple extension to the block layout driver to use SCSI
persistent reservations for access control and fencing, as well as
SCSI VPD pages for device identification.

For this we need to pass the nfs4_client to the proc_getdeviceinfo method
to generate the reservation key, and add a new fence_client method
to allow for fence actions in the layout driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/blocklayout.c    | 234 +++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/blocklayoutxdr.c |  65 ++++++++++++-
 fs/nfsd/blocklayoutxdr.h |  14 +++
 fs/nfsd/nfs4layouts.c    |  28 ++++--
 fs/nfsd/nfs4proc.c       |   6 +-
 fs/nfsd/pnfs.h           |   4 +
 6 files changed, 331 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index c29d942..48308ee 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -1,11 +1,14 @@
 /*
- * Copyright (c) 2014 Christoph Hellwig.
+ * Copyright (c) 2014-2016 Christoph Hellwig.
  */
 #include <linux/exportfs.h>
 #include <linux/genhd.h>
 #include <linux/slab.h>
+#include <linux/pr.h>
 
 #include <linux/nfsd/debug.h>
+#include <scsi/scsi_proto.h>
+#include <scsi/scsi_common.h>
 
 #include "blocklayoutxdr.h"
 #include "pnfs.h"
@@ -37,6 +40,7 @@ nfsd4_block_get_device_info_simple(struct super_block *sb,
 
 static __be32
 nfsd4_block_proc_getdeviceinfo(struct super_block *sb,
+		struct nfs4_client *clp,
 		struct nfsd4_getdeviceinfo *gdp)
 {
 	if (sb->s_bdev != sb->s_bdev->bd_contains)
@@ -44,6 +48,163 @@ nfsd4_block_proc_getdeviceinfo(struct super_block *sb,
 	return nfserrno(nfsd4_block_get_device_info_simple(sb, gdp));
 }
 
+
+static int nfsd4_scsi_identify_device(struct block_device *bdev,
+		struct pnfs_block_volume *b)
+{
+	struct request_queue *q = bdev->bd_disk->queue;
+	struct request *rq;
+	size_t bufflen = 252, len, id_len;
+	u8 *buf, *d, type, assoc;
+	int error;
+
+	buf = kzalloc(bufflen, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	rq = blk_get_request(q, READ, GFP_KERNEL);
+	if (IS_ERR(rq)) {
+		error = -ENOMEM;
+		goto out_free_buf;
+	}
+	blk_rq_set_block_pc(rq);
+
+	error = blk_rq_map_kern(q, rq, buf, bufflen, GFP_KERNEL);
+	if (error)
+		goto out_put_request;
+
+	rq->cmd[0] = INQUIRY;
+	rq->cmd[1] = 1;
+	rq->cmd[2] = 0x83;
+	rq->cmd[3] = bufflen >> 8;
+	rq->cmd[4] = bufflen & 0xff;
+	rq->cmd_len = COMMAND_SIZE(INQUIRY);
+
+	error = blk_execute_rq(rq->q, NULL, rq, 1);
+	if (error) {
+		pr_err("pNFS: INQUIRY 0x83 failed with: %x\n",
+			rq->errors);
+		
+	}
+
+	len = (buf[2] << 8) + buf[3] + 4;
+	if (len > bufflen) {
+		pr_err("pNFS: INQUIRY 0x83 response invalid (len = %zd)\n",
+			len);
+		goto out_put_request;
+	}
+
+	d = buf + 4;
+	for (d = buf + 4; d < buf + len; d += id_len + 4) {
+		id_len = d[3];
+		type = d[1] & 0xf;
+		assoc = (d[1] >> 4) & 0x3;
+
+		/*
+		 * We only care about a EUI-64 and NAA designator types
+		 * with LU association.
+		 */
+		if (assoc != 0x00)
+			continue;
+		if (type != 0x02 && type != 0x03)
+			continue;
+		if (id_len != 8 && id_len != 12 && id_len != 16)
+			continue;
+
+		b->scsi.code_set = PS_CODE_SET_BINARY;
+		b->scsi.designator_type = type == 0x02 ?
+			PS_DESIGNATOR_EUI64 : PS_DESIGNATOR_NAA;
+		b->scsi.designator_len = id_len;
+		memcpy(b->scsi.designator, d + 4, id_len);
+
+		/*
+		 * If we found a 8 or 12 byte descriptor continue on to
+		 * see if a 16 byte one is available.  If we find a
+		 * 16 byte descriptor we're done.
+		 */
+		if (id_len == 16)
+			break;
+	}
+
+out_put_request:
+	blk_put_request(rq);
+out_free_buf:
+	kfree(buf);
+	return error;
+}
+
+#define NFSD_MDS_PR_KEY		0x0100000000000000
+
+/*
+ * We use the client ID as a uniqueue key for the reservations.
+ * This allows us to easily fence a client when recalls fail.
+ */
+static u64 nfsd4_scsi_pr_key(struct nfs4_client *clp)
+{
+	return ((u64)clp->cl_clientid.cl_boot << 32) | clp->cl_clientid.cl_id;
+}
+
+static int
+nfsd4_block_get_device_info_scsi(struct super_block *sb,
+		struct nfs4_client *clp,
+		struct nfsd4_getdeviceinfo *gdp)
+{
+	struct pnfs_block_deviceaddr *dev;
+	struct pnfs_block_volume *b;
+	const struct pr_ops *ops;
+	int error;
+
+	dev = kzalloc(sizeof(struct pnfs_block_deviceaddr) +
+		      sizeof(struct pnfs_block_volume), GFP_KERNEL);
+	if (!dev)
+		return -ENOMEM;
+	gdp->gd_device = dev;
+
+	dev->nr_volumes = 1;
+	b = &dev->volumes[0];
+
+	b->type = PNFS_BLOCK_VOLUME_SCSI;
+	b->scsi.pr_key = nfsd4_scsi_pr_key(clp);
+
+	error = nfsd4_scsi_identify_device(sb->s_bdev, b);
+	if (error)
+		return error;
+
+	ops = sb->s_bdev->bd_disk->fops->pr_ops;
+	if (!ops) {
+		pr_err("pNFS: device %s does not support PRs.\n",
+			sb->s_id);
+		return -EINVAL;
+	}
+
+	error = ops->pr_register(sb->s_bdev, 0, NFSD_MDS_PR_KEY, true);
+	if (error) {
+		pr_err("pNFS: failed to register key for device %s.\n",
+			sb->s_id);
+		return -EINVAL;
+	}
+
+	error = ops->pr_reserve(sb->s_bdev, NFSD_MDS_PR_KEY,
+			PR_EXCLUSIVE_ACCESS_REG_ONLY, 0);
+	if (error) {
+		pr_err("pNFS: failed to reserve device %s.\n",
+			sb->s_id);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static __be32
+nfsd4_scsi_proc_getdeviceinfo(struct super_block *sb,
+		struct nfs4_client *clp,
+		struct nfsd4_getdeviceinfo *gdp)
+{
+	if (sb->s_bdev != sb->s_bdev->bd_contains)
+		return nfserr_inval;
+	return nfserrno(nfsd4_block_get_device_info_scsi(sb, clp, gdp));
+}
+
 static __be32
 nfsd4_block_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
 		struct nfsd4_layoutget *args)
@@ -141,20 +302,13 @@ out_layoutunavailable:
 }
 
 static __be32
-nfsd4_block_proc_layoutcommit(struct inode *inode,
-		struct nfsd4_layoutcommit *lcp)
+nfsd4_block_commit_blocks(struct inode *inode, struct nfsd4_layoutcommit *lcp,
+		struct iomap *iomaps, int nr_iomaps)
 {
 	loff_t new_size = lcp->lc_last_wr + 1;
 	struct iattr iattr = { .ia_valid = 0 };
-	struct iomap *iomaps;
-	int nr_iomaps;
 	int error;
 
-	nr_iomaps = nfsd4_block_decode_layoutupdate(lcp->lc_up_layout,
-			lcp->lc_up_len, &iomaps, 1 << inode->i_blkbits);
-	if (nr_iomaps < 0)
-		return nfserrno(nr_iomaps);
-
 	if (lcp->lc_mtime.tv_nsec == UTIME_NOW ||
 	    timespec_compare(&lcp->lc_mtime, &inode->i_mtime) < 0)
 		lcp->lc_mtime = current_fs_time(inode->i_sb);
@@ -172,6 +326,46 @@ nfsd4_block_proc_layoutcommit(struct inode *inode,
 	return nfserrno(error);
 }
 
+static __be32
+nfsd4_block_proc_layoutcommit(struct inode *inode,
+		struct nfsd4_layoutcommit *lcp)
+{
+	struct iomap *iomaps;
+	int nr_iomaps;
+
+	nr_iomaps = nfsd4_block_decode_layoutupdate(lcp->lc_up_layout,
+			lcp->lc_up_len, &iomaps, 1 << inode->i_blkbits);
+	if (nr_iomaps < 0)
+		return nfserrno(nr_iomaps);
+
+	return nfsd4_block_commit_blocks(inode, lcp, iomaps, nr_iomaps);
+}
+
+static __be32
+nfsd4_scsi_proc_layoutcommit(struct inode *inode,
+		struct nfsd4_layoutcommit *lcp)
+{
+	struct iomap *iomaps;
+	int nr_iomaps;
+
+	nr_iomaps = nfsd4_scsi_decode_layoutupdate(lcp->lc_up_layout,
+			lcp->lc_up_len, &iomaps, 1 << inode->i_blkbits);
+	if (nr_iomaps < 0)
+		return nfserrno(nr_iomaps);
+
+	return nfsd4_block_commit_blocks(inode, lcp, iomaps, nr_iomaps);
+}
+
+static void
+nfsd4_scsi_fence_client(struct nfs4_layout_stateid *ls)
+{
+	struct nfs4_client *clp = ls->ls_stid.sc_client;
+	struct block_device *bdev = ls->ls_file->f_path.mnt->mnt_sb->s_bdev;
+
+	bdev->bd_disk->fops->pr_ops->pr_preempt(bdev, NFSD_MDS_PR_KEY,
+			nfsd4_scsi_pr_key(clp), 0, true);
+}
+
 const struct nfsd4_layout_ops bl_layout_ops = {
 	/*
 	 * Pretend that we send notification to the client.  This is a blatant
@@ -190,3 +384,23 @@ const struct nfsd4_layout_ops bl_layout_ops = {
 	.encode_layoutget	= nfsd4_block_encode_layoutget,
 	.proc_layoutcommit	= nfsd4_block_proc_layoutcommit,
 };
+
+const struct nfsd4_layout_ops scsi_layout_ops = {
+	/*
+	 * Pretend that we send notification to the client.  This is a blatant
+	 * lie to force recent Linux clients to cache our device IDs.
+	 * We rarely ever change the device ID, so the harm of leaking deviceids
+	 * for a while isn't too bad.  Unfortunately RFC5661 is a complete mess
+	 * in this regard, but I filed errata 4119 for this a while ago, and
+	 * hopefully the Linux client will eventually start caching deviceids
+	 * without this again.
+	 */
+	.notify_types		=
+			NOTIFY_DEVICEID4_DELETE | NOTIFY_DEVICEID4_CHANGE,
+	.proc_getdeviceinfo	= nfsd4_scsi_proc_getdeviceinfo,
+	.encode_getdeviceinfo	= nfsd4_block_encode_getdeviceinfo,
+	.proc_layoutget		= nfsd4_block_proc_layoutget,
+	.encode_layoutget	= nfsd4_block_encode_layoutget,
+	.proc_layoutcommit	= nfsd4_scsi_proc_layoutcommit,
+	.fence_client		= nfsd4_scsi_fence_client,
+};
diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
index 6d834dc..ca18836 100644
--- a/fs/nfsd/blocklayoutxdr.c
+++ b/fs/nfsd/blocklayoutxdr.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Christoph Hellwig.
+ * Copyright (c) 2014-2016 Christoph Hellwig.
  */
 #include <linux/sunrpc/svc.h>
 #include <linux/exportfs.h>
@@ -53,6 +53,18 @@ nfsd4_block_encode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 		p = xdr_encode_hyper(p, b->simple.offset);
 		p = xdr_encode_opaque(p, b->simple.sig, b->simple.sig_len);
 		break;
+	case PNFS_BLOCK_VOLUME_SCSI:
+		len = 4 + 4 + 4 + 4 + b->scsi.designator_len + 8;
+		p = xdr_reserve_space(xdr, len);
+		if (!p)
+			return -ETOOSMALL;
+
+		*p++ = cpu_to_be32(b->type);
+		*p++ = cpu_to_be32(b->scsi.code_set);
+		*p++ = cpu_to_be32(b->scsi.designator_type);
+		p = xdr_encode_opaque(p, b->scsi.designator, b->scsi.designator_len);
+		p = xdr_encode_hyper(p, b->scsi.pr_key);
+		break;
 	default:
 		return -ENOTSUPP;
 	}
@@ -155,3 +167,54 @@ fail:
 	kfree(iomaps);
 	return -EINVAL;
 }
+
+int
+nfsd4_scsi_decode_layoutupdate(__be32 *p, u32 len, struct iomap **iomapp,
+		u32 block_size)
+{
+	struct iomap *iomaps;
+	u32 nr_iomaps, expected, i;
+
+	if (len < sizeof(u32)) {
+		dprintk("%s: extent array too small: %u\n", __func__, len);
+		return -EINVAL;
+	}
+
+	nr_iomaps = be32_to_cpup(p++);
+	expected = sizeof(__be32) + nr_iomaps * PNFS_SCSI_RANGE_SIZE;
+	if (len != expected) {
+		dprintk("%s: extent array size mismatch: %u/%u\n",
+			__func__, len, expected);
+		return -EINVAL;
+	}
+
+	iomaps = kcalloc(nr_iomaps, sizeof(*iomaps), GFP_KERNEL);
+	if (!iomaps) {
+		dprintk("%s: failed to allocate extent array\n", __func__);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < nr_iomaps; i++) {
+		u64 val;
+
+		p = xdr_decode_hyper(p, &val);
+		if (val & (block_size - 1)) {
+			dprintk("%s: unaligned offset 0x%llx\n", __func__, val);
+			goto fail;
+		}
+		iomaps[i].offset = val;
+
+		p = xdr_decode_hyper(p, &val);
+		if (val & (block_size - 1)) {
+			dprintk("%s: unaligned length 0x%llx\n", __func__, val);
+			goto fail;
+		}
+		iomaps[i].length = val;
+	}
+
+	*iomapp = iomaps;
+	return nr_iomaps;
+fail:
+	kfree(iomaps);
+	return -EINVAL;
+}
diff --git a/fs/nfsd/blocklayoutxdr.h b/fs/nfsd/blocklayoutxdr.h
index 6de925f..397bc75 100644
--- a/fs/nfsd/blocklayoutxdr.h
+++ b/fs/nfsd/blocklayoutxdr.h
@@ -15,6 +15,11 @@ struct pnfs_block_extent {
 	enum pnfs_block_extent_state	es;
 };
 
+struct pnfs_block_range {
+	u64				foff;
+	u64				len;
+};
+
 /*
  * Random upper cap for the uuid length to avoid unbounded allocation.
  * Not actually limited by the protocol.
@@ -29,6 +34,13 @@ struct pnfs_block_volume {
 			u32		sig_len;
 			u8		sig[PNFS_BLOCK_UUID_LEN];
 		} simple;
+		struct {
+			enum scsi_code_set		code_set;
+			enum scsi_designator_type	designator_type;
+			int				designator_len;
+			u8				designator[256];
+			u64				pr_key;
+		} scsi;
 	};
 };
 
@@ -43,5 +55,7 @@ __be32 nfsd4_block_encode_layoutget(struct xdr_stream *xdr,
 		struct nfsd4_layoutget *lgp);
 int nfsd4_block_decode_layoutupdate(__be32 *p, u32 len, struct iomap **iomapp,
 		u32 block_size);
+int nfsd4_scsi_decode_layoutupdate(__be32 *p, u32 len, struct iomap **iomapp,
+		u32 block_size);
 
 #endif /* _NFSD_BLOCKLAYOUTXDR_H */
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index ce2d010..786e59e 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -1,6 +1,7 @@
 /*
  * Copyright (c) 2014 Christoph Hellwig.
  */
+#include <linux/blkdev.h>
 #include <linux/kmod.h>
 #include <linux/file.h>
 #include <linux/jhash.h>
@@ -27,6 +28,7 @@ static const struct lock_manager_operations nfsd4_layouts_lm_ops;
 
 const struct nfsd4_layout_ops *nfsd4_layout_ops[LAYOUT_TYPE_MAX] =  {
 	[LAYOUT_BLOCK_VOLUME]	= &bl_layout_ops,
+	[LAYOUT_SCSI]		= &scsi_layout_ops,
 };
 
 /* pNFS device ID to export fsid mapping */
@@ -121,10 +123,17 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 	if (!(exp->ex_flags & NFSEXP_PNFS))
 		return;
 
-	if (sb->s_export_op->get_uuid &&
-	    sb->s_export_op->map_blocks &&
-	    sb->s_export_op->commit_blocks)
-		exp->ex_layout_type = LAYOUT_BLOCK_VOLUME;
+	/*
+	 * Check if the file systems supports exporting a block-like layout.
+	 * If the block device supports reservations prefer the SCSI layout,
+	 * else advertise the block layout.
+	 */
+	if (sb->s_export_op->map_blocks && sb->s_export_op->commit_blocks) {
+		if (sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops)
+			exp->ex_layout_type = LAYOUT_SCSI;
+		else if (sb->s_export_op->get_uuid)
+			exp->ex_layout_type = LAYOUT_BLOCK_VOLUME;
+	}
 }
 
 static void
@@ -590,8 +599,6 @@ nfsd4_cb_layout_fail(struct nfs4_layout_stateid *ls)
 
 	rpc_ntop((struct sockaddr *)&clp->cl_addr, addr_str, sizeof(addr_str));
 
-	trace_layout_recall_fail(&ls->ls_stid.sc_stateid);
-
 	printk(KERN_WARNING
 		"nfsd: client %s failed to respond to layout recall. "
 		"  Fencing..\n", addr_str);
@@ -626,6 +633,7 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 		container_of(cb, struct nfs4_layout_stateid, ls_recall);
 	struct nfsd_net *nn;
 	ktime_t now, cutoff;
+	const struct nfsd4_layout_ops *ops;
 	LIST_HEAD(reaplist);
 
 
@@ -661,7 +669,13 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 		/*
 		 * Unknown error or non-responding client, we'll need to fence.
 		 */
-		nfsd4_cb_layout_fail(ls);
+		trace_layout_recall_fail(&ls->ls_stid.sc_stateid);
+
+		ops = nfsd4_layout_ops[ls->ls_layout_type];
+		if (ops->fence_client)
+			ops->fence_client(ls);
+		else
+			nfsd4_cb_layout_fail(ls);
 		return -1;
 	}
 }
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4cba786..629443e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1269,8 +1269,10 @@ nfsd4_getdeviceinfo(struct svc_rqst *rqstp,
 		goto out;
 
 	nfserr = nfs_ok;
-	if (gdp->gd_maxcount != 0)
-		nfserr = ops->proc_getdeviceinfo(exp->ex_path.mnt->mnt_sb, gdp);
+	if (gdp->gd_maxcount != 0) {
+		nfserr = ops->proc_getdeviceinfo(exp->ex_path.mnt->mnt_sb,
+					cstate->session->se_client, gdp);
+	}
 
 	gdp->gd_notify_types &= ops->notify_types;
 out:
diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index d4c4453..3b54e43 100644
--- a/fs/nfsd/pnfs.h
+++ b/fs/nfsd/pnfs.h
@@ -21,6 +21,7 @@ struct nfsd4_layout_ops {
 	u32		notify_types;
 
 	__be32 (*proc_getdeviceinfo)(struct super_block *sb,
+			struct nfs4_client *clp,
 			struct nfsd4_getdeviceinfo *gdevp);
 	__be32 (*encode_getdeviceinfo)(struct xdr_stream *xdr,
 			struct nfsd4_getdeviceinfo *gdevp);
@@ -32,10 +33,13 @@ struct nfsd4_layout_ops {
 
 	__be32 (*proc_layoutcommit)(struct inode *inode,
 			struct nfsd4_layoutcommit *lcp);
+
+	void (*fence_client)(struct nfs4_layout_stateid *ls);
 };
 
 extern const struct nfsd4_layout_ops *nfsd4_layout_ops[];
 extern const struct nfsd4_layout_ops bl_layout_ops;
+extern const struct nfsd4_layout_ops scsi_layout_ops;
 
 __be32 nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, stateid_t *stateid,
-- 
2.1.4

