Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756241Ab2AUAEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 19:04:11 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Use kcalloc() when allocating arrays
Date: Fri, 20 Jan 2012 19:03:48 -0500
Message-Id: <1327104228-14764-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1327104228-14764-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1327104228-14764-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/blocklayout/extents.c |    2 +-
 fs/nfs/pnfs.c                |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 1abac09..1f9a603 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -147,7 +147,7 @@ static int _preload_range(struct pnfs_inval_markings *marks,
 	count = (int)(end - start) / (int)tree->mtt_step_size;
 
 	/* Pre-malloc what memory we might need */
-	storage = kmalloc(sizeof(*storage) * count, GFP_NOFS);
+	storage = kcalloc(count, sizeof(*storage), GFP_NOFS);
 	if (!storage)
 		return -ENOMEM;
 	for (i = 0; i < count; i++) {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 17149a4..9292787 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -590,7 +590,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
 	max_pages = max_resp_sz >> PAGE_SHIFT;
 
-	pages = kzalloc(max_pages * sizeof(struct page *), gfp_flags);
+	pages = kcalloc(max_pages, sizeof(struct page *), gfp_flags);
 	if (!pages)
 		goto out_err_free;
 
-- 
1.7.7.5

