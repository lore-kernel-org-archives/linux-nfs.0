Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55428 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754281Ab1GLTaI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 15:30:08 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/8] NFS: Use the nfs_pageio_descriptor->pg_bsize in the read/write request
Date: Tue, 12 Jul 2011 15:29:50 -0400
Message-Id: <1310498994-12685-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1310498994-12685-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-3-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Instead of looking up the rsize and wsize, the routines that generate the
RPC requests should really be using the pg_bsize, since that is what we
use when deciding whether or not to coalesce write requests...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/read.c  |    2 +-
 fs/nfs/write.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index b2e9aad..47f92c1 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -303,7 +303,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head
 	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
 	struct page *page = req->wb_page;
 	struct nfs_read_data *data;
-	size_t rsize = NFS_SERVER(desc->pg_inode)->rsize, nbytes;
+	size_t rsize = desc->pg_bsize, nbytes;
 	unsigned int offset;
 	int requests = 0;
 	int ret = 0;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 8fa7def..80bd74f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -946,7 +946,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc, struct list_head
 	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
 	struct page *page = req->wb_page;
 	struct nfs_write_data *data;
-	size_t wsize = NFS_SERVER(desc->pg_inode)->wsize, nbytes;
+	size_t wsize = desc->pg_bsize, nbytes;
 	unsigned int offset;
 	int requests = 0;
 	int ret = 0;
-- 
1.7.6

