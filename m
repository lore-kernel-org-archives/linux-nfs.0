Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52093 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755041Ab0IRDSd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Sep 2010 23:18:33 -0400
Received: from localhost.localdomain (scher1-lxp.hq.netapp.com [10.58.61.44] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8I3IEV5012071
	for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 20:18:17 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/12] RFC: pnfsd, pnfs: protocol level pnfs constants
Date: Fri, 17 Sep 2010 23:17:45 -0400
Message-Id: <1284779874-10499-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1284779874-10499-1-git-send-email-iisaman@netapp.com>
References: <1284779874-10499-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Use only layoutreturn constant for both returns and recalls.
(return_* works better for recall_type rather the other way around)

Signed-off-by: TBD - melding/reorganization of several patches
---
 include/linux/nfs4.h |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 07e40c6..6798fc3 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -471,6 +471,8 @@ enum lock_type4 {
 #define FATTR4_WORD1_TIME_MODIFY        (1UL << 21)
 #define FATTR4_WORD1_TIME_MODIFY_SET    (1UL << 22)
 #define FATTR4_WORD1_MOUNTED_ON_FILEID  (1UL << 23)
+#define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
+#define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
 
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1
@@ -550,6 +552,43 @@ enum state_protect_how4 {
 	SP4_SSV		= 2
 };
 
+enum pnfs_layouttype {
+	LAYOUT_NFSV4_1_FILES  = 1,
+	LAYOUT_OSD2_OBJECTS = 2,
+	LAYOUT_BLOCK_VOLUME = 3,
+};
+
+/* used for both layout return and recall */
+enum pnfs_layoutreturn_type {
+	RETURN_FILE = 1,
+	RETURN_FSID = 2,
+	RETURN_ALL  = 3
+};
+
+enum pnfs_iomode {
+	IOMODE_READ = 1,
+	IOMODE_RW = 2,
+	IOMODE_ANY = 3,
+};
+
+enum pnfs_notify_deviceid_type4 {
+	NOTIFY_DEVICEID4_CHANGE = 1 << 1,
+	NOTIFY_DEVICEID4_DELETE = 1 << 2,
+};
+
+#define NFL4_UFLG_MASK			0x0000003F
+#define NFL4_UFLG_DENSE			0x00000001
+#define NFL4_UFLG_COMMIT_THRU_MDS	0x00000002
+#define NFL4_UFLG_STRIPE_UNIT_SIZE_MASK	0xFFFFFFC0
+
+/* Encoded in the loh_body field of type layouthint4 */
+enum filelayout_hint_care4 {
+	NFLH4_CARE_DENSE		= NFL4_UFLG_DENSE,
+	NFLH4_CARE_COMMIT_THRU_MDS	= NFL4_UFLG_COMMIT_THRU_MDS,
+	NFLH4_CARE_STRIPE_UNIT_SIZE	= 0x00000040,
+	NFLH4_CARE_STRIPE_COUNT		= 0x00000080
+};
+
 #endif
 #endif
 
-- 
1.7.2.1

