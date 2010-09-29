Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37089 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752536Ab0I2LJi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:09:38 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] SQUASHME: move nfs4_deviceid definitions to include/linux/nfs4.h
Date: Wed, 29 Sep 2010 13:09:36 +0200
Message-Id: <1285758576-26785-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These are pure protocol level constants
squash into "pnfs: add LAYOUTGET and GETDEVICEINFO infrastructure"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.h        |    6 ------
 include/linux/nfs4.h |    6 ++++++
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 97c3bc4..9500aa4 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -38,8 +38,6 @@ struct pnfs_layout_segment {
 	struct pnfs_layout_hdr *layout;
 };
 
-#define NFS4_DEVICEID4_SIZE 16
-
 enum pnfs_try_status {
 	PNFS_ATTEMPTED     = 0,
 	PNFS_NOT_ATTEMPTED = 1,
@@ -113,10 +111,6 @@ struct pnfs_layout_hdr {
 	struct inode		*inode;
 };
 
-struct nfs4_deviceid {
-	char data[NFS4_DEVICEID4_SIZE];
-};
-
 struct pnfs_device {
 	struct nfs4_deviceid dev_id;
 	unsigned int  layout_type;
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index ae99e4f..3d04746 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -613,6 +613,12 @@ enum filelayout_hint_care4 {
 	NFLH4_CARE_STRIPE_COUNT		= 0x00000080
 };
 
+#define NFS4_DEVICEID4_SIZE 16
+
+struct nfs4_deviceid {
+	char data[NFS4_DEVICEID4_SIZE];
+};
+
 #endif
 #endif
 
-- 
1.7.2.3

