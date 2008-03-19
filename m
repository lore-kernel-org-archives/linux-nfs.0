From: Fred Isaman <iisaman@citi.umich.edu>
Subject: [PATCH 1/1] nfs: remove duplicate initializations of nfs_read_data field
Date: Wed, 19 Mar 2008 11:54:04 -0400
Message-ID: <1205942044-10576-1-git-send-email-iisaman@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:40336 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127AbYCSTYw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 15:24:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
---
 fs/nfs/read.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 77f8ac9..03d079b 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -253,7 +253,6 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 		data = nfs_readdata_alloc(1);
 		if (!data)
 			goto out_bad;
-		INIT_LIST_HEAD(&data->pages);
 		list_add(&data->pages, &list);
 		requests++;
 		nbytes -= len;
@@ -300,7 +299,6 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 	if (!data)
 		goto out_bad;
 
-	INIT_LIST_HEAD(&data->pages);
 	pages = data->pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
-- 
1.5.3.3

