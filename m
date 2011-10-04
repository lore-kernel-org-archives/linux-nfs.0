Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52030 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab1JDK35 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:29:57 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 04/19] ore/exofs: Change the type of the devices array (API change)
Date: Tue, 4 Oct 2011 12:29:47 +0200
Message-ID: <1317724187-27417-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In the pNFS obj-LD the device table at the layout level needs
to point to a device_cache node, where it is possible and likely
that many layouts will point to the same device-nodes.

In Exofs we have a more orderly structure where we have a single
array of devices that repeats twice for a round-robin view of the
device table

This patch moves to a model that can be used by the pNFS obj-LD
where struct ore_components holds an array of ore_dev-pointers.
(ore_dev is newly defined and contains a struct osd_dev *od
 member)

Each pointer in the array of pointers will point to a bigger
user-defined dev_struct. That can be accessed by use of the
container_of macro.

In Exofs an __alloc_dev_table() function allocates the
ore_dev-pointers array as well as an exofs_dev array, in one
allocation and does the addresses dance to set everything pointing
correctly. It still keeps the double allocation trick for the
inodes round-robin view of the table.

The device table is always allocated dynamically, also for the
single device case. So it is unconditionally freed at umount.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/exofs.h       |   10 +++-
 fs/exofs/ore.c         |    2 +-
 fs/exofs/super.c       |   99 +++++++++++++++++++++++++++++------------------
 include/scsi/osd_ore.h |   26 ++++++++++++-
 4 files changed, 94 insertions(+), 43 deletions(-)

diff --git a/fs/exofs/exofs.h b/fs/exofs/exofs.h
index 3b2e047..006fd6f 100644
--- a/fs/exofs/exofs.h
+++ b/fs/exofs/exofs.h
@@ -53,6 +53,10 @@
 /* u64 has problems with printk this will cast it to unsigned long long */
 #define _LLU(x) (unsigned long long)(x)
 
+struct exofs_dev {
+	struct ore_dev ored;
+	unsigned did;
+};
 /*
  * our extension to the in-memory superblock
  */
@@ -69,7 +73,6 @@ struct exofs_sb_info {
 	struct ore_layout	layout;		/* Default files layout       */
 	struct ore_comp one_comp;		/* id & cred of partition id=0*/
 	struct ore_components oc;		/* comps for the partition    */
-	struct osd_dev	*_min_one_dev[1];	/* Place holder for one dev   */
 };
 
 /*
@@ -214,13 +217,14 @@ static inline void exofs_init_comps(struct ore_components *oc,
 	one_comp->obj.id = oid;
 	exofs_make_credential(one_comp->cred, &one_comp->obj);
 
-	oc->numdevs = sbi->oc.numdevs;
+	oc->numdevs = sbi->layout.group_width * sbi->layout.mirrors_p1 *
+							sbi->layout.group_count;
 	oc->single_comp = EC_SINGLE_COMP;
 	oc->comps = one_comp;
 
 	/* Round robin device view of the table */
 	first_dev = (dev_mod * sbi->layout.mirrors_p1) % sbi->oc.numdevs;
-	oc->ods = sbi->oc.ods + first_dev;
+	oc->ods = &sbi->oc.ods[first_dev];
 }
 
 #endif
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index c2b0033..a7d7925 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -59,7 +59,7 @@ static struct osd_obj_id *_ios_obj(struct ore_io_state *ios, unsigned index)
 
 static struct osd_dev *_ios_od(struct ore_io_state *ios, unsigned index)
 {
-	return ios->oc->ods[index];
+	return ore_comp_dev(ios->oc, index);
 }
 
 int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *oc,
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index 90b4c52..bce3686 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -431,17 +431,18 @@ static void _exofs_print_device(const char *msg, const char *dev_path,
 
 static void exofs_free_sbi(struct exofs_sb_info *sbi)
 {
-	while (sbi->oc.numdevs) {
-		int i = --sbi->oc.numdevs;
-		struct osd_dev *od = sbi->oc.ods[i];
+	unsigned numdevs = sbi->oc.numdevs;
+
+	while (numdevs) {
+		unsigned i = --numdevs;
+		struct osd_dev *od = ore_comp_dev(&sbi->oc, i);
 
 		if (od) {
-			sbi->oc.ods[i] = NULL;
+			ore_comp_set_dev(&sbi->oc, i, NULL);
 			osduld_put_device(od);
 		}
 	}
-	if (sbi->oc.ods != sbi->_min_one_dev)
-		kfree(sbi->oc.ods);
+	kfree(sbi->oc.ods);
 	kfree(sbi);
 }
 
@@ -468,7 +469,7 @@ static void exofs_put_super(struct super_block *sb)
 				  msecs_to_jiffies(100));
 	}
 
