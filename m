Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52000 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab1JDK2W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:28:22 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 01/19] exofs: Rename struct ore_components comps => oc
Date: Tue, 4 Oct 2011 12:28:12 +0200
Message-ID: <1317724092-27321-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

ore_components already has a comps member so this leads
to things like comps->comps which is annoying. the name oc
was already used in new code. So rename all old usage of
ore_components comps => ore_components oc.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/exofs.h       |   16 ++++++------
 fs/exofs/inode.c       |   22 +++++++++---------
 fs/exofs/ore.c         |   30 ++++++++++++------------
 fs/exofs/super.c       |   58 ++++++++++++++++++++++++------------------------
 include/scsi/osd_ore.h |    2 +-
 5 files changed, 64 insertions(+), 64 deletions(-)

diff --git a/fs/exofs/exofs.h b/fs/exofs/exofs.h
index f4e442e..c09d5a7 100644
--- a/fs/exofs/exofs.h
+++ b/fs/exofs/exofs.h
@@ -71,7 +71,7 @@ struct exofs_sb_info {
 						 */
 	struct ore_layout	layout;		/* Default files layout       */
 	struct ore_comp one_comp;		/* id & cred of partition id=0*/
-	struct ore_components comps;		/* comps for the partition    */
+	struct ore_components oc;		/* comps for the partition    */
 	struct osd_dev	*_min_one_dev[1];	/* Place holder for one dev   */
 };
 
@@ -86,7 +86,7 @@ struct exofs_i_info {
 	uint32_t       i_dir_start_lookup; /* which page to start lookup      */
 	uint64_t       i_commit_size;      /* the object's written length     */
 	struct ore_comp one_comp;	   /* same component for all devices  */
-	struct ore_components comps;	   /* inode view of the device table  */
+	struct ore_components oc;	   /* inode view of the device table  */
 };
 
 static inline osd_id exofs_oi_objno(struct exofs_i_info *oi)
@@ -207,7 +207,7 @@ extern const struct inode_operations exofs_fast_symlink_inode_operations;
  * bigger and that the device table repeats twice.
  * See: exofs_read_lookup_dev_table()
  */
