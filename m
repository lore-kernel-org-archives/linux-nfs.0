Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailrelay010.isp.belgacom.be ([195.238.6.177]:7156 "EHLO
	mailrelay010.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757671AbaFYS0a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 14:26:30 -0400
From: Fabian Frederick <fabf@skynet.be>
To: linux-kernel@vger.kernel.org
Cc: Fabian Frederick <fabf@skynet.be>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] FS/NFS: replace count*size kzalloc by kcalloc
Date: Wed, 25 Jun 2014 20:26:21 +0200
Message-Id: <1403720781-19319-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kcalloc manages count*sizeof overflow.

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 fs/nfs/blocklayout/blocklayout.c  | 2 +-
 fs/nfs/filelayout/filelayoutdev.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9b431f4..b74d889 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1063,7 +1063,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	pages = kzalloc(max_pages * sizeof(struct page *), GFP_NOFS);
+	pages = kcalloc(max_pages, sizeof(struct page *), GFP_NOFS);
 	if (pages == NULL) {
 		kfree(dev);
 		return ERR_PTR(-ENOMEM);
diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 44bf014..48f8dcd 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -695,7 +695,7 @@ filelayout_get_device_info(struct inode *inode,
 	if (pdev == NULL)
 		return NULL;
 
-	pages = kzalloc(max_pages * sizeof(struct page *), gfp_flags);
+	pages = kcalloc(max_pages, sizeof(struct page *), gfp_flags);
 	if (pages == NULL) {
 		kfree(pdev);
 		return NULL;
-- 
1.9.1

