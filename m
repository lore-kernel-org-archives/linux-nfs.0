Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:57977 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755717Ab2CPGWG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 02:22:06 -0400
Message-ID: <4F62DC04.4090603@panasas.com>
Date: Thu, 15 Mar 2012 23:21:56 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        "Bhamare, Sachin" <sbhamare@panasas.com>
CC: Benny Halevy <bhalevy@tonian.com>, Steve Dickson <steved@redhat.com>,
        "Welch, Brent" <welch@panasas.com>
Subject: [PATCH 2/4] pnfs-obj: Remove unused variable from objlayout_get_deviceinfo().
References: <4F62DADD.3010502@panasas.com>
In-Reply-To: <4F62DADD.3010502@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Sachin Bhamare <sbhamare@panasas.com>

Local variable 'sb' was not being used in objlayout_get_deviceinfo().

Signed-off-by: Sachin Bhamare <sbhamare@panasas.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index b3c2903..71047c9 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -601,7 +601,6 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 {
 	struct objlayout_deviceinfo *odi;
 	struct pnfs_device pd;
-	struct super_block *sb;
 	struct page *page, **pages;
 	u32 *p;
 	int err;
@@ -620,7 +619,6 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 	pd.pglen = PAGE_SIZE;
 	pd.mincount = 0;
 
-	sb = pnfslay->plh_inode->i_sb;
 	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd);
 	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
 	if (err)
-- 
1.7.6.2