-static inline void exofs_init_comps(struct ore_components *comps,
+static inline void exofs_init_comps(struct ore_components *oc,
 				    struct ore_comp *one_comp,
 				    struct exofs_sb_info *sbi, osd_id oid)
 {
@@ -217,13 +217,13 @@ static inline void exofs_init_comps(struct ore_components *comps,
 	one_comp->obj.id = oid;
 	exofs_make_credential(one_comp->cred, &one_comp->obj);
 
-	comps->numdevs = sbi->comps.numdevs;
-	comps->single_comp = EC_SINGLE_COMP;
-	comps->comps = one_comp;
+	oc->numdevs = sbi->oc.numdevs;
+	oc->single_comp = EC_SINGLE_COMP;
+	oc->comps = one_comp;
 
 	/* Round robin device view of the table */
-	first_dev = (dev_mod * sbi->layout.mirrors_p1) % sbi->comps.numdevs;
-	comps->ods = sbi->comps.ods + first_dev;
+	first_dev = (dev_mod * sbi->layout.mirrors_p1) % sbi->oc.numdevs;
+	oc->ods = sbi->oc.ods + first_dev;
 }
 
 #endif
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index f39a38f..61b2f7e 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -270,7 +270,7 @@ static int read_exec(struct page_collect *pcol)
 		return 0;
 
 	if (!pcol->ios) {
-		int ret = ore_get_rw_state(&pcol->sbi->layout, &oi->comps, true,
+		int ret = ore_get_rw_state(&pcol->sbi->layout, &oi->oc, true,
 					     pcol->pg_first << PAGE_CACHE_SHIFT,
 					     pcol->length, &pcol->ios);
 
@@ -516,7 +516,7 @@ static int write_exec(struct page_collect *pcol)
 		return 0;
 
 	BUG_ON(pcol->ios);
-	ret = ore_get_rw_state(&pcol->sbi->layout, &oi->comps, false,
+	ret = ore_get_rw_state(&pcol->sbi->layout, &oi->oc, false,
 				 pcol->pg_first << PAGE_CACHE_SHIFT,
 				 pcol->length, &pcol->ios);
 
@@ -860,7 +860,7 @@ static int _do_truncate(struct inode *inode, loff_t newsize)
 
 	inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 
-	ret = ore_truncate(&sbi->layout, &oi->comps, (u64)newsize);
+	ret = ore_truncate(&sbi->layout, &oi->oc, (u64)newsize);
 	if (likely(!ret))
 		truncate_setsize(inode, newsize);
 
@@ -927,14 +927,14 @@ static int exofs_get_inode(struct super_block *sb, struct exofs_i_info *oi,
 	struct exofs_on_disk_inode_layout *layout;
 	int ret;
 
-	ret = ore_get_io_state(&sbi->layout, &oi->comps, &ios);
+	ret = ore_get_io_state(&sbi->layout, &oi->oc, &ios);
 	if (unlikely(ret)) {
 		EXOFS_ERR("%s: ore_get_io_state failed.\n", __func__);
 		return ret;
 	}
 
-	attrs[1].len = exofs_on_disk_inode_layout_size(sbi->comps.numdevs);
-	attrs[2].len = exofs_on_disk_inode_layout_size(sbi->comps.numdevs);
+	attrs[1].len = exofs_on_disk_inode_layout_size(sbi->oc.numdevs);
+	attrs[2].len = exofs_on_disk_inode_layout_size(sbi->oc.numdevs);
 
 	ios->in_attr = attrs;
 	ios->in_attr_len = ARRAY_SIZE(attrs);
@@ -1018,7 +1018,7 @@ struct inode *exofs_iget(struct super_block *sb, unsigned long ino)
 		return inode;
 	oi = exofs_i(inode);
 	__oi_init(oi);
-	exofs_init_comps(&oi->comps, &oi->one_comp, sb->s_fs_info,
+	exofs_init_comps(&oi->oc, &oi->one_comp, sb->s_fs_info,
 			 exofs_oi_objno(oi));
 
 	/* read the inode from the osd */
@@ -1172,13 +1172,13 @@ struct inode *exofs_new_inode(struct inode *dir, int mode)
 	spin_unlock(&sbi->s_next_gen_lock);
 	insert_inode_hash(inode);
 
-	exofs_init_comps(&oi->comps, &oi->one_comp, sb->s_fs_info,
+	exofs_init_comps(&oi->oc, &oi->one_comp, sb->s_fs_info,
 			 exofs_oi_objno(oi));
 	exofs_sbi_write_stats(sbi); /* Make sure new sbi->s_nextid is on disk */
 
 	mark_inode_dirty(inode);
 
-	ret = ore_get_io_state(&sbi->layout, &oi->comps, &ios);
+	ret = ore_get_io_state(&sbi->layout, &oi->oc, &ios);
 	if (unlikely(ret)) {
 		EXOFS_ERR("exofs_new_inode: ore_get_io_state failed\n");
 		return ERR_PTR(ret);
@@ -1267,7 +1267,7 @@ static int exofs_update_inode(struct inode *inode, int do_sync)
 	} else
 		memcpy(fcb->i_data, oi->i_data, sizeof(fcb->i_data));
 
-	ret = ore_get_io_state(&sbi->layout, &oi->comps, &ios);
+	ret = ore_get_io_state(&sbi->layout, &oi->oc, &ios);
 	if (unlikely(ret)) {
 		EXOFS_ERR("%s: ore_get_io_state failed.\n", __func__);
 		goto free_args;
@@ -1350,7 +1350,7 @@ void exofs_evict_inode(struct inode *inode)
 	/* ignore the error, attempt a remove anyway */
 
 	/* Now Remove the OSD objects */
-	ret = ore_get_io_state(&sbi->layout, &oi->comps, &ios);
+	ret = ore_get_io_state(&sbi->layout, &oi->oc, &ios);
 	if (unlikely(ret)) {
 		EXOFS_ERR("%s: ore_get_io_state failed\n", __func__);
 		return;
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 6114fdf..870f85a 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -49,20 +49,20 @@ MODULE_LICENSE("GPL");
 
 static u8 *_ios_cred(struct ore_io_state *ios, unsigned index)
 {
-	return ios->comps->comps[index & ios->comps->single_comp].cred;
+	return ios->oc->comps[index & ios->oc->single_comp].cred;
 }
 
 static struct osd_obj_id *_ios_obj(struct ore_io_state *ios, unsigned index)
 {
-	return &ios->comps->comps[index & ios->comps->single_comp].obj;
+	return &ios->oc->comps[index & ios->oc->single_comp].obj;
 }
 
 static struct osd_dev *_ios_od(struct ore_io_state *ios, unsigned index)
 {
-	return ios->comps->ods[index];
+	return ios->oc->ods[index];
 }
 
-int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *comps,
+int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *oc,
 		      bool is_reading, u64 offset, u64 length,
 		      struct ore_io_state **pios)
 {
@@ -71,16 +71,16 @@ int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *comps,
 	/*TODO: Maybe use kmem_cach per sbi of size
 	 * exofs_io_state_size(layout->s_numdevs)
 	 */
-	ios = kzalloc(ore_io_state_size(comps->numdevs), GFP_KERNEL);
+	ios = kzalloc(ore_io_state_size(oc->numdevs), GFP_KERNEL);
 	if (unlikely(!ios)) {
 		ORE_DBGMSG("Failed kzalloc bytes=%d\n",
-			     ore_io_state_size(comps->numdevs));
+			     ore_io_state_size(oc->numdevs));
 		*pios = NULL;
 		return -ENOMEM;
 	}
 
 	ios->layout = layout;
-	ios->comps = comps;
+	ios->oc = oc;
 	ios->offset = offset;
 	ios->length = length;
 	ios->reading = is_reading;
@@ -90,10 +90,10 @@ int  ore_get_rw_state(struct ore_layout *layout, struct ore_components *comps,
 }
 EXPORT_SYMBOL(ore_get_rw_state);
 
-int  ore_get_io_state(struct ore_layout *layout, struct ore_components *comps,
+int  ore_get_io_state(struct ore_layout *layout, struct ore_components *oc,
 		      struct ore_io_state **ios)
 {
-	return ore_get_rw_state(layout, comps, true, 0, 0, ios);
+	return ore_get_rw_state(layout, oc, true, 0, 0, ios);
 }
 EXPORT_SYMBOL(ore_get_io_state);
 
@@ -476,7 +476,7 @@ int ore_create(struct ore_io_state *ios)
 {
 	int i, ret;
 
-	for (i = 0; i < ios->comps->numdevs; i++) {
+	for (i = 0; i < ios->oc->numdevs; i++) {
 		struct osd_request *or;
 
 		or = osd_start_request(_ios_od(ios, i), GFP_KERNEL);
@@ -501,7 +501,7 @@ int ore_remove(struct ore_io_state *ios)
 {
 	int i, ret;
 
-	for (i = 0; i < ios->comps->numdevs; i++) {
+	for (i = 0; i < ios->oc->numdevs; i++) {
 		struct osd_request *or;
 
 		or = osd_start_request(_ios_od(ios, i), GFP_KERNEL);
@@ -768,7 +768,7 @@ static void _calc_trunk_info(struct ore_layout *layout, u64 file_offset,
 	ti->max_devs = layout->group_width * layout->group_count;
 }
 
-int ore_truncate(struct ore_layout *layout, struct ore_components *comps,
+int ore_truncate(struct ore_layout *layout, struct ore_components *oc,
 		   u64 size)
 {
 	struct ore_io_state *ios;
@@ -779,7 +779,7 @@ int ore_truncate(struct ore_layout *layout, struct ore_components *comps,
 	struct _trunc_info ti;
 	int i, ret;
 
-	ret = ore_get_io_state(layout, comps, &ios);
+	ret = ore_get_io_state(layout, oc, &ios);
 	if (unlikely(ret))
 		return ret;
 
@@ -792,7 +792,7 @@ int ore_truncate(struct ore_layout *layout, struct ore_components *comps,
 		goto out;
 	}
 
-	ios->numdevs = ios->comps->numdevs;
+	ios->numdevs = ios->oc->numdevs;
 
 	for (i = 0; i < ti.max_devs; ++i) {
 		struct exofs_trunc_attr *size_attr = &size_attrs[i];
@@ -815,7 +815,7 @@ int ore_truncate(struct ore_layout *layout, struct ore_components *comps,
 		size_attr->attr.val_ptr = &size_attr->newsize;
 
 		ORE_DBGMSG("trunc(0x%llx) obj_offset=0x%llx dev=%d\n",
-			     _LLU(comps->comps->obj.id), _LLU(obj_size), i);
+			     _LLU(oc->comps->obj.id), _LLU(obj_size), i);
 		ret = _truncate_mirrors(ios, i * ios->layout->mirrors_p1,
 					&size_attr->attr);
 		if (unlikely(ret))
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index afe79ee..babb195 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -266,7 +266,7 @@ static int __sbi_read_stats(struct exofs_sb_info *sbi)
 	struct ore_io_state *ios;
 	int ret;
 
-	ret = ore_get_io_state(&sbi->layout, &sbi->comps, &ios);
+	ret = ore_get_io_state(&sbi->layout, &sbi->oc, &ios);
 	if (unlikely(ret)) {
 		EXOFS_ERR("%s: ore_get_io_state failed.\n", __func__);
 		return ret;
@@ -321,7 +321,7 @@ int exofs_sbi_write_stats(struct exofs_sb_info *sbi)
 	struct ore_io_state *ios;
 	int ret;
 
-	ret = ore_get_io_state(&sbi->layout, &sbi->comps, &ios);
+	ret = ore_get_io_state(&sbi->layout, &sbi->oc, &ios);
 	if (unlikely(ret)) {
 		EXOFS_ERR("%s: ore_get_io_state failed.\n", __func__);
 		return ret;
@@ -360,7 +360,7 @@ static int exofs_sync_fs(struct super_block *sb, int wait)
 	struct exofs_sb_info *sbi;
 	struct exofs_fscb *fscb;
 	struct ore_comp one_comp;
-	struct ore_components comps;
+	struct ore_components oc;
 	struct ore_io_state *ios;
 	int ret = -ENOMEM;
 
@@ -378,9 +378,9 @@ static int exofs_sync_fs(struct super_block *sb, int wait)
 	 * the writeable info is set in exofs_sbi_write_stats() above.
 	 */
 
-	exofs_init_comps(&comps, &one_comp, sbi, EXOFS_SUPER_ID);
+	exofs_init_comps(&oc, &one_comp, sbi, EXOFS_SUPER_ID);
 
-	ret = ore_get_io_state(&sbi->layout, &comps, &ios);
+	ret = ore_get_io_state(&sbi->layout, &oc, &ios);
 	if (unlikely(ret))
 		goto out;
 
@@ -431,17 +431,17 @@ static void _exofs_print_device(const char *msg, const char *dev_path,
 
 static void exofs_free_sbi(struct exofs_sb_info *sbi)
 {
-	while (sbi->comps.numdevs) {
-		int i = --sbi->comps.numdevs;
-		struct osd_dev *od = sbi->comps.ods[i];
+	while (sbi->oc.numdevs) {
+		int i = --sbi->oc.numdevs;
+		struct osd_dev *od = sbi->oc.ods[i];
 
 		if (od) {
-			sbi->comps.ods[i] = NULL;
+			sbi->oc.ods[i] = NULL;
 			osduld_put_device(od);
 		}
 	}
-	if (sbi->comps.ods != sbi->_min_one_dev)
-		kfree(sbi->comps.ods);
+	if (sbi->oc.ods != sbi->_min_one_dev)
+		kfree(sbi->oc.ods);
 	kfree(sbi);
 }
 
@@ -468,7 +468,7 @@ static void exofs_put_super(struct super_block *sb)
 				  msecs_to_jiffies(100));
 	}
 
-	_exofs_print_device("Unmounting", NULL, sbi->comps.ods[0],
+	_exofs_print_device("Unmounting", NULL, sbi->oc.ods[0],
 			    sbi->one_comp.obj.partition);
 
 	bdi_destroy(&sbi->bdi);
@@ -623,7 +623,7 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 		return -ENOMEM;
 	}
 
-	sbi->comps.numdevs = 0;
+	sbi->oc.numdevs = 0;
 
 	comp.obj.partition = sbi->one_comp.obj.partition;
 	comp.obj.id = EXOFS_DEVTABLE_ID;
@@ -648,13 +648,13 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 		goto out;
 
 	if (likely(numdevs > 1)) {
-		unsigned size = numdevs * sizeof(sbi->comps.ods[0]);
+		unsigned size = numdevs * sizeof(sbi->oc.ods[0]);
 
 		/* Twice bigger table: See exofs_init_comps() and below
 		 * comment
 		 */
-		sbi->comps.ods = kzalloc(size + size - 1, GFP_KERNEL);
-		if (unlikely(!sbi->comps.ods)) {
+		sbi->oc.ods = kzalloc(size + size - 1, GFP_KERNEL);
+		if (unlikely(!sbi->oc.ods)) {
 			EXOFS_ERR("ERROR: faild allocating Device array[%d]\n",
 				  numdevs);
 			ret = -ENOMEM;
@@ -681,8 +681,8 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 		 * line. We always keep them in device-table order.
 		 */
 		if (fscb_od && osduld_device_same(fscb_od, &odi)) {
-			sbi->comps.ods[i] = fscb_od;
-			++sbi->comps.numdevs;
+			sbi->oc.ods[i] = fscb_od;
+			++sbi->oc.numdevs;
 			fscb_od = NULL;
 			continue;
 		}
@@ -695,8 +695,8 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 			goto out;
 		}
 
-		sbi->comps.ods[i] = od;
-		++sbi->comps.numdevs;
+		sbi->oc.ods[i] = od;
+		++sbi->oc.numdevs;
 
 		/* Read the fscb of the other devices to make sure the FS
 		 * partition is there.
@@ -719,7 +719,7 @@ static int exofs_read_lookup_dev_table(struct exofs_sb_info *sbi,
 out:
 	kfree(dt);
 	if (likely(!ret)) {
-		unsigned numdevs = sbi->comps.numdevs;
+		unsigned numdevs = sbi->oc.numdevs;
 
 		if (unlikely(fscb_od)) {
 			EXOFS_ERR("ERROR: Bad device-table container device not present\n");
@@ -732,7 +732,7 @@ out:
 		 * starting at this device. See exofs_init_comps()
 		 */
 		for (i = 0; i < numdevs - 1; ++i)
-			sbi->comps.ods[i + numdevs] = sbi->comps.ods[i];
+			sbi->oc.ods[i + numdevs] = sbi->oc.ods[i];
 	}
 	return ret;
 }
@@ -783,10 +783,10 @@ static int exofs_fill_super(struct super_block *sb, void *data, int silent)
 	sbi->one_comp.obj.partition = opts->pid;
 	sbi->one_comp.obj.id = 0;
 	exofs_make_credential(sbi->one_comp.cred, &sbi->one_comp.obj);
-	sbi->comps.numdevs = 1;
-	sbi->comps.single_comp = EC_SINGLE_COMP;
-	sbi->comps.comps = &sbi->one_comp;
-	sbi->comps.ods = sbi->_min_one_dev;
+	sbi->oc.numdevs = 1;
+	sbi->oc.single_comp = EC_SINGLE_COMP;
+	sbi->oc.comps = &sbi->one_comp;
+	sbi->oc.ods = sbi->_min_one_dev;
 
 	/* fill in some other data by hand */
 	memset(sb->s_id, 0, sizeof(sb->s_id));
@@ -835,7 +835,7 @@ static int exofs_fill_super(struct super_block *sb, void *data, int silent)
 		if (unlikely(ret))
 			goto free_sbi;
 	} else {
-		sbi->comps.ods[0] = od;
+		sbi->oc.ods[0] = od;
 	}
 
 	__sbi_read_stats(sbi);
@@ -875,7 +875,7 @@ static int exofs_fill_super(struct super_block *sb, void *data, int silent)
 		goto free_sbi;
 	}
 
-	_exofs_print_device("Mounting", opts->dev_name, sbi->comps.ods[0],
+	_exofs_print_device("Mounting", opts->dev_name, sbi->oc.ods[0],
 			    sbi->one_comp.obj.partition);
 	return 0;
 
@@ -924,7 +924,7 @@ static int exofs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	uint64_t used = ULLONG_MAX;
 	int ret;
 
-	ret = ore_get_io_state(&sbi->layout, &sbi->comps, &ios);
+	ret = ore_get_io_state(&sbi->layout, &sbi->oc, &ios);
 	if (ret) {
 		EXOFS_DBGMSG("ore_get_io_state failed.\n");
 		return ret;
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index c5c5e00..954292a 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -64,7 +64,7 @@ struct ore_io_state {
 	ore_io_done_fn	done;
 
 	struct ore_layout	*layout;
-	struct ore_components	*comps;
+	struct ore_components	*oc;
 
 	/* Global read/write IO*/
 	loff_t			offset;
-- 
1.7.2.3

