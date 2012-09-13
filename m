Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36152 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab2IMXiS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:38:18 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
CC: Sachin Bhamare <sbhamare@panasas.com>
Subject: [PATCH 08/10] SQUASHME: pnfsd-exofs: Autologin XDR also encode URI in device_info
Date: Fri, 14 Sep 2012 02:38:06 +0300
Message-ID: <1347579486-21684-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <50526B39.3000802@panasas.com>
References: <50526B39.3000802@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Sachin Bhamare <sbhamare@panasas.com>

Add the missing bits to encode the autologin info strings

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exportfs/pnfs_osd_xdr_srv.c | 45 +++++++++++++++++++++++++++++++++++++++---
 include/linux/pnfs_osd_xdr.h   |  5 +++++
 2 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
index 35b3d32..04a3681 100644
--- a/fs/exportfs/pnfs_osd_xdr_srv.c
+++ b/fs/exportfs/pnfs_osd_xdr_srv.c
@@ -178,6 +178,42 @@ static enum nfsstat4 _encode_string(struct exp_xdr_stream *xdr,
 	return 0;
 }
 
+/* struct pnfs_osd_targetaddr {
+ *	u32				ota_available;
+ *	struct pnfs_osd_net_addr	ota_netaddr;
+ * };
+ */
+static inline enum nfsstat4 pnfs_osd_xdr_encode_targetaddr(
+	struct exp_xdr_stream *xdr,
+	struct pnfs_osd_targetaddr *taddr)
+{
+	__be32 *p;
+
+	/* ota_available */
+	p = exp_xdr_reserve_space(xdr, 4);
+	if (!p)
+		return NFS4ERR_TOOSMALL;
+	p = exp_xdr_encode_u32(p, taddr->ota_available);
+
+	/* encode r_netid */
+	p = exp_xdr_reserve_space(xdr, 4 + taddr->ota_netaddr.r_netid.len);
+	if (!p)
+		return NFS4ERR_TOOSMALL;
+
+	p = exp_xdr_encode_opaque(p,
+				taddr->ota_netaddr.r_netid.data,
+				taddr->ota_netaddr.r_netid.len);
+
+	/* encode r_addr */
+	p = exp_xdr_reserve_space(xdr, 4 + taddr->ota_netaddr.r_addr.len);
+	if (!p)
+		return NFS4ERR_TOOSMALL;
+	p = exp_xdr_encode_opaque(p,
+				taddr->ota_netaddr.r_addr.data,
+				taddr->ota_netaddr.r_addr.len);
+	return 0;
+}
+
 /* struct pnfs_osd_deviceaddr {
  *	struct pnfs_osd_targetid	oda_targetid;
  *	struct pnfs_osd_targetaddr	oda_targetaddr;
@@ -193,17 +229,20 @@ enum nfsstat4 pnfs_osd_xdr_encode_deviceaddr(
 	__be32 *p;
 	enum nfsstat4 err;
 
-	p = exp_xdr_reserve_space(xdr, 4 + 4 + sizeof(devaddr->oda_lun));
+	p = exp_xdr_reserve_space(xdr, sizeof(u32));
 	if (!p)
 		return NFS4ERR_TOOSMALL;
 
 	/* Empty oda_targetid */
 	p = exp_xdr_encode_u32(p, OBJ_TARGET_ANON);
 
-	/* Empty oda_targetaddr for now */
-	p = exp_xdr_encode_u32(p, 0);
+	/* oda_targetaddr */
+	err = pnfs_osd_xdr_encode_targetaddr(xdr, &devaddr->oda_targetaddr);
+	if (err)
+		return err;
 
 	/* oda_lun */
+	p = exp_xdr_reserve_space(xdr, sizeof(devaddr->oda_lun));
 	exp_xdr_encode_bytes(p, devaddr->oda_lun, sizeof(devaddr->oda_lun));
 
 	err = _encode_string(xdr, &devaddr->oda_systemid);
diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index 435dd5f..3aab6e2 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -148,6 +148,11 @@ enum pnfs_osd_targetid_type {
 	OBJ_TARGET_SCSI_DEVICE_ID = 3,
 };
 
+enum pnfs_osd_target_ota {
+	OBJ_OTA_UNAVAILABLE = 0,
+	OBJ_OTA_AVAILABLE = 1,
+};
+
 /*   union pnfs_osd_targetid4 switch (pnfs_osd_targetid_type4 oti_type) {
  *       case OBJ_TARGET_SCSI_NAME:
  *           string              oti_scsi_name<>;
-- 
1.7.10.2.677.gb6bc67f

