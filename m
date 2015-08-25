Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34636 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbbHYBnL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 21:43:11 -0400
Received: by iodb91 with SMTP id b91so169541429iod.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 18:43:11 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFSv4.1/flexfile: Ensure uniqueness of mirrors across layout segments
Date: Mon, 24 Aug 2015 21:43:05 -0400
Message-Id: <1440466986-36826-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1440466986-36826-2-git-send-email-trond.myklebust@primarydata.com>
References: <1440466986-36826-1-git-send-email-trond.myklebust@primarydata.com>
 <1440466986-36826-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Keep the full list of mirrors in the struct nfs4_ff_layout_mirror so that
they can be shared among the layout segments that use them.
Also ensure that we send out only one copy of the layoutstats per mirror.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 116 ++++++++++++++++++++++++++-------
 fs/nfs/flexfilelayout/flexfilelayout.h |   3 +
 2 files changed, 95 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f3efff640989..210352741177 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -34,6 +34,7 @@ ff_layout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
 	ffl = kzalloc(sizeof(*ffl), gfp_flags);
 	if (ffl) {
 		INIT_LIST_HEAD(&ffl->error_list);
+		INIT_LIST_HEAD(&ffl->mirrors);
 		return &ffl->generic_hdr;
 	} else
 		return NULL;
@@ -135,6 +136,66 @@ decode_name(struct xdr_stream *xdr, u32 *id)
 	return 0;
 }
 
+static bool ff_mirror_match_fh(const struct nfs4_ff_layout_mirror *m1,
+		const struct nfs4_ff_layout_mirror *m2)
+{
+	int i, j;
+
+	if (m1->fh_versions_cnt != m2->fh_versions_cnt)
+		return false;
+	for (i = 0; i < m1->fh_versions_cnt; i++) {
+		bool found_fh = false;
+		for (j = 0; j < m2->fh_versions_cnt; i++) {
+			if (nfs_compare_fh(&m1->fh_versions[i],
+					&m2->fh_versions[j])) {
+				found_fh = true;
+				break;
+			}
+		}
+		if (!found_fh)
+			return false;
+	}
+	return true;
+}
+
+static struct nfs4_ff_layout_mirror *
+ff_layout_add_mirror(struct pnfs_layout_hdr *lo,
+		struct nfs4_ff_layout_mirror *mirror)
+{
+	struct nfs4_flexfile_layout *ff_layout = FF_LAYOUT_FROM_HDR(lo);
+	struct nfs4_ff_layout_mirror *pos;
+	struct inode *inode = lo->plh_inode;
+
+	spin_lock(&inode->i_lock);
+	list_for_each_entry(pos, &ff_layout->mirrors, mirrors) {
+		if (mirror->mirror_ds != pos->mirror_ds)
+			continue;
+		if (!ff_mirror_match_fh(mirror, pos))
+			continue;
+		if (atomic_inc_not_zero(&pos->ref)) {
+			spin_unlock(&inode->i_lock);
+			return pos;
+		}
+	}
+	list_add(&mirror->mirrors, &ff_layout->mirrors);
+	mirror->layout = lo;
+	spin_unlock(&inode->i_lock);
+	return mirror;
+}
+
+void
+ff_layout_remove_mirror(struct nfs4_ff_layout_mirror *mirror)
+{
+	struct inode *inode;
+	if (mirror->layout == NULL)
+		return;
+	inode = mirror->layout->plh_inode;
+	spin_lock(&inode->i_lock);
+	list_del(&mirror->mirrors);
+	spin_unlock(&inode->i_lock);
+	mirror->layout = NULL;
+}
+
 static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(gfp_t gfp_flags)
 {
 	struct nfs4_ff_layout_mirror *mirror;
@@ -143,12 +204,14 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(gfp_t gfp_flags)
 	if (mirror != NULL) {
 		spin_lock_init(&mirror->lock);
 		atomic_set(&mirror->ref, 1);
+		INIT_LIST_HEAD(&mirror->mirrors);
 	}
 	return mirror;
 }
 
 static void ff_layout_free_mirror(struct nfs4_ff_layout_mirror *mirror)
 {
+	ff_layout_remove_mirror(mirror);
 	kfree(mirror->fh_versions);
 	nfs4_ff_layout_put_deviceid(mirror->mirror_ds);
 	kfree(mirror);
@@ -267,6 +330,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		goto out_err_free;
 
 	for (i = 0; i < fls->mirror_array_cnt; i++) {
+		struct nfs4_ff_layout_mirror *mirror;
 		struct nfs4_deviceid devid;
 		struct nfs4_deviceid_node *idnode;
 		u32 ds_count;
@@ -355,6 +419,12 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		if (rc)
 			goto out_err_free;
 
+		mirror = ff_layout_add_mirror(lh, fls->mirror_array[i]);
+		if (mirror != fls->mirror_array[i]) {
+			ff_layout_free_mirror(fls->mirror_array[i]);
+			fls->mirror_array[i] = mirror;
+		}
+
 		dprintk("%s: uid %d gid %d\n", __func__,
 			fls->mirror_array[i]->uid,
 			fls->mirror_array[i]->gid);
@@ -1883,24 +1953,27 @@ ff_layout_encode_layoutstats(struct xdr_stream *xdr,
 	*start = cpu_to_be32((xdr->p - start - 1) * 4);
 }
 
-static bool
+static int
 ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 			       struct pnfs_layout_segment *pls,
-			       int *dev_count, int dev_limit)
+			       int dev_limit)
 {
+	struct nfs4_flexfile_layout *ff_layout = FF_LAYOUT_FROM_HDR(pls->pls_layout);
 	struct nfs4_ff_layout_mirror *mirror;
 	struct nfs4_deviceid_node *dev;
 	struct nfs42_layoutstat_devinfo *devinfo;
-	int i;
+	int i = 0;
 
-	for (i = 0; i < FF_LAYOUT_MIRROR_COUNT(pls); i++) {
-		if (*dev_count >= dev_limit)
+	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
+		if (i >= dev_limit)
 			break;
-		mirror = FF_LAYOUT_COMP(pls, i);
-		if (!mirror || !mirror->mirror_ds)
+		if (!mirror->mirror_ds)
 			continue;
-		dev = FF_LAYOUT_DEVID_NODE(pls, i);
-		devinfo = &args->devinfo[*dev_count];
+		/* mirror refcount put in cleanup_layoutstats */
+		if (!atomic_inc_not_zero(&mirror->ref))
+			continue;
+		dev = &mirror->mirror_ds->id_node; 
+		devinfo = &args->devinfo[i];
 		memcpy(&devinfo->dev_id, &dev->deviceid, NFS4_DEVICEID4_SIZE);
 		devinfo->offset = pls->pls_range.offset;
 		devinfo->length = pls->pls_range.length;
@@ -1911,24 +1984,25 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 		devinfo->layout_type = LAYOUT_FLEX_FILES;
 		devinfo->layoutstats_encode = ff_layout_encode_layoutstats;
 		devinfo->layout_private = mirror;
-		/* mirror refcount put in cleanup_layoutstats */
-		atomic_inc(&mirror->ref);
 
-		++(*dev_count);
+		i++;
 	}
-
-	return *dev_count < dev_limit;
+	return i;
 }
 
 static int
 ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
 {
+	struct nfs4_flexfile_layout *ff_layout;
+	struct nfs4_ff_layout_mirror *mirror;
 	struct pnfs_layout_segment *pls;
 	int dev_count = 0;
 
 	spin_lock(&args->inode->i_lock);
-	list_for_each_entry(pls, &NFS_I(args->inode)->layout->plh_segs, pls_list) {
-		dev_count += FF_LAYOUT_MIRROR_COUNT(pls);
+	ff_layout = FF_LAYOUT_FROM_HDR(NFS_I(args->inode)->layout);
+	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
+		if (atomic_read(&mirror->ref) != 0)
+			dev_count ++;
 	}
 	spin_unlock(&args->inode->i_lock);
 	/* For now, send at most PNFS_LAYOUTSTATS_MAXDEV statistics */
@@ -1937,20 +2011,14 @@ ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
 			__func__, dev_count, PNFS_LAYOUTSTATS_MAXDEV);
 		dev_count = PNFS_LAYOUTSTATS_MAXDEV;
 	}
