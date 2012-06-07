Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35108 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795Ab2FGPmP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jun 2012 11:42:15 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] NFS4: Fix open bug when pnfs module blacklisted
Date: Thu,  7 Jun 2012 11:42:12 -0400
Message-Id: <1339083732-20119-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 29fd23c..64f90d8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -365,7 +365,7 @@ static inline bool
 pnfs_use_threshold(struct nfs4_threshold **dst, struct nfs4_threshold *src,
 		   struct nfs_server *nfss)
 {
-	return (dst && src && src->bm != 0 &&
+	return (dst && src && src->bm != 0 && nfss->pnfs_curr_ld &&
 					nfss->pnfs_curr_ld->id == src->l_type);
 }
 
-- 
1.7.2.1

