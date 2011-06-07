Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53228 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1FGR16 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:27:58 -0400
Date: Tue, 7 Jun 2011 13:27:56 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 18/88] pnfsblock: construct and load md table
Message-ID: <b79d3be4930b16115d20c69e22a19ff0b6e225b5.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Uses preparsed information gathered from GETDEVICEINFO to
create a dm device table that represents the given volume
topology.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.h   |    3 +-
 fs/nfs/blocklayout/blocklayoutdm.c |  191 +++++++++++++++++++++++++++++++++++-
 2 files changed, 191 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index b705906..d695f8e 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -40,7 +40,8 @@
 extern struct class shost_class; /* exported from drivers/scsi/hosts.c */
 extern int dm_dev_create(struct dm_ioctl *param); /* from dm-ioctl.c */
 extern int dm_dev_remove(struct dm_ioctl *param); /* from dm-ioctl.c */
-
+extern int dm_do_resume(struct dm_ioctl *param);
+extern int dm_table_load(struct dm_ioctl *param, size_t param_size);
 
 struct block_mount_id {
 	struct super_block		*bm_sb;     /* back pointer */
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index 0e04494..4bff748 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -36,6 +36,31 @@
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
+/* Defines used for calculating memory usage in nfs4_blk_flatten() */
+#define ARGSIZE   24    /* Max bytes needed for linear target arg string */
+#define SPECSIZE (sizeof8(struct dm_target_spec) + ARGSIZE)
+#define SPECS_PER_PAGE (PAGE_SIZE / SPECSIZE)
+#define SPEC_HEADER_ADJUST (SPECS_PER_PAGE - \
+			    (PAGE_SIZE - sizeof8(struct dm_ioctl)) / SPECSIZE)
+#define roundup8(x) (((x)+7) & ~7)
+#define sizeof8(x) roundup8(sizeof(x))
+
+/* Given x>=1, return smallest n such that 2**n >= x */
+static unsigned long find_order(int x)
+{
+	unsigned long rv = 0;
+	for (x--; x; x >>= 1)
+		rv++;
+	return rv;
+}
+
+/* Debugging aid */
+static void print_extent(u64 meta_offset, dev_t disk,
+			 u64 disk_offset, u64 length)
+{
+	dprintk("%lli:, %d:%d %lli, %lli\n", meta_offset, MAJOR(disk),
+			MINOR(disk), disk_offset, length);
+}
 static int dev_create(const char *name, dev_t *dev)
 {
 	struct dm_ioctl ctrl;
@@ -60,6 +85,14 @@ static int dev_remove(const char *name)
 	return dm_dev_remove(&ctrl);
 }
 
+static int dev_resume(const char *name)
+{
+	struct dm_ioctl ctrl;
+	memset(&ctrl, 0, sizeof(ctrl));
+	strncpy(ctrl.name, name, DM_NAME_LEN-1);
+	return dm_do_resume(&ctrl);
+}
+
 /*
  * Release meta device
  */
@@ -141,10 +174,164 @@ struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
 	return NULL;
 }
 
