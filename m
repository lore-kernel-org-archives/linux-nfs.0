Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33044 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757287Ab2EARQh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 13:16:37 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH v2 1/3] NFS: Read cleanups
Date: Tue,  1 May 2012 13:16:34 -0400
Message-Id: <1335892596-13667-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove unused variables, and reformat some code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/read.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 35e2dce..20a0293 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -341,8 +341,6 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
 	struct nfs_read_data *data;
 	size_t rsize = desc->pg_bsize, nbytes;
 	unsigned int offset;
-	int requests = 0;
-	int ret = 0;
 
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &hdr->pages);
@@ -358,12 +356,11 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
 		data->pages.pagevec[0] = page;
 		nfs_read_rpcsetup(data, len, offset);
 		list_add(&data->list, &hdr->rpc_list);
-		requests++;
 		nbytes -= len;
 		offset += len;
-	} while(nbytes != 0);
+	} while (nbytes != 0);
 	desc->pg_rpc_callops = &nfs_read_common_ops;
-	return ret;
+	return 0;
 out_bad:
 	while (!list_empty(&hdr->rpc_list)) {
 		data = list_first_entry(&hdr->rpc_list, struct nfs_read_data, list);
@@ -387,8 +384,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 							  desc->pg_count));
 	if (!data) {
 		desc->pg_completion_ops->error_cleanup(head);
-		ret = -ENOMEM;
-		goto out;
+		return -ENOMEM;
 	}
 
 	pages = data->pages.pagevec;
@@ -402,8 +398,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 	nfs_read_rpcsetup(data, desc->pg_count, 0);
 	list_add(&data->list, &hdr->rpc_list);
 	desc->pg_rpc_callops = &nfs_read_common_ops;
-out:
-	return ret;
+	return 0;
 }
 
 int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
-- 
1.7.7.6

