Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30725 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756117Ab0JOGRk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 02:17:40 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/12] RFC: pnfsd, pnfs: protocol level pnfs constants
Date: Sun, 10 Oct 2010 11:22:44 -0400
Message-Id: <1286724173-8493-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
References: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Use only layoutreturn constant for both returns and recalls.
(return_* works better for recall_type rather the other way around)

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 include/linux/nfs4.h |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 07e40c6..6c0406e 100644
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
@@ -550,6 +552,49 @@ enum state_protect_how4 {
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
+#define NFS4_DEVICEID4_SIZE 16
+
+struct nfs4_deviceid {
+	char data[NFS4_DEVICEID4_SIZE];
+};
+
 #endif
 #endif
 
-- 
1.7.2.1

