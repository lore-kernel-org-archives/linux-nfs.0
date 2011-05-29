Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44758 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab1E2IG6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 04:06:58 -0400
Message-ID: <4DE1FE9B.9000109@panasas.com>
Date: Sun, 29 May 2011 11:06:51 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: into NFSv4.1: purge deviceid cache - let ver <
 4.1 compile
References: <4DDD7392.6040505@panasas.com> <1306358821-16967-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306358821-16967-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


In C parameter names cannot be omitted from function implementation

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 020be34..48d0a8e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -415,7 +415,7 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	return 0;
 }
 
-static inline void nfs4_deviceid_purge_client(struct nfs_client *)
+static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
 {
 }
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.7.2.3


