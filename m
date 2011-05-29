Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44789 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab1E2IKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 04:10:42 -0400
Message-ID: <4DE1FF7D.7000403@panasas.com>
Date: Sun, 29 May 2011 11:10:37 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2] SQUASHME: Fix BUG in: NFSv4.1: unify pnfs_pageio_init
 functions
References: <4DDD7392.6040505@panasas.com> <1306358998-17872-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306358998-17872-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The call to pnfs_pageio_init() was done before the call
to nfs_pageio_init which would override the .pg_test set
there.

But enough is enough. One init function is more than
enough. Call pnfs_pageio_init() from within the
nfs_pageio_init(). It is kept separate so the code can
compile in ver < 4.1, where the layout_driver type is not
defined

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pagelist.c |    1 +
 fs/nfs/pnfs.c     |    2 +-
 fs/nfs/pnfs.h     |    6 ++++--
 fs/nfs/read.c     |    1 -
 fs/nfs/write.c    |    1 -
 5 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index dbf82ab..624ec2c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -245,6 +245,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
 	desc->pg_test = nfs_generic_pg_test;
+	pnfs_pageio_init(desc, inode);
 }
 
 /**
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8171212..d79f2df 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1058,7 +1058,7 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		access_type = IOMODE_RW;
 		gfp_flags = GFP_NOFS;
 	}
-		
+
 	if (pgio->pg_count == prev->wb_bytes) {
 		/* This is first coelesce call for a series of nfs_pages */
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a279969..020be34 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -292,7 +292,8 @@ static inline int pnfs_return_layout(struct inode *ino)
 	return 0;
 }
 
-static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio, struct inode *inode)
+static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio,
+				    struct inode *inode)
 {
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 
@@ -383,7 +384,8 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 {
 }
 
-static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *, struct inode *)
+static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio,
+				    struct inode *inode)
 {
 }
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 6bd09a8..20a7f95 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -664,7 +664,6 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	pnfs_pageio_init(&pgio, inode);
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d81c5c0..e268e3b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1036,7 +1036,6 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
-	pnfs_pageio_init(pgio, inode);
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
 	else
-- 
1.7.2.3


