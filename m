Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:44372 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755023Ab1HJVQ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 17:16:27 -0400
Received: from zenyatta.panasas.com (zenyatta.int.panasas.com [172.17.28.63])
	by natasha.panasas.com (8.13.1/8.13.1) with ESMTP id p7ALGRPQ000875
	for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 17:16:27 -0400
Message-ID: <4E42F524.5060004@panasas.com>
Date: Wed, 10 Aug 2011 14:16:20 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 2/4] SQUASHME: pnfsd-exofs: Convert to ORE (2)
References: <4E42F3E3.8050006@panasas.com>
In-Reply-To: <4E42F3E3.8050006@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


This is on top of Benny's conversion (SQUASHME):
	pnfsd-exofs: convert to v3.1 ORE

This patch does 3 things:
1. Most of the code is doing the conversion to the new ORE code.

2. Upstream exofs patch has removed the sbi->data_map
   member see:
	exofs: Remove unused data_map member from exofs_sb_info

3. A *creds variable was set to NULL and kfreed at end, which is
   a fallout of some passed, "Convert osd XDR layout encoding"
   patch.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   58 +++++++++++++++++++++++++++-------------------------
 1 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 07bc5e2..10b9adb 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -73,11 +73,16 @@ err:
 	return status;
 }
 
-static unsigned exofs_layout_od_id(struct ore_layout *layout,
-				   struct ore_components *comps,
-				   osd_id obj_no, unsigned layout_index)
+void ore_layout_2_pnfs_layout(struct pnfs_osd_layout *pl,
+			      const struct ore_layout *ol)
 {
-	return (layout_index + obj_no * layout->mirrors_p1) % comps->numdevs;
+	pl->olo_map.odm_num_comps = ol->group_width * ol->mirrors_p1 *
+				    ol->group_count;
+	pl->olo_map.odm_stripe_unit = ol->stripe_unit;
+	pl->olo_map.odm_group_width = ol->group_width;
+	pl->olo_map.odm_group_depth = ol->group_depth;
+	pl->olo_map.odm_mirror_cnt = ol->mirrors_p1 - 1;
+	pl->olo_map.odm_raid_algorithm = ol->raid_algorithm;
 }
 
 static enum nfsstat4 exofs_layout_get(
@@ -88,9 +93,6 @@ static enum nfsstat4 exofs_layout_get(
 {
 	struct exofs_i_info *oi = exofs_i(inode);
 	struct exofs_sb_info *sbi = inode->i_sb->s_fs_info;
-	struct ore_layout *el = &sbi->layout;
-	struct ore_components *ec = &sbi->comps;
-	struct pnfs_osd_object_cred *creds = NULL;
 	struct pnfs_osd_layout layout;
 	__be32 *start;
 	unsigned i;
@@ -110,29 +112,25 @@ static enum nfsstat4 exofs_layout_get(
 	}
 
 	/* Fill in a pnfs_osd_layout struct */
-	layout.olo_map = sbi->data_map;
+	ore_layout_2_pnfs_layout(&layout, &sbi->layout);
+
 	layout.olo_comps_index = 0;
-	layout.olo_num_comps = ec->numdevs;
-	layout.olo_comps = creds;
+	layout.olo_num_comps = layout.olo_map.odm_num_comps;
 
 	nfserr = pnfs_osd_xdr_encode_layout_hdr(xdr, &layout);
 	if (unlikely(nfserr))
 		goto out;
 
 	/* Encode layout components */
-	for (i = 0; i < ec->numdevs; i++) {
+	for (i = 0; i <  layout.olo_num_comps; i++) {
 		struct pnfs_osd_object_cred cred;
-		struct osd_obj_id oid = {
-			.partition = sbi->one_comp.obj.partition,
-			.id = exofs_oi_objno(oi)
-		};
-		unsigned dev = exofs_layout_od_id(el, ec, oid.id, i);
+		unsigned sbi_dev = oi->comps.ods - sbi->comps.ods + i;
 
 		set_dev_id(&cred.oc_object_id.oid_device_id, args->lg_sbid,
-			   dev);
-		cred.oc_object_id.oid_partition_id = oid.partition;
-		cred.oc_object_id.oid_object_id = oid.id;
-		cred.oc_osd_version = osd_dev_is_ver1(ec->ods[dev]) ?
+			   sbi_dev);
+		cred.oc_object_id.oid_partition_id = oi->one_comp.obj.partition;
+		cred.oc_object_id.oid_object_id = oi->one_comp.obj.id;
+		cred.oc_osd_version = osd_dev_is_ver1(oi->comps.ods[i]) ?
 						PNFS_OSD_VERSION_1 :
 						PNFS_OSD_VERSION_2;
 		cred.oc_cap_key_sec = PNFS_OSD_CAP_KEY_SEC_NONE;
@@ -141,10 +139,15 @@ static enum nfsstat4 exofs_layout_get(
 		cred.oc_cap_key.cred		= NULL;
 
 		cred.oc_cap.cred_len	= OSD_CAP_LEN;
-		exofs_make_credential(cred.oc_cap.cred, &oid);
+		cred.oc_cap.cred	= oi->one_comp.cred;
+
 		nfserr = pnfs_osd_xdr_encode_layout_cred(xdr, &cred);
-		if (unlikely(nfserr))
+		if (unlikely(nfserr)) {
+			EXOFS_DBGMSG("(0x%lx) nfserr=%u total=%u encoded=%u\n",
+				     inode->i_ino, nfserr, layout.olo_num_comps,
+				     i - 1);
 			goto out;
+		}
 	}
 
 	exp_xdr_encode_opaque_len(start, xdr->p);
@@ -160,9 +163,9 @@ static enum nfsstat4 exofs_layout_get(
 	spin_unlock(&oi->i_layout_lock);
 
 out:
-	kfree(creds);
-	EXOFS_DBGMSG("(0x%lx) nfserr=%u xdr_bytes=%zu\n",
-		     inode->i_ino, nfserr, exp_xdr_qbytes(xdr->p - start));
+	if (unlikely(nfserr))
+		EXOFS_DBGMSG("(0x%lx) nfserr=%u xdr_bytes=%zu\n",
+			  inode->i_ino, nfserr, exp_xdr_qbytes(xdr->p - start));
 	return nfserr;
 }
 
@@ -288,7 +291,6 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 			  const struct nfsd4_pnfs_deviceid *devid)
 {
 	struct exofs_sb_info *sbi = sb->s_fs_info;
-	struct ore_components *ec = &sbi->comps;
 	struct pnfs_osd_deviceaddr devaddr;
 	const struct osd_dev_info *odi;
 	u64 devno = devid->devid;
@@ -297,13 +299,13 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 
 	memset(&devaddr, 0, sizeof(devaddr));
 
-	if (unlikely(devno >= ec->numdevs)) {
+	if (unlikely(devno >= sbi->comps.numdevs)) {
 		EXOFS_DBGMSG("Error: Device((%llx,%llx) does not exist\n",
 			     devid->sbid, devno);
 		return -ENODEV;
 	}
 
-	odi = osduld_device_info(ec->ods[devno]);
+	odi = osduld_device_info(sbi->comps.ods[devno]);
 
 	devaddr.oda_systemid.len = odi->systemid_len;
 	devaddr.oda_systemid.data = (void *)odi->systemid; /* !const cast */
-- 
1.7.6


