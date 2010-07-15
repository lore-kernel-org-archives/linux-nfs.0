From: andros@netapp.com
Subject: [PATCH 2/4] SQUASHME pnfs-submit remove unused nfs4_filelayout fields
Date: Thu, 15 Jul 2010 12:33:48 -0400
Message-ID: <1279211630-6039-2-git-send-email-andros@netapp.com>
References: <1279211630-6039-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2923 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933715Ab0GOQd0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:33:26 -0400
In-Reply-To: <1279211630-6039-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index fd25e76..1de176d 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -69,9 +69,6 @@ struct nfs4_filelayout_segment {
 
 struct nfs4_filelayout {
 	struct pnfs_layout_type fl_layout;
-	int uncommitted_write;
-	loff_t last_commit_size;
-	u64 layout_id;
 	u32 stripe_unit;
 };
 
-- 
1.6.6

