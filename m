Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595Ab1JSUuk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:50:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] NFS: Get rid of unnecessary calls to ClearPageError() in read code
Date: Wed, 19 Oct 2011 13:50:16 -0700
Message-Id: <1319057418-9851-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1319057418-9851-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-2-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-3-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-4-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-5-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The generic file read code does that for us anyway.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/read.c  |    2 --
 fs/nfs/write.c |    1 -
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index e866a7e..09829d96 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -322,7 +322,6 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head
 		offset += len;
 	} while(nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
-	ClearPageError(page);
 	desc->pg_rpc_callops = &nfs_read_partial_ops;
 	return ret;
 out_bad:
@@ -357,7 +356,6 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &data->pages);
-		ClearPageError(req->wb_page);
 		*pages++ = req->wb_page;
 	}
 	req = nfs_list_entry(data->pages.next);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ad90b0c9..2219c88 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1011,7 +1011,6 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc, struct list_head *r
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &data->pages);
-		ClearPageError(req->wb_page);
 		*pages++ = req->wb_page;
 	}
 	req = nfs_list_entry(data->pages.next);
-- 
1.7.6.4

