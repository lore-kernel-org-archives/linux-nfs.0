Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38497 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab1HINZj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Aug 2011 09:25:39 -0400
Received: by wyg24 with SMTP id 24so351487wyg.19
        for <linux-nfs@vger.kernel.org>; Tue, 09 Aug 2011 06:25:37 -0700 (PDT)
Message-ID: <4E41354C.6060103@tonian.com>
Date: Tue, 09 Aug 2011 09:25:32 -0400
From: Benny Halevy <bhalevy@tonian.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH RFC] pnfsd-exofs: convert to v3.1 ORE
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Boaz,

Does the following patch makes sense in the new v3.1 ORE world?
Can you please help test it?
If it looks ok to you I'll just go ahead and release the rebased tree
to linux-nfs.org and you can pull it from there.

Thanks,

Benny

>From d89d93c733c8bc2984f1a918e522494558306f1d Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@tonian.com>
Date: Tue, 9 Aug 2011 07:33:11 -0400
Subject: [PATCH] pnfsd-exofs: convert to v3.1 ORE

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/exofs/export.c |   34 +++++++++++++++++++++++-----------
 1 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 8281c85..07bc5e2 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -73,6 +73,13 @@ err:
 	return status;
 }

+static unsigned exofs_layout_od_id(struct ore_layout *layout,
+				   struct ore_components *comps,
+				   osd_id obj_no, unsigned layout_index)
+{
+	return (layout_index + obj_no * layout->mirrors_p1) % comps->numdevs;
+}
+
 static enum nfsstat4 exofs_layout_get(
 	struct inode *inode,
 	struct exp_xdr_stream *xdr,
@@ -81,7 +88,8 @@ static enum nfsstat4 exofs_layout_get(
 {
 	struct exofs_i_info *oi = exofs_i(inode);
 	struct exofs_sb_info *sbi = inode->i_sb->s_fs_info;
-	struct exofs_layout *el = &sbi->layout;
+	struct ore_layout *el = &sbi->layout;
+	struct ore_components *ec = &sbi->comps;
 	struct pnfs_osd_object_cred *creds = NULL;
 	struct pnfs_osd_layout layout;
 	__be32 *start;
@@ -104,7 +112,7 @@ static enum nfsstat4 exofs_layout_get(
 	/* Fill in a pnfs_osd_layout struct */
 	layout.olo_map = sbi->data_map;
 	layout.olo_comps_index = 0;
-	layout.olo_num_comps = el->s_numdevs;
+	layout.olo_num_comps = ec->numdevs;
 	layout.olo_comps = creds;

 	nfserr = pnfs_osd_xdr_encode_layout_hdr(xdr, &layout);
@@ -112,16 +120,19 @@ static enum nfsstat4 exofs_layout_get(
 		goto out;

 	/* Encode layout components */
-	for (i = 0; i < el->s_numdevs; i++) {
+	for (i = 0; i < ec->numdevs; i++) {
 		struct pnfs_osd_object_cred cred;
-		osd_id id = exofs_oi_objno(oi);
-		unsigned dev = exofs_layout_od_id(el, id, i);
+		struct osd_obj_id oid = {
+			.partition = sbi->one_comp.obj.partition,
+			.id = exofs_oi_objno(oi)
+		};
+		unsigned dev = exofs_layout_od_id(el, ec, oid.id, i);

 		set_dev_id(&cred.oc_object_id.oid_device_id, args->lg_sbid,
 			   dev);
-		cred.oc_object_id.oid_partition_id = el->s_pid;
-		cred.oc_object_id.oid_object_id = id;
-		cred.oc_osd_version = osd_dev_is_ver1(el->s_ods[dev]) ?
+		cred.oc_object_id.oid_partition_id = oid.partition;
+		cred.oc_object_id.oid_object_id = oid.id;
+		cred.oc_osd_version = osd_dev_is_ver1(ec->ods[dev]) ?
 						PNFS_OSD_VERSION_1 :
 						PNFS_OSD_VERSION_2;
 		cred.oc_cap_key_sec = PNFS_OSD_CAP_KEY_SEC_NONE;
@@ -130,7 +141,7 @@ static enum nfsstat4 exofs_layout_get(
 		cred.oc_cap_key.cred		= NULL;

 		cred.oc_cap.cred_len	= OSD_CAP_LEN;
-		cred.oc_cap.cred	= oi->i_cred;
+		exofs_make_credential(cred.oc_cap.cred, &oid);
 		nfserr = pnfs_osd_xdr_encode_layout_cred(xdr, &cred);
 		if (unlikely(nfserr))
 			goto out;
@@ -277,6 +288,7 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 			  const struct nfsd4_pnfs_deviceid *devid)
 {
 	struct exofs_sb_info *sbi = sb->s_fs_info;
+	struct ore_components *ec = &sbi->comps;
 	struct pnfs_osd_deviceaddr devaddr;
 	const struct osd_dev_info *odi;
 	u64 devno = devid->devid;
@@ -285,13 +297,13 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,

 	memset(&devaddr, 0, sizeof(devaddr));

-	if (unlikely(devno >= sbi->layout.s_numdevs)) {
+	if (unlikely(devno >= ec->numdevs)) {
 		EXOFS_DBGMSG("Error: Device((%llx,%llx) does not exist\n",
 			     devid->sbid, devno);
 		return -ENODEV;
 	}

-	odi = osduld_device_info(sbi->layout.s_ods[devno]);
+	odi = osduld_device_info(ec->ods[devno]);

 	devaddr.oda_systemid.len = odi->systemid_len;
 	devaddr.oda_systemid.data = (void *)odi->systemid; /* !const cast */
-- 
1.7.6

