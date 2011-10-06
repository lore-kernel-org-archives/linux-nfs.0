Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54426 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756359Ab1JFM3D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Oct 2011 08:29:03 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 4/5] SQUASHME: pnfsd-exofs: Type & Name of the devices array changed
Date: Thu, 6 Oct 2011 14:28:53 +0200
Message-ID: <1317904133-17386-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8D9D56.6020803@panasas.com>
References: <4E8D9D56.6020803@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do to patch:
    	exofs: Rename struct ore_components comps => oc
   Fix it here as well.

Do to patch:
	ore/exofs: Change the type of the devices array (API change)

  * Comply with the API change of the ore_components device table
    type.
  * Use the container_of macro to access the extra exofs device info.
    .e.g the device_id

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 42d21c0..f85197e 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -133,14 +133,14 @@ static enum nfsstat4 exofs_layout_get(
 	/* Encode layout components */
 	for (i = 0; i <  layout.olo_num_comps; i++) {
 		struct pnfs_osd_object_cred cred;
-		unsigned sbi_dev = (oi->comps.ods - sbi->comps.ods + i) %
-							sbi->comps.numdevs;
+		struct exofs_dev *ed = container_of(oi->oc.ods[i],
+							typeof(*ed), ored);
 
 		set_dev_id(&cred.oc_object_id.oid_device_id, args->lg_sbid,
-			   sbi_dev);
+			   ed->did);
 		cred.oc_object_id.oid_partition_id = oi->one_comp.obj.partition;
 		cred.oc_object_id.oid_object_id = oi->one_comp.obj.id;
-		cred.oc_osd_version = osd_dev_is_ver1(oi->comps.ods[i]) ?
+		cred.oc_osd_version = osd_dev_is_ver1(ed->ored.od) ?
 						PNFS_OSD_VERSION_1 :
 						PNFS_OSD_VERSION_2;
 		cred.oc_cap_key_sec = PNFS_OSD_CAP_KEY_SEC_NONE;
@@ -309,13 +309,13 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 
 	memset(&devaddr, 0, sizeof(devaddr));
 
-	if (unlikely(devno >= sbi->comps.numdevs)) {
+	if (unlikely(devno >= sbi->oc.numdevs)) {
 		EXOFS_DBGMSG("Error: Device((%llx,%llx) does not exist\n",
 			     devid->sbid, devno);
 		return -ENODEV;
 	}
 
-	odi = osduld_device_info(sbi->comps.ods[devno]);
+	odi = osduld_device_info(sbi->oc.ods[devno]->od);
 
 	devaddr.oda_systemid.len = odi->systemid_len;
 	devaddr.oda_systemid.data = (void *)odi->systemid; /* !const cast */
-- 
1.7.2.3

