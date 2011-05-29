Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45997 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab1E2KaF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 06:30:05 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 1/8] SQUASHME: into NFSv4.1: purge deviceid cache - let ver < 4.1 compile
Date: Sun, 29 May 2011 13:29:54 +0300
Message-Id: <1306664994-971-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE21CD5.8070907@panasas.com>
References: <4DE21CD5.8070907@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

In C parameter names cannot be omitted from function implementation

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9667a62..80a5d0e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -357,7 +357,7 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	return 0;
 }
 
-static inline void nfs4_deviceid_purge_client(struct nfs_client *)
+static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
 {
 }
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.7.2.3