-	_exofs_print_device("Unmounting", NULL, sbi->oc.ods[0],
+	_exofs_print_device("Unmounting", NULL, ore_comp_dev(&sbi->oc, 0),
 			    sbi->one_comp.obj.partition);
 
 	bdi_destroy(&sbi->bdi);
@@ -592,12 +593,40 @@ static int exofs_devs_2_odi(struct exofs_dt_device_info *dt_dev,
 	return !(odi->systemid_len || odi->osdname_len);
 }
 
+int __alloc_dev_table(struct exofs_sb_info *sbi, unsigned numdevs,
+		      struct exofs_dev **peds)
+{
+	struct __alloc_ore_devs_and_exofs_devs {
+		/* Twice bigger table: See exofs_init_comps() and comment at
+		 * exofs_read_lookup_dev_table()
+		 */
+		struct ore_dev *oreds[numdevs * 2 - 1];
+		struct exofs_dev eds[numdevs];
+	} *aoded;
+	struct exofs_dev *eds;
+	unsigned i;
+
+	aoded = kzalloc(sizeof(*aoded), GFP_KERNEL);
+	if (unlikely(!aoded)) {
+		EXOFS_ERR("ERROR: faild allocating Device array[%d]\n",
+			  numdevs);
+		return -ENOMEM;
+	}
+
+	sbi->oc.ods = aoded->oreds;
+	*peds = eds = aoded->eds;
+	for (i = 0; i < numdevs; ++i)
+		aoded->oreds[i] = &eds[i].ored;
+	return 0;
+}
+
 static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 				       struct osd_dev *fscb_od,
 				       unsigned table_count)
 {
 	struct ore_comp comp;
 	struct exofs_device_table *dt;
+	struct exofs_dev *eds;
 	unsigned table_bytes = table_count * sizeof(dt->dt_dev_table[0]) +
 					     sizeof(*dt);
 	unsigned numdevs, i;
@@ -634,20 +663,16 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 	if (unlikely(ret))
 		goto out;
 
-	if (likely(numdevs > 1)) {
-		unsigned size = numdevs * sizeof(sbi->oc.ods[0]);
-
-		/* Twice bigger table: See exofs_init_comps() and below
-		 * comment
-		 */
-		sbi->oc.ods = kzalloc(size + size - 1, GFP_KERNEL);
-		if (unlikely(!sbi->oc.ods)) {
-			EXOFS_ERR("ERROR: faild allocating Device array[%d]\n",
-				  numdevs);
-			ret = -ENOMEM;
-			goto out;
-		}
-	}
+	ret = __alloc_dev_table(sbi, numdevs, &eds);
+	if (unlikely(ret))
+		goto out;
+	/* exofs round-robins the device table view according to inode
+	 * number. We hold a: twice bigger table hence inodes can point
+	 * to any device and have a sequential view of the table
+	 * starting at this device. See exofs_init_comps()
+	 */
+	memcpy(&sbi->oc.ods[numdevs], &sbi->oc.ods[0],
+		(numdevs - 1) * sizeof(sbi->oc.ods[0]));
 
 	for (i = 0; i < numdevs; i++) {
 		struct exofs_fscb fscb;
@@ -663,12 +688,15 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 		printk(KERN_NOTICE "Add device[%d]: osd_name-%s\n",
 		       i, odi.osdname);
 
+		/* the exofs id is currently the table index */
+		eds[i].did = i;
+
 		/* On all devices the device table is identical. The user can
 		 * specify any one of the participating devices on the command
 		 * line. We always keep them in device-table order.
 		 */
 		if (fscb_od && osduld_device_same(fscb_od, &odi)) {
-			sbi->oc.ods[i] = fscb_od;
+			eds[i].ored.od = fscb_od;
 			++sbi->oc.numdevs;
 			fscb_od = NULL;
 			continue;
@@ -682,7 +710,7 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 			goto out;
 		}
 
-		sbi->oc.ods[i] = od;
+		eds[i].ored.od = od;
 		++sbi->oc.numdevs;
 
 		/* Read the fscb of the other devices to make sure the FS
@@ -705,21 +733,10 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 
 out:
 	kfree(dt);
-	if (likely(!ret)) {
-		unsigned numdevs = sbi->oc.numdevs;
-
-		if (unlikely(fscb_od)) {
+	if (unlikely(fscb_od && !ret)) {
 			EXOFS_ERR("ERROR: Bad device-table container device not present\n");
 			osduld_put_device(fscb_od);
 			return -EINVAL;
-		}
-		/* exofs round-robins the device table view according to inode
-		 * number. We hold a: twice bigger table hence inodes can point
-		 * to any device and have a sequential view of the table
-		 * starting at this device. See exofs_init_comps()
-		 */
-		for (i = 0; i < numdevs - 1; ++i)
-			sbi->oc.ods[i + numdevs] = sbi->oc.ods[i];
 	}
 	return ret;
 }
