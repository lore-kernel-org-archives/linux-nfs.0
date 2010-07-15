From: andros@netapp.com
Subject: [PATCH 1/7] SQUASHME pnfs-submit fix CONFIG_NFS_V4_1 not set compile error
Date: Thu, 15 Jul 2010 12:13:48 -0400
Message-ID: <1279210434-2772-2-git-send-email-andros@netapp.com>
References: <1279210434-2772-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7766 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933612Ab0GOQNp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:13:45 -0400
In-Reply-To: <1279210434-2772-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfs4_pnfs.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 9eebbdd..fe18143 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -84,6 +84,12 @@ layoutcommit_needed(struct nfs_inode *nfsi)
 #else /* CONFIG_NFS_V4_1 */
 
 static inline bool
+has_layout(struct nfs_inode *nfsi)
+{
+	return false; 
+}
+
+static inline bool
 layoutcommit_needed(struct nfs_inode *nfsi)
 {
 	return 0;
-- 
1.6.6

