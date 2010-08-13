Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45275 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754424Ab0HMVdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:33:21 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 49/50] SQUASHME pnfs_post_submit: cb notify deviceid declarations
Date: Fri, 13 Aug 2010 17:32:01 -0400
Message-Id: <1281735122-1496-50-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-49-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
 <1281735122-1496-34-git-send-email-andros@netapp.com>
 <1281735122-1496-35-git-send-email-andros@netapp.com>
 <1281735122-1496-36-git-send-email-andros@netapp.com>
 <1281735122-1496-37-git-send-email-andros@netapp.com>
 <1281735122-1496-38-git-send-email-andros@netapp.com>
 <1281735122-1496-39-git-send-email-andros@netapp.com>
 <1281735122-1496-40-git-send-email-andros@netapp.com>
 <1281735122-1496-41-git-send-email-andros@netapp.com>
 <1281735122-1496-42-git-send-email-andros@netapp.com>
 <1281735122-1496-43-git-send-email-andros@netapp.com>
 <1281735122-1496-44-git-send-email-andros@netapp.com>
 <1281735122-1496-45-git-send-email-andros@netapp.com>
 <1281735122-1496-46-git-send-email-andros@netapp.com>
 <1281735122-1496-47-git-send-email-andros@netapp.com>
 <1281735122-1496-48-git-send-email-andros@netapp.com>
 <1281735122-1496-49-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.h    |   17 +++++++++++++++++
 include/linux/nfs4.h |    5 +++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index ab9b421..b39ac86 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -152,6 +152,23 @@ struct cb_pnfs_layoutrecallargs {
 extern unsigned pnfs_cb_layoutrecall(struct cb_pnfs_layoutrecallargs *args,
 				     void *dummy);
 
+struct cb_pnfs_devicenotifyitem {
+	uint32_t		cbd_notify_type;
+	uint32_t		cbd_layout_type;
+	struct pnfs_deviceid	cbd_dev_id;
+	uint32_t		cbd_immediate;
+};
+
+/* XXX: Should be dynamic up to max compound size */
+#define NFS4_DEV_NOTIFY_MAXENTRIES 10
+struct cb_pnfs_devicenotifyargs {
+	struct sockaddr			*addr;
+	int				 ndevs;
+	struct cb_pnfs_devicenotifyitem	 devs[NFS4_DEV_NOTIFY_MAXENTRIES];
+};
+
+extern unsigned pnfs_cb_devicenotify(struct cb_pnfs_devicenotifyargs *args,
+				     void *dummy);
 #endif /* CONFIG_NFS_V4_1 */
 
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 2d3d277..e947a32 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -596,6 +596,11 @@ enum pnfs_iomode {
 	IOMODE_ANY = 3,
 };
 
+enum pnfs_notify_deviceid_type4 {
+	NOTIFY_DEVICEID4_CHANGE = 1 << 1,
+	NOTIFY_DEVICEID4_DELETE = 1 << 2,
+};
+
 #define NFL4_UFLG_MASK			0x0000003F
 #define NFL4_UFLG_DENSE			0x00000001
 #define NFL4_UFLG_COMMIT_THRU_MDS	0x00000002
-- 
1.6.2.5

