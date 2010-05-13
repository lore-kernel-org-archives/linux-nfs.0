Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306Ab0EMVIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:25 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCO021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:25 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/15] NFS: Read requests can use GFP_KERNEL.
Date: Thu, 13 May 2010 17:08:11 -0400
Message-Id: <1273784901-25599-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

There is no danger of deadlock should the allocation trigger page
writeback.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/read.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index db9b360..6e2b06e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -40,7 +40,7 @@ static mempool_t *nfs_rdata_mempool;
 
 struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 {
-	struct nfs_read_data *p = mempool_alloc(nfs_rdata_mempool, GFP_NOFS);
+	struct nfs_read_data *p = mempool_alloc(nfs_rdata_mempool, GFP_KERNEL);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -50,7 +50,7 @@ struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 		if (pagecount <= ARRAY_SIZE(p->page_array))
 			p->pagevec = p->page_array;
 		else {
-			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
+			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_KERNEL);
 			if (!p->pagevec) {
 				mempool_free(p, nfs_rdata_mempool);
 				p = NULL;
-- 
1.6.6.1

