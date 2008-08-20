From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Reserve NFS fileid values for btrfs
Date: Wed, 20 Aug 2008 14:58:23 +0100
Message-ID: <1219240703.2988.152.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, btrfs-devel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:41551 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbYHTN6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2008 09:58:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

---
Purely cosmetic for now, but we might as well get it merged ASAP.

diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index f5abd13..27e772c 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -35,6 +35,27 @@ enum fid_type {
 	FILEID_INO32_GEN_PARENT = 2,
 
 	/*
+	 * 64 bit object ID, 64 bit root object ID,
+	 * 32 bit generation number.
+	 */
+	FILEID_BTRFS_WITHOUT_PARENT = 0x4d,
+
+	/*
+	 * 64 bit object ID, 64 bit root object ID,
+	 * 32 bit generation number,
+	 * 64 bit parent object ID, 32 bit parent generation.
+	 */
+	FILEID_BTRFS_WITH_PARENT = 0x4e,
+
+	/*
+	 * 64 bit object ID, 64 bit root object ID,
+	 * 32 bit generation number,
+	 * 64 bit parent object ID, 32 bit parent generation,
+	 * 64 bit parent root object ID.
+	 */
+	FILEID_BTRFS_WITH_PARENT_ROOT = 0x4f,
+
+	/*
 	 * 32 bit block number, 16 bit partition reference,
 	 * 16 bit unused, 32 bit generation number.
 	 */


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