-/* Stub */
+/*
+ * Given a vol_offset into root, returns the disk and disk_offset it
+ * corresponds to, as well as the length of the contiguous segment thereafter.
+ * All offsets/lengths are in 512-byte sectors.
+ */
+static int nfs4_blk_resolve(int root, struct pnfs_blk_volume *vols,
+			    u64 vol_offset, dev_t *disk, u64 *disk_offset,
+			    u64 *length)
+{
+	struct pnfs_blk_volume *node;
+	u64 node_offset;
+
+	/* Walk down device tree until we hit a leaf node (VOLUME_SIMPLE) */
+	node = &vols[root];
+	node_offset = vol_offset;
+	*length = node->bv_size;
+	while (1) {
+		dprintk("offset=%lli, length=%lli\n",
+			node_offset, *length);
+		if (node_offset > node->bv_size)
+			return -EIO;
+		switch (node->bv_type) {
+		case PNFS_BLOCK_VOLUME_SIMPLE:
+			*disk = node->bv_dev;
+			dprintk("%s VOLUME_SIMPLE: node->bv_dev %d:%d\n",
+			       __func__,
+			       MAJOR(node->bv_dev),
+			       MINOR(node->bv_dev));
+			*disk_offset = node_offset;
+			*length = min(*length, node->bv_size - node_offset);
+			return 0;
+		case PNFS_BLOCK_VOLUME_SLICE:
+			dprintk("%s VOLUME_SLICE:\n", __func__);
+			*length = min(*length, node->bv_size - node_offset);
+			node_offset += node->bv_offset;
+			node = node->bv_vols[0];
+			break;
+		case PNFS_BLOCK_VOLUME_CONCAT: {
+			u64 next = 0, sum = 0;
+			int i;
+			dprintk("%s VOLUME_CONCAT:\n", __func__);
+			for (i = 0; i < node->bv_vol_n; i++) {
+				next = sum + node->bv_vols[i]->bv_size;
+				if (node_offset < next)
+					break;
+				sum = next;
+			}
+			*length = min(*length, next - node_offset);
+			node_offset -= sum;
+			node = node->bv_vols[i];
+			}
+			break;
+		case PNFS_BLOCK_VOLUME_STRIPE: {
+			u64 global_s_no;
+			u64 stripe_pos;
+			u64 local_s_no;
+			u64 disk_number;
+
+			dprintk("%s VOLUME_STRIPE:\n", __func__);
+			global_s_no = node_offset;
+			/* BUG - note this assumes stripe_unit <= 2**32 */
+			stripe_pos = (u64) do_div(global_s_no,
+						  (u32)node->bv_stripe_unit);
+			local_s_no = global_s_no;
+			disk_number = (u64) do_div(local_s_no,
+						   (u32) node->bv_vol_n);
+			*length = min(*length,
+				      node->bv_stripe_unit - stripe_pos);
+			node_offset = local_s_no * node->bv_stripe_unit +
+					stripe_pos;
+			node = node->bv_vols[disk_number];
+			}
+			break;
+		default:
+			return -EIO;
+		}
+	}
+}
+
+/*
+ * Create an LVM dm device table that represents the volume topology returned
+ * by GETDEVICELIST or GETDEVICEINFO.
+ *
+ * vols:  topology with VOLUME_SIMPLEs mapped to visable scsi disks.
+ * size:  number of volumes in vols.
+ */
 int nfs4_blk_flatten(struct pnfs_blk_volume *vols, int size,
 		     struct pnfs_block_dev *bdev)
 {
-	return 0;
+	u64 meta_offset = 0;
+	u64 meta_size = vols[size-1].bv_size;
+	dev_t disk;
+	u64 disk_offset, len;
+	int status = 0, count = 0, pages_needed;
+	struct dm_ioctl *ctl;
+	struct dm_target_spec *spec;
+	char *args = NULL;
+	unsigned long p;
+
+	dprintk("%s enter. mdevname %s number of volumes %d\n", __func__,
+			bdev->bm_mdevname, size);
+
+	/* We need to reserve memory to store segments, so need to count
+	 * segments.  This means we resolve twice, basically throwing away
+	 * all info from first run apart from the count.  Seems like
+	 * there should be a better way.
+	 */
+	for (meta_offset = 0; meta_offset < meta_size; meta_offset += len) {
+		status = nfs4_blk_resolve(size-1, vols, meta_offset, &disk,
+						&disk_offset, &len);
+		/* TODO Check status */
+		count += 1;
+	}
+
+	dprintk("%s: Have %i segments\n", __func__, count);
+	pages_needed = ((count + SPEC_HEADER_ADJUST) / SPECS_PER_PAGE) + 1;
+	dprintk("%s: Need %i pages\n", __func__, pages_needed);
+	p = __get_free_pages(GFP_KERNEL, find_order(pages_needed));
+	if (!p)
+		return -ENOMEM;
+	/* A dm_ioctl is placed at the beginning, followed by a series of
+	 * (dm_target_spec, argument string) pairs.
+	 */
+	ctl = (struct dm_ioctl *) p;
+	spec = (struct dm_target_spec *) (p + sizeof8(*ctl));
+	memset(ctl, 0, sizeof(*ctl));
+	ctl->data_start = (char *) spec - (char *) ctl;
+	ctl->target_count = count;
+	strncpy(ctl->name, bdev->bm_mdevname, DM_NAME_LEN);
+
+	dprintk("%s ctl->name %s\n", __func__, ctl->name);
+	for (meta_offset = 0; meta_offset < meta_size; meta_offset += len) {
+		status = nfs4_blk_resolve(size-1, vols, meta_offset, &disk,
+							&disk_offset, &len);
+		if (!len)
+			break;
+		/* TODO Check status */
+		print_extent(meta_offset, disk, disk_offset, len);
+		spec->sector_start = meta_offset;
+		spec->length = len;
+		spec->status = 0;
+		strcpy(spec->target_type, "linear");
+		args = (char *) (spec + 1);
+		sprintf(args, "%i:%i %lli",
+			MAJOR(disk), MINOR(disk), disk_offset);
+		dprintk("%s args %s\n", __func__, args);
+		spec->next = roundup8(sizeof(*spec) + strlen(args) + 1);
+		spec = (struct dm_target_spec *) (((char *) spec) + spec->next);
+	}
+	ctl->data_size = (char *) spec - (char *) ctl;
+
+	status = dm_table_load(ctl, ctl->data_size);
+	dprintk("%s dm_table_load returns %d\n", __func__, status);
+
+	dev_resume(bdev->bm_mdevname);
+
+	free_pages(p, find_order(pages_needed));
+	dprintk("%s returns %d\n", __func__, status);
+	return status;
 }
 
-- 
1.7.4.1

