Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38298 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167Ab1FNViz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:38:55 -0400
Message-ID: <4DF7D4EE.80109@panasas.com>
Date: Tue, 14 Jun 2011 17:38:54 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 10/10] SQUASHME: pnfsd-exofs: checkpatch love and a dprint
References: <4DF7CA2F.7030407@panasas.com> <4DF7D36F.9070602@panasas.com>
In-Reply-To: <4DF7D36F.9070602@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Singed-off-by: Boaz Harrosh <bharrosh@panasas.com>

---
diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index c153ad6..8281c85 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -85,8 +85,8 @@ static enum nfsstat4 exofs_layout_get(
 	struct pnfs_osd_object_cred *creds = NULL;
 	struct pnfs_osd_layout layout;
 	__be32 *start;
+	unsigned i;
 	bool in_recall;
-	int i;
 	enum nfsstat4 nfserr;
 
 	res->lg_seg.offset = 0;
@@ -285,8 +285,11 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 
 	memset(&devaddr, 0, sizeof(devaddr));
 
-	if (unlikely(devno >= sbi->layout.s_numdevs))
+	if (unlikely(devno >= sbi->layout.s_numdevs)) {
+		EXOFS_DBGMSG("Error: Device((%llx,%llx) does not exist\n",
+			     devid->sbid, devno);
 		return -ENODEV;
+	}
 
 	odi = osduld_device_info(sbi->layout.s_ods[devno]);
 
diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
index 01b0e53..12a3bda 100644
--- a/fs/exportfs/pnfs_osd_xdr_srv.c
+++ b/fs/exportfs/pnfs_osd_xdr_srv.c
@@ -43,12 +43,12 @@
 
 /*
  * struct pnfs_osd_data_map {
- * 	u32	odm_num_comps;
- * 	u64	odm_stripe_unit;
- * 	u32	odm_group_width;
- * 	u32	odm_group_depth;
- * 	u32	odm_mirror_cnt;
- * 	u32	odm_raid_algorithm;
+ *	u32	odm_num_comps;
+ *	u64	odm_stripe_unit;
+ *	u32	odm_group_width;
+ *	u32	odm_group_depth;
+ *	u32	odm_mirror_cnt;
+ *	u32	odm_raid_algorithm;
  * };
  */
 static enum nfsstat4 pnfs_osd_xdr_encode_data_map(
@@ -72,9 +72,9 @@ static enum nfsstat4 pnfs_osd_xdr_encode_data_map(
 
 /*
  * struct pnfs_osd_objid {
- * 	struct nfs4_deviceid	oid_device_id;
- * 	u64			oid_partition_id;
- * 	u64			oid_object_id;
+ *	struct nfs4_deviceid	oid_device_id;
+ *	u64			oid_partition_id;
+ *	u64			oid_object_id;
  * };
  */
 static inline enum nfsstat4 pnfs_osd_xdr_encode_objid(
@@ -98,16 +98,16 @@ static inline enum nfsstat4 pnfs_osd_xdr_encode_objid(
 
 /*
  * enum pnfs_osd_cap_key_sec4 {
- * 	PNFS_OSD_CAP_KEY_SEC_NONE = 0,
- * 	PNFS_OSD_CAP_KEY_SEC_SSV  = 1
+ *	PNFS_OSD_CAP_KEY_SEC_NONE = 0,
+ *	PNFS_OSD_CAP_KEY_SEC_SSV  = 1
  * };
  *
  * struct pnfs_osd_object_cred {
- * 	struct pnfs_osd_objid		oc_object_id;
- * 	u32				oc_osd_version;
- * 	u32				oc_cap_key_sec;
- * 	struct pnfs_osd_opaque_cred	oc_cap_key
- * 	struct pnfs_osd_opaque_cred	oc_cap;
+ *	struct pnfs_osd_objid		oc_object_id;
+ *	u32				oc_osd_version;
+ *	u32				oc_cap_key_sec;
+ *	struct pnfs_osd_opaque_cred	oc_cap_key
+ *	struct pnfs_osd_opaque_cred	oc_cap;
  * };
  */
 enum nfsstat4 pnfs_osd_xdr_encode_layout_cred(
@@ -140,10 +140,10 @@ EXPORT_SYMBOL(pnfs_osd_xdr_encode_layout_cred);
 
 /*
  * struct pnfs_osd_layout {
- * 	struct pnfs_osd_data_map	olo_map;
- * 	u32				olo_comps_index;
- * 	u32				olo_num_comps;
- * 	struct pnfs_osd_object_cred	*olo_comps;
+ *	struct pnfs_osd_data_map	olo_map;
+ *	u32				olo_comps_index;
+ *	u32				olo_num_comps;
+ *	struct pnfs_osd_object_cred	*olo_comps;
  * };
  */
 enum nfsstat4 pnfs_osd_xdr_encode_layout_hdr(
@@ -180,12 +180,12 @@ static enum nfsstat4 _encode_string(struct exp_xdr_stream *xdr,
 }
 
 /* struct pnfs_osd_deviceaddr {
- * 	struct pnfs_osd_targetid	oda_targetid;
- * 	struct pnfs_osd_targetaddr	oda_targetaddr;
- * 	u8				oda_lun[8];
- * 	struct nfs4_string		oda_systemid;
- * 	struct pnfs_osd_object_cred	oda_root_obj_cred;
- * 	struct nfs4_string		oda_osdname;
+ *	struct pnfs_osd_targetid	oda_targetid;
+ *	struct pnfs_osd_targetaddr	oda_targetaddr;
+ *	u8				oda_lun[8];
+ *	struct nfs4_string		oda_systemid;
+ *	struct pnfs_osd_object_cred	oda_root_obj_cred;
+ *	struct nfs4_string		oda_osdname;
  * };
  */
 enum nfsstat4 pnfs_osd_xdr_encode_deviceaddr(
@@ -226,9 +226,9 @@ EXPORT_SYMBOL(pnfs_osd_xdr_encode_deviceaddr);
 
 /*
  * struct pnfs_osd_layoutupdate {
- * 	u32	dsu_valid;
- * 	s64	dsu_delta;
- * 	u32	olu_ioerr_flag;
+ *	u32	dsu_valid;
+ *	s64	dsu_delta;
+ *	u32	olu_ioerr_flag;
  * };
  */
 __be32 *
@@ -244,9 +244,9 @@ EXPORT_SYMBOL(pnfs_osd_xdr_decode_layoutupdate);
 
 /*
  * struct pnfs_osd_objid {
- * 	struct nfs4_deviceid	oid_device_id;
- * 	u64			oid_partition_id;
- * 	u64			oid_object_id;
+ *	struct nfs4_deviceid	oid_device_id;
+ *	u64			oid_partition_id;
+ *	u64			oid_object_id;
  * }; xdr size 32
  */
 static inline __be32 *
@@ -263,11 +263,11 @@ pnfs_osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
 
 /*
  * struct pnfs_osd_ioerr {
- * 	struct pnfs_osd_objid	oer_component;
- * 	u64			oer_comp_offset;
- * 	u64			oer_comp_length;
- * 	u32			oer_iswrite;
- * 	u32			oer_errno;
+ *	struct pnfs_osd_objid	oer_component;
+ *	u64			oer_comp_offset;
+ *	u64			oer_comp_length;
+ *	u32			oer_iswrite;
+ *	u32			oer_errno;
  * }; xdr size 32 + 24
  */
 bool pnfs_osd_xdr_decode_ioerr(struct pnfs_osd_ioerr *ioerr,
diff --git a/include/linux/nfsd/pnfs_osd_xdr_srv.h b/include/linux/nfsd/pnfs_osd_xdr_srv.h
index 2909fbe..fab244e 100644
--- a/include/linux/nfsd/pnfs_osd_xdr_srv.h
+++ b/include/linux/nfsd/pnfs_osd_xdr_srv.h
@@ -30,7 +30,7 @@ enum nfsstat4 pnfs_osd_xdr_encode_deviceaddr(
 	struct exp_xdr_stream *xdr, struct pnfs_osd_deviceaddr *devaddr);
 
 /* layout_commit decoding */
-__be32 * pnfs_osd_xdr_decode_layoutupdate(
+__be32 *pnfs_osd_xdr_decode_layoutupdate(
 	struct pnfs_osd_layoutupdate *lou, __be32 *p);
 
 /* layout_return decoding */

