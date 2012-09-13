Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36163 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759055Ab2IMXis (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:38:48 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
CC: Sachin Bhamare <sbhamare@panasas.com>
Subject: [PATCH 09/10] SQUASHME: pnfsd-exofs: Autologin support to get_device_info
Date: Fri, 14 Sep 2012 02:38:36 +0300
Message-ID: <1347579516-21717-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <50526B39.3000802@panasas.com>
References: <50526B39.3000802@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Sachin Bhamare <sbhamare@panasas.com>

In exofs_get_device_info also send the URI string set by the
user-mode mounter associated with each device, to enable
autologin in the client.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 809fa19..c5712f3 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -324,6 +324,7 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 {
 	struct exofs_sb_info *sbi = sb->s_fs_info;
 	struct pnfs_osd_deviceaddr devaddr;
+	struct exofs_dev *edev;
 	const struct osd_dev_info *odi;
 	u64 devno = devid->devid;
 	__be32 *start;
@@ -337,7 +338,8 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 		return -ENODEV;
 	}
 
-	odi = osduld_device_info(sbi->oc.ods[devno]->od);
+	edev = container_of(sbi->oc.ods[devno], typeof(*edev), ored);
+	odi = osduld_device_info(edev->ored.od);
 
 	devaddr.oda_systemid.len = odi->systemid_len;
 	devaddr.oda_systemid.data = (void *)odi->systemid; /* !const cast */
@@ -345,6 +347,10 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 	devaddr.oda_osdname.len = odi->osdname_len ;
 	devaddr.oda_osdname.data = (void *)odi->osdname;/* !const cast */
 
+	devaddr.oda_targetaddr.ota_available = OBJ_OTA_AVAILABLE;
+	devaddr.oda_targetaddr.ota_netaddr.r_addr.data = (void *)edev->uri;
+	devaddr.oda_targetaddr.ota_netaddr.r_addr.len = edev->urilen;
+
 	/* skip opaque size, will be filled-in later */
 	start = exp_xdr_reserve_qwords(xdr, 1);
 	if (!start) {
-- 
1.7.10.2.677.gb6bc67f