@@ -773,7 +790,6 @@ static int exofs_fill_super(struct super_block *sb, void *data, int silent)
 	sbi->oc.numdevs = 1;
 	sbi->oc.single_comp = EC_SINGLE_COMP;
 	sbi->oc.comps = &sbi->one_comp;
-	sbi->oc.ods = sbi->_min_one_dev;
 
 	/* fill in some other data by hand */
 	memset(sb->s_id, 0, sizeof(sb->s_id));
@@ -822,7 +838,13 @@ static int exofs_fill_super(struct super_block *sb, void *data, int silent)
 		if (unlikely(ret))
 			goto free_sbi;
 	} else {
-		sbi->oc.ods[0] = od;
+		struct exofs_dev *eds;
+
+		ret = __alloc_dev_table(sbi, 1, &eds);
+		if (unlikely(ret))
+			goto free_sbi;
+
+		ore_comp_set_dev(&sbi->oc, 0, od);
 	}
 
 	__sbi_read_stats(sbi);
@@ -862,7 +884,8 @@ static int exofs_fill_super(struct super_block *sb, void *data, int silent)
 		goto free_sbi;
 	}
 
-	_exofs_print_device("Mounting", opts->dev_name, sbi->oc.ods[0],
+	_exofs_print_device("Mounting", opts->dev_name,
+			    ore_comp_dev(&sbi->oc, 0),
 			    sbi->one_comp.obj.partition);
 	return 0;
 
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index e4d550f..8fefdfb 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -44,6 +44,10 @@ struct ore_layout {
 	unsigned group_count;
 };
 
+struct ore_dev {
+	struct osd_dev *od;
+};
+
 struct ore_components {
 	unsigned	numdevs;		/* Num of devices in array    */
 	/* If @single_comp == EC_SINGLE_COMP, @comps points to a single
@@ -53,9 +57,29 @@ struct ore_components {
 		EC_SINGLE_COMP = 0, EC_MULTPLE_COMPS = 0xffffffff
 	}		single_comp;
 	struct ore_comp	*comps;
-	struct osd_dev	**ods;			/* osd_dev array              */
+
+	/* Array of pointers to ore_dev-* . User will usually have these pointed
+	 * too a bigger struct which contain an "ore_dev ored" member and use
+	 * container_of(oc->ods[i], struct foo_dev, ored) to access the bigger
+	 * structure.
+	 */
+	struct ore_dev	**ods;
 };
 
+/* ore_comp_dev Recievies a logical device index */
+static inline struct osd_dev *ore_comp_dev(
+	const struct ore_components *oc, unsigned i)
+{
+	BUG_ON(oc->numdevs <= i);
+	return oc->ods[i]->od;
+}
+
+static inline void ore_comp_set_dev(
+	struct ore_components *oc, unsigned i, struct osd_dev *od)
+{
+	oc->ods[i]->od = od;
+}
+
 struct ore_striping_info {
 	u64 obj_offset;
 	u64 group_length;
-- 
1.7.2.3