-	args->devinfo = kmalloc(dev_count * sizeof(*args->devinfo), GFP_KERNEL);
+	args->devinfo = kmalloc_array(dev_count, sizeof(*args->devinfo), GFP_NOIO);
 	if (!args->devinfo)
 		return -ENOMEM;
 
 	dev_count = 0;
 	spin_lock(&args->inode->i_lock);
-	list_for_each_entry(pls, &NFS_I(args->inode)->layout->plh_segs, pls_list) {
-		if (!ff_layout_mirror_prepare_stats(args, pls, &dev_count,
-						    PNFS_LAYOUTSTATS_MAXDEV)) {
-			break;
-		}
-	}
+	args->num_dev = ff_layout_mirror_prepare_stats(args, pls, dev_count);
 	spin_unlock(&args->inode->i_lock);
-	args->num_dev = dev_count;
 
 	return 0;
 }
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index fe9d3ff7cf85..68cc0d9828f9 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -67,6 +67,8 @@ struct nfs4_ff_layoutstat {
 };
 
 struct nfs4_ff_layout_mirror {
+	struct pnfs_layout_hdr		*layout;
+	struct list_head		mirrors;
 	u32				ds_count;
 	u32				efficiency;
 	struct nfs4_ff_layout_ds	*mirror_ds;
@@ -95,6 +97,7 @@ struct nfs4_ff_layout_segment {
 struct nfs4_flexfile_layout {
 	struct pnfs_layout_hdr generic_hdr;
 	struct pnfs_ds_commit_info commit_info;
+	struct list_head	mirrors;
 	struct list_head	error_list; /* nfs4_ff_layout_ds_err */
 };
 
-- 
2.4.3

