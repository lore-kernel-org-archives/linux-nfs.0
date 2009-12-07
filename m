From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 03/35] pnfsd, pnfs: protocol level pnfs constants
Date: Mon,  7 Dec 2009 11:30:24 +0200
Message-ID: <1260178224-14745-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Fred Isaman <iisaman@citi.umich.edu>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:55803 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759062AbZLGJ32 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:29:28 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[extracted from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: update pNFS server ops to draft 13]
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: Move getdeviceinfo to draft-19 on client] [for NOTIFY_DEVICEID4_* defs]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: pnfs_notify_deviceid_type4 should define bitmasks not offsets]
    The notify_deviceid_type4 values in the spec denote bit offsets, not
    bitmask values.  Since we use these constants as bitmasks, just define them
    this way.
[removed LAYOUT_PVFS2's definition]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[compile fixes for pnfs branch]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[removed #ifdef CONFIG_PNFS{,D}]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs4.h |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c4c0602..a899cff 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -469,6 +469,8 @@ enum lock_type4 {
 #define FATTR4_WORD1_TIME_MODIFY        (1UL << 21)
 #define FATTR4_WORD1_TIME_MODIFY_SET    (1UL << 22)
 #define FATTR4_WORD1_MOUNTED_ON_FILEID  (1UL << 23)
+#define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
+#define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
 
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1
@@ -546,6 +548,49 @@ enum state_protect_how4 {
 	SP4_SSV		= 2
 };
 
+enum pnfs_layouttype {
+	LAYOUT_NFSV4_FILES  = 1,
+	LAYOUT_OSD2_OBJECTS = 2,
+	LAYOUT_BLOCK_VOLUME = 3,
+};
+
+/* FIXME: should recall and return types be combined? */
+enum pnfs_layoutrecall_type {
+	RECALL_FILE = 1,
+	RECALL_FSID = 2,
+	RECALL_ALL  = 3
+};
+
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
1.6.5.1

