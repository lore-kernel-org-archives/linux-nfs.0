Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:40448 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727575AbeIEX4r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 19:56:47 -0400
Received: by mail-it0-f65.google.com with SMTP id h23-v6so10963593ita.5
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 12:25:12 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id x198-v6sm1459928ite.19.2018.09.05.12.25.11
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 12:25:11 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/7] pNFS: Don't allocate more pages than we need to fit a layoutget response
Date: Wed,  5 Sep 2018 15:23:55 -0400
Message-Id: <20180905192400.107485-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905192400.107485-2-trond.myklebust@hammerspace.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <20180905192400.107485-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For the 'files' and 'flexfiles' layout types, we do not expect the reply
to be any larger than 4k. The block and scsi layout types are a little more
greedy, so we keep allocating the maximum response size for now.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/filelayout/filelayout.c         | 1 +
 fs/nfs/flexfilelayout/flexfilelayout.c | 1 +
 fs/nfs/pnfs.c                          | 7 +++++++
 fs/nfs/pnfs.h                          | 1 +
 4 files changed, 10 insertions(+)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index d175724ff566..61f46facb39c 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1164,6 +1164,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.id			= LAYOUT_NFSV4_1_FILES,
 	.name			= "LAYOUT_NFSV4_1_FILES",
 	.owner			= THIS_MODULE,
+	.max_layoutget_response	= 4096, /* 1 page or so... */
 	.alloc_layout_hdr	= filelayout_alloc_layout_hdr,
 	.free_layout_hdr	= filelayout_free_layout_hdr,
 	.alloc_lseg		= filelayout_alloc_lseg,
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index cae43333ef16..86bcba40ca61 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2356,6 +2356,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.name			= "LAYOUT_FLEX_FILES",
 	.owner			= THIS_MODULE,
 	.flags			= PNFS_LAYOUTGET_ON_OPEN,
+	.max_layoutget_response	= 4096, /* 1 page or so... */
 	.set_layoutdriver	= ff_layout_set_layoutdriver,
 	.alloc_layout_hdr	= ff_layout_alloc_layout_hdr,
 	.free_layout_hdr	= ff_layout_free_layout_hdr,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6b5b2d36f502..c5672c02afd6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -991,6 +991,7 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 	   gfp_t gfp_flags)
 {
 	struct nfs_server *server = pnfs_find_server(ino, ctx);
+	size_t max_reply_sz = server->pnfs_curr_ld->max_layoutget_response;
 	size_t max_pages = max_response_pages(server);
 	struct nfs4_layoutget *lgp;
 
@@ -1000,6 +1001,12 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 	if (lgp == NULL)
 		return NULL;
 
+	if (max_reply_sz) {
+		size_t npages = (max_reply_sz + PAGE_SIZE - 1) >> PAGE_SHIFT;
+		if (npages < max_pages)
+			max_pages = npages;
+	}
+
 	lgp->args.layout.pages = nfs4_alloc_pages(max_pages, gfp_flags);
 	if (!lgp->args.layout.pages) {
 		kfree(lgp);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index ece367ebde69..e2e9fcd5341d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -125,6 +125,7 @@ struct pnfs_layoutdriver_type {
 	struct module *owner;
 	unsigned flags;
 	unsigned max_deviceinfo_size;
+	unsigned max_layoutget_response;
 
 	int (*set_layoutdriver) (struct nfs_server *, const struct nfs_fh *);
 	int (*clear_layoutdriver) (struct nfs_server *);
-- 
2.17.1
