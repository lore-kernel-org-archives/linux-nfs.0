From: andros@netapp.com
Subject: [PATCH 5/5] SQUASHME pnfs-submit fix has_layout compile error
Date: Tue, 20 Jul 2010 13:01:23 -0400
Message-ID: <1279645283-9862-6-git-send-email-andros@netapp.com>
References: <1279645283-9862-1-git-send-email-andros@netapp.com>
 <1279645283-9862-2-git-send-email-andros@netapp.com>
 <1279645283-9862-3-git-send-email-andros@netapp.com>
 <1279645283-9862-4-git-send-email-andros@netapp.com>
 <1279645283-9862-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33652 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761395Ab0GTRCE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 13:02:04 -0400
In-Reply-To: <1279645283-9862-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfs4_pnfs.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index a2239a5..b0c2b0a 100644
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

