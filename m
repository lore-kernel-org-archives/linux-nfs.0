Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35923 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032Ab2IMXeX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:34:23 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 02/10] Revert "pnfsd-exofs: Add autologin support to exofs"
Date: Fri, 14 Sep 2012 02:34:11 +0300
Message-ID: <1347579251-21479-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <50526B39.3000802@panasas.com>
References: <50526B39.3000802@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 0157f33be71f4607021c595743e5454031319111.
In Benny's tree needs better versions

Boaz
---
 fs/exofs/export.c              |  8 +-------
 fs/exportfs/pnfs_osd_xdr_srv.c | 45 +++---------------------------------------
 include/linux/pnfs_osd_xdr.h   |  5 -----
 3 files changed, 4 insertions(+), 54 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index a53f575..621bd11 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -321,7 +321,6 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 {
 	struct exofs_sb_info *sbi = sb->s_fs_info;
 	struct pnfs_osd_deviceaddr devaddr;
-	struct exofs_dev *edev;
 	const struct osd_dev_info *odi;
 	u64 devno = devid->devid;
 	__be32 *start;
@@ -335,8 +334,7 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 		return -ENODEV;
 	}
 
-	edev = container_of(sbi->oc.ods[devno], typeof(*edev), ored);
-	odi = osduld_device_info(edev->ored.od);
+	odi = osduld_device_info(sbi->oc.ods[devno]->od);
 
 	devaddr.oda_systemid.len = odi->systemid_len;
 	devaddr.oda_systemid.data = (void *)odi->systemid; /* !const cast */
@@ -344,10 +342,6 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 	devaddr.oda_osdname.len = odi->osdname_len ;
 	devaddr.oda_osdname.data = (void *)odi->osdname;/* !const cast */
 
-	devaddr.oda_targetaddr.ota_available = OBJ_OTA_AVAILABLE;
-	devaddr.oda_targetaddr.ota_netaddr.r_addr.data = (void *)edev->uri;
-	devaddr.oda_targetaddr.ota_netaddr.r_addr.len = edev->urilen;
-
 	/* skip opaque size, will be filled-in later */
 	start = exp_xdr_reserve_qwords(xdr, 1);
 	if (!start) {
diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
index 04a3681..35b3d32 100644
--- a/fs/exportfs/pnfs_osd_xdr_srv.c
+++ b/fs/exportfs/pnfs_osd_xdr_srv.c
@@ -178,42 +178,6 @@ static enum nfsstat4 _encode_string(struct exp_xdr_stream *xdr,
 	return 0;
 }
 
-/* struct pnfs_osd_targetaddr {
- *	u32				ota_available;
- *	struct pnfs_osd_net_addr	ota_netaddr;
- * };
- */
-static inline enum nfsstat4 pnfs_osd_xdr_encode_targetaddr(
-	struct exp_xdr_stream *xdr,
-	struct pnfs_osd_targetaddr *taddr)
-{
-	__be32 *p;
-
-	/* ota_available */
-	p = exp_xdr_reserve_space(xdr, 4);
-	if (!p)
-		return NFS4ERR_TOOSMALL;
-	p = exp_xdr_encode_u32(p, taddr->ota_available);
-
-	/* encode r_netid */
-	p = exp_xdr_reserve_space(xdr, 4 + taddr->ota_netaddr.r_netid.len);
-	if (!p)
-		return NFS4ERR_TOOSMALL;
-
-	p = exp_xdr_encode_opaque(p,
-				taddr->ota_netaddr.r_netid.data,
-				taddr->ota_netaddr.r_netid.len);
-
-	/* encode r_addr */
-	p = exp_xdr_reserve_space(xdr, 4 + taddr->ota_netaddr.r_addr.len);
-	if (!p)
-		return NFS4ERR_TOOSMALL;
-	p = exp_xdr_encode_opaque(p,
-				taddr->ota_netaddr.r_addr.data,
-				taddr->ota_netaddr.r_addr.len);
-	return 0;
-}
-
 /* struct pnfs_osd_deviceaddr {
  *	struct pnfs_osd_targetid	oda_targetid;
  *	struct pnfs_osd_targetaddr	oda_targetaddr;
@@ -229,20 +193,17 @@ enum nfsstat4 pnfs_osd_xdr_encode_deviceaddr(
 	__be32 *p;
 	enum nfsstat4 err;
 
-	p = exp_xdr_reserve_space(xdr, sizeof(u32));
+	p = exp_xdr_reserve_space(xdr, 4 + 4 + sizeof(devaddr->oda_lun));
 	if (!p)
 		return NFS4ERR_TOOSMALL;
 
 	/* Empty oda_targetid */
 	p = exp_xdr_encode_u32(p, OBJ_TARGET_ANON);
 
-	/* oda_targetaddr */
-	err = pnfs_osd_xdr_encode_targetaddr(xdr, &devaddr->oda_targetaddr);
-	if (err)
-		return err;
+	/* Empty oda_targetaddr for now */
+	p = exp_xdr_encode_u32(p, 0);
 
 	/* oda_lun */
-	p = exp_xdr_reserve_space(xdr, sizeof(devaddr->oda_lun));
 	exp_xdr_encode_bytes(p, devaddr->oda_lun, sizeof(devaddr->oda_lun));
 
 	err = _encode_string(xdr, &devaddr->oda_systemid);
diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index 3aab6e2..435dd5f 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -148,11 +148,6 @@ enum pnfs_osd_targetid_type {
 	OBJ_TARGET_SCSI_DEVICE_ID = 3,
 };
 
-enum pnfs_osd_target_ota {
-	OBJ_OTA_UNAVAILABLE = 0,
-	OBJ_OTA_AVAILABLE = 1,
-};
-
 /*   union pnfs_osd_targetid4 switch (pnfs_osd_targetid_type4 oti_type) {
  *       case OBJ_TARGET_SCSI_NAME:
  *           string              oti_scsi_name<>;
-- 
1.7.10.2.677.gb6bc67f

