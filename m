Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54611 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227Ab0LOQDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 11:03:23 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBFG3Los001580
	for <linux-nfs@vger.kernel.org>; Wed, 15 Dec 2010 08:03:23 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/11] wave 2: remove pnfs_ld_layoutret_on_setattr()
Date: Wed, 15 Dec 2010 11:03:03 -0500
Message-Id: <1292428991-30788-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
References: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dead code.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c413954..f77a35b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -336,12 +336,6 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
 }
 
 static inline bool
-pnfs_ld_layoutret_on_setattr(struct inode *inode)
-{
-	return false;
-}
-
-static inline bool
 pnfs_roc(struct inode *ino)
 {
 	return false;
-- 
1.7.2.1

