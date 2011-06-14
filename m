Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36604 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928Ab1FNVDc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:03:32 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 6/8] pnfsd-exofs: get_device_info implementation.
Date: Tue, 14 Jun 2011 17:03:31 -0400
Message-Id: <1308085411-12630-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7CA2F.7030407@panasas.com>
References: <4DF7CA2F.7030407@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Implement a .get_device_info operation from the
pnfs_export_operations.

Retrieve to system_id and osdname for the requested
devices.

TODO: Return also UNC hints for the device login
information.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   54 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 0a068b7..23c1666 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -185,11 +185,65 @@ static int exofs_layout_return(
 	return 0;
 }
 
+int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
+			  u32 layout_type,
+			  const struct nfsd4_pnfs_deviceid *devid)
+{
+	struct exofs_sb_info *sbi = sb->s_fs_info;
+	struct pnfs_osd_deviceaddr devaddr;
+	const struct osd_dev_info *odi;
+	u64 devno = devid->devid;
+	__be32 *start;
+	int err;
+
+	memset(&devaddr, 0, sizeof(devaddr));
+
+	if (unlikely(devno >= sbi->layout.s_numdevs)) {
+		EXOFS_DBGMSG("Error: Device((%llx,%llx) does not exist\n",
+			     devid->sbid, devno);
+		return -ENODEV;
+	}
+
+	odi = osduld_device_info(sbi->layout.s_ods[devno]);
+
+	devaddr.oda_systemid.len = odi->systemid_len;
+	devaddr.oda_systemid.data = (void *)odi->systemid; /* !const cast */
+
+	devaddr.oda_osdname.len = odi->osdname_len ;
+	devaddr.oda_osdname.data = (void *)odi->osdname;/* !const cast */
+
+	/* skip opaque size, will be filled-in later */
+	start = exp_xdr_reserve_qwords(xdr, 1);
+	if (!start) {
+		err = -ETOOSMALL;
+		goto err;
+	}
+
+	err = pnfs_osd_xdr_encode_deviceaddr(xdr, &devaddr);
+	if (err) {
+		err = -ETOOSMALL;
+		goto err;
+	}
+
+	exp_xdr_encode_opaque_len(start, xdr->p);
+
+	EXOFS_DBGMSG("xdr_bytes=%Zu devid=(%llx,%llx) osdname-%s\n",
+		     exp_xdr_qbytes(xdr->p - start), devid->sbid, devno,
+		     odi->osdname);
+	return 0;
+
+err:
+	EXOFS_DBGMSG("Error: err=%d at_byte=%zu\n",
+		     err, exp_xdr_qbytes(xdr->p - start));
+	return err;
+}
+
 struct pnfs_export_operations exofs_pnfs_ops = {
 	.layout_type	= exofs_layout_type,
 	.layout_get	= exofs_layout_get,
 	.layout_commit	= exofs_layout_commit,
 	.layout_return	= exofs_layout_return,
+	.get_device_info = exofs_get_device_info,
 };
 
 void exofs_init_export(struct super_block *sb)
-- 
1.7.3.4

