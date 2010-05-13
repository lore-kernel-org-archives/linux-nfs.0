Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25852 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266Ab0EMVIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:25 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCN021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:24 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/15] NFS: Clean up nfs_create_request()
Date: Thu, 13 May 2010 17:08:10 -0400
Message-Id: <1273784901-25599-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
 <1273784901-25599-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

There is no point in looping if we're out of memory.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pagelist.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 29d9d36..a3654e5 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -60,16 +60,10 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 {
 	struct nfs_page		*req;
 
-	for (;;) {
-		/* try to allocate the request struct */
-		req = nfs_page_alloc();
-		if (req != NULL)
-			break;
-
-		if (fatal_signal_pending(current))
-			return ERR_PTR(-ERESTARTSYS);
-		yield();
-	}
+	/* try to allocate the request struct */
+	req = nfs_page_alloc();
+	if (req == NULL)
+		return ERR_PTR(-ENOMEM);
 
 	/* Initialize the request struct. Initially, we assume a
 	 * long write-back delay. This will be adjusted in
-- 
1.6.6.1

